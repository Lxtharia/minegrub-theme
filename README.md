# minegrub-theme
A Grub Theme in the style of Minecraft!


![Minegrub Preview "Screenshot"](preview_minegrub.png)

### How do i install it??
- `cd /boot/grub2/themes/` and do `git clone https://github.com/Lxtharia/minegrub-theme.git` 
- change/add this line in your `/etc/default/grub`:
```
GRUB_THEME=/boot/grub2/themes/minegrub-theme/theme.txt
```
- update your live grub config by running `sudo grub-mkconfig -o /boot/grub2/grub.cfg`
- your good to go

### Important Notes:
- When you have more/less than 4 boot options, you might want to adjust the height of the bottom bar (that says "Options" and "Console")
- The formula is in the theme.txt, so you should be able to easily adjust it.

### Notes:
- your grub folder might not be called `/boot/grub2/` but only `/boot/grub/`, in any case, grub should be version 2
- the `GRUB_TIMEOUT_STYLE` in the defaults/grub file should be set to `menu` so it immediately shows the menu (else you would need to press ESC and you dont want that)
- im no linux expert, thats why i explain it so thoroughly, for other newbies :>
- i use arch btw
- i hope u like it, cause i sure do lmao

#### Thanks to
- https://github.com/toboot for giving me this wonderful idea!
- the internet for giving me wisdom lmao


Font downloaded from https://www.fontspace.com/minecraft-font-f28180 and used for non commercial use.
