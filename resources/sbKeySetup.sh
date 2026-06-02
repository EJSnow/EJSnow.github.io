#!/bin/bash
# A Secure Boot key generator and enroller for Arch Linux. Includes Microsoft's keys for safety
# (not including them can soft-brick systems whose GPUs have signed OpROMs).

# This needs sudo and curl.

echo "Before continuing, make sure Secure Boot is in setup mode."
echo ""
echo "Otherwise this script won't do much."

echo "Installing dependencies..."
sudo pacman -S --needed efitools sbsigntools curl
# These packages are needed to generate and enroll keys

echo -n "Enter an identifying name to embed in your keys: "
read name

echo "Creating user keys..."
mkdir ~/secure-boot-keys && cd ~/secure-boot-keys
uuidgen --random > GUID.txt

openssl req -newkey rsa:4096 -noenc -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=$name PK/" -out PK.crt
openssl req -newkey rsa:4096 -noenc -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=$name KEK/" -out KEK.crt
openssl req -newkey rsa:4096 -noenc -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=$name db/" -out db.crt

cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl
cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl
cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl

sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK /dev/null noPK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth

echo "Downloading Microsoft's public keys..."
# Download Microsoft's public keys
curl -L -o microsoft-windows-production-pca-2011.crt https://www.microsoft.com/pkiops/certs/MicWinProPCA2011_2011-10-19.crt
curl -L -o windows-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/windows%20uefi%20ca%202023.crt
curl -L -o microsoft-corporation-uefi-ca-2011.crt https://www.microsoft.com/pkiops/certs/MicCorUEFCA2011_2011-06-27.crt
curl -L -o microsoft-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20uefi%20ca%202023.crt
curl -L -o microsoft-option-rom-uefi-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20option%20rom%20uefi%20ca%202023.crt
curl -L -o microsoft-corporation-kek-ca-2011.crt https://www.microsoft.com/pkiops/certs/MicCorKEKCA2011_2011-06-24.crt
curl -L -o microsoft-corporation-kek-2k-ca-2023.crt https://www.microsoft.com/pkiops/certs/microsoft%20corporation%20kek%202k%20ca%202023.crt

echo "Preparing Microsoft db and KEK additions..."
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_db_2011.esl microsoft-windows-production-pca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_db_2023.esl windows-uefi-ca-2023.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_UEFI_db_2011.esl microsoft-corporation-uefi-ca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_UEFI_db_2023.esl microsoft-uefi-ca-2023.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_OpROM_UEFI_db_2023.esl microsoft-option-rom-uefi-ca-2023.crt
cat MS_Win_db_2011.esl MS_Win_db_2023.esl MS_UEFI_db_2011.esl MS_UEFI_db_2023.esl MS_OpROM_UEFI_db_2023.esl > MS_db.esl
rm microsoft-windows-production-pca-2011.crt windows-uefi-ca-2023.crt microsoft-corporation-uefi-ca-2011.crt microsoft-uefi-ca-2023.crt microsoft-option-rom-uefi-ca-2023.crt

sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_KEK_2011.esl microsoft-corporation-kek-ca-2011.crt
sbsiglist --owner 77fa9abd-0359-4d32-bd60-28f4e78f784b --type x509 --output MS_Win_KEK_2023.esl microsoft-corporation-kek-2k-ca-2023.crt
cat MS_Win_KEK_2011.esl MS_Win_KEK_2023.esl > MS_Win_KEK.esl
rm microsoft-corporation-kek-ca-2011.crt microsoft-corporation-kek-2k-ca-2023.crt

sign-efi-sig-list -a -g 77fa9abd-0359-4d32-bd60-28f4e78f784b -k KEK.key -c KEK.crt db MS_db.esl add_MS_db.auth
sign-efi-sig-list -a -g 77fa9abd-0359-4d32-bd60-28f4e78f784b -k PK.key -c PK.crt KEK MS_Win_KEK.esl add_MS_Win_KEK.auth

chmod 0600 *.key

echo ""
echo "Creating keystore in /etc/secureboot/keys"
sudo mkdir -p /etc/secureboot/keys/{db,KEK,PK}
sudo cp PK.auth /etc/secureboot/keys/PK/
sudo cp *KEK.auth /etc/secureboot/keys/KEK/
sudo cp *db.auth /etc/secureboot/keys/db/

echo "Enrolling keys in UEFI..."

sudo sbkeysync --keystore /etc/secureboot/keys --verbose
sudo sbkeysync --keystore /etc/secureboot/keys --verbose --pk
if ! $? == 0; then {
    echo "Key enrollment failed. Make sure Secure Boot is in setup mode and try again."
    echo "If you keep seeing errors with the platform key specifically, try running:"
    echo "# efi-updatevar -f /etc/secureboot/keys/PK/PK.auth PK"
}

echo "Copying db key to /etc/secureboot"
sudo cp db.key /etc/secureboot/
sudo cp db.crt /etc/secureboot/

echo "Finished! Check console output above for errors, otherwise continue with signing"
echo "your kernel and bootloader."
