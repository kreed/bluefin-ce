#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Packages

dnf5 -y copr enable kreed/quad9ctl

INCLUDED_PACKAGES=(
  gnome-shell-extension-quad9
  kitty-terminfo
  quad9ctl
  )

dnf5 -y install "${INCLUDED_PACKAGES[@]}"
dnf5 -y copr disable kreed/quad9ctl

### dconf

# Compile /etc/dconf/db/*.d/ overrides shipped in system_files/
dconf update

### GNOME Shell extensions

# Enable the Quad9 quick-settings extension by default. The base image sets
# its own enabled-extensions default in a gschema override, and overrides
# replace rather than merge, so append to whichever list currently wins:
# glib compiles overrides in sorted filename order and the last wins, hence
# the zz9 prefix and the matching sorted() scan below. The winning section is
# preserved because the key may live in a session-scoped section like
# [org.gnome.shell:GNOME].
python3 - <<'EOF'
import ast, configparser, glob, os

OWN = "/usr/share/glib-2.0/schemas/zz9-bluefin-ce.gschema.override"
UUID = "quad9@kreed.github.io"

section, extensions = "org.gnome.shell", []
for path in sorted(glob.glob("/usr/share/glib-2.0/schemas/*.override")):
    if path == OWN:  # ignore our own output when the build layer is re-run
        continue
    config = configparser.ConfigParser(interpolation=None, strict=False)
    config.read(path)
    for candidate in config.sections():
        if candidate == "org.gnome.shell" or candidate.startswith("org.gnome.shell:"):
            if config.has_option(candidate, "enabled-extensions"):
                value = config.get(candidate, "enabled-extensions")
                # GVariant text allows an optional type prefix Python doesn't.
                value = value.removeprefix("@as").strip()
                section, extensions = candidate, ast.literal_eval(value)

if UUID not in extensions:
    extensions.append(UUID)
with open(OWN, "w") as f:
    f.write("[%s]\nenabled-extensions=%r\n" % (section, extensions))
EOF
glib-compile-schemas /usr/share/glib-2.0/schemas

### Plymouth

# remove logo
rm -f /usr/share/plymouth/themes/spinner/*watermark.png

# rebuild initramfs
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

### Nix

# Empty mountpoint for the Determinate installer's nix.mount; it can't be
# created at runtime on a composefs (read-only /) system. See
# https://github.com/DeterminateSystems/nix-installer/issues/1445
mkdir /nix
