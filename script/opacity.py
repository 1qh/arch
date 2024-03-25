#!/usr/bin/env python3
from argparse import ArgumentParser
from os.path import expanduser

parser = ArgumentParser()
parser.add_argument('value', type=float)
file = expanduser('~/.opa.txt')

with open(file, 'r+') as file:
  num = float(file.read())
  num += parser.parse_args().value
  num = min(max(num, 0.0), 1.0)
  num = round(num, 1)
  file.seek(0)
  print(num)
  file.write(str(num))
