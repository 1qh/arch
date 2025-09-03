#!/bin/bash
all=$(niri msg -j windows)
cur=$(echo "$all" | jaq -r '.[] | select(.is_focused)')
ap=$(echo "$cur" | jaq -r '.app_id')
id=$(echo "$cur" | jaq -r '.id')
list=$(echo "$all" | jaq -r ".[] | select(.app_id == \"$ap\") | .id")
next=$(echo "$list" | grep -A1 "^$id$" | tail -1)
[ "$next" = "$id" ] && next=$(echo "$list" | head -1)
[ "$next" != "$id" ] && niri msg action focus-window --id "$next"