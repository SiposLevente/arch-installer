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

echo 'Setting timezone to Europe/Budapest...'
ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

echo 'Generateing "/etc/adjtime"'
hwclock --systohc

echo 'Press ENTER to continue...'
read
clear

echo 'Copying locales...'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'hu_HU.UTF-8 UTF-8' >> /etc/locale.gen
echo 'Generateing locales...'
locale-gen
echo 'Press ENTER to continue...'
read
clear

echo 'Setting system language to US english'
touch /etc/locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo 'Creating a keyboard layout...'
declare KEYMAP

echo 'What layout should the keyboard have? [hu, us] (default: hu)'
read KEYMAP

KEYMAP=$(default_values "$KEYMAP" "hu" "us")

touch /etc/vconsole.conf
echo "KEYMAP=$KEYMAP" >> /etc/vconsole.conf
echo 'Press ENTER to continue...'
read
clear

declare HOSTNAME
echo 'Enter the name of the computer: '
read HOSTNAME
touch /etc/hostname
echo "$HOSTNAME" >> /etc/hostname
echo 'Press ENTER to continue...'
read
clear

echo 'Creating host config'

declare ipv4lh
declare ipv6lh
declare ipv4ld

echo 'Enter the IPv4 address that you want to use as localhost'
read ipv4lh
echo "$ipv4lh	localhost" >> /etc/hosts

echo 'Enter the IPv6 address that you want to use as localhost'
read ipv6lh
echo "$ipv6lh	localhost" >> /etc/hosts

echo 'Enter the IPv4 address that you want to use as localdomain'
read ipv4ld
echo "$ipv4ld	$HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo 'Press ENTER to continue...'
read
clear

echo 'Creating new initramfs...'
mkinitcpio -p linux

echo 'Press ENTER to continue...'
read
clear

echo 'Setting root password...'
passwd

echo 'Press ENTER to continue...'
read
clear

declare GRUB
echo 'Should GRUB be installed on the system? [y, n] (default: y)'
read GRUB

GRUB=$(default_values "$GRUB" "y" "n")

if [ $GRUB == "y" ];
then
		echo 'Downloading and Installing GRUB and efibootmgr'
		pacman -S grub
		pacman -S efibootmgr

		grub-install --target=x86_64-efi --efi-directory=/boot
		grub-mkconfig -o /boot/grub/grub.cfg
fi

echo 'Exiting the mounted system'
exit

#Made by Sipos Levente (KeTl3r)
