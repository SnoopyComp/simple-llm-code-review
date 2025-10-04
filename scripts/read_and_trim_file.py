#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, os

def main():
    if len(sys.argv) != 3:
        print("usage: read_and_trim_file.py MAX_BYTES PATH", file=sys.stderr)
        sys.exit(2)

    try:
        maxb = int(sys.argv[1])
    except ValueError:
        print("MAX_BYTES must be int", file=sys.stderr)
        sys.exit(2)

    path = sys.argv[2]
    if not os.path.isfile(path):
        print(f"file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with open(path, "rb") as f:
        data = f.read(maxb + 1)

    data = data.replace(b"\r\n", b"\n").replace(b"\r", b"\n")

    if len(data) <= maxb:
        sys.stdout.buffer.write(data)
        return

    cut = maxb
    while cut > 0 and (data[cut - 1] & 0xC0) == 0x80:
        cut -= 1

    sys.stdout.buffer.write(data[:cut])
    sys.stdout.write("\n\n[...truncated...]\n")

if __name__ == "__main__":
    main()
