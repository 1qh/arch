#!/usr/bin/env python3

import json
import os
from pathlib import Path
from subprocess import CalledProcessError, check_output
from typing import Annotated

from requests import get
from typer import Argument, run


def show_deps(deps: set[str] | list[str], pkg: str) -> None:
  print(f'\n=== {len(deps)} DEPENDENCIES of {pkg} ===')
  print(*deps, sep='\n')


def app(  # noqa: C901, PLR0912
  p: Annotated[str, Argument(metavar='PACKAGE', help='to check', show_default=False)] = 'ultralytics',
  env: str = 'base',
) -> None:
  os.system(f'micromamba list --json -n {env} > a.json')

  tmp = Path('a.json')
  with tmp.open(encoding='utf-8') as f:
    l1 = [p['name'] for p in json.load(f)]
  tmp.unlink()

  l2 = [
    i.split('==')[0].lower().replace('_', '-')
    for i in check_output(['pip', 'list', '--format=freeze']).decode('utf-8').split('\n')
    if i
  ]

  installed = set(l1 + l2)

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
      dep = get(f'https://pypi.org/pypi/{p}/json', timeout=1e3).json()['info']['requires_dist']
      try:
        dep = [
          i.replace('>=', ' ').replace('==', ' ').replace('[', ' ').replace(';', ' ').split(' ')[0].lower() for i in dep
        ]
        dep = set(dep)

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
