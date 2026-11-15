grub := `if [ -d /boot/grub2 ] && [ ! -d /boot/grub ]; then echo /boot/grub2; else echo /boot/grub; fi`

default:
    @just --list

# Install the theme non-interactively and regenerate grub.cfg
install:
    sudo ./install_theme.sh --yes
    sudo sh -c 'if [ -d /boot/grub ]; then grub-mkconfig -o /boot/grub/grub.cfg; else grub2-mkconfig -o /boot/grub2/grub.cfg; fi'

# Update splash text, background and package count
update:
    sudo python3 {{grub}}/themes/minegrub/update_theme.py

# Install and enable the systemd update service
service-install:
    sudo cp -uv minegrub-update.service /etc/systemd/system/
    sudo systemctl enable minegrub-update.service

# Remove the installed theme (then drop GRUB_THEME and regenerate grub.cfg)
uninstall:
    sudo rm -rf {{grub}}/themes/minegrub
