alias mocp 'mocp -T /usr/share/moc/themes/transparent-background'
alias v "neovide --neovim-bin (which lvim) --multigrid --maximized --frame none"

set dc "dconf write /org/gnome/desktop/interface"
abbr theme "$dc/color-scheme \"'prefer-dark'\" && $dc/gtk-theme \"'Materia-dark-compact'\" && $dc/font-name \"'SF Pro 16'\""

abbr dusteam dua i ~/.local/share/Steam/steamapps/compatdata

abbr tv teamviewer --daemon start
abbr mntwin sudo mount /dev/nvme0n1p4 ~/c
abbr usb sudo mount /dev/sda1 ~/usb
abbr win 'sudo virsh start win11; exec remote-viewer spice://localhost:5900'
abbr cammax "v4l2-ctl -d /dev/video0 --list-formats-ext | rg Size: | tail -1 | awk '{print \$NF}'"

if test -d ~/Desktop
    set -l shortcuts ~/Desktop/*.desktop
    if set -q shortcuts[1]
        abbr pool steam-native steam://rungameid/(cat ~/Desktop/*.desktop | rg rungameid | cut -d "/" -f 4)
    end
end
