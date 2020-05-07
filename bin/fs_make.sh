#!/bin/bash
# description: This script is used to mount /opt/www on a data drive.
# process: * identify a disk with no partition on it
#          * create a primary partition
#          * create a ext4 file system on the partition
#          * mount the file system as /opt/www
#          * back up fstab
#          * identify the uuid of the file system
#          * update fstab with new file system

function test_device {
	candidate=$1
	sudo partprobe -d -s /dev/${candidate} 1>/dev/null 2>&1;rc=$?
	if [[ ${rc} -ne 0 ]]
	then
		return
	fi
	partition=$(sudo partprobe -d -s /dev/${candidate} | awk '{print $4}')
    if [[ -z ${partition} ]]
	then
		device=${candidate}
	fi
    return
}

function get_device {
    for namevalue in $(lsblk --pairs --scsi)
    do
        name=$(echo ${namevalue} | awk -F= '{print $1}'|tr -d \")
        value=$(echo ${namevalue} | awk -F= '{print $2}'|tr -d \")
        if [[ ${name} == NAME ]]
        then
            test_device ${value}
        fi
    done
    return
}

device=''
echo "Getting device..."
get_device
if [[ -z ${device} ]]
then
	echo $0 found no devices without partitions
	exit 1
fi
echo "Device set to /dev/${device}..."

echo "Creating partition on /dev/$device..."
sudo parted /dev/${device} --script mklabel gpt mkpart primary 0% 100%;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR creating partition for /dev/${device}"
    exit ${rc}
fi

echo "Creating file system on /dev/${device}1..."
sudo mkfs -t ext4 /dev/${device}1;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR creating file system for /dev/${device}1"
    exit ${rc}
fi

echo "Probe partition for /dev/${device}..."
sudo partprobe /dev/${device}1;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR probing partition for /dev/${device}1"
    exit ${rc}
fi

if [[ ! -d /opt/www ]]
then
    echo "Creating /opt/www as directory..."
	sudo mkdir /opt/www;rc=$?
    if [[ ${rc} -ne 0 ]]
    then
        echo "ERROR making directory /opt/www"
        exit ${rc}
    fi
fi

echo "Mounting /dev/${device}1 as /opt/www..."
sudo mount /dev/${device}1 /opt/www;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR mouting /dev/${device}1 as /opt/www"
    exit ${rc}
fi

echo "Backing up /etc/fstab to /etc/fstab.backup"
sudo cp /etc/fstab /etc/fstab.backup;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR making backup of /etc/fstab"
    exit ${rc}
fi

echo "Finding uuid for /etc/${device}1..."
uuid=$(sudo -i blkid|grep /dev/${device}1|awk '{print $2}'|awk -F= '{print $2}'|tr -d \");rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR getting uuid for /dev/${device}1"
    exit ${rc}
fi

echo "Updating /etc/fstab..."
cp /etc/fstab ./fstable;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR making copy of /etc/fstab"
    exit ${rc}
fi

printf "UUID=$uuid\t/opt/www\text4\tdefaults,nofail\t1 2\n" >> ./fstable;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR updating ./fstable"
    exit ${rc}
fi

sudo cp ./fstable /etc/fstab;rc=$?
if [[ ${rc} -ne 0 ]]
then
    echo "ERROR replacing /etc/fstab with ./fstable"
    exit ${rc}
fi

exit 0
