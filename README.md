# minegrub-theme
A Grub Theme in the style of Minecraft!

![Minegrub Preview "Screenshot"](preview_minegrub.png)

### How do i install it??
- just `cd /boot/grub/themes/` and do `git clone https://github.com/Lxtharia/minegrub-theme.git` 
- change/add this line in your `/etc/defaults/grub`:
```![preview_minegrub](https://user-images.githubusercontent.com/87075045/205452695-5eb382d7-fc3a-4e7e-97e7-461a3c036474.png)

GRUB_THEME=/boot/grub/themes/minegrub-theme/theme.txt
```
- update your live grub config by running `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- your good to go

### Important Notes:
- When you have more/less than 4 boot options, you might want to adjust the height of the bottom bar (that says "Options" and "Console")
- The formula is in the theme.txt, so you should be able to easily adjust it.

### Notes:
- the `GRUB_TIMEOUT_STYLE` in the defaults/grub file should be set to `menu` so it immediately shows the menu (else you would need to press ESC and you dont want that)
- im no linux expert, thats why i explain it so thoroughly, for other newbies :>
- i use arch btw
- i hope u like it, cause i sure do lmao


Font downloaded from https://www.fontspace.com/minecraft-font-f28180 and used for non commercial use.
