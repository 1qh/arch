#!/usr/bin/env python3

import json
import os
from subprocess import CalledProcessError, check_output

import requests
from typer import Argument, run
from typing_extensions import Annotated


def show_deps(deps, pkg):
  print(f'\n=== {len(deps)} DEPENDENCIES of {pkg} ===')
  print(*deps, sep='\n')


def app(
  p: Annotated[
    str, Argument(metavar='PACKAGE', help='to check', show_default=False)
  ] = 'ultralytics',
  env: str = 'base',
):
  os.system(f'micromamba list --json -n {env} > a.json')

  with open('a.json') as f:
    l1 = [p['name'] for p in json.load(f)]
  os.remove('a.json')

  l2 = [
    i.split('==')[0].lower().replace('_', '-')
    for i in check_output(['pip', 'list', '--format=freeze']).decode('utf-8').split('\n')
    if i
  ]

  installed = set(sorted(l1 + l2))

  if p.lower() in installed:
    print(f'\n=== {p} is already installed ===')
    try:
      m = check_output(
        f'pip show {p} | rg Requires:',
        shell=True,
        text=True,
      )
      m = [i.strip().replace(',', '') for i in m.split(' ')[1:]]

    except CalledProcessError:
      m = check_output(
        f'micromamba repoquery --json depends {p}',
        shell=True,
        text=True,
      )
      m = [i.strip().split(' ')[0] for i in m.split('\n')[2:]]

      if p in m:
        m.remove(p)
    try:
      m = ' '.join(m).split()
      if len(m):
        show_deps(m, p)
      else:
        print('\nNO DEPENDENCY FOUND\n')
    except TypeError:
      print('\nNO DEPENDENCY FOUND\n')

  else:
    try:
      dep = requests.get(f'https://pypi.org/pypi/{p}/json').json()['info']['requires_dist']
      try:
        dep = [
          i.replace('>=', ' ')
          .replace('==', ' ')
          .replace('[', ' ')
          .replace(';', ' ')
          .split(' ')[0]
          .lower()
          for i in dep
        ]
        dep = set(sorted(dep))

        miss = [i for i in dep if i not in installed]
        if c := len(miss):
          print(f'\n=== {c} MISSING ===')
          print(*miss, sep='\n')
        else:
          print(f'\n=== pip install {p} ===')

      except TypeError:
        print(f'\n=== pip install {p} ===')

      try:
        if len(dep):
          show_deps(dep, p)
        else:
          print('\nNO DEPENDENCY FOUND\n')

      except TypeError:
        print('\nNO DEPENDENCY FOUND\n')

    except KeyError:
      print(f'\n=== {p} not found ===\n')


if __name__ == '__main__':
  run(app)
