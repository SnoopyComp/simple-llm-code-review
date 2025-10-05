#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import re
from pathlib import Path
from typing import Tuple

COMMENT_PATTERN_BYTES = re.compile(br"<!--.*?-->", re.DOTALL)
TRUNCATION_MARK = b"\n\n[...truncated...]\n"


def normalize_newlines(data: bytes) -> bytes:
    # \r\n -> \n, then lone \r -> \n
    data = data.replace(b"\r\n", b"\n")
    data = data.replace(b"\r", b"\n")
    return data


def strip_md_comments(data: bytes) -> bytes:
    # HTML 주석 패턴을 바이트 레벨에서 제거 (확장자 무관)
    return COMMENT_PATTERN_BYTES.sub(b"", data)


def utf8_safe_trim(data: bytes, maxb: int) -> Tuple[bytes, bool]:
    """UTF-8 멀티바이트 중간 절단 방지하여 자르기."""
    if len(data) <= maxb:
        return data, False
    cut = maxb
    # 이전 바이트가 UTF-8 continuation (10xxxxxx)이면 뒤로 이동
    while cut > 0 and (data[cut - 1] & 0xC0) == 0x80:
        cut -= 1
    trimmed = data[:cut] + TRUNCATION_MARK
    return trimmed, True


def build_output_path(src: Path) -> Path:
    stem = src.stem  # 파일명(확장자 제외)
    if stem.endswith("_raw"):
        new_stem = stem[: -len("_raw")] + "_clean"
    else:
        new_stem = stem + "_clean"
    return src.with_name(new_stem + src.suffix)


def process_file(src_path: Path, max_bytes: int) -> Path:
    data = src_path.read_bytes()
    data = normalize_newlines(data)

    # ✅ 확장자와 무관하게 HTML 주석 제거
    data = strip_md_comments(data)

    data, _ = utf8_safe_trim(data, max_bytes)

    out_path = build_output_path(src_path)
    out_path.write_bytes(data)
    return out_path


def main() -> None:
    if len(sys.argv) != 3:
        print(f"Usage: {Path(sys.argv[0]).name} <file_path> <max_bytes>", file=sys.stderr)
        sys.exit(2)

    src = Path(sys.argv[1]).expanduser().resolve()
    try:
        maxb = int(sys.argv[2])
    except ValueError:
        print("max_bytes must be an integer", file=sys.stderr)
        sys.exit(2)

    if not src.is_file():
        print(f"Not a file: {src}", file=sys.stderr)
        sys.exit(1)

    out = process_file(src, maxb)
    # 결과 경로 출력(필요시 파이프라인에서 활용)
    print(str(out))


if __name__ == "__main__":
    main()
