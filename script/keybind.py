#!/usr/bin/env python3
from operator import itemgetter
from pathlib import Path

from xmltodict import parse

SYMBOLS: dict[str, str] = {
  'Space': '⎵',
  'W': '◆',
  'C': '⌃',
  'S': '⇧',
  'A': '⌥',
  'Tab': '⇥',
  'Escape': '⎋',
  'Return': '⏎',
  'KP_Enter': '⏎',
  'bracketleft': '[',
  'bracketright': ']',
  'period': '.',
  'slash': '/',
  'semicolon': ';',
  'apostrophe': "'",
  '-': ' ',
  'minus': '-',
  'equal': '=',
}
EXCLUDED: set[str] = {'GoToDesktop', 'MoveToEdge', 'SendToDesktop', 'SnapToEdge', 'SnapToRegion'}


def clean(c: str) -> str:
  c = c.removeprefix('footclient ').replace('--ozone-platform=wayland', '').replace('  ', ' ').strip()
  return (
    c.split(' ')[0]
    if c.startswith(('fuzzel', 'code'))
    else 'code [fuzzy]'
    if '$(fd' in c
    else ' '.join(c.split(' ')[3:])
    if '-c ~' in c
    else c
  )


def fmt(s: str) -> str:
  for o, n in SYMBOLS.items():
    s = s.replace(o, n)
  a, b = s.rsplit(' ', 1)
  return f'{a:<5} {b:<2} |'


kb = parse(Path('~/arch/labwc/rc.xml').expanduser().read_text())['labwc_config']['keyboard']['keybind']
d: dict[str, str] = {}
for i in kb:
  k = i['@key']
  if k.startswith('XF') or 'KP_' in k or k == 'Print':
    continue
  a = i['action']
  if a['@name'] == 'Execute':
    cmd = a['@command'].replace('Toggle', '')
    if cmd.startswith('busctl --user'):
      p = cmd.split('/')[1]
      v = ' '.join(p.split(' ')[2:]).replace(' q ', ' ').replace(' n ', ' ').replace('Update', '')
    elif cmd.startswith('sh -c'):
      u = cmd.split("'", 2)[1]
      if '||' in u:
        v = clean(u.split('||', 1)[1].strip())
      elif u.startswith('wtype -M'):
        v = (
          u
          .replace('wtype -M', '')
          .replace('-m ctrl', '')
          .replace('-m shift', '')
          .replace('ctrl -k ', '⌃')
          .replace('; ', '→')
          .strip()
        )
      else:
        v = u
    else:
      v = clean(cmd)
  else:
    t = a['@name'].replace('Toggle', '')
    if t in EXCLUDED:
      continue
    v = t
  d[k] = v

lines = [f'{fmt(k)} {v}' for k, v in sorted(d.items(), key=itemgetter(1))]
Path('~/arch/keybind.txt').expanduser().write_text('\n'.join(lines) + '\n')
