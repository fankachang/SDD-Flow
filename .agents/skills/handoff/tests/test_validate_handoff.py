from __future__ import annotations

import importlib.util
import re
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "validate_handoff.py"
EXAMPLES = Path(__file__).resolve().parents[4] / "Docs" / "examples" / "agent-handoff-examples.md"
SPEC = importlib.util.spec_from_file_location("validate_handoff", SCRIPT)
assert SPEC and SPEC.loader
validate_handoff = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = validate_handoff
SPEC.loader.exec_module(validate_handoff)


def handoff_document(
    *,
    status: str = "completed",
    completed_work: str = "- [x] 完成指定工作",
    pending_work: str = "不適用",
    validation_rows: str = "| Build | `./scripts/build` | 通過 | exit code 0 |",
    blockers: str = "無",
) -> str:
    return textwrap.dedent(
        f"""
        # Agent Hand-off

        ## 1. 任務概述

        - **目前狀態**：`{status}`

        ## 4. 已完成工作

        {completed_work}

        ## 5. 尚未完成工作

        {pending_work}

        ## 8. 驗證狀態

        | 驗證項目 | 命令／方法 | 結果 | 實際證據／備註 |
        |---|---|---|---|
        {validation_rows}

        ## 10. 阻塞與待使用者決策

        {blockers}

        ## 11. 下一步

        1. 交付成果。

        ## 12. 續接工作所需最小 Context

        1. `spec.md`

        ## 14. 交接中繼資料

        - **產生／更新時間**：`2026-07-17T12:00:00+08:00`
        """
    ).strip()


def issue_codes(document: str) -> set[str]:
    return {issue.code for issue in validate_handoff.validate_document(document)}


class ValidateDocumentTests(unittest.TestCase):
    def test_valid_completed_document_passes(self) -> None:
        self.assertEqual([], validate_handoff.validate_document(handoff_document()))

    def test_missing_title_is_reported(self) -> None:
        document = handoff_document().replace("# Agent Hand-off\n\n", "", 1)

        self.assertIn("HOF001", issue_codes(document))

    def test_missing_required_section_is_reported(self) -> None:
        document = handoff_document().replace(
            "## 12. 續接工作所需最小 Context\n\n1. `spec.md`\n\n",
            "",
        )

        self.assertIn("HOF002", issue_codes(document))

    def test_duplicate_or_out_of_order_sections_are_reported(self) -> None:
        document = handoff_document().replace(
            "## 11. 下一步",
            "## 10. 重複章節\n\n無\n\n## 11. 下一步",
        )

        self.assertIn("HOF003", issue_codes(document))

    def test_missing_status_is_reported(self) -> None:
        document = handoff_document().replace(
            "- **目前狀態**：`completed`\n",
            "",
        )

        self.assertIn("HOF004", issue_codes(document))

    def test_invalid_status_is_reported(self) -> None:
        self.assertIn(
            "HOF005",
            issue_codes(handoff_document(status="done")),
        )

    def test_invalid_validation_result_is_reported(self) -> None:
        document = handoff_document(
            validation_rows="| Build | `./scripts/build` | 成功 | exit code 0 |",
        )

        self.assertIn("HOF007", issue_codes(document))

    def test_validation_table_requires_a_data_row(self) -> None:
        document = handoff_document(validation_rows="")

        self.assertIn("HOF006", issue_codes(document))

    def test_completed_rejects_pending_work(self) -> None:
        document = handoff_document(pending_work="- [ ] 尚待實作")

        self.assertIn("HOF101", issue_codes(document))

    def test_completed_rejects_unfinished_validation(self) -> None:
        document = handoff_document(
            validation_rows="| Tests | `./scripts/test` | 未執行 | 尚未執行 |",
        )

        self.assertIn("HOF102", issue_codes(document))

    def test_completed_rejects_blockers(self) -> None:
        document = handoff_document(blockers="- [ ] 仍需使用者決策")

        self.assertIn("HOF107", issue_codes(document))

    def test_completed_unverified_requires_not_run_validation(self) -> None:
        document = handoff_document(status="completed-unverified")

        self.assertIn("HOF103", issue_codes(document))

    def test_completed_unverified_rejects_failed_validation(self) -> None:
        document = handoff_document(
            status="completed-unverified",
            validation_rows="| Tests | `./scripts/test` | 失敗 | 1 failed |",
        )

        self.assertIn("HOF104", issue_codes(document))

    def test_valid_completed_unverified_document_passes(self) -> None:
        document = handoff_document(
            status="completed-unverified",
            pending_work="- [ ] 執行測試",
            validation_rows="| Tests | `./scripts/test` | 未執行 | 尚未執行 |",
        )

        self.assertEqual([], validate_handoff.validate_document(document))

    def test_blocked_requires_a_blocker(self) -> None:
        document = handoff_document(
            status="blocked",
            pending_work="- [ ] 等待外部資料",
        )

        self.assertIn("HOF105", issue_codes(document))

    def test_valid_blocked_document_passes(self) -> None:
        document = handoff_document(
            status="blocked",
            pending_work="- [ ] 等待外部資料",
            validation_rows="| Build | `不適用` | 不適用 | 尚未實作 |",
            blockers="- [ ] 需要使用者提供 schema",
        )

        self.assertEqual([], validate_handoff.validate_document(document))

    def test_not_started_rejects_completed_work(self) -> None:
        document = handoff_document(
            status="not-started",
            validation_rows="| Build | `不適用` | 不適用 | 尚未開始 |",
        )

        self.assertIn("HOF106", issue_codes(document))


class CliTests(unittest.TestCase):
    def test_document_examples_pass(self) -> None:
        examples = re.split(
            r"(?m)^# Agent Hand-off\s*$",
            EXAMPLES.read_text(encoding="utf-8"),
        )[1:]

        self.assertEqual(2, len(examples))
        for example in examples:
            document = "# Agent Hand-off" + example
            self.assertEqual([], validate_handoff.validate_document(document))

    def test_cli_exit_codes(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            valid_path = Path(tempdir) / "valid.md"
            invalid_path = Path(tempdir) / "invalid.md"
            valid_path.write_text(handoff_document(), encoding="utf-8")
            invalid_path.write_text(
                handoff_document(pending_work="- [ ] 尚待實作"),
                encoding="utf-8",
            )

            valid = subprocess.run(
                [sys.executable, str(SCRIPT), str(valid_path)],
                capture_output=True,
                text=True,
                check=False,
            )
            invalid = subprocess.run(
                [sys.executable, str(SCRIPT), str(invalid_path)],
                capture_output=True,
                text=True,
                check=False,
            )
            missing = subprocess.run(
                [sys.executable, str(SCRIPT), str(Path(tempdir) / "missing.md")],
                capture_output=True,
                text=True,
                check=False,
            )

        self.assertEqual(0, valid.returncode, valid.stdout + valid.stderr)
        self.assertEqual(1, invalid.returncode, invalid.stdout + invalid.stderr)
        self.assertEqual(2, missing.returncode, missing.stdout + missing.stderr)
        self.assertIn("HOF101", invalid.stdout)


if __name__ == "__main__":
    unittest.main()
