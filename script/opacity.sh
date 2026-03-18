#!/bin/bash

f=~/.opa.txt

if [ ! -f $f ]; then
    echo 0 >$f
fi

n=$(<$f)

if [[ $n == *.* ]]; then
    n=${n#0.}
else
    n=10
fi

n=$((n + $1))

if ((n < 1)); then
    n=0.0
elif ((n > 9)); then
    n=1
else
    n="0.$n"
fi

echo $n >$f

alacritty msg config window.opacity=$n
