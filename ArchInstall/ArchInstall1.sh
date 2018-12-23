default_values(){
	local valt
	local def
	local masik
	
	valt=$1
	def=$2
	masik=$3

	if [ "$valt" != "$def" ]; then
		if [ "$valt" != "$masik" ];then		
			valt=$def
		fi
	fi
	echo "$valt"
}

loadkeys hu
clear
echo 'I AM NOT RESPONSIBLE FOR ANYTHING IF SOMETHING GOES WRONG!'
echo 'DURING THE INSTALLATION NO OTHER DEVICES SHOULD BE PLUGGED INTO THE COMPUTER!'
echo 'THIS ONLY WORKS IF YOU ONLY WANT TO MAKE THE PARTITONS "ROOT" "SWAP" "HOME" "BOOT/EFI"'
echo 'Press any key to continue...'
read
clear

declare layout
echo 'The default layout for this installer is hungarian. Do you wish to change it to US layout?? [y, n] (default: n)'
read layout
layout=$(default_values "$layout" "n" "y")
if [ $layout == "y" ];
then
		loadkeys us
fi
clear

echo 'The system has to have UEFI mode enabled on the motherboard to get this installer to work!'
declare uefi
echo 'Are you shure that UEFI is enabled on the system? [y, n] (default: n)'
read uefi
uefi=$(default_values "$uefi" "n" "y")
if [ $uefi == "n" ];
then
		ls /sys/firmware/efi/efivars
		echo 'If the previous step returned strings then the system has UEFI, otherwise you should exit the script with CTRL+C'

fi

echo 'Press any key to continue...'
read
clear

declare network

echo 'Do you want to check if you have network connection? [y, n] (default: y)'
read network

network=$(default_values "$network" "y" "n")

if [ $network == "y" ];then
		ping -c 5 archlinux.org
		echo "If the ping was succesful you can continue, otherwise you shold fix the network first"
fi
echo 'Network time protocol enabled'
timedatectl set-ntp true
echo 'Press any key to continue...'
read
clear

echo 'Updateing repositories'
pacman -Syy
echo 'Press any key to continue...'
read
clear

cfdisk /dev/sd*
clear
fdisk -l
echo 'Press any key to continue...'
read

declare -i partitionNum
echo 'Whitch directory is the ROOT partition? [number]'
read partitionNum
mkfs.ext4 /dev/sd*"$partitionNum"
mount /dev/sd*"$partitionNum" /mnt
echo 'Whitch directory is the BOOT/EFI partition? [number]'
read partitionNum
mkdir /mnt/boot
mkfs.vfat /dev/sd*"$partitionNum"
mount /dev/sd*"$partitionNum" /mnt/boot
echo 'Whitch directory is the SWAP partition? [number]'
read partitionNum
mkswap /dev/sd*"$partitionNum"
swapon /dev/sd*"$partitionNum"
declare HOME
echo 'Do you have a HOME directory? [y, n] (default: n)'
read HOME
HOME=$(default_values "$HOME" "n" "y")
if [ $HOME == "y" ];
then
	   echo 'Whitch directory is the HOME partition? [number]'
	   read partitionNum
	   mkdir /mnt/home
	   mkfs.ext4 /dev/sd*"$partitionNum"
	   mount /dev/sd*"$partitionNum" /mnt/home
fi
echo 'Press any key to continue...'
read
clear

echo 'Copying the mirrorlist...'
rm /etc/pacman.d/mirrorlist
cp mirrorlist /etc/pacman.d
echo 'Downloading the packpages (base, base-devel)...'
pacstrap /mnt base base-devel

echo 'Press any key to continue...'
read
clear

echo 'Generateing fstab...'
genfstab -U /mnt >> /mnt/etc/fstab

cp ArchInstall2.sh /mnt/ArchInstall2.sh

echo 'Press any key to continue...'
read
clear

echo 'Changeing root into the new system...'
arch-chroot /mnt ./ArchInstall2.sh

echo 'Press any key to continue...'
read
clear


declare um
echo 'Shoud the partitions be unmounted? [y, n] (default y)'
read um

um=$(default_values "$um" "y" "n")

if [ $um == "y" ];
then
		umount -R /mnt
fi

declare rb

echo 'Shoud the computer be rebooted into Arch? [y, n] (default y)'
read rb

rb=$(default_values "$rb" "y" "n")

if [ $rb == "y" ];
then
	   echo 'Arch Linux has been succesfully installed on this computer! Thank you for useing my installer!'
	   echo 'To reboot press any key...'
	   reboot
fi

echo 'Arch Linux has been succesfully installed on this computer! Thank you for useing my installer!
echo 'Press any key to continue...'
read
clear

echo "Exiting installer!"

#Made by Sipos Levente (KeTl3r)
