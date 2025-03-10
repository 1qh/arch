pkill swaybg
if [ "$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Inverted)" = "b false" ]; then
    swaybg -c '#000000' >/dev/null 2>&1 &
else
    swaybg -c '#ffffff' >/dev/null 2>&1 &
fi
