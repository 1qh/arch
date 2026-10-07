set dc "dconf write /org/gnome/desktop/interface"
abbr theme "$dc/color-scheme \"'prefer-dark'\" && $dc/gtk-theme \"'Materia-dark-compact'\" && $dc/font-name \"'SF Pro 16'\""

abbr burn --set-cursor sudo dd bs=4M if=% of=/dev/sda conv=fsync oflag=direct status=progress
abbr cammax "v4l2-ctl -d /dev/video0 --list-formats-ext | rg Size: | tail -1 | awk '{print \$NF}'"
abbr camtest exec yolo track source=0 show=True
abbr listen --set-cursor "yt-dlp -f ba '%' -o - 2>/dev/null | ffplay -loop 9 -nodisp -autoexit -i - &>/dev/null"
abbr owncode "sudo chown -R $(whoami) /usr/share/code"
abbr pow poweroff
abbr usb sudo mount /dev/sda1 ~/usb
abbr vpndisconnect openvpn3 session-manage --disconnect -c ~/my.ovpn
abbr vpnlist openvpn3 sessions-list
abbr vpnstart openvpn3 session-start -c ~/my.ovpn
abbr win 'sudo virsh start win11; exec remote-viewer spice://localhost:5900'

alias code 'code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=wayland'

abbr dusteam dua i ~/.local/share/Steam/steamapps/compatdata
if test -d ~/Desktop
    set -l shortcuts ~/Desktop/*.desktop
    if set -q shortcuts[1]
        abbr pool steam-native steam://rungameid/(cat ~/Desktop/*.desktop | rg rungameid | cut -d "/" -f 4)
    end
end
