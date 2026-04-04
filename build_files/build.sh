#!/bin/bash

set -ouex pipefail

### Kernel - update from testing repo (MES hang fix)

# Remove version lock, old kmods, and update kernel from testing repo
dnf5 versionlock delete kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra || true
dnf5 -y remove \
    kmod-framework-laptop framework-laptop-kmod-common \
    kmod-v4l2loopback v4l2loopback || true
dnf5 -y --enablerepo=updates-testing --setopt=tsflags=noscripts update \
    kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-devel-matched
dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
ARCH="$(uname -m)"
RELEASE="$(rpm -E '%fedora')"

# Build kmods against new kernel
chmod 1777 /tmp
dnf5 -y install akmods
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

# Install akmod source packages
dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${RELEASE}".noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${RELEASE}".noarch.rpm
dnf5 -y --setopt=tsflags=noscripts install \
    akmod-framework-laptop-*.fc"${RELEASE}"."${ARCH}" \
    akmod-v4l2loopback-*.fc"${RELEASE}"."${ARCH}"

# Build and verify kmods
for kmod in framework-laptop v4l2loopback; do
    akmods --force --kernels "${KERNEL}" --kmod "${kmod}"
    find /var/cache/akmods/"${kmod}"/ -name \*.log -print -exec cat {} \;
done
modinfo /usr/lib/modules/"${KERNEL}"/extra/framework-laptop/framework_laptop.ko.xz > /dev/null
modinfo /usr/lib/modules/"${KERNEL}"/extra/v4l2loopback/v4l2loopback.ko.xz > /dev/null

# Install built kmods
dnf5 -y install \
    /var/cache/akmods/framework-laptop/kmod-framework-laptop-*.rpm \
    /var/cache/akmods/v4l2loopback/kmod-v4l2loopback-*.rpm \
    framework-laptop-kmod-common \
    v4l2loopback
# Clean up build dependencies
dnf5 -y remove \
    rpmfusion-free-release rpmfusion-nonfree-release \
    akmod-framework-laptop akmod-v4l2loopback \
    akmods \
    kernel-devel kernel-devel-matched
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
rm -rf /var/cache/akmods

### Packages

INCLUDED_PACKAGES=(
  git-delta
  gnome-shell-extension-dash-to-panel
  )

EXCLUDED_PACKAGES=(
  gnome-shell-extension-apps-menu
  gnome-shell-extension-dash-to-dock
  gnome-shell-extension-logo-menu
  gnome-shell-extension-places-menu
  gnome-shell-extension-window-list
  )

dnf5 -y install "${INCLUDED_PACKAGES[@]}"

readarray -t EXCLUDED_PACKAGES < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}")

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y remove "${EXCLUDED_PACKAGES[@]}"
else
    echo "No packages to remove."
fi

### Plymouth

# remove logo
rm /usr/share/plymouth/themes/spinner/*watermark.png

# rebuild initramfs
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

### Cleanup
dnf clean all
rm -r /var/lib/dnf
