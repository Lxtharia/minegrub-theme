grub := `if [ -d /boot/grub2 ] && [ ! -d /boot/grub ]; then echo /boot/grub2; else echo /boot/grub; fi`
mkconfig := if grub == "/boot/grub2" { "grub2-mkconfig" } else { "grub-mkconfig" }

default:
    @just --list

# Install the theme (interactive)
install:
    sudo ./install_theme.sh

# Choose a static background from background_options/
background:
    ./choose_background.sh

# Copy the theme to the boot partition without prompts
copy:
    sudo mkdir -p {{grub}}/themes
    sudo cp -ruv ./minegrub {{grub}}/themes/
    sudo cp -r ./button_options {{grub}}/themes/minegrub/

# Update splash text, background and package count in the installed theme
update:
    sudo python3 {{grub}}/themes/minegrub/update_theme.py

# Regenerate the grub config
mkconfig:
    sudo {{mkconfig}} -o {{grub}}/grub.cfg

# Install and enable the systemd update service
service-install:
    sudo cp -uv minegrub-update.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable minegrub-update.service

# Disable and remove the systemd update service
service-uninstall:
    sudo systemctl disable minegrub-update.service
    sudo rm -f /etc/systemd/system/minegrub-update.service
    sudo systemctl daemon-reload

# Remove the installed theme (then drop GRUB_THEME and run `just mkconfig`)
uninstall:
    sudo rm -rf {{grub}}/themes/minegrub

# Check the Nix flake
check:
    nix flake check

# Update flake inputs
flake-update:
    nix flake update
