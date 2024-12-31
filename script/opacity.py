#!/usr/bin/env python3
from pathlib import Path
from sys import argv
from sys import exit as ex

MIN_ARGS = 2

if len(argv) > MIN_ARGS:
  print('Usage: opacity.py [0.0-1.0]')
  ex(1)

with Path('~/.opa.txt').expanduser().open('r+', encoding='utf-8') as f:
  n = float(f.read()) + float(argv[1])
  n = min(max(n, 0.0), 1.0)
  n = round(n, 1)
  f.seek(0)
  print(n)
  f.write(str(n))
