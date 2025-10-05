#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import re

def main() -> None:
    text = sys.stdin.read()
    cleaned = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)
    sys.stdout.write(cleaned)

if __name__ == "__main__":
    main()
