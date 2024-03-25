#!/usr/bin/env python3

from os.path import expanduser

from xmltodict import parse

with open(expanduser('~/arch/labwc/rc.xml')) as f:
  ori = parse(f.read())['labwc_config']['keyboard']['keybind']

ori = [
  (i['action'], i['@key']) for i in ori if not i['@key'].startswith('XF') and 'KP_' not in i['@key']
]
ori = [(i[-1] if isinstance(i, list) else i, j) for i, j in ori]

d = {}

commands = [(i['@command'].replace('Toggle', ''), j) for i, j in ori if i['@name'] == 'Execute']
for c, k in commands:
  if c.startswith('sh -c'):
    s = c.split("'")[1]
    if '||' in s:
      s = s.split('||')[1].strip() + ' [focus]'
    elif s.startswith('wtype -M'):
      s = (
        s.replace('wtype -M', '')
        .replace('-m ctrl', '')
        .replace('-m shift', '')
        .replace('ctrl -k ', '⌃')
        .replace('; ', '→')
        .strip()
      )
  elif c.startswith('busctl --user'):
    s = (
      ' '.join(c.split('/')[1].split(' ')[2:])
      .replace(' q ', ' ')
      .replace(' n ', ' ')
      .replace('Update', '')
    )
  else:
    c = [i for i in c.split(' ') if all(j not in i for j in ['wayland', 'disable'])]
    start = c[0]
    if start == 'footclient' and len(c) > 1:
      s = ' '.join(c[8:]) if len(c) > 7 else c[1]
    elif start in ('fuzzel', 'neovide'):
      s = start
    else:
      s = ' '.join(c)
      if 'code $' in s:
        s = 'code $(fd -t d | sk)'
  d[k] = s
d = {k: d[k] for k in sorted(d, key=d.get)}

d[' '] = ' '

exclude = [
  'GoToDesktop',
  'MoveToEdge',
  'SendToDesktop',
  'SnapToEdge',
  'SnapToRegion',
]
actions = [(i['@name'].replace('Toggle', ''), j) for i, j in ori]
actions = [(i, j) for i, j in actions if i not in exclude and i != 'Execute']
for a, k in actions:
  d[k] = f'=== {a:<14} ==='


def symbol_map(s: str):
  before = [
    'Space',
    'W',
    'C',
    'S',
    'A',
    'Tab',
    'Escape',
    'Return',
    'KP_Enter',
    'bracketleft',
    'bracketright',
    'period',
    'slash',
    'semicolon',
    'apostrophe',
    '-',
    'minus',
    'equal',
  ]
  after = [
    '⎵',
    '◆',
    '⌃',
    '⇧',
    '⌥',
    '⇥',
    '⎋',
    '⏎',
    '⏎',
    '[',
    ']',
    '.',
    '/',
    ';',
    "'",
    ' ',
    '-',
    '=',
  ]
  for b, a in zip(before, after):
    s = s.replace(b, a)
  a, b = s.rsplit(' ', 1)
  return f'{a:<4}{b:<3}: '


l = [f'{symbol_map(k)}{v}' for k, v in d.items()]

with open(expanduser('~/arch/keybind.txt'), 'w') as f:
  f.write('\n'.join(l))
