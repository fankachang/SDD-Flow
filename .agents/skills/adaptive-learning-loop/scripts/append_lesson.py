#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import os
import re
import sys
from datetime import date
from pathlib import Path


MAX_FIELD_LENGTH = 800
CONTROL_CHARACTER_PATTERN = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")
WINDOWS_PATH_PATTERN = re.compile(r"^(?:[A-Za-z]:[\\/]|\\\\)")
SECRET_PATTERNS = (
    re.compile(r"sk-[A-Za-z0-9]{20,}"),
    re.compile(r"(?:ghp|gho|github_pat)_[A-Za-z0-9_]{20,}"),
    re.compile(r"AKIA[A-Z0-9]{16}"),
    re.compile(r"AIza[A-Za-z0-9_-]{35}"),
    re.compile(r"-----BEGIN [^-]{1,80} PRIVATE KEY-----"),
)


def default_target() -> Path:
    return Path(__file__).resolve().parents[1] / "references" / "lessons.md"


def normalize_field(value: str, field_name: str) -> str:
    stripped_value = value.strip()
    if not stripped_value:
        raise ValueError(f"{field_name} must not be empty")
    if CONTROL_CHARACTER_PATTERN.search(stripped_value):
        raise ValueError(f"{field_name} must be a single line without control characters")
    if len(stripped_value) > MAX_FIELD_LENGTH:
        raise ValueError(f"{field_name} must be at most {MAX_FIELD_LENGTH} characters")
    for secret_pattern in SECRET_PATTERNS:
        if secret_pattern.search(stripped_value):
            raise ValueError(f"{field_name} contains a value that must be redacted")
    return " ".join(stripped_value.split())


def make_lesson_id(values: list[str]) -> str:
    normalized_values = "\x1f".join(values)
    return hashlib.sha256(normalized_values.encode("utf-8")).hexdigest()[:16]


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Append one validated, deduplicated lesson to a Markdown log."
    )
    parser.add_argument("--target", type=Path, default=default_target())
    parser.add_argument("--summary", required=True)
    parser.add_argument("--symptom", required=True)
    parser.add_argument("--cause", required=True)
    parser.add_argument("--correction", required=True)
    parser.add_argument("--evidence", required=True)
    parser.add_argument("--scope", default="general")
    parser.add_argument("--status", choices=("candidate", "verified", "retired"), default="verified")
    parser.add_argument("--date", dest="record_date", default=date.today().isoformat())
    parser.add_argument("--tag", action="append", default=[])
    return parser.parse_args()


def read_existing(target_path: Path) -> str:
    if not target_path.exists():
        return ""
    try:
        return target_path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise ValueError(f"cannot read target log: {error}") from error


def normalize_target_path(target_path: Path) -> Path:
    target_text = str(target_path)
    if os.name != "nt" and WINDOWS_PATH_PATTERN.match(target_text):
        raise ValueError(
            "Windows path detected on a POSIX/WSL runtime; use a POSIX path "
            "or a WSL mount path such as /mnt/c/..."
        )
    return target_path.expanduser()


def render_record(
    record_date: str,
    summary: str,
    symptom: str,
    cause: str,
    correction: str,
    evidence: str,
    scope: str,
    status: str,
    tags: list[str],
    lesson_id: str,
) -> str:
    tag_text = ", ".join(tags) if tags else "general"
    return (
        f"## {record_date} - {summary}\n"
        f"<!-- lesson-id: {lesson_id} -->\n"
        f"- **Status**: {status}\n"
        f"- **Symptom**: {symptom}\n"
        f"- **Cause**: {cause}\n"
        f"- **Correction**: {correction}\n"
        f"- **Evidence**: {evidence}\n"
        f"- **Scope**: {scope}\n"
        f"- **Tags**: {tag_text}\n\n"
    )


def append_record(arguments: argparse.Namespace) -> tuple[str, Path]:
    summary = normalize_field(arguments.summary, "summary")
    symptom = normalize_field(arguments.symptom, "symptom")
    cause = normalize_field(arguments.cause, "cause")
    correction = normalize_field(arguments.correction, "correction")
    evidence = normalize_field(arguments.evidence, "evidence")
    scope = normalize_field(arguments.scope, "scope")
    tags = [normalize_field(tag, "tag").lower() for tag in arguments.tag]

    try:
        record_date = date.fromisoformat(arguments.record_date).isoformat()
    except ValueError as error:
        raise ValueError("date must use YYYY-MM-DD") from error

    lesson_id = make_lesson_id(
        [summary, symptom, cause, correction, evidence, scope, arguments.status, *tags]
    )
    target_path = normalize_target_path(arguments.target)
    existing_content = read_existing(target_path)
    marker = f"<!-- lesson-id: {lesson_id} -->"
    if marker in existing_content:
        return "DUPLICATE", target_path

    target_path.parent.mkdir(parents=True, exist_ok=True)
    record = render_record(
        record_date,
        summary,
        symptom,
        cause,
        correction,
        evidence,
        scope,
        arguments.status,
        tags,
        lesson_id,
    )
    if not existing_content:
        prefix = "# Adaptive Learning Log\n\n"
    elif existing_content.endswith("\n\n"):
        prefix = ""
    elif existing_content.endswith("\n"):
        prefix = "\n"
    else:
        prefix = "\n\n"

    try:
        with target_path.open("a", encoding="utf-8") as target_file:
            target_file.write(prefix + record)
    except OSError as error:
        raise ValueError(f"cannot append to target log: {error}") from error
    return "APPENDED", target_path


def main() -> int:
    arguments = parse_arguments()
    try:
        result, target_path = append_record(arguments)
    except ValueError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    print(f"{result}: {target_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())