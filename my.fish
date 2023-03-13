set root arch
set TTY1 (tty)
[ "$TTY1" = /dev/tty1 ] && exec labwc -C ~/$root/labwc

set fs ~/$root/my.fish
set pkg ~/$root/pkg
set conf ~/$root/conf
set vs ~/$root/vscode
set mb $pkg/mb.txt
set pip $pkg/pip.txt
set pm $pkg/pm.txt
set qm $pkg/qm.txt
set aur $pkg/aur.txt
set aurgit $pkg/aurgit.txt
set lvcf ~/.config/lvim
set brave ~/.config/BraveSoftware/Brave-Browser/Default
set edge ~/.config/microsoft-edge/Default

set width (tput cols)
set height (tput lines)
set thetime (date +%R)
set num_pac (pacman -Qq | wc -l)
set linux_version (uname -r | awk -F'-' '{print $1}' | cut -c 3-)
set disk_percent (df -h / | awk 'NR==2{printf "%.0f/%.0f", $3,$2}')

set hide "-I Desktop -I Documents -I Downloads -I Music -I Pictures -I Public -I R-I Templates -I Videos -I tags"
set hidedot "-I .alacritty.yml -I .anydesk -I .bashrc -I .byobu -I .cache -I .cert -I .config -I .fonts -I .git -I .gitconfig -I .gnupg -I .ipython -I .java -I .lemminx -I .lesshst -I .local -I .moc -I .npm -I .pki -I .python_history -I .pythonhist -I .r -I .sonarlint -I .ssh -I .streamlit -I .viminfo -I .vscode -I .wget-hsts -I .wine"

abbr ... ../..
abbr .... ../../..
abbr ..... ../../../..
abbr s sudo
abbr c code

abbr n pnpm
abbr p python
abbr m micromamba
abbr mac micromamba activate
abbr mbin micromamba install -c conda-forge
abbr nv nvidia-smi
abbr st streamlit
abbr rmr rm -rf

abbr d docker
abbr dc docker-compose
abbr dcu docker-compose up -d
abbr dcd docker-compose down
abbr dsp docker system prune -a

abbr pacin sudo pacman -S --needed
abbr pacrm sudo pacman -Rns
abbr atrm "sudo pacman -Rns (pacman -Qdttq)"

abbr fishcf code $fs

abbr pmsync "sudo pacman -S --needed -< $pm"
abbr qmsync "sudo pacman -S --needed -< $qm"
abbr aursync "paru -S --needed --skipreview -< $aur"
abbr aurgitsync "paru -S --needed --skipreview -< $aurgit"
abbr allsync "sudo pacman -S --needed -< $pm && paru -S --needed --skipreview -< $aur"

abbr mbsync "micromamba activate && micromamba install $(echo $(cat $mb) | tr "\n" " ")-c conda-forge"
abbr pipsync pip install -Ur $pip

abbr lvsync "rm $lvcf/config.lua; ln $conf/config.lua $lvcf"
abbr hostsync sudo cp $conf/unmicrosoftededge /etc/hosts
abbr kmap sudo cp $conf/keyd.conf /etc/keyd/default.conf
abbr myala cp $conf/.alacritty.yml ~

abbr br2edge "rm -rf $edge/Extensions/ && cp -r $brave/* $edge/"
abbr booksync cp $brave/Bookmarks $edge/

abbr gs git status
abbr gitquick 'git add . && git commit --allow-empty-message -am. && git push origin master'

abbr weather curl wttr.in/Hanoi
abbr myip curl ip.me
abbr twdj 'python manage.py tailwind start & python manage.py runserver'
abbr cvat docker-compose -f ~/cvat/docker-compose.yml -f ~/cvat/components/serverless/docker-compose.serverless.yml up -d
abbr win 'sudo virsh start win11; remote-viewer spice://localhost:5900'
abbr mntwin sudo mount /dev/nvme0n1p4 ~/c
abbr screencap '/usr/lib/xdg-desktop-portal -r & /usr/lib/xdg-desktop-portal-wlr'
abbr sfpro dconf write /org/gnome/desktop/interface/font-name \"\'SF Pro Display 16\'\"
abbr nobg dconf write /org/gnome/desktop/background/picture-uri \"\'file://$conf/nothing.png\'\"
abbr customcss "sudo chown -R $(whoami) $(which code) && sudo chown -R $(whoami) /opt/visual-studio-code"
abbr vscode "cp $vs/code-flags.conf ~/.config && cp $vs/settings.json ~/.config/Code/User && cp $vs/markdown.css /opt/visual-studio-code/resources/app/extensions/markdown-language-features/media/"

abbr nasmount sudo mount -t nfs 192.168.2.50:/volume1/01_TempData ~/asilla
abbr nasmount2 sudo mount -t nfs 192.168.2.50:/volume2/02_SafeData ~/asilla
abbr nasumount sudo umount ~/asilla

alias l='lsd -l $hide && echo'
alias ll='lsd -lA $hide $hidedot && echo'
alias mocp='mocp -T /usr/share/moc/themes/transparent-background'
alias v="neovide --neovim-bin (which lvim) --multigrid --maximized --frame none"

function center
    printf "$argv" | awk -v w=$width '{printf "%" int((w - length($0)) / 2) "s%s\n", "", $0}' | dotacat
end

function fish_prompt
    # tput cup (math $height - 2) 0
    echo -n (string replace $HOME '~' $PWD)' '
end

function fish_greeting
    # clear
    center $disk_percent'   '$num_pac'   '$linux_version'   '$thetime
    cal | head -n -1 | awk -v w=$width '{printf "%" int((w - length($0)) / 2) "s%s\n", "", $0}' | awk -v d=$(date +%e) '{gsub(" "(d)" ", "\033[7m "d" \033[27m"); print}' | dotacat
    center Hello, I\'m Huy\nHave a nice day!
    micromamba activate
end

# function on_exit --on-event fish_exit # this is dangerous
#   kill -9 (ps aux | grep -e neovide -e fish | awk '{print $2}')
# end

function cdls --on-variable PWD
    l
end

function cl
    micromamba clean --all
    rm -rf (string match --invert ~/.cache/huggingface ~/.cache/*) /tmp/* ~/.config/BraveSoftware/Brave-Browser/Default/History ~/.config/BraveSoftware/Brave-Browser/Default/Service\ Worker/ ~/.nv ~/__pycache__ ~/.Rhistory ~/.bash_history ~/.lesshst ~/.local/share/fish/fish_history ~/.mysql_history ~/.python_history ~/.pythonhist ~/.sqlite_history ~/.viminfo
    sudo pacman -Rns (pacman -Qdttq) && pacman -Scc && rm -rf /var/cache/ /var/lib/systemd/coredump/
    fish
end

function listenyt -a url
    youtube-dl -f bestaudio $url -o - 2>/dev/null | ffplay -nodisp -autoexit -i - &>/dev/null
end

function mamall
    echo micromamba install (micromamba env export --from-history -n base | grep -A 1000 'es:' | awk '{print $2}' | grep . | sort) -c conda-forge -n base
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
