#!/usr/bin/env python3
"""Repository 一致性 / SSOT 自我檢測。

偵測治理文件（AGENTS.md、.agents/skills、.github/instructions 等）常見問題：
  1. 跨檔案重複內容（違反單一真相來源 SSOT 原則）
  2. SKILL.md / SKILL_zhTW.md 未成對
  3. prompt → agent 執行鏈重複載入同一治理文件
  4. 重複載入自動注入文件，或治理文件形成載入循環

純標準函式庫，跨平台（macOS / Linux / WSL / Windows）皆可用同一支 python 執行。

用法：
    python3 .agents/skills/consistency-check/scripts/consistency-check.py [--strict] [--json]

離開碼：
    0 = 無 BLOCK 級問題（--strict 時亦無警告）
    1 = 發現 BLOCK 級問題（或 --strict 下有警告）
"""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


def find_repo_root(start: Path) -> Path:
    """向上尋找含 AGENTS.md 的目錄作為 repo root。"""
    cur = start.resolve()
    for parent in [cur, *cur.parents]:
        if (parent / "AGENTS.md").exists():
            return parent
    # 後備：腳本位於 .agents/skills/consistency-check/scripts/
    return start.resolve().parents[4]


def load_ignore_patterns(root: Path) -> list[str]:
    """讀取 ignore.txt（每行一個子字串樣式，# 為註解），比對檔案相對路徑。"""
    ignore_file = (
        root / ".agents" / "skills" / "consistency-check" / "ignore.txt"
    )
    patterns: list[str] = []
    if ignore_file.exists():
        for line in ignore_file.read_text(encoding="utf-8").splitlines():
            s = line.strip()
            if s and not s.startswith("#"):
                patterns.append(s)
    return patterns


def collect_target_files(root: Path, ignore: list[str], scan_all: bool) -> list[Path]:
    """收集需要檢查的治理 / skill markdown 檔案。"""
    targets: list[Path] = []

    top = root / "AGENTS.md"
    if top.exists():
        targets.append(top)

    copilot = root / ".github" / "copilot-instructions.md"
    if copilot.exists():
        targets.append(copilot)

    inst_dir = root / ".github" / "instructions"
    if inst_dir.is_dir():
        targets.extend(sorted(inst_dir.glob("*.md")))

    skills_dir = root / ".agents" / "skills"
    if skills_dir.is_dir():
        for md in sorted(skills_dir.rglob("*.md")):
            posix = md.as_posix()
            # 略過第三方 vendor 內容
            if "/vendor/" in posix:
                continue
            # 預設略過 references/ 補充範例（常見共用程式碼，非治理重點）
            if not scan_all and "/references/" in posix:
                continue
            targets.append(md)

    # 套用 ignore 樣式（比對相對路徑子字串）
    def keep(p: Path) -> bool:
        rel = p.relative_to(root).as_posix()
        return not any(pat in rel for pat in ignore)

    targets = [p for p in targets if keep(p)]

    # 去重且保持順序
    seen: set[Path] = set()
    unique: list[Path] = []
    for p in targets:
        if p not in seen:
            seen.add(p)
            unique.append(p)
    return unique


def collect_load_instruction_files(root: Path, ignore: list[str]) -> list[Path]:
    """收集可能定義文件載入行為的 prompt、agent 與治理 Markdown。"""
    targets: list[Path] = []

    for rel in ("AGENTS.md", ".github/copilot-instructions.md"):
        path = root / rel
        if path.exists():
            targets.append(path)

    patterns = (
        ".github/agents/*.agent.md",
        ".github/prompts/*.prompt.md",
        ".github/instructions/*.md",
        "Docs/governance/**/*.md",
    )
    for pattern in patterns:
        targets.extend(sorted(root.glob(pattern)))

    unique: list[Path] = []
    seen: set[Path] = set()
    for path in targets:
        rel = path.relative_to(root).as_posix()
        if any(pattern in rel for pattern in ignore):
            continue
        if path not in seen:
            seen.add(path)
            unique.append(path)
    return unique


_WS_RE = re.compile(r"\s+")
_TABLE_SEP_RE = re.compile(r"^\|[\s:|+-]+\|?$")


def normalize(line: str) -> str:
    return _WS_RE.sub(" ", line.strip())


def is_significant(s: str) -> bool:
    """判斷是否為「有內容、值得比對」的行。過短或純結構行不計入。"""
    if len(s) < 40:
        return False
    if s.startswith("#"):        # 標題可合理重複
        return False
    if s.startswith("```"):      # 程式碼柵欄
        return False
    if _TABLE_SEP_RE.match(s):   # 表格分隔列
        return False
    return True


def build_index(files: list[Path], root: Path):
    """建立 normalized_line -> [(relpath, lineno), ...] 索引，以及每檔的顯著行序列。"""
    index: dict[str, list[tuple[str, int]]] = defaultdict(list)
    per_file: dict[str, list[tuple[int, str]]] = {}

    for f in files:
        rel = f.relative_to(root).as_posix()
        sig_lines: list[tuple[int, str]] = []
        try:
            text = f.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for i, raw in enumerate(text.splitlines(), start=1):
            norm = normalize(raw)
            if is_significant(norm):
                index[norm].append((rel, i))
                sig_lines.append((i, norm))
        per_file[rel] = sig_lines
    return index, per_file


def group_of(rel: str) -> str:
    """把檔案歸類到 SSOT 群組。同群內的重複（如中英翻譯對、同 skill 的 references）
    屬預期共用，不視為違反 SSOT；只有跨群重複才需回報。"""
    if rel == "AGENTS.md":
        return "AGENTS"
    if rel.startswith(".github/"):
        return "github-instructions"
    if rel.startswith(".agents/skills/"):
        parts = rel.split("/")
        if len(parts) >= 3:
            return f"skill:{parts[2]}"
    return rel


@dataclass(frozen=True)
class LoadDirective:
    source: str
    line: int
    target: str


@dataclass(frozen=True)
class LoadIssue:
    kind: str
    severity: str
    target: str
    locations: tuple[str, ...]
    message: str


_READ_VERB_RE = re.compile(
    r"(?:讀取|閱讀|載入|依據|依[據照參]?|參照|遵照|依照|\b(?:read|load|refer to|according to)\b)",
    re.IGNORECASE,
)
_LOAD_MODAL_RE = re.compile(
    r"(?:必須|務必|執行前|接收.{0,20}前|\b(?:must|required)\b)", re.IGNORECASE
)
_NEGATED_LOAD_RE = re.compile(
    r"(?:禁止|不得|不要|不應|無需|避免|\b(?:never|do not|must not|avoid)\b)",
    re.IGNORECASE,
)
_LIST_ITEM_RE = re.compile(r"^\s*(?:[-*+]\s+|\d+[.)]\s+)")
_MD_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
_CODE_SPAN_RE = re.compile(r"`([^`]+)`")
_FRONTMATTER_AGENT_RE = re.compile(
    r"^agent:\s*[\"']?([A-Za-z0-9_.-]+)[\"']?\s*$", re.MULTILINE
)
_LOCAL_FILE_SUFFIXES = (".md", ".yaml", ".yml", ".json")
_AUTO_LOADED_TARGETS = {"AGENTS.md"}


def _resolve_load_target(
    raw: str,
    source: Path,
    root: Path,
    *,
    link_relative: bool,
) -> str | None:
    """把 Markdown 連結或 code span 解析成 repo-relative 現存檔案。"""
    value = raw.strip().strip("<>").split("#", 1)[0].strip()
    if not value or re.match(r"^[a-z][a-z0-9+.-]*://", value, re.IGNORECASE):
        return None
    if not value.lower().endswith(_LOCAL_FILE_SUFFIXES):
        return None

    if value == "AGENTS.md":
        candidate = root / value
    elif Path(value).is_absolute():
        candidate = Path(value)
    elif link_relative or value.startswith(("./", "../")):
        candidate = source.parent / value
    else:
        candidate = root / value

    candidate = candidate.resolve()
    try:
        rel = candidate.relative_to(root.resolve()).as_posix()
    except ValueError:
        return None
    return rel if candidate.is_file() else None


def _extract_targets(raw: str, source: Path, root: Path) -> list[str]:
    """擷取單行中的本地文件目標；一般文字提及不算載入。"""
    targets: list[str] = []
    seen: set[str] = set()

    candidates: list[tuple[str, bool]] = []
    candidates.extend((match, True) for match in _MD_LINK_RE.findall(raw))
    candidates.extend((match, False) for match in _CODE_SPAN_RE.findall(raw))
    if "AGENTS.md" in raw:
        candidates.append(("AGENTS.md", False))

    for value, link_relative in candidates:
        target = _resolve_load_target(
            value, source, root, link_relative=link_relative
        )
        if target and target not in seen:
            seen.add(target)
            targets.append(target)
    return targets


def _is_explicit_load_instruction(raw: str) -> bool:
    """排除禁止句、表格描述與一般名詞，只保留可執行的載入與參照指令。"""
    if not _READ_VERB_RE.search(raw) or _NEGATED_LOAD_RE.search(raw):
        return False
    if _LOAD_MODAL_RE.search(raw) or _LIST_ITEM_RE.match(raw):
        return True
    stripped = re.sub(r"^[\s>*_#`-]+", "", raw)
    return bool(
        re.match(
            r"(?:(?:使用|use)\s+`?read`?.{0,20})?"
            r"(?:讀取|閱讀|載入|依據|依[據照參]?|參照|遵照|依照|read\b|load\b|refer\b|according\b)",
            stripped,
            re.IGNORECASE,
        )
    )


_WRITE_VERB_RE = re.compile(
    r"(?:寫入|寫回|覆蓋|產出|\b(?:write|save|create|overwrite|output)\b)", re.IGNORECASE
)


def extract_load_directives(files: list[Path], root: Path) -> list[LoadDirective]:
    """擷取明確的 read/load 指令，以及其後緊接的 Markdown 清單。"""
    directives: list[LoadDirective] = []

    for path in files:
        rel = path.relative_to(root).as_posix()
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except (UnicodeDecodeError, OSError):
            continue

        pending_list = False
        for lineno, raw in enumerate(lines, start=1):
            stripped = raw.strip()

            if pending_list:
                if not stripped:
                    continue
                if _LIST_ITEM_RE.match(raw):
                    if not _WRITE_VERB_RE.search(raw):
                        for target in _extract_targets(raw, path, root):
                            directives.append(LoadDirective(rel, lineno, target))
                    continue
                pending_list = False

            if not _is_explicit_load_instruction(raw):
                continue

            targets = _extract_targets(raw, path, root)
            directives.extend(LoadDirective(rel, lineno, target) for target in targets)

            if not targets and stripped.endswith((":", "：")):
                pending_list = True

    return directives


def extract_prompt_agents(files: list[Path], root: Path) -> dict[str, str]:
    """解析 prompt frontmatter 的 agent 欄位，建立 prompt → agent 執行鏈。"""
    routes: dict[str, str] = {}
    for path in files:
        rel = path.relative_to(root).as_posix()
        if not rel.startswith(".github/prompts/") or not rel.endswith(".prompt.md"):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        if not text.startswith("---"):
            continue
        parts = re.split(r"^---\s*$", text, maxsplit=2, flags=re.MULTILINE)
        if len(parts) < 3:
            continue
        match = _FRONTMATTER_AGENT_RE.search(parts[1])
        if not match:
            continue
        agent = root / ".github" / "agents" / f"{match.group(1)}.agent.md"
        if agent.is_file():
            routes[rel] = agent.relative_to(root).as_posix()
    return routes


def detect_cross_file_blocks(index, per_file):
    """找出「連續多行且在其他『群組』檔案出現」的重複區塊（高嚴重度）。
    同群組內（中英翻譯、同 skill references）的共用內容不計入。"""
    # 哪些 normalized 行是跨群組重複的
    dup_norms: dict[str, list[tuple[str, int]]] = {}
    for norm, locs in index.items():
        if len({group_of(rel) for rel, _ in locs}) >= 2:
            dup_norms[norm] = locs

    blocks = []          # (rel, start, end, [other_files])
    single_lines = []    # (norm, [(rel, lineno)...])

    for rel, sig_lines in per_file.items():
        my_group = group_of(rel)
        run: list[tuple[int, str]] = []

        def flush(run_):
            if len(run_) < 2:
                return
            # 交集：run 內每行都出現的「其他群組」檔案
            other_sets = []
            for _, norm in run_:
                others = {
                    r for r, _ in dup_norms.get(norm, [])
                    if group_of(r) != my_group
                }
                other_sets.append(others)
            common = set.intersection(*other_sets) if other_sets else set()
            if common:
                blocks.append((rel, run_[0][0], run_[-1][0], sorted(common)))

        for lineno, norm in sig_lines:
            if norm in dup_norms:
                run.append((lineno, norm))
            else:
                flush(run)
                run = []
        flush(run)

    # 單行重複（低嚴重度警告），排除已被 block 覆蓋的
    covered = defaultdict(set)
    for rel, start, end, _ in blocks:
        for ln in range(start, end + 1):
            covered[rel].add(ln)

    for norm, locs in dup_norms.items():
        remaining = [(rel, ln) for rel, ln in locs if ln not in covered[rel]]
        if len({group_of(rel) for rel, _ in remaining}) >= 2:
            single_lines.append((norm, sorted(remaining)))

    return blocks, single_lines


def detect_skill_pairing(root: Path):
    """SKILL.md 必須有 SKILL_zhTW.md 成對，反之亦然。"""
    issues = []
    skills_dir = root / ".agents" / "skills"
    if not skills_dir.is_dir():
        return issues
    for skill_md in sorted(skills_dir.rglob("SKILL.md")):
        if "/vendor/" in skill_md.as_posix():
            continue
        zh = skill_md.with_name("SKILL_zhTW.md")
        if not zh.exists():
            issues.append(
                (skill_md.relative_to(root).as_posix(), "缺少對應的 SKILL_zhTW.md")
            )
    for zh_md in sorted(skills_dir.rglob("SKILL_zhTW.md")):
        if "/vendor/" in zh_md.as_posix():
            continue
        en = zh_md.with_name("SKILL.md")
        if not en.exists():
            issues.append(
                (zh_md.relative_to(root).as_posix(), "缺少對應的 SKILL.md")
            )
    return issues


def _is_governance_target(target: str) -> bool:
    return (
        target in _AUTO_LOADED_TARGETS
        or target.startswith("Docs/governance/")
        or target.startswith(".github/instructions/")
    )


def detect_redundant_loads(
    directives: list[LoadDirective], prompt_agents: dict[str, str]
) -> list[LoadIssue]:
    """偵測自動載入、同檔重複、prompt → agent 重複與跨來源共享載入。"""
    issues: list[LoadIssue] = []
    by_source_target: dict[tuple[str, str], list[LoadDirective]] = defaultdict(list)
    by_target: dict[str, list[LoadDirective]] = defaultdict(list)
    for directive in directives:
        by_source_target[(directive.source, directive.target)].append(directive)
        by_target[directive.target].append(directive)

    for directive in directives:
        if directive.target in _AUTO_LOADED_TARGETS:
            issues.append(
                LoadIssue(
                    "auto-loaded",
                    "block",
                    directive.target,
                    (f"{directive.source}:{directive.line}",),
                    "自動注入文件不得再要求顯式讀取",
                )
            )

    for (source, target), matches in by_source_target.items():
        if len(matches) < 2:
            continue
        issues.append(
            LoadIssue(
                "same-source",
                "block",
                target,
                tuple(f"{item.source}:{item.line}" for item in matches),
                "同一文件內重複要求載入相同目標",
            )
        )

    related_pairs: set[frozenset[str]] = set()
    for prompt, agent in prompt_agents.items():
        related_pairs.add(frozenset((prompt, agent)))
        prompt_targets = {
            target for source, target in by_source_target if source == prompt
        }
        agent_targets = {
            target for source, target in by_source_target if source == agent
        }
        for target in sorted(prompt_targets & agent_targets):
            matches = by_source_target[(prompt, target)] + by_source_target[(agent, target)]
            issues.append(
                LoadIssue(
                    "prompt-agent",
                    "block",
                    target,
                    tuple(f"{item.source}:{item.line}" for item in matches),
                    "prompt 與其指定 agent 重複要求載入相同文件",
                )
            )

    for target, matches in by_target.items():
        if not _is_governance_target(target):
            continue
        sources = sorted({item.source for item in matches})
        if len(sources) < 2:
            continue
        unrelated = [
            (left, right)
            for index, left in enumerate(sources)
            for right in sources[index + 1 :]
            if frozenset((left, right)) not in related_pairs
        ]
        if not unrelated:
            continue
        issues.append(
            LoadIssue(
                "shared-governance",
                "warn",
                target,
                tuple(f"{item.source}:{item.line}" for item in matches),
                "無直接執行鏈關係的文件載入相同治理目標，請確認是否必要",
            )
        )

    # 同類問題可能同時被清單與行內語法擷取；以完整內容去重。
    unique: list[LoadIssue] = []
    seen: set[LoadIssue] = set()
    for issue in issues:
        if issue not in seen:
            seen.add(issue)
            unique.append(issue)
    return unique


def detect_load_cycles(
    directives: list[LoadDirective], source_files: set[str]
) -> list[tuple[str, ...]]:
    """偵測治理文件明確載入指令形成的有向循環。"""
    graph: dict[str, set[str]] = defaultdict(set)
    for directive in directives:
        if directive.target in source_files:
            graph[directive.source].add(directive.target)

    state: dict[str, int] = {}
    stack: list[str] = []
    cycles: set[tuple[str, ...]] = set()

    def canonicalize(nodes: list[str]) -> tuple[str, ...]:
        body = nodes[:-1]
        rotations = [tuple(body[index:] + body[:index]) for index in range(len(body))]
        best = min(rotations)
        return (*best, best[0])

    def visit(node: str) -> None:
        state[node] = 1
        stack.append(node)
        for target in sorted(graph.get(node, ())):
            if state.get(target, 0) == 0:
                visit(target)
            elif state.get(target) == 1:
                index = stack.index(target)
                cycles.add(canonicalize(stack[index:] + [target]))
        stack.pop()
        state[node] = 2

    for node in sorted(source_files):
        if state.get(node, 0) == 0:
            visit(node)
    return sorted(cycles)


def main() -> int:
    strict = "--strict" in sys.argv
    as_json = "--json" in sys.argv
    scan_all = "--all" in sys.argv

    root = find_repo_root(Path(__file__))
    ignore = load_ignore_patterns(root)
    files = collect_target_files(root, ignore, scan_all)
    index, per_file = build_index(files, root)
    blocks, single_lines = detect_cross_file_blocks(index, per_file)
    pairing = detect_skill_pairing(root)
    load_files = collect_load_instruction_files(root, ignore)
    load_directives = extract_load_directives(load_files, root)
    prompt_agents = extract_prompt_agents(load_files, root)
    redundant_loads = detect_redundant_loads(load_directives, prompt_agents)
    load_cycles = detect_load_cycles(
        load_directives,
        {path.relative_to(root).as_posix() for path in load_files},
    )

    if as_json:
        print(json.dumps(
            {
                "scanned_files": len(files),
                "load_instruction_files": len(load_files),
                "duplicate_blocks": [
                    {"file": r, "start": s, "end": e, "also_in": o}
                    for r, s, e, o in blocks
                ],
                "duplicate_lines": [
                    {"text": n, "locations": [f"{r}:{ln}" for r, ln in locs]}
                    for n, locs in single_lines
                ],
                "pairing_issues": [
                    {"file": f, "problem": p} for f, p in pairing
                ],
                "redundant_loads": [
                    {
                        "kind": issue.kind,
                        "severity": issue.severity,
                        "target": issue.target,
                        "locations": list(issue.locations),
                        "message": issue.message,
                    }
                    for issue in redundant_loads
                ],
                "load_cycles": [list(cycle) for cycle in load_cycles],
            },
            ensure_ascii=False,
            indent=2,
        ))
    else:
        print("=== Repository 一致性檢測 ===")
        print(f"內容重複掃描檔案數：{len(files)}")
        print(f"載入指令掃描檔案數：{len(load_files)}\n")

        if pairing:
            print(f"❌ SKILL 成對問題（{len(pairing)}）")
            for f, p in pairing:
                print(f"   - {f}：{p}")
            print()

        if blocks:
            print(f"❌ 跨檔案重複區塊（{len(blocks)}）— 違反 SSOT，請保留單一來源、其餘改為引用")
            for rel, start, end, others in blocks:
                span = f"{rel}:{start}" if start == end else f"{rel}:{start}-{end}"
                print(f"   - {span} 與下列檔案重複：{', '.join(others)}")
            print()

        if single_lines:
            print(f"⚠️  跨檔案重複單行（{len(single_lines)}）— 建議檢視是否應收斂")
            for norm, locs in single_lines[:20]:
                where = ", ".join(f"{r}:{ln}" for r, ln in locs)
                preview = norm[:60] + ("…" if len(norm) > 60 else "")
                print(f"   - 「{preview}」→ {where}")
            if len(single_lines) > 20:
                print(f"   （其餘 {len(single_lines) - 20} 筆略）")
            print()

        blocking_loads = [
            issue for issue in redundant_loads if issue.severity == "block"
        ]
        warning_loads = [
            issue for issue in redundant_loads if issue.severity == "warn"
        ]

        if blocking_loads:
            print(f"❌ 重複載入指令（{len(blocking_loads)}）")
            for issue in blocking_loads:
                where = ", ".join(issue.locations)
                print(
                    f"   - [{issue.kind}] {issue.target}：{issue.message} → {where}"
                )
            print()

        if warning_loads:
            print(f"⚠️  共享治理文件載入（{len(warning_loads)}）— 請確認是否必要")
            for issue in warning_loads:
                where = ", ".join(issue.locations)
                print(f"   - {issue.target}：{issue.message} → {where}")
            print()

        if load_cycles:
            print(f"❌ 治理文件載入循環（{len(load_cycles)}）")
            for cycle in load_cycles:
                print(f"   - {' → '.join(cycle)}")
            print()

        if not (pairing or blocks or single_lines or redundant_loads or load_cycles):
            print("✅ 未發現重複、成對或載入關係問題。")

        print("修正原則：見 AGENTS.md「內容分層規則（防重複 / 防遞迴）」的 SSOT 準則。")

    has_error = bool(
        blocks
        or pairing
        or load_cycles
        or any(issue.severity == "block" for issue in redundant_loads)
    )
    if strict and (
        single_lines
        or any(issue.severity == "warn" for issue in redundant_loads)
    ):
        has_error = True
    return 1 if has_error else 0


if __name__ == "__main__":
    sys.exit(main())
