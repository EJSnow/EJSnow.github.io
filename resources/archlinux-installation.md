---
layout: page.html
title: Arch Linux Installation (with full disk encryption using TPM2 and Secure Boot)
date: 2026-01-31
lastUpdated: Mar 6, 2026
toc: true
tags: resource
---

My preferred route for installing Arch Linux including full disk encryption (with TPM2-based automatic unlocking!) and Secure Boot support. This mostly exists just in case I ever have to do a full reinstall/just because I want to fully document my installation route.

<!-- excerpt -->

**Important:** This is my own personalized installation guide for personal use. I do not recommend following this if you aren't me. Use the [official installation](https://wiki.archlinux.org/title/Installation_guide) guide instead.

This setup uses systemd-boot as the bootloader and boots from a signed unified kernel image (UKI) incorporating the kernel image, initrd, and kernel commandline in one file to reduce complexity (as a side benefit, the initrd and kernel commandline are also validated by Secure Boot).

## Warming up

[Download the latest ISO](https://archlinux.org/download) and follow the instructions on that page to verify it. Then put it on a USB drive to boot it either using [Ventoy](https://ventoy.net/) or by writing it directly to the USB drive (see the [relevant Arch](https://wiki.archlinux.org/title/USB_flash_installation_medium)Wiki page for more info).

Boot the installation media. After it boots up, you'll be greeted by the ArchISO prompt:![The Arch Linux installer](/images/arch-installer.png) The Arch Linux ISO doesn't support Secure Boot, so it must be disabled before booting it.

Set the console font if necessary (for example on not-quite-HiDPI laptop screens) and ensure you have Internet access as described in the [installation guide](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet).

## Partitioning

See the [installation guide](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks) and [Partitioning#Partition scheme](https://wiki.archlinux.org/title/Partitioning#Partition_scheme) for more details.

Below is my preferred partitioning scheme (GPT/UEFI). I use swap on zram and a larger swap file for hibernation (if hibernation is desired). Also note that for an NVME drive the partitions will be `/dev/nvme0n1p1` for the ESP and `/dev/nvme0n1p2` for the root partition. I honestly don't put too much stock in the partition numbers though since they often end up being completely different due to dual-booting shenaniganery. Use `lsblk` to ensure you've got the partitions straight :)

|Mount point|Partition|Partition type GUID|Suggested size|
|---|---|---|---|
|`/efi`|`/dev/sda1`|`C12A7328-F81F-11D2-BA4B-00A0C93EC93B`: EFI system partition (`uefi` alias in fdisk)|250MiB-1GiB|
|`/`|`/dev/sda2`|`4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709`: Linux x86_64 root|Remainder of the drive.|

Create the partitions using, e.g, [fdisk](https://wiki.archlinux.org/title/Fdisk). Obviously **all data on the drive will be erased** so take appropriate precautions.

The root partition can be [encrypted](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LUKS_on_a_partition_with_TPM2_and_Secure_Boot) now using LUKS2. After booting into the new installation you can enroll your TPM2, generate a secure recovery key, and erase the password you create here.

```sh
# cryptsetup luksFormat /dev/sda2
# cryptsetup open /dev/sda2 root
```

Now the unlocked root partition can be formatted as ext4 (although other filesystems can be used).

```sh
# mkfs.ext4 -L "Arch Linux" /dev/mapper/root
```

The ESP has to be formatted as FAT32, unless re-using an existing one, then don't format it.

```sh
# mkfs.fat -F 32 -n "EFI" /dev/sda1
```

Mount the unlocked root partition to `/mnt` and the ESP to `/mnt/efi`.

## Installing the base system

Generally refer to the [official](https://wiki.archlinux.org/title/Installation_guide#Installation) installation guide for this part. The following reflector command can be used to generate a good mirrorlist for the US:

```sh
# reflector --latest 10 --sort rate --country 'United States' --save /etc/pacman.d/mirrorlist
```

Anyways time to `pacstrap` the system. Suggested packages to install here (my choices plus some things beyond what the installation guide suggests):

* `base-devel` for AUR packages and possibly other shenanigans
* Userspace filesystem utilities: At a minimum, `dosfstools`, `e2fsprogs`, and `exfatprogs`. `ntfs-3g` might be wanted for NTFS (note that the kernel has a native NTFS driver now so `ntfs-3g` is only required for creating/modifying NTFS's). If I ever get into Btrfs, obviously `btrfs-progs`.
* I use `networkmanager` for network/Internet access
* Always `fastfetch` for good luck ;)

## Configuration

It's now time to perform initial configuration of your installation.

Back in the day you had to generate `/etc/fstab` to handle partition mounting on boot but Systemd can [automount partitions](https://wiki.archlinux.org/title/Systemd#GPT_partition_automounting) when they have the correct types (shown above in the partition layout). So you can skip generating it and continue on in the [chroot](https://wiki.archlinux.org/title/Installation_guide#Chroot).

I skipped setting up a swap space when partitioning since I use swap on zram and this is best set up at this stage once we're in the chroot. The easiest way to set this up is to install `zram-generator` and create `/etc/systemd/zram-generator.conf` with the following:

```
[zram0]
```

Yes, that's literally it.

For [hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation) support (swap on zram doesn't support hibernation), create a [swap file](https://wiki.archlinux.org/title/Swap#Swap_file) that is half the size of your RAM to start with. I rarely use hibernation though and it's best to avoid it entirely when dualbooting since that causes all sorts of weirdness.

Follow the installation [guide](https://wiki.archlinux.org/title/Installation_guide#Time) from the "Time" section up until "Initramfs". I use systemd-timesyncd for time synchronization. For the "Network configuration" section, enable `NetworkManager.service` and install/enable `firewalld`.

As far as user accounts go, I prefer to lock the root account (preventing you from logging into it) and rely on sudo for root access. Sudo should already be installed (it's a dependency of `base-devel`). [Configure it](https://wiki.archlinux.org/title/Sudo#Configuration) to give members of the `wheel` group admin privileges. Then add a [user account](https://wiki.archlinux.org/title/Users_and_groups#User_management) that is in the `wheel` group and set a password for it. Finally [lock the](https://wiki.archlinux.org/title/Sudo#Disable_root_login) root account.

Also set up [Plymouth](https://wiki.archlinux.org/title/Plymouth).

### Desktop environment

I currently use KDE Plasma because it's epic. Other supported DEs can be found on the [Desktop Environment](https://wiki.archlinux.org/title/Desktop_environment) ArchWiki page.

To install a fully featured KDE Plasma session with my preferred KDE apps + Firefox as the web browser, run the following command:

```sh
# pacman -S plasma-meta kde-system-meta plymouth-kcm baloo-widgets breeze5 dolphin-plugins ffmpegthumbs kdeconnect kdegraphics-thumbnailers kdenetwork-filesharing kimageformats kio-admin kio-extras kio-fuse kwalletmanager phonon-qt6-vlc plasma5-integration qqc2-desktop-style icoutils iio-sensor-proxy libappindicator noto-fonts-emoji power-profiles-daemon qt6-imageformats thermald xdg-desktop-portal-gtk xsettingsd ark dragon elisa filelight gwenview kamoso kate kcalc kcharselect kdialog konsole kup kwalletmanager markdownpart okular svgpart firefox
```

Don't forget to enable `plasmalogin.service` to actually boot into a graphical session.

For graphics drivers consult this handy table for Intel and AMD graphics (note that `mesa` which provides the basic graphics stack and OpenGL drivers is required by Plasma so is already installed):

|GPU brand:|Required packages for Vulkan and hardware video acceleration:|
|---|---|
|AMD|`vulkan-radeon` (hardware video acceleration is built into mesa)|
|Intel|`vulkan-intel` (Only supports Broadwell and newer GPUs)<br>`intel-media-driver` (Broadwell and newer, recommended)<br>`libva-intel-driver` (GMA 4500 through Coffee Lake, legacy driver)<br>For QuickSync video, install `libvpl` and one of these packages depending on your hardware:<br>`vpl-gpu-rt` (Tiger Lake and newer)<br>`intel-media-sdk` (Broadwell through Ice Lake)|

While it's unlikely I will ever use an Nvidia GPU, if I do end up with one, see the [Nvidia page on](https://wiki.archlinux.org/title/NVIDIA) the ArchWiki.

### Kernel/initramfs config

In order to boot successfully, make sure the `HOOKS` array in `mkinitcpio.conf` contains the following:

```
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems plymouth)
```

The `fsck` hook is skipped because systemd provides its own filesystem checking mechanism and it keeps the console output while booting to a minimum.

Follow the instructions at [Unified kernel image#mkinitcpio](https://wiki.archlinux.org/title/Unified_kernel_image#mkinitcpio) to set up UKI generation. Do not regenerate the initramfs after finishing, as the required directory on the ESP hasn't been created yet. For the kernel command line create `/etc/cmdline.d/silent.conf` containing the following:

```
quiet loglevel=3 systemd.show_status=auto rd.udev.log_level=3 splash"
```

And `/etc/cmdline.d/disable-zswap.conf` since we're using swap on zram:

```
zswap.enabled=0
```

Systemd's GPT partition automounting mechanism will automatically find, unlock, and mount the root partition, don't worry about it.

## Finishing up

There's only a couple more steps!

Install [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) as the bootloader. Systemd-boot automatically picks up UKIs on the ESP, so no further configuration is required to boot. At this point, you can regenerate the initramfs as well (which will build a UKI and place it on the ESP).

At this point we need to get Secure Boot enabled, so it's time to reboot into the new installation. Make a quick detour into the BIOS to put Secure Boot in setup mode so keys can be enrolled. After logging in to the new install, make a fastfetch screenshot for good luck before proceeding.

I use the method described [here](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Assisted_process_with_sbctl) for enabling Secure Boot.

Once Secure Boot is enabled, now we can enlist the help of the TPM2 to ensure a smooth boot process with no pesky password prompts to unlock the root partition. Use [`systemd-cryptenroll`](https://wiki.archlinux.org/title/Systemd-cryptenroll) to add a recovery key, enroll the TPM2, and wipe the password created earlier:

```sh
$ sudo systemd-cryptenroll /dev/sda2 --recovery-key
$ sudo systemd-cryptenroll /dev/sda2 --wipe-slot=password --tpm2-device=auto --tpm2-pcrs=7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000
```

The TPM2 will release the key as long as the Secure Boot state hasn't been tampered with. If it doesn't, the system will prompt for the recovery key. Make sure to save it somewhere safe otherwise it won't be very useful.

Reboot to make sure everything works.

### Finishing touches

Now it's time to put some finishing touches on the installation. I use yay as my AUR helper, which supports the [Apdatifier](https://github.com/exequtic/apdatifier) plasmoid (which can do some basic package management stuff but most importantly makes it way easier to keep your system up to date).

To install yay, open a terminal and navigate to a directory where you won't mind having an AUR package compiled. Your user account needs read/write permissions on it. Then run the following:

```sh
$ git clone https://aur.archlinux.org/yay.git && cd yay
$ makepkg -sci
```

I also like to add the [Chaotic-AUR](https://aur.chaotic.cx/) repository to my systems as it provides prebuilt AUR packages. It doesn't provide *every* AUR package but it provides quite a few and is nice to have.

Now, here's all the other apps I like to install: 

```sh
$ yay -S --needed digikam discord easyeffects ghostwriter goverlay kdenlive keepassxc krita ktorrent lact libreoffice-fresh mangohud modrinth-app-bin obs-studio octopi spotify steam visual-studio-code-bin
```

And finally my Plasma dotfiles. Follow the instructions on [the repository](https://github.com/EJSnow/dotfiles) and that will about do it (currently the panel layout isn't done automatically though).![My Arch setup](/images/my-arch-setup.jpg)

## References

I wrote this with the help of MANY ArchWiki pages and a few manpages. Seriously the ArchWiki is amazing, go [check it out](https://wiki.archlinux.org).

* [The official installation guide](https://wiki.archlinux.org/title/Installation_guide) (The basic skeleton for this page)
* [This example for encrypting your installation](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LUKS_on_a_partition_with_TPM2_and_Secure_Boot) (I basically lifted the encryption instructions from there)
* [mkfs.ext4 manpage](https://man.archlinux.org/man/mkfs.ext4.8.en) (mostly for adding a filesystem label when formatting)
* [mkfs.fat manpage](https://man.archlinux.org/man/mkfs.fat.8.en) (Same as above)
* [Reflector examples](https://man.archlinux.org/man/reflector.1#EXAMPLES) (Used this to build the mirrorlist generator command)
* [Swap on zram](https://wiki.archlinux.org/title/Zram#Usage_as_swap)
* [Hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation)
* [AMD graphics (AMDGPU)](https://wiki.archlinux.org/title/AMDGPU) (For the required packages table in [#Desktop Environment](#desktop-environment))
* [Intel graphics](https://wiki.archlinux.org/title/Intel_graphics) (same as above)
* [Hardware video acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration) (Same as above lol)
* [Installing AUR packages](https://wiki.archlinux.org/title/Arch_User_Repository#Installing_and_upgrading_packages) (For installing yay at the very end)
