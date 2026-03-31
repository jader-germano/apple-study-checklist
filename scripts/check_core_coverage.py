#!/usr/bin/env python3

import json
import sys
from pathlib import Path

INCLUDED_FILES = {
    "Sources/AppleStudyChecklist/Design/ThemeKit.swift",
    "Sources/AppleStudyChecklist/Models.swift",
    "Sources/AppleStudyChecklist/StudyCatalog.swift",
    "Sources/AppleStudyChecklist/StudyStore.swift",
    "Sources/AppleStudyChecklist/StudyVaultLoader.swift",
}


def relative_repo_path(filename: str) -> str:
    marker = "/apple-study-checklist/"
    if marker in filename:
        return filename.split(marker, 1)[1]
    return filename


def missing_lines(file_payload: dict) -> list[int]:
    covered = set()
    total = set()

    for segment in file_payload["segments"]:
        line = segment[0]
        count = segment[2]
        has_count = segment[3]
        if not has_count:
            continue
        total.add(line)
        if count > 0:
            covered.add(line)

    return sorted(total - covered)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: check_core_coverage.py <SwiftPM-codecov-json>", file=sys.stderr)
        return 2

    coverage_path = Path(sys.argv[1])
    payload = json.loads(coverage_path.read_text())

    failures: list[tuple[str, list[int]]] = []
    for file_payload in payload["data"][0]["files"]:
        relative_path = relative_repo_path(file_payload["filename"])
        if relative_path not in INCLUDED_FILES:
            continue
        missing = missing_lines(file_payload)
        if missing:
            failures.append((relative_path, missing))

    if failures:
        print("Core coverage check failed.")
        for relative_path, missing in failures:
            print(f"- {relative_path}: uncovered lines {missing}")
        return 1

    print("Core coverage check passed.")
    for relative_path in sorted(INCLUDED_FILES):
        print(f"- {relative_path}: 100%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
