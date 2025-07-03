# System Wide Updates
sudo apt -y update
sudo apt -y dist-upgrade
sudo apt -y autoremove
sudo apt-get -y install \
  curl \
  jq \
  wireguard \
  libgstrtspserver-1.0-0 \
  collectd \
  locales \
  python3-pip

#
# Python dependencies
#

sudo python -m pip install cpu-cores --break-system-packages


#
# RPi firmware config
#

if sudo grep -q "usb_max_current_enable=" /boot/firmware/config.txt; then
  sudo sed -i '/usb_max_current_enable=/c\usb_max_current_enable=1' /boot/firmware/config.txt
else \
  sudo sh -c 'echo "\n#Enable USB max current\nusb_max_current_enable=1" >> /boot/firmware/config.txt'
fi

if sudo grep -q "enable_uart=" /boot/firmware/config.txt; then
  sudo sed -i '/enable_uart=/c\enable_uart=1' /boot/firmware/config.txt
else
  sudo sh -c 'echo "\nenable_uart=1" >> /boot/firmware/config.txt'
fi

if sudo grep -q "dtparam=uart0" /boot/firmware/config.txt; then
  sudo sed -i '/dtparam=uart0=/c\dtparam=uart0=1' /boot/firmware/config.txt
else
  sudo sh -c 'echo "\ndtparam=uart0=1" >> /boot/firmware/config.txt';
fi

if sudo grep -q "console=serial0,115200" /boot/firmware/cmdline.txt; then
  sudo sed -i 's/console=serial0,115200//'  /boot/firmware/cmdline.txt;
fi

# 
# Install Minicom
sudo apt -y install minicom 
minicom -b 921600 -D /dev/serial0

#
# Get aitinout
#

got clone https://github.com/beralt/atinout.git


#
# Create a connection for the gimbal camera (currently Siyi A8)
#

if ! nmcli dev | grep -q 'Gimbal-Cam-0 '; then
   sudo nmcli con add type ethernet ifname eth0 con-name Gimbal-Cam-0 ip4 192.168.144.12/24 ipv4.route-metric 900 autoconnect yes
fi


#
# Set up 5G Modem
#

ModemManufacturer=$(mmcli -L | grep -Po "(?<=\[).*(?=\])")
ModemATInterface="if02"

#
# Determine serial port
#
ModemSerialPorts=(/dev/serial/by-id/*"${ModemManufacturer}"*"${ModemATInterface}"*)
ModemSerialPort=${ModemSerialPorts[0]}

#
# Issue AT commands to configure the modem:
#

echo AT+CGDCONT=1,\"IPV4V6\",\"broadband\" | sudo atinout - "$ModemSerialPort" -
echo AT+QCFG=\"usbnet\",0 | sudo atinout - "$ModemSerialPort" -
echo "Waiting for 10 seconds"
sleep 10
echo AT+CFUN=1,1 | sudo atinout - "$ModemSerialPort" -
echo "Waiting for 10 seconds"
sleep 10

#
# Create the cellular modem connection
#

if ! nmcli dev | grep -q 'GSM-0 '; then
   sudo nmcli con add type gsm ifname cdc-wdm0 con-name GSM-0 apn broadband ipv4.route-metric 110 ipv6.method disabled autoconnect yes
fi



# Make folders, Clone reposistory, Navigate to your cloned repository
mkdir /home/tony/Projects/
cd /home/tony/Projects/
git clone montereytony/QGC-lite
cd /home/tony/Projects/QGC-lite

# Create the directory structure we planned
mkdir rpi_edge_node cloud_server web_frontend

# Create a Python virtual environment inside the project folder
# This creates a folder named 'venv'
python3 -m venv venv

# Activate the virtual environment. 
# Your terminal prompt should change to show (venv).
source venv/bin/activate

# While inside the QGC-lite directory with venv active
pip install pymavlink pyserial websockets

