set EDITOR code

abbr s sudo
abbr c code

set PAGER bat

set m micromamba
abbr m $m
abbr b bun
abbr p python
abbr rmr rm -rf
abbr hisdel history delete

set ol ollama
abbr ol $ol
abbr oser "$ol serve"
abbr orun "$ol run"
abbr oup "$ol ls | awk '{print \$1}' | rg -v NAME | xargs -n1 $ol pull"

set rainbow lolcrab
abbr cf "code (fd -E $m/ -t d | sk)"
abbr sw tclock stopwatch
abbr nv nvidia-smi
abbr st streamlit run

abbr d docker
abbr dcu docker compose up
abbr dsp docker system prune -a
abbr dkstop "docker stop (docker ps -q)"
abbr dkrm "docker stop (docker ps -aq); docker rm (docker ps -aq)"

abbr cn container
abbr cnss container s start
abbr cnrm 'container stop (container ls -aq); container rm (container ls -aq)'

abbr k kubectl
abbr kx kubectx

set mac $m activate
set mbi $m install -c conda-forge
set mrm $m remove

set p uv pip
set uvin $p install --system -U
set uvrm $p uninstall --system

set uvall "$p freeze | rg ="
set uvempty "$mrm -y pygobject py-opencv; $uvrm ($uvall)"
set mbempty "mkdir -p ~/$m && $mbi -y python_abi; $uvempty; $mrm -ya"
set torch 'pytorch::ignite pytorch::pytorch pytorch::torchaudio pytorch::torchserve pytorch::torchvision'

abbr uvin $uvin --dry-run
abbr uvinnd $uvin --no-deps
abbr uvrm $uvrm
abbr uvall $uvall
abbr uvempty $uvempty

abbr mac $mac
abbr mde $m deactivate
abbr mbin $mbi
abbr menv $m create -n
abbr mbfish $m shell init -s fish -r ~/$m
abbr mtorch "$mbi $torch"
abbr mrm $mrm

if type -q nvidia-smi
    set py_nvidia -c nvidia pytorch::pytorch-cuda $torch -c conda-forge
end

set today (date +%d%m)
abbr mbtest "$m env export >$today.yml && $m env -n test create -f $today.yml"
abbr mball0 "$m env export --from-history -n base | rg - | rg -v 'conda-forge' | sd '-' '\b\b' | nl"
set clean_m_list "| rg 34m | cut -c 12- | awk '{\$1=\$1};1' | awk '{print \$1}' | nl"
abbr mball1 "script -qc '$m list' $clean_m_list && rm typescript"
abbr mball2 "unbuffer -p $m list $clean_m_list"

abbr mbup --set-cursor "set -l p %; $mrm \$p && $mbi \$p"
abbr mbcheck --set-cursor "set -l p %; $m repoquery depends -c pytorch -c conda-forge \$p | rg \$p; $mbi \$p"

abbr rr 'ruff check --fix --unsafe-fixes && ruff format'

set gs "git -c color.status=always status | rg -v 'nothing to commit, working tree clean|\(use'"
set grs "git remote show origin | rg date"

abbr gco git checkout
abbr gs $gs
abbr grs $grs
abbr gitquick --set-cursor "git add . && git commit --allow-empty-message -am '%.' && git push"
abbr gitfresh --set-cursor 'set -l b ma%; git checkout --orphan z && git add -A && git commit -nam . && git branch -D $b && git branch -m $b && git push -f origin $b'
abbr ghssh "ssh-keygen -t ed25519 -C \"$(git config user.email)\" && gh ssh-key add ~/.ssh/id_ed25519.pub"
abbr gis gh gist create -p
abbr gsa _each_repo \"$gs\"
abbr grsa _each_repo \"$grs\"
abbr gcl --set-cursor 'set -l r %;rm -rf $r && gh repo clone $r && cp $r.env $r/.env && cd $r && bun i'
abbr ghemptyworkflow --set-cursor 'for id in (gh run list --workflow ci%.yml --json databaseId --jq \'.[].databaseId\'); gh run delete $id; end'
abbr prc lefthook run pre-commit --all-files

set sv systemctl start
abbr sv $sv
abbr svdocker $sv docker
abbr svlibvirt $sv libvirtd
abbr svmongo $sv mongodb

abbr newssh chmod 600 ~/.ssh/\*

abbr 4d --set-cursor "$(string join \n -- 'for dir in */' 'cd $dir' '%' '..' 'end')"

abbr ytdes --set-cursor "yt-dlp --write-description --skip-download % -o a && cat a.description && rm a.description"
abbr hex2str --set-cursor "echo % | xxd -r -p | wl-copy"
abbr weather curl wttr.in/Hanoi

if type -q cmd.exe
    set cmdopen cmd.exe /c start
else
    set cmdopen open
end

abbr au --set-cursor $cmdopen \"'https://aur.archlinux.org/packages?K=%'\"
abbr dh --set-cursor $cmdopen \"'https://hub.docker.com/search?q=%'\"
abbr et --set-cursor $cmdopen \"'https://chrome.google.com/webstore/search/%?_category=extensions'\"
abbr fb --set-cursor $cmdopen \"'https://facebook.com/search/?q=%'\"
abbr gg --set-cursor $cmdopen \"'https://google.com/search?q=%'\"
abbr gm --set-cursor $cmdopen \"'https://google.com/maps/search/%'\"
abbr gt --set-cursor $cmdopen \"'https://translate.google.com/?sl=en&text=%'\"
abbr ha --set-cursor $cmdopen \"'https://hopamchuan.com/search?q=%'\"
abbr mb --set-cursor $cmdopen \"'https://anaconda.org/search?q=%'\"
abbr pd --set-cursor $cmdopen \"'https://phind.com/search?q=%'\"
abbr pm --set-cursor $cmdopen \"'https://archlinux.org/packages/?q=%'\"
abbr sp --set-cursor $cmdopen \"'https://shopee.vn/search?keyword=%'\"
abbr ug --set-cursor $cmdopen \"'https://ultimate-guitar.com/search.php?value=%'\"
abbr ym --set-cursor $cmdopen \"'https://music.youtube.com/search?q=%'\"
abbr yt --set-cursor $cmdopen \"'https://youtube.com/results?q=%'\"

abbr shad --set-cursor "rm -rf ~/my-app && gh repo clone my-app cn && bunx --bun shadcn@latest init && cd my-app/packages/ui && bunx --bun shadcn@latest add -ayo && bunx --bun shadcn@latest add @ai-elements/all -ayo && bunx --bun shadcn@latest migrate radix && cd ../.. && rm -rf .git node_modules pnpm-lock.yaml pnpm-workspace.yaml .npmrc README.md && rm -rf (fd -H .gitkeep) && rm -rf (fd -te -td) && cd ~/% && mv ~/my-app apps/0/ && bun fix; bun lint:fix; bunx biome check --fix --unsafe; mv apps/0/my-app ~/ && mv ~/cn/.git ~/my-app && rm -rf ~/cn && cd ~/my-app && code . && git status"

function fish_remove_path
    if set -l index (contains -i "$argv" $fish_user_paths)
        set -e fish_user_paths[$index]
        echo "Removed $argv from the path"
    end
end

function openlink -a prefix file
    while read url
        $cmdopen "$prefix$url"
    end <$file
end

function flat -a file
    cat $file | sed 's/ /\n/g'
end

function on_exit -e fish_exit
    string repeat -n 2000 'bye '
end

function mark_prompt_start -e fish_prompt
    echo -en "\e]133;A\e\\"
end

function _done_noti_ -e fish_postexec
    set excludes bat btop cat cd code dua gitui man micro navi nvim sk vi vim yazi zellij
    set base_cmd (string split ' ' $argv)[1]

    if not contains $base_cmd $excludes && not set -q fish_private_mode && test $CMD_DURATION -gt 5000
        set time_taken (math -s1 $CMD_DURATION / 1000)
        set popup "Command takes $time_taken seconds"
        if type -q notify-send
            notify-send $popup $argv
        end
        if type -q ntfy
            ntfy pub -t $popup -m $argv -T computer _ >/dev/null 2>&1
        end
        if type -q osascript
            osascript -e "display notification \"$popup\" with title \"$argv\""
        end
    end
end

function _multicd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr _dotdot -r '^\.\.+$' -f _multicd

function commonlines -a f1 f2
    set c1 (cat $f1)
    set c2 (cat $f2)

    for l in $c1
        if string match $l $c2
            echo $l
        end
    end
end

function slide -a out
    for file in *.pdf
        pdftotext $file (basename $file .pdf).z
    end
    cat *.z >$out
    rm *.z
    sed -i '/^.$/d' $out
    awk -i inplace NF $out
    sed -i ':a;N;$!ba;s/\n\([[:lower:]]\)/ \1/g' $out
    sed -i '/^[^a-zA-Z]\+$/d' $out
    uniq $out >temp
    mv temp $out
end

function recursive_7z -a z
    set ignore otf ttf
    7z e $z
    rm $z
    for file in (fd -t f)
        if not contains (string split . $file)[-1] $ignore
            if 7z l $file >/dev/null
                recursive_7z $file
            end
        end
    end
    find . -type d -empty -delete
end

abbr dmg_extract "recursive_7z && rm .* *.otf"

function _each_repo -a cmd
    functions -e _ls_when_cd_
    for d in (find -mindepth 2 -maxdepth 2 -type d -name .git -exec dirname {} \;)
        cd $d
        set_color -oi
        echo \n'  === '(string replace "./" "" $d)' ===' | $rainbow
        set_color normal
        eval $cmd
        cd ..
    end
    _cdls
end

abbr abc 'echo U2FsdGVkX1/auhYFHStA5fNMyoikeTNgOTcyfDyzMqy8ZQgAtbznXOpxHPJ7kvZ1GSiA46NOA7LKfVqQ6/JXN675BDMqEm1HVTcokQEQwM0LrcajiqVXkfL3iFYl/80NAXnWCckobfnUnmP3Fk4FSjQS3FBWmfCxm2K+qC7K59Wc7/1GKfCgTiMSls2SMSlq7oruWTiaQ9nv0V+otnOBDmgGWLf3EpNtoFtKorENV7LlhSoqKCkB2ob5TKGGAJ1N | openssl aes-256-ecb -d -pbkdf2 -a'
