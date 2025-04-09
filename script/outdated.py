#!/usr/bin/env python3

from pathlib import Path
from subprocess import check_output

packages = [
  i.replace("'", '').split('>')[0] for i in Path('~/arch/pkg/py/mb.txt').expanduser().read_text().splitlines() if i
]


def less_info(ver: list[str], package: str) -> list[str]:
  info = next(j for j in [i.split(' ') for i in ver] if j[0] == package)[1:]
  if info[-1] == 'conda-forge':
    info.pop()
  return info


def check(package: str) -> tuple | None:
  current = (
    check_output(
      f"micromamba list | rg {package} | awk '{{$1=$1}};1'",
      shell=True,
    )
    .decode()
    .splitlines()
  )
  latest = (
    check_output(
      f"micromamba repoquery depends -c pytorch -c conda-forge {package} | rg {package} | awk '{{$1=$1}};1'",
      shell=True,
    )
    .decode()
    .splitlines()
  )
  if current != latest:
    current = less_info(current, package)
    latest = less_info(latest, package)
    if current[0] != latest[0]:
      if current[1] == latest[1]:
        current.pop(1)
        latest.pop(1)
      print(f'\n{package}')
      print('\t'.join(current))
      print('\t'.join(latest))
      return package, latest[0]
  return None


outdated = [i for i in [check(p) for p in packages] if i is not None]
rm = ' '.join([i[0] for i in outdated])
up = ' '.join([f"{i[0]}'>={i[1]}'" for i in outdated])

print(f'\n micromamba remove {rm}')
print(f'\n micromamba install -c conda-forge {up}')
