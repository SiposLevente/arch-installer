default_values() {
	local valt
	local def
	local masik

	valt=$1
	def=$2
	masik=$3

	if [ "$valt" != "$def" ]; then
		if [ "$valt" != "$masik" ]; then
			valt=$def
		fi
	fi
	echo "$valt"
}

loadkeys hu
echo 'I AM NOT RESPONSIBLE FOR ANY DATALOSS, OR OTHER PROBLEMS THAT MIGHT APPEAR DURING THE INSTALLATION!!!'
echo 'THIS ONLY WORKS IF YOU ONLY WANT TO MAKE THE PARTITONS "ROOT" "SWAP" "HOME" "BOOT/EFI"'
echo 'THIS INSTALLER IS NOT A FOOL PROOF INSTALLER, SO INSTALL CAREFULLY!'
echo 'Feedback is appreciated!'
echo 'Press ENTER to continue...'
read
clear

declare layout
echo 'The default layout for this installer is hungarian. Do you wish to change it to US layout?? [y, n] (default: n)'
read layout

layout=$(default_values "$layout" "n" "y")
if [ $layout == "y" ]; then
	loadkeys us
fi
clear

echo 'The system has to have UEFI mode enabled on the motherboard to get this installer to work!'
declare uefi
echo 'Are you sure that UEFI is enabled on the system? [y, n] (default: y)'
read uefi
uefi=$(default_values "$uefi" "y" "n")
if [ $uefi == "n" ]; then
	ls /sys/firmware/efi/efivars
	echo 'If the previous step returned strings then the system has UEFI, otherwise you should exit the script with CTRL+C'

fi

echo 'Press ENTER to continue...'
read
clear
sed -i '10 i ParallelDownloads = 5' /etc/pacman.conf 
echo 'Network time protocol enabled'
timedatectl set-ntp true

echo 'Updating repositories'
pacman -Syy

declare partitionLet
fdisk -l

declare loopExit="0"
while [ $loopExit != "1" ]; do
	echo 'Which partition do you want to format? (eg.: sda, sdb, sdc)'
	read partitionLet
	cfdisk /dev/"$partitionLet"

	declare partAgain
	echo 'Do you want to partition another drive? [y, n] (default: y)'
	read partAgain
	partAgain=$(default_values "$partAgain" "y" "n")
	if [ $partAgain == "n" ]; then
		loopExit="1"
	fi
done
clear
fdisk -l

declare partitionNum
echo 'Whitch directory is the ROOT partition? [partition name and number] (eg.: sda1, sdb2, sdc3)'
read partitionNum
mkfs.ext4 /dev/"$partitionNum"
echo "Mounting /dev/$partitionNum to /mnt"
mount /dev/"$partitionNum" /mnt
echo 'Whitch directory is the BOOT/EFI partition? [partition name and number]'
read partitionNum
mkdir /mnt/boot
mkfs.vfat /dev/"$partitionNum"
echo "Mounting /dev/$partitionNum to /mnt/boot"
mount /dev/"$partitionNum" /mnt/boot
echo 'Whitch directory is the SWAP partition? [partition name and number]'
read partitionNum
mkswap /dev/"$partitionNum"
echo "Turning swap on /dev/$partitionNum"
swapon /dev/"$partitionNum"
declare HOME
echo 'Do you have a HOME directory? [y, n] (default: n)'
read HOME
HOME=$(default_values "$HOME" "n" "y")
if [ $HOME == "y" ]; then
	echo 'Whitch directory is the HOME partition? [partition name and number]'
	read partitionNum
	mkdir /mnt/home
	mkfs.ext4 /dev/"$partitionNum"
	mount /dev/"$partitionNum" /mnt/home
fi
clear

echo 'Copying the mirrorlist...'
rm /etc/pacman.d/mirrorlist
cp mirrorlist /etc/pacman.d
echo 'Downloading the packpages (base, base-devel)...'
pacstrap /mnt base base-devel dhcpcd less linux-firmware linux vim man-db man-pages netctl

echo 'Generating fstab...'
genfstab -U /mnt >>/mnt/etc/fstab

cp ArchInstall2.sh /mnt/ArchInstall2.sh

echo 'Changing root into the new system...'
arch-chroot /mnt ./ArchInstall2.sh

declare um
echo 'Shoud the partitions be unmounted? [y, n] (default y)'
echo 'Arch Linux was successfully installed! If you would like to do anything else to the computer before it reboots into the system DO NOT unmount the partitions!'
read um

um=$(default_values "$um" "y" "n")

if [ $um == "y" ]; then
	umount -R /mnt
	reboot
fi
