Apple iBridge and Touch Bar Linux Driver
=======================================

Out-of-tree kernel modules for Apple iBridge-based Touch Bar support, focused on modern Linux kernels (including Arch Linux).

This repository currently builds two modules:

- apple-ibridge: exposes virtual HID devices for iBridge collections (Touch Bar + ALS related paths)
- apple-touchbar: handles Touch Bar mode selection, brightness state, idle/dim logic, and Fn-row translation

Build (local)
-------------

1. Install build dependencies on Arch Linux:

	sudo pacman -S --needed base-devel linux-headers

2. Build modules:

	make

3. Load modules:

	sudo modprobe apple-ibridge
	sudo modprobe apple-touchbar
Validation
----------

Run the smoke test to validate strict build quality and required upstream
submission artifacts:

	make test

DKMS (recommended on Arch)
--------------------------

Using DKMS keeps modules rebuilt automatically after kernel updates.

1. Install DKMS tooling:

	sudo pacman -S --needed dkms base-devel linux-headers

2. Register this source tree in /usr/src (example version 0.1):

	sudo mkdir -p /usr/src/apple-touchbar-0.1
	sudo rsync -a --delete ./ /usr/src/apple-touchbar-0.1/

3. Build and install with DKMS:

	sudo dkms install -m apple-touchbar -v 0.1

4. Load modules:

	sudo modprobe apple-ibridge
	sudo modprobe apple-touchbar

macOS-like Touch Bar behavior on Arch
-------------------------------------

The driver defaults are now tuned to feel closer to macOS out of the box:

- Special keys by default, function keys while Fn is pressed
- Display dims first, then turns off after inactivity (default dim at 60s, off at 90s)
- F3/F4 are mapped to modern Linux desktop actions when available

Recommended persistent module options:

1. Create /etc/modprobe.d/apple-touchbar.conf with:

	options apple-touchbar fnmode=1 dim_timeout=60 idle_timeout=90

2. Reload the module (or reboot):

	sudo modprobe -r apple-touchbar apple-ibridge
	sudo modprobe apple-ibridge
	sudo modprobe apple-touchbar

Runtime tuning via sysfs
------------------------

The driver exposes three writable attributes on the mode HID device:

- fnmode
- dim_timeout
- idle_timeout

To locate the right sysfs node:

	find /sys/devices -type f \( -name fnmode -o -name dim_timeout -o -name idle_timeout \)

Example:

	echo 1 | sudo tee /sys/devices/.../fnmode
	echo 60 | sudo tee /sys/devices/.../dim_timeout
	echo 90 | sudo tee /sys/devices/.../idle_timeout

Fn mode values
--------------

- 0: function keys only
- 1: default special keys, hold Fn for function keys (macOS-like)
- 2: inverse of mode 1
- 3: special keys only
- 4: Escape only

Special key mapping notes
-------------------------

- F1/F2: display brightness down/up
- F3: Mission Control style action (falls back to older KEY_SCALE if needed)
- F4: Launchpad / all-applications style action (falls back to older keycodes if needed)
- F7-F12: media and volume controls

Notes
-----

- Touch Bar behavior depends on desktop keybindings for translated keys.
- F3 and F4 are exposed as Mission Control / Applications style events when supported by the running kernel and userspace mapping.
- On suspend/resume, T1 devices get explicit state restoration to avoid stale display/mode states.

Upstream roadmap
----------------

- A concrete 3-stage path to prepare this project for Linux mainline submission is available in UPSTREAM_PLAN.md.
- Stage 3 submission artifacts are available in MAINTAINERS, Documentation/ABI/testing/sysfs-driver-hid-apple-touchbar, Documentation/hid/apple-touchbar.rst, and docs/upstream/.

