#!/usr/bin/env python3

from os.path import expanduser
from subprocess import check_output

with open(expanduser('~/arch/pkg/py/mb.txt'), 'r') as f:
  packages = [i.replace("'", '').split('>')[0] for i in f.read().splitlines() if i != '']


def less_info(ver, package):
  info = [j for j in [i.split(' ') for i in ver] if j[0] == package][0][1:]
  if info[-1] == 'conda-forge':
    info.pop()
  return info


def check(package):
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


outdated = [i for i in [check(p) for p in packages] if i is not None]
rm = ' '.join([i[0] for i in outdated])
up = ' '.join([f"{i[0]}'>={i[1]}'" for i in outdated])

print(f'\nmicromamba remove {rm}')
print(f'\nmicromamba install -c conda-forge -c pytorch {up}')
