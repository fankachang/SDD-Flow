#!/usr/bin/env python3
"""只用 Python 標準函式庫檢查單一 Hand-off Markdown 文件。

此 repository 工具不需要虛擬環境或安裝套件。
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence


REQUIRED_SECTIONS = (1, 4, 5, 8, 10, 11, 12, 14)
ALLOWED_STATUSES = {
    "not-started",
    "in-progress",
    "blocked",
    "partially-completed",
    "completed-unverified",
    "completed",
    "cancelled",
}
VALIDATION_RESULTS = {
    "通過": "passed",
    "失敗": "failed",
    "未執行": "not-run",
    "不適用": "not-applicable",
    "passed": "passed",
    "failed": "failed",
    "not-run": "not-run",
    "not-applicable": "not-applicable",
}
SECTION_HEADING = re.compile(r"^##\s+(\d+)\.\s+.+?\s*$")
STATUS_FIELD = re.compile(
    r"^\s*-\s+\*\*(?:目前狀態|Current status)\*\*\s*[：:]\s*(.*?)\s*$",
    re.IGNORECASE,
)
COMPLETED_ITEM = re.compile(r"^\s*-\s*\[[xX]\]\s+")
PENDING_ITEM = re.compile(r"^\s*-\s*\[\s\]\s+")
FENCE = re.compile(r"^\s*(`{3,}|~{3,})")
NO_BLOCKER_VALUES = {"無", "none", "n/a", "不適用", "not applicable"}


@dataclass(frozen=True)
class Issue:
    """單一格式或狀態一致性問題。"""

    code: str
    message: str
    line: int | None = None


@dataclass(frozen=True)
class ValidationResult:
    """驗證表中已正規化的結果。"""

    value: str
    line: int


def _visible_lines(lines: list[str]) -> list[bool]:
    """標記不在 fenced code block 內的行。"""
    visible: list[bool] = []
    fence_marker: str | None = None

    for line in lines:
        match = FENCE.match(line)
        if match:
            marker = match.group(1)
            if fence_marker is None:
                fence_marker = marker[0]
            elif marker[0] == fence_marker:
                fence_marker = None
            visible.append(False)
            continue
        visible.append(fence_marker is None)

    return visible


def _section_ranges(
    lines: list[str],
    visible: list[bool],
) -> tuple[dict[int, tuple[int, int]], list[Issue]]:
    """解析編號章節並回報重複或順序錯誤。"""
    headings: list[tuple[int, int]] = []
    issues: list[Issue] = []

    for index, line in enumerate(lines):
        if not visible[index]:
            continue
        match = SECTION_HEADING.match(line)
        if match:
            headings.append((int(match.group(1)), index))

    numbers = [number for number, _ in headings]
    first_bad_line: int | None = None
    seen: set[int] = set()
    previous = -1
    for number, index in headings:
        if number in seen or number < previous:
            first_bad_line = index + 1
            break
        seen.add(number)
        previous = number

    if first_bad_line is not None:
        issues.append(
            Issue(
                "HOF003",
                "編號章節重複或未依數字遞增排列。",
                first_bad_line,
            )
        )

    ranges: dict[int, tuple[int, int]] = {}
    for position, (number, index) in enumerate(headings):
        end = headings[position + 1][1] if position + 1 < len(headings) else len(lines)
        ranges.setdefault(number, (index + 1, end))

    for required in REQUIRED_SECTIONS:
        if required not in ranges:
            issues.append(
                Issue(
                    "HOF002",
                    f"缺少必要章節 {required}。",
                )
            )

    return ranges, issues


def _section_content(
    lines: list[str],
    visible: list[bool],
    ranges: dict[int, tuple[int, int]],
    number: int,
) -> list[tuple[int, str]]:
    """取得章節內不含 fenced code block 的可見行。"""
    if number not in ranges:
        return []
    start, end = ranges[number]
    return [
        (index + 1, lines[index])
        for index in range(start, end)
        if visible[index]
    ]


def _plain_cell(value: str) -> str:
    """移除表格儲存格外層的簡單 Markdown 標記。"""
    return value.strip().strip("`*_ ").strip()


def _parse_status(section: list[tuple[int, str]]) -> tuple[str | None, list[Issue]]:
    """解析且驗證任務狀態欄位。"""
    matches: list[tuple[int, str]] = []
    for line_number, line in section:
        match = STATUS_FIELD.match(line)
        if match:
            matches.append((line_number, _plain_cell(match.group(1))))

    if len(matches) != 1:
        return None, [
            Issue(
                "HOF004",
                "第 1 節必須且只能包含一個「目前狀態」欄位。",
                matches[0][0] if matches else None,
            )
        ]

    line_number, status = matches[0]
    if status not in ALLOWED_STATUSES:
        return None, [
            Issue(
                "HOF005",
                f"不支援的任務狀態：{status or '空值'}。",
                line_number,
            )
        ]

    return status, []


def _parse_validation_table(
    section: list[tuple[int, str]],
) -> tuple[list[ValidationResult], list[Issue]]:
    """解析第 8 節驗證表並正規化結果值。"""
    results: list[ValidationResult] = []
    issues: list[Issue] = []
    data_rows = 0

    for line_number, line in section:
        stripped = line.strip()
        if not stripped.startswith("|"):
            continue

        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        if cells and _plain_cell(cells[0]).casefold() in {"驗證項目", "validation item"}:
            continue
        if cells and all(re.fullmatch(r":?-{3,}:?", cell) for cell in cells):
            continue

        data_rows += 1
        if len(cells) != 4:
            issues.append(
                Issue(
                    "HOF006",
                    "驗證表資料列必須包含四個欄位。",
                    line_number,
                )
            )
            continue

        raw_result = _plain_cell(cells[2])
        normalized = VALIDATION_RESULTS.get(raw_result.casefold())
        if normalized is None:
            normalized = VALIDATION_RESULTS.get(raw_result)
        if normalized is None:
            issues.append(
                Issue(
                    "HOF007",
                    f"不支援的驗證結果：{raw_result or '空值'}。",
                    line_number,
                )
            )
            continue
        results.append(ValidationResult(normalized, line_number))

    if data_rows == 0:
        issues.append(
            Issue(
                "HOF006",
                "第 8 節必須包含至少一筆驗證資料列。",
            )
        )

    return results, issues


def _first_matching_line(
    section: list[tuple[int, str]],
    pattern: re.Pattern[str],
) -> int | None:
    """回傳章節內第一個符合項目的行號。"""
    return next(
        (line_number for line_number, line in section if pattern.match(line)),
        None,
    )


def _has_blocker(section: list[tuple[int, str]]) -> bool:
    """判斷第 10 節是否記錄實際阻塞或待決策事項。"""
    meaningful: list[str] = []
    for _, line in section:
        value = re.sub(r"^\s*-\s*(?:\[[ xX]\]\s*)?", "", line).strip()
        value = _plain_cell(value).casefold()
        if value:
            meaningful.append(value)
    return bool(meaningful) and any(value not in NO_BLOCKER_VALUES for value in meaningful)


def _status_issues(
    status: str | None,
    completed_section: list[tuple[int, str]],
    pending_section: list[tuple[int, str]],
    blocker_section: list[tuple[int, str]],
    validation_results: list[ValidationResult],
) -> list[Issue]:
    """依 canonical 狀態定義檢查可機械判斷的矛盾。"""
    if status is None:
        return []

    issues: list[Issue] = []
    validation_values = {result.value for result in validation_results}

    if status == "completed":
        pending_line = _first_matching_line(pending_section, PENDING_ITEM)
        if pending_line is not None:
            issues.append(
                Issue(
                    "HOF101",
                    "狀態為 completed，但第 5 節仍有未完成項目。",
                    pending_line,
                )
            )
        unfinished = next(
            (
                result
                for result in validation_results
                if result.value in {"failed", "not-run"}
            ),
            None,
        )
        if unfinished is not None:
            issues.append(
                Issue(
                    "HOF102",
                    "狀態為 completed，但仍有失敗或未執行的驗證。",
                    unfinished.line,
                )
            )
        if _has_blocker(blocker_section):
            issues.append(
                Issue(
                    "HOF107",
                    "狀態為 completed，但第 10 節仍有阻塞或待決策事項。",
                )
            )

    if status == "completed-unverified" and validation_results:
        failed = next(
            (result for result in validation_results if result.value == "failed"),
            None,
        )
        if failed is not None:
            issues.append(
                Issue(
                    "HOF104",
                    "狀態為 completed-unverified，但驗證已明確失敗。",
                    failed.line,
                )
            )
        elif "not-run" not in validation_values:
            issues.append(
                Issue(
                    "HOF103",
                    "狀態為 completed-unverified，但沒有未執行的驗證。",
                )
            )

    if status == "blocked" and not _has_blocker(blocker_section):
        issues.append(
            Issue(
                "HOF105",
                "狀態為 blocked，但第 10 節沒有實際阻塞或待決策事項。",
            )
        )

    if status == "not-started":
        completed_line = _first_matching_line(completed_section, COMPLETED_ITEM)
        if completed_line is not None:
            issues.append(
                Issue(
                    "HOF106",
                    "狀態為 not-started，但第 4 節已有完成項目。",
                    completed_line,
                )
            )

    return issues


def validate_document(document: str) -> list[Issue]:
    """檢查單一 Hand-off 文件的格式與狀態一致性。"""
    lines = document.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    visible = _visible_lines(lines)
    issues: list[Issue] = []

    title_lines = [
        index + 1
        for index, line in enumerate(lines)
        if visible[index] and line.strip().lstrip("\ufeff") == "# Agent Hand-off"
    ]
    if len(title_lines) != 1:
        issues.append(
            Issue(
                "HOF001",
                "文件必須且只能包含一個「# Agent Hand-off」標題。",
                title_lines[0] if title_lines else None,
            )
        )

    ranges, section_issues = _section_ranges(lines, visible)
    issues.extend(section_issues)

    status, status_issues = _parse_status(
        _section_content(lines, visible, ranges, 1)
    )
    issues.extend(status_issues)

    validation_results, validation_issues = _parse_validation_table(
        _section_content(lines, visible, ranges, 8)
    )
    issues.extend(validation_issues)

    issues.extend(
        _status_issues(
            status,
            _section_content(lines, visible, ranges, 4),
            _section_content(lines, visible, ranges, 5),
            _section_content(lines, visible, ranges, 10),
            validation_results,
        )
    )

    return sorted(
        issues,
        key=lambda issue: (issue.line is None, issue.line or 0, issue.code),
    )


def _build_parser() -> argparse.ArgumentParser:
    """建立 CLI 參數解析器。"""
    parser = argparse.ArgumentParser(
        description="檢查單一 Agent Hand-off Markdown 的格式與狀態矛盾。",
    )
    parser.add_argument("handoff", type=Path, help="要檢查的 Hand-off Markdown 路徑")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    """執行 CLI 並回傳穩定的 exit code。"""
    args = _build_parser().parse_args(argv)
    try:
        document = args.handoff.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        print(f"❌ 無法讀取 {args.handoff}：{error}", file=sys.stderr)
        return 2

    issues = validate_document(document)
    if not issues:
        print(f"✅ Hand-off 格式與狀態一致：{args.handoff}")
        return 0

    print(f"❌ Hand-off 發現 {len(issues)} 個問題：{args.handoff}")
    for issue in issues:
        location = f"line {issue.line}：" if issue.line is not None else ""
        print(f"- {issue.code} {location}{issue.message}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
