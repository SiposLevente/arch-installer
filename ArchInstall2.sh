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

echo 'Generating "/etc/adjtime"'
hwclock --systohc

echo 'Copying locales...'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'hu_HU.UTF-8 UTF-8' >> /etc/locale.gen
echo 'Generating locales...'
locale-gen

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
echo 'Creating host config'

echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1	$HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo 'Creating new initramfs...'
mkinitcpio -p linux

echo 'Setting root password...'
passwd

echo 'Installing networking applications...'
pacman -S netctl wpa_supplicant --noconfirm
clear

declare GRUB
echo 'Should GRUB be installed on the system? [y, n] (default: y)'
read GRUB

GRUB=$(default_values "$GRUB" "y" "n")

if [ $GRUB == "y" ];
then
		echo 'Downloading and Installing GRUB and efibootmgr'
		pacman -S grub efibootmgr --noconfirm

		grub-install --target=x86_64-efi --efi-directory=/boot
		grub-mkconfig -o /boot/grub/grub.cfg
fi

echo 'Exiting the mounted system'
exit
