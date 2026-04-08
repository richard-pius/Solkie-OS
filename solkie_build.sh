#!/bin/bash

# ==========================================
# 1. REPOSITORIES & KEYS
# ==========================================
# Native Firefox (Mozilla PPA)
add-apt-repository ppa:mozillateam/ppa -y

# VSCodium GPG Key & Repo
wget -qO - https://download.vscodium.com/debs/vscodium.gpg | gpg --dearmor | tee /usr/share/keyrings/vscodium.gpg > /dev/null
echo 'deb [ signed-by=/usr/share/keyrings/vscodium.gpg ] https://download.vscodium.com/debs vscodium main' | tee /etc/apt/sources.list.d/vscodium.list

# Pin Firefox to prevent Snap re-installation
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=ubuntu
Pin-Priority: -1
' | tee /etc/apt/preferences.d/mozilla-firefox

apt update

# ==========================================
# 2. SOFTWARE REMOVAL & INSTALLATION
# ==========================================
# Remove VS Code and Bloat
apt purge -y code thunderbird libreoffice*
apt autoremove -y

# Install Core Apps & Dev Stack
apt install -y firefox codium python3-pip rustc default-jdk mongodb-org

# ==========================================
# 3. IDENTITY & BRANDING (The "Solkie" Look)
# ==========================================
# Set Hostname
echo "solkie-os" > /etc/hostname

# Update OS Release files
cat <<EOF > /etc/os-release
NAME="Solkie OS"
VERSION="1.0 (Noble)"
ID=solkie
ID_LIKE=ubuntu
PRETTY_NAME="Solkie OS 1.0"
VERSION_ID="24.04"
HOME_URL="https://github.com/richard-pius/Solkie-OS"
SUPPORT_URL="https://github.com/richard-pius/Solkie-OS/issues"
BUG_REPORT_URL="https://github.com/richard-pius/Solkie-OS/issues"
PRIVACY_POLICY_URL="https://github.com/richard-pius/Solkie-OS"
VERSION_CODENAME=noble
UBUNTU_CODENAME=noble
EOF

# Update Login Banner
echo "Solkie OS 1.0 \n \l" > /etc/issue

# ==========================================
# 4. BACKGROUND & BOOT LOGO
# ==========================================
# NOTE: Replace the URLs below with your actual GitHub raw image links
# Replace the system wallpaper
wget -O /usr/share/backgrounds/solkie-wallpaper.png https://raw.githubusercontent.com/richard-pius/Solkie-OS/main/branding/wallpaper.png
# Replace the boot/system logo
wget -O /usr/share/pixmaps/ubuntu-logo.png https://raw.githubusercontent.com/richard-pius/Solkie-OS/main/branding/logo.png

# Create the wallpaper override
cat <<EOF > /usr/share/glib-2.0/schemas/99_solkie_wallpaper.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/solkie-wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/solkie-wallpaper.png'
picture-options='zoom'

[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/solkie-wallpaper.png'
EOF

# Compile schemas to apply the wallpaper
glib-compile-schemas /usr/share/glib-2.0/schemas/

# ==========================================
# 5. FINAL POLISH & CLEANUP
# ==========================================
# Rebrand VSCodium in the menu
sed -i 's/Exec=\/usr\/bin\/codium/Exec=\/usr\/bin\/codium --no-sandbox/g' /usr/share/applications/codium.desktop
sed -i 's/Name=VSCodium/Name=Solkie Code Editor/g' /usr/share/applications/codium.desktop

# Wipe machine-specific IDs
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

apt clean
history -c
