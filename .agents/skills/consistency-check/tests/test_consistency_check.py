from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "consistency-check.py"
SPEC = importlib.util.spec_from_file_location("consistency_check", SCRIPT)
assert SPEC and SPEC.loader
consistency_check = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = consistency_check
SPEC.loader.exec_module(consistency_check)


class LoadInstructionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.write("AGENTS.md", "# Project rules\n")

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def write(self, rel: str, content: str) -> None:
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def analyze(self):
        files = consistency_check.collect_load_instruction_files(self.root, [])
        directives = consistency_check.extract_load_directives(files, self.root)
        routes = consistency_check.extract_prompt_agents(files, self.root)
        issues = consistency_check.detect_redundant_loads(directives, routes)
        cycles = consistency_check.detect_load_cycles(
            directives,
            {path.relative_to(self.root).as_posix() for path in files},
        )
        return directives, issues, cycles

    def test_old_resume_pattern_is_blocked(self) -> None:
        self.write(
            ".github/prompts/sdd-resume.prompt.md",
            """---
agent: ba
---
執行前必須閱讀：

1. [AGENTS](../../AGENTS.md)
2. [TEAM](../../Docs/governance/TEAM.md)
""",
        )
        self.write(
            ".github/agents/ba.agent.md",
            "必須先讀取 [TEAM](../../Docs/governance/TEAM.md)。\n",
        )
        self.write("Docs/governance/TEAM.md", "# TEAM\n")

        _, issues, _ = self.analyze()
        kinds = {(issue.kind, issue.target) for issue in issues}

        self.assertIn(("auto-loaded", "AGENTS.md"), kinds)
        self.assertIn(("prompt-agent", "Docs/governance/TEAM.md"), kinds)

    def test_thin_resume_prompt_passes(self) -> None:
        self.write(
            ".github/prompts/sdd-resume.prompt.md",
            """---
agent: ba
---
所需治理文件由 BA 依其啟動檢查清單載入。
""",
        )
        self.write(
            ".github/agents/ba.agent.md",
            "必須先讀取 [TEAM](../../Docs/governance/TEAM.md)。\n",
        )
        self.write("Docs/governance/TEAM.md", "# TEAM\n")

        _, issues, cycles = self.analyze()

        self.assertEqual([], issues)
        self.assertEqual([], cycles)

    def test_informational_link_is_not_a_load_instruction(self) -> None:
        self.write(
            ".github/prompts/help.prompt.md",
            "詳見 [TEAM](../../Docs/governance/TEAM.md)。\n",
        )
        self.write("Docs/governance/TEAM.md", "# TEAM\n")

        directives, issues, _ = self.analyze()

        self.assertEqual([], directives)
        self.assertEqual([], issues)

    def test_negated_load_rule_is_not_an_instruction(self) -> None:
        self.write(
            "AGENTS.md",
            "禁止在 AGENTS.md 中直接載入會引用回 AGENTS.md 的文件。\n",
        )

        directives, issues, cycles = self.analyze()

        self.assertEqual([], directives)
        self.assertEqual([], issues)
        self.assertEqual([], cycles)

    def test_governance_table_description_is_not_an_instruction(self) -> None:
        self.write(
            ".github/instructions/code-safety.instructions.md",
            "# Safety\n",
        )
        self.write(
            ".github/copilot-instructions.md",
            "| `.github/instructions/code-safety.instructions.md` | 大檔讀取規則 |\n",
        )

        directives, issues, _ = self.analyze()

        self.assertEqual([], directives)
        self.assertEqual([], issues)

    def test_same_source_duplicate_is_blocked(self) -> None:
        self.write(
            ".github/agents/ba.agent.md",
            """必須讀取 [TEAM](../../Docs/governance/TEAM.md)。
讀取 [TEAM](../../Docs/governance/TEAM.md) 並執行。
""",
        )
        self.write("Docs/governance/TEAM.md", "# TEAM\n")

        _, issues, _ = self.analyze()

        self.assertIn(
            ("same-source", "Docs/governance/TEAM.md"),
            {(issue.kind, issue.target) for issue in issues},
        )

    def test_unrelated_agents_share_governance_as_warning(self) -> None:
        self.write(
            ".github/agents/one.agent.md",
            "必須讀取 [TEAM](../../Docs/governance/TEAM.md)。\n",
        )
        self.write(
            ".github/agents/two.agent.md",
            "必須讀取 [TEAM](../../Docs/governance/TEAM.md)。\n",
        )
        self.write("Docs/governance/TEAM.md", "# TEAM\n")

        _, issues, _ = self.analyze()
        shared = [issue for issue in issues if issue.kind == "shared-governance"]

        self.assertEqual(1, len(shared))
        self.assertEqual("warn", shared[0].severity)

    def test_load_cycle_is_blocked(self) -> None:
        self.write(
            "Docs/governance/a.md",
            "必須讀取 [B](b.md)。\n",
        )
        self.write(
            "Docs/governance/b.md",
            "必須讀取 [A](a.md)。\n",
        )

        _, _, cycles = self.analyze()

        self.assertEqual(
            [("Docs/governance/a.md", "Docs/governance/b.md", "Docs/governance/a.md")],
            cycles,
        )

    def test_referencing_auto_loaded_agents_is_blocked(self) -> None:
        self.write(
            ".github/instructions/git-workflow.instructions.md",
            "- 測試執行依 `AGENTS.md` 規範優先使用 `rtk test <cmd>` 節省 token。\n",
        )

        _, issues, _ = self.analyze()
        kinds = {(issue.kind, issue.target) for issue in issues}

        self.assertIn(("auto-loaded", "AGENTS.md"), kinds)


if __name__ == "__main__":
    unittest.main()
