set EDITOR code

abbr s sudo
abbr c code

if type -q apt-get
    set fd_bin fdfind
else
    set fd_bin fd
end

set PAGER bat

set m micromamba
abbr m $m
abbr b bun
abbr p python
abbr rmr rm -rf
abbr hisdel history delete
abbr t zellij

set ol ollama
abbr ol $ol
abbr oser "$ol serve"
abbr orun "$ol run"
abbr oup "$ol ls | awk '{print \$1}' | rg -v NAME | xargs -n1 $ol pull"

abbr cf "code ($fd_bin -E $m/ -E runs/ -t d | sk)"
abbr sw tclock stopwatch
abbr nv nvidia-smi
abbr st streamlit run

abbr d docker
abbr dcu docker compose up -d
abbr dcd docker compose down
abbr dsp docker system prune -a
abbr dkstop "docker stop (docker ps -q)"

set mbi $m install -c conda-forge
set mrm $m remove
set mac $m activate

abbr mac $mac
abbr mde $m deactivate
abbr mbin $mbi
abbr menv $m create -n
abbr mbnew $m shell init -s fish
abbr mrm $mrm

set p uv pip
set uvin $p install -U --dry-run
set uvrm $p uninstall
set uvall "$p freeze | rg ="
abbr uvin $uvin
abbr uvrm $uvrm
abbr uvall $uvall
abbr uvempty "$uvrm ($uvall)"

set today (date +%d%m)
abbr mbtest "$m env export >$today.yml && $m env -n test create -f $today.yml"
abbr mball1 "$m env export --from-history -n base | rg -A 1000 'es:' | awk '{print \$2}' | rg . | nl"
abbr mball2 "script -qc '$m list' | rg 34m | cut -c 12- | awk '{\$1=\$1};1' | awk '{print \$1}' | nl && rm typescript"
abbr mbup --set-cursor "set -l p %; $mrm \$p && $mbi \$p"
abbr mbcheck --set-cursor "set -l p %; $m repoquery depends -c pytorch -c conda-forge \$p | rg \$p; $mbi \$p"

abbr newruff 'ruff generate-shell-completion fish > ~/.config/fish/completions/ruff.fish'
abbr rr 'ruff check && ruff format'

set gs "git -c color.status=always status | rg -v 'nothing to commit, working tree clean|\(use'"
set grs "git remote show origin | rg date"

abbr gco git checkout
abbr gs $gs
abbr grs $grs
abbr gitquick --set-cursor "git add . && git commit --allow-empty-message -am '%.' && git push"
abbr gitfresh --set-cursor 'set -l b ma%; git checkout --orphan z && git add -A && git commit -am . && git branch -D $b && git branch -m $b && git push -f origin $b'
abbr ghssh "ssh-keygen -t ed25519 -C \"$(git config user.email)\" && gh ssh-key add ~/.ssh/id_ed25519.pub"
abbr gis gh gist create -p
abbr gsa _each_repo \"$gs\"
abbr grsa _each_repo \"$grs\"
abbr gcl --set-cursor 'set -l r %;rm -rf $r && gh repo clone $r && cp $r.env $r/.env && cd $r && bun i'
abbr ghemptyworkflow --set-cursor 'for id in (gh run list --workflow ci%.yml --json databaseId --jq \'.[].databaseId\'); gh run delete $id; end'
abbr prc pre-commit run -a

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
abbr myip curl ip.me

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
abbr hf --set-cursor $cmdopen \"'https://huggingface.co/models?search=%'\"
abbr mb --set-cursor $cmdopen \"'https://anaconda.org/search?q=%'\"
abbr pd --set-cursor $cmdopen \"'https://phind.com/search?q=%'\"
abbr pm --set-cursor $cmdopen \"'https://archlinux.org/packages/?q=%'\"
abbr pp --set-cursor $cmdopen \"'https://paperswithcode.com/search?q=%'\"
abbr sp --set-cursor $cmdopen \"'https://shopee.vn/search?keyword=%'\"
abbr ug --set-cursor $cmdopen \"'https://ultimate-guitar.com/search.php?value=%'\"
abbr ym --set-cursor $cmdopen \"'https://music.youtube.com/search?q=%'\"
abbr yt --set-cursor $cmdopen \"'https://youtube.com/results?q=%'\"

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

function on_exit -e fish_exit
    string repeat -n 2000 'bye '
end

function mark_prompt_start -e fish_prompt
    echo -en "\e]133;A\e\\"
end

function _done_noti_ -e fish_postexec
    set excludes code dua gitui man micro navi nvim sk vi vim yazi zellij
    set base_cmd (string split ' ' $argv)[1]

    if not contains $base_cmd $excludes && not set -q fish_private_mode && test $CMD_DURATION -gt 5000
        set time_taken (math -s1 $CMD_DURATION / 1000)
        set popup "Command takes $time_taken seconds"
        if type -q notify-send
            notify-send $popup $argv
        end
        if type -q ntfy
            ntfy pub -t $popup -m $argv -T computer _
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
    for file in ($fd_bin -t f)
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
        echo \n'  === '(string replace "./" "" $d)' ===' | dotacat
        set_color normal
        eval $cmd
        cd ..
    end
    _cdls
end

function cpgit -a path
    if test -z $path
        echo "Usage: cpgit user/repo[/folder][#branch]"
    else
        set repo (string split '#' (basename $path))[1]
        if test -d $repo
            echo "Directory $repo already exists"
        else if test (count *) -eq 0
            bunx degit $path
        else
            bunx degit $path $repo
        end
    end
end

abbr abc 'echo U2FsdGVkX1/auhYFHStA5fNMyoikeTNgOTcyfDyzMqy8ZQgAtbznXOpxHPJ7kvZ1GSiA46NOA7LKfVqQ6/JXN675BDMqEm1HVTcokQEQwM0LrcajiqVXkfL3iFYl/80NAXnWCckobfnUnmP3Fk4FSjQS3FBWmfCxm2K+qC7K59Wc7/1GKfCgTiMSls2SMSlq7oruWTiaQ9nv0V+otnOBDmgGWLf3EpNtoFtKorENV7LlhSoqKCkB2ob5TKGGAJ1N | openssl aes-256-ecb -d -pbkdf2 -a'
