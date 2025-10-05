#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, re, pathlib

def main():
    if len(sys.argv) != 2:
        print("usage: parse_reference_paths.py <PR_BODY_FILE>", file=sys.stderr)
        sys.exit(2)

    pr_body_path = pathlib.Path(sys.argv[1])
    if not pr_body_path.is_file():
        print(f"missing file: {pr_body_path}", file=sys.stderr)
        sys.exit(1)

    text = pr_body_path.read_text(encoding="utf-8", errors="replace")
    text = text.replace("\r\n", "\n").replace("\r", "\n")

    pattern = re.compile(r'reference\s*=\s*\{(.*?)\}', re.IGNORECASE | re.DOTALL)
    blocks = pattern.findall(text)

    seen = set()
    out = []

    for block in blocks:
        tokens = re.split(r'[,\n]', block)
        for raw in tokens:
            ref = raw.strip().strip('\'"`').rstrip('\r')
            if not ref:
                continue
            if ref.startswith("```") or ref.endswith("```"):
                ref = ref.strip('`').strip()
                if not ref:
                    continue
            if ref not in seen:
                seen.add(ref)
                out.append(ref)

    for p in out:
        print(p)

if __name__ == "__main__":
    main()
