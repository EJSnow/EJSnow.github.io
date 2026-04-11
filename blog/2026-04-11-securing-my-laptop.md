---
layout: page.html
title: Securing Twilight (my laptop)
date: 2026-04-11
lastUpdated: Apr 11, 2026
tags: blog
---

In February I decided to try to "secure" Twilight (my laptop), by enabling Secure Boot and encrypting its SSD. Now that I've pretty much finalized the setup, I thought I'd write down a detailed explanation of it. Also, welcome to the blog!<!-- excerpt --> It'll be replacing the projects section I had before, and I'll be writing posts basically whenever I feel like it. Anyways. I won't explain Secure Boot and encryption here since there are multiple good explanations out there already:

* Secure Boot: [Rodsbooks' Secure Boot article](https://www.rodsbooks.com/efi-bootloaders/secureboot.html) (Mainly the "What is Secure Boot?" section)
* Encryption: [Data-at-rest encryption - ArchWiki](https://wiki.archlinux.org/title/Data-at-rest_encryption)

I mainly just want to document my Secure Boot/disk encryption process because why not?

## Secure Booting

So the first thing I decided to set up was Secure Boot, as it seemed less risky than encrypting the SSD. I ended up generating and using my own Secure Boot keys, which has the benefit of not requiring [shim](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#shim) (used by Ubuntu, Fedora and friends) but does have some downsides; namely that some hardware has signed option ROMS and may require Microsoft's keys to be enrolled in order to work (you really only need this for GPUs and some SSDs), and forgetting to enroll Microsoft's keys is rather awkward to recover from.

### Key creation

There's a few ways to create your own keys. Me being me, I decided to go the fully manual route, and automate the resigning of the bootloader and kernel when they update. For the future, I also wrote a script to automatically generate keys (and download Microsoft's keys in case they're needed).

<details><summary><ins>Here's the script (click to expand):</ins></summary>

```bash
#!/bin/bash
# A Secure Boot key generator that also includes Microsoft's keys
# as separate .auth files.
# NOTE: efitools is needed to generate the .esl and .auth files.
# Additionally, curl and sbsigntools are needed to download and
# convert Microsoft's keys.

echo -n "Enter a common name to embed in your keys: "
read NAME

echo "Creating user keys..."
uuidgen --random > GUID.txt

openssl req -newkey rsa:4096 -noenc -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME PK/" -out PK.crt
openssl req -newkey rsa:4096 -noenc -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME KEK/" -out KEK.crt
openssl req -newkey rsa:4096 -noenc -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME db/" -out db.crt
openssl x509 -outform DER -in PK.crt -out PK.cer
openssl x509 -outform DER -in KEK.crt -out KEK.cer
openssl x509 -outform DER -in db.crt -out db.cer

cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl
cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl
cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl

sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK /dev/null noPK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth

echo "Downloading Microsoft's public keys..."
# Download Microsoft's public keys
curl -o microsoft-windows-production-pca-2011.crt https://www.microsoft.com/pkiops/certs/MicWinProPCA2011_2011-10-19.crt
curl -o windows-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/windows%20uefi%20ca%202023.crt
curl -o microsoft-corporation-uefi-ca-2011.crt https://www.microsoft.com/pkiops/certs/MicCorUEFCA2011_2011-06-27.crt
curl -o microsoft-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20uefi%20ca%202023.crt
curl -o microsoft-option-rom-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20option%20rom%20uefi%20ca%202023.crt
curl -o microsoft-corporation-kek-ca-2011.crt https://www.microsoft.com/pkiops/certs/MicCorKEKCA2011_2011-06-24.crt
curl -o microsoft-corporation-kek-2k-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20corporation%20kek%202k%20ca%202023.crt

echo "Preparing Microsoft db and KEK additions..."
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_db_2011.esl microsoft-windows-production-pca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_db_2023.esl windows-uefi-ca-2023.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_UEFI_db_2011.esl microsoft-corporation-uefi-ca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_UEFI_db_2023.esl microsoft-uefi-ca-2023.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_OpROM_UEFI_db_2023.esl microsoft-option-rom-uefi-ca-2023.crt
cat MS_Win_db_2011.esl MS_Win_db_2023.esl MS_UEFI_db_2011.esl MS_UEFI_db_2023.esl MS_OpROM_UEFI_db_2023.esl > MS_db.esl

sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_KEK_2011.esl microsoft-corporation-kek-ca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_KEK_2023.esl microsoft-corporation-kek-2k-ca-2023.crt
cat MS_Win_KEK_2011.esl MS_Win_KEK_2023.esl > MS_Win_KEK.esl

sign-efi-sig-list -a -g 77fa9abd-0359-4d32-bd60-28f4e78f784b -k KEK.key -c KEK.crt db MS_db.esl add_MS_db.auth
sign-efi-sig-list -a -g 77fa9abd-0359-4d32-bd60-28f4e78f784b -k PK.key -c PK.crt KEK MS_Win_KEK.esl add_MS_Win_KEK.auth

chmod 0600 *.key

echo ""
ls *.auth
echo -e "\nFinished creating keys and EFI signature lists.\nThe .auth files shown are ready for use."
```

</details>

I have it sitting on my laptop named `genkeys.sh`. When run it generates all the keys, and lists the .auth files that get enrolled in the UEFI.

### enrolling the keys

As is typical on Linux there's about 5 different tools to do this, but I used (or attempted to use, you'll see why later on) `sbkeysync` from `sbsigntools`.

I copied the keys to the suggested location for `sbkeysync` and arranged them in the way it expects. Then I enrolled the keys. This requires setting Secure Boot in setup mode, otherwise you can't just enroll any old keys. Additionally, the platform key must be enrolled last, since enrolling it will put Secure Boot back in user mode. So everything else is enrolled first:

```sh
# sbkeysync --keystore /etc/secureboot/keys --verbose
```

This initially failed saying "Operation not permitted", weirdly enough. However, I tried again a few minutes later, and it worked, so I guess my laptop's UEFI was just being weird. Then I tried to enroll the platform key:

```sh
# sbkeysync --keystore /etc/secureboot/keys --pk --verbose
```

Once again, I got "Operation not permitted" errors, and despite retrying multiple times, sbkeysync stubbornly refused to enroll the platform key. Fortunately, there's an alternative way:

```sh
# efi-updatevar -f /etc/secureboot/keys/PK/PK.auth PK
```

This finally worked, finishing the Secure Boot setup. After signing systemd-boot and my UKI, I rebooted, and it worked! To ensure painless upgrades, I automated kernel and bootloader resigning when they're updated. The UKI is signed when it's built by systemd-ukify and I made a pacman hook to automatically resign systemd-boot on systemd updates. 

## Encryption

Surprisingly, this wasn't that hard to do, just extremely time-consuming. The usual warnings apply: have backups, test in VMs, etc. I went with an encryption setup similar to Bitlocker's default setup on Windows: TPM2-based automatic unlocking, plus a recovery key for when the TPM2 fails me. The ESP contains boot files and has to remain unencrypted.

First, I needed to boot into a live Arch ISO since the root partition has to be unmounted before encrypting. Also, before encrypting, the filesystem (NOT the partition) needed to be shrunk to give space for a LUKS header. This is a bit of a nasty workaround to avoid having to erase the SSD before encrypting. After doing that, the root partition was ready to be encrypted using cryptsetup:

```sh
# cryptsetup reencrypt --encrypt --reduce-device-size 32M /dev/nvme0n1p5
```

This command asked for a password to unlock the partition. I entered a temporary one to satisfy it, but I wasn't going to keep it. Encrypting an existing filesystem takes a very very long time, but once it finishes, some additional system configuration was needed in order for Arch to boot.

The short version was I had to simply add the `sd-encrypt` hook to mkinitcpio's configuration (I'm using a systemd-based initramfs, which is now the default, and while you also need the `keyboard` hook to be able to enter the recovery key if it's needed, it's included in the default config). I also initally explicitly specified the root partition via kernel parameters, but I later discovered that systemd's GPT partition automounting (which I'm taking advantage of) can find and unlock the root partition without needing any kernel parameters telling it where the root is, which is extremely neat. Finally, after regenerating the initramfs, I rebooted to re-enable Secure Boot (the ISO currently doesn't support Secure Boot). Then I enrolled the TPM2, generated a strong recovery key, and removed the temporary password from before:

```sh
# systemd-cryptenroll /dev/nvme0n1p5 --recovery-key
# systemd-cryptenroll /dev/nvme0n1p5 --wipe-slot=password --tpm2-device=auto --tpm2-pcrs=12
```

The `--tpm2-pcrs` option really depends on your preference. After this, I saved the generated recovery key in a VerySafe™ location. Then I rebooted, and it did in fact unlock the root partition automatically and proceeded to boot normally.

## Conclusion

Have I achieved my goal of making my laptop more secure? I think so. To be honest, it realistically doesn't matter that much, but it was a fun learning experience, which is mostly why I did it. I haven't done all this on my PC, partly because I plan on upgrading it soon (RX 6600 incoming... 👀) and I don't want to have to transfer it all to a new system, and partly because my PC doesn't have a TPM2 because it's old (it should still be possible with a TPM1.2 though).
