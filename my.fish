set repo ~/arch
source $repo/server.fish
source $repo/kube.fish

set current_wm labwc

set TTY (tty)
[ "$TTY" = /dev/tty1 ] && exec $current_wm -C $repo/labwc

set name (string upper (whoami))

set df ~/.config
set my $repo/conf
set pkg $repo/pkg
set script $repo/script

set hidels $repo/hidels
set nodot (flat $hidels/nodot.txt)
set dot (flat $hidels/dot.txt)

set myls eza -lh --icons --no-user --time-style relative -I
set nodots $myls \'(echo $nodot | sd ' ' '|')\'
set hiddens $myls \'(echo $nodot $dot | sd ' ' '|')\' -a

set l $nodots
set ll $hiddens
set chi $nodots -T

alias l "$l"
alias ll "$ll"
alias chi "$chi"

abbr baby "$script/baby.sh > ~/.ans"
abbr logo "$script/eximgpt.sh > ~/.ans"
abbr logo_python "$script/logo_python.sh > ~/.ans"

abbr formatprettier prettier --config $my/.prettierrc -w .
abbr kbind "$script/keybind.py && cat $repo/keybind.txt | rg :"

abbr camtest exec yolo track source=0 show=True
abbr listen --set-cursor "yt-dlp -f ba '%' -o - 2>/dev/null | ffplay -loop 9 -nodisp -autoexit -i - &>/dev/null"

set zed $repo/zed
abbr zedsync "cp -r $zed $df"
abbr wlelec "tee $df/code-flags.conf $df/youtube-music-flags.conf < $my/electron-flags.conf"

if type -q $current_wm
    source $repo/desktop.fish
end

if type -q pacman
    set pacin sudo pacman -S --needed
    set pacrm sudo pacman -Rns
    set aurin paru -S --needed --skipreview

    abbr aurin $aurin

    if type -q $current_wm
        set pm $pkg/desktop/pacman.txt
        set aur $pkg/desktop/aur.txt
        set qm $pkg/qemu.txt
        set tex $pkg/tex.txt
        set desktop_setup "$pacin -< $pm && $aurin -< $aur &&"

        abbr qmsync "$pacin -< $qm && sudo usermod -aG libvirt $USER && sudo virsh net-autostart default"
        abbr texsync "$pacin -< $tex"
    end

    if not type -q paru
        abbr paru 'git clone https://aur.archlinux.org/paru-bin && cd paru-bin && makepkg -si && cd .. && rm -rf paru-bin && paru'
    end

    set pm $pkg/cli/pacman.txt
    set aur $pkg/cli/aur.txt
    set server_setup "$pacin -< $pm && $aurin -< $aur &&"

    abbr ok "paru && $server_setup $desktop_setup paru"

    function cl
        $m clean --all
        rm -rf (string match --invert ~/.cache/huggingface ~/.cache/*) /tmp/* $df/BraveSoftware/Brave-Browser/Default/History $df/BraveSoftware/Brave-Browser/Default/Service\ Worker/ ~/.nv ~/__pycache__ ~/.Rhistory ~/.bash_history ~/.lesshst ~/.local/share/fish/fish_history ~/.mysql_history ~/.python_history ~/.pythonhist ~/.sqlite_history ~/.viminfo
        $pacrm (pacman -Qdttq)
        sudo pacman -Scc
        sudo rm -rf /var/cache/ /var/lib/systemd/coredump/
        clear -x
    end

    abbr hostsync sudo cp $my/unmicrosoftededge /etc/hosts
    abbr kmap sudo cp $my/keyd.conf /etc/keyd/default.conf
    abbr fixjack sudo cp $my/audio-jack.conf /etc/modprobe.d/

    set lvcf $df/lvim
    abbr mylvim "rm $lvcf/config.lua; cp $my/config.lua $lvcf"
    abbr nobg dconf write /org/gnome/desktop/background/picture-uri \"\'file://$my/nothing.png\'\"
    abbr cursor "mkdir -p ~/.icons/default/ && cp $my/index.theme ~/.icons/default/ && dconf write /org/gnome/desktop/interface/cursor-theme \"'FlatbedCursors-White'\""

    set brave $df/BraveSoftware/Brave-Browser/Default
    set edge $df/microsoft-edge/Default
    abbr br2edge "rm -rf $edge/Extensions/ && cp -r $brave/* $edge/"
    abbr booksync cp $brave/Bookmarks $edge/

    set vs $repo/vscode
    abbr vscode "cp $vs/app-settings.json $df/Code/User/settings.json"
    abbr ownvscode sudo chown -R (whoami) /opt/visual-studio-code
end

if type -q apt
    alias fd fdfind
    alias code='code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto'

    set pacin sudo apt install --no-install-recommends
    set pacrm sudo apt purge --autoremove

    set deb (flat $pkg/apt.txt)
    set cg (flat $pkg/cargo.txt)

    abbr ok "$pacin $deb && sudo apt update && sudo apt upgrade"
    abbr cl "sudo apt autoremove && sudo rm -rf /var/cache/apt/*"
    abbr cgok "cargo install $cg && cargo install-update -a"
end

if type -q xcode-select
    set pacin brew install
    set pacrm brew uninstall
    set pacdep brew deps --tree

    set opt /opt/homebrew/opt
    abbr addbin "fish_add_path $opt/uutils-coreutils/libexec/uubin $opt/uutils-findutils/libexec/uubin $opt/util-linux/bin"

    set brw (flat $pkg/brew.txt)
    abbr ok "$pacin $brw && brew update && brew upgrade && brew cleanup --prune=all"
end

if type -q cmd.exe
    set pacin winget install
    set pacrm winget uninstall

    set winget (flat $pkg/winget.txt)
    abbr ok "$pacin $winget && winget upgrade"
end

if type -q $m || type -q apt # fix later
    set pypkg $pkg/py
    if not type -q cmd.exe
        set mb_nowin (flat $pypkg/mb_nowin.txt)
    end
    set mb (flat $pypkg/mb.txt)
    set nodep (flat $pypkg/nodep.txt)
    set pip (flat $pypkg/pip.txt)

    set MAMBA_NO_PROMPT
    set mbbase "$mbi $py_nvidia% $mb_nowin $mb $nodep"
    abbr mbbase --set-cursor "$mbbase"
    abbr mok --set-cursor "$mbempty && $mbbase -y; $m clean -a"
    abbr mbrm1by1 --set-cursor "for i in (cat $pypkg/%); echo \n\n=== REMOVING \$i ===\n; $mrm \$i; end"
    abbr mbin1by1 --set-cursor "for i in (cat $pypkg/%); echo \n\n=== INSTALLING \$i ===\n; $mbi \$i; end"
    abbr mbsearch --set-cursor "openlink 'https://anaconda.org/search?q=' $pypkg/%.txt"
    abbr pipsync "$uvin $pip"
end

function fish_prompt
    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0
    set_color brblack
    echo -n $CONDA_DEFAULT_ENV' '
    set_color -i magenta
    fish_vcs_prompt '%s '
    set_color normal
    set_color -o yellow
    printf '%s ' (prompt_pwd)
end

function center
    printf "$argv" | awk -v w=(tput cols) '{printf "%" int((w - length($0)) / 2) "s%s\n", "", $0}' | $rainbow | head -n -1
end

function centerf
    cat "$argv" | awk -v w=(tput cols) '{printf "%" int((w - length($0)) / 2) "s%s\n", "", $0}' | $rainbow | head -n -1
end

function fish_greeting
    if not type -q cmd.exe
        $mac
    end
    clear -x
    if type -q dysk
        dysk
    end
    cal | awk -v w=(tput cols) '{printf "%" int((w - length($0)) / 2) "s%s\n", "", $0}' | awk -v d=(date +%e) '{gsub(" "(d)" ", "\033[7m "d" \033[27m"); print}' | $rainbow | head -n -1
    if type -q fortune
        set qoute (fortune -s)
        echo $qoute | tr -d '\t' | rg -ve '^--' | sed 's/--/-/g; s/  / /g' >.qoute.txt
        centerf .qoute.txt
        rm .qoute.txt
    end
    fastfetch -l ~/.ans -c $my/fastfetch.json --separator \r\t\t\t\t\t\t\t\t\t\t\t\t\t
    center Hello, I\'m $name\nHave a nice day!
end

function _cdls
    function _ls_when_cd_ -v PWD
        if string match -q "$HOME*" $PWD && not string match -q "*$m" $PWD
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1
                set flag --git
            else
                set flag --git-repos
            end
            if test -d $m -o (fd -Id1 -td | wc -l) -eq 0 || test (fd -I | wc -l) -ge (math (tput lines) - 2)
                alias l "$l $flag"
                l
            else
                alias chi "$chi $flag"
                chi
            end
            if string match -q "$HOME/*" $PWD && not test (fd -Id1 | wc -l) -eq 0
                center (dua | rg total) (fd -I | wc -l) items
            end
        else
            l
        end
    end
end
_cdls

abbr pacin $pacin
abbr pacrm $pacrm
abbr pacdep $pacdep
