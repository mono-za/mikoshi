#!/usr/bin/env bash

# Exit on errors, undefined variables, and pipe failures
set -oue pipefail

# Add the negativo17 Fedora multimedia repository
curl -Lo /etc/yum.repos.d/negativo17-fedora-multimedia.repo https://negativo17.org/repos/fedora-multimedia.repo
sed -i '0,/enabled=1/{s/enabled=1/enabled=1\npriority=90/}' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# Define the packages to override/replace
PACKAGES=(
  libheif
  libva
  libva-intel-media-driver
  mesa-dri-drivers
  mesa-filesystem
  mesa-libEGL
  mesa-libGL
  mesa-libgbm
  mesa-libglapi
  mesa-libxatracker
  mesa-va-drivers
  mesa-vulkan-drivers
  gstreamer1-plugin-libav
  gstreamer1-plugin-vaapi
)

# Remove existing conflicting packages
for pkg in "${PACKAGES[@]}"; do
  echo "Attempting to remove $pkg..."
  rpm-ostree override remove "$pkg" || echo "Warning: Failed to remove $pkg. Continuing..."
done

# Override and replace packages
echo "Starting package override/replace..."
rpm-ostree override replace \
  --experimental \
  --from repo='fedora-multimedia' \
  "${PACKAGES[@]}" || echo "Warning: rpm-ostree override replace encountered issues. Continuing..."
