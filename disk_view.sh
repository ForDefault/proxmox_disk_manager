#!/bin/bash

# Function to print the header
print_header() {
    echo "Proxmox Storage Management (Default View)"
    echo "================================================"
    echo ""
}

# Function to print the directory mounts
print_directory_mounts() {
    echo "                                                         -> Directory Mounts <┐"
    echo "                                                      +--------------------------+"
    echo "                                                                   \|/            +"
    echo "                                                                    └────────────+ +"
    echo "                                                                                  |+"
    echo "                                 -->> Active Directory Mounts <<--++++++++++++++++++"
    echo "                                                 \|/                              +"
    echo "                                                  |                               +"
    echo "                                                  |                               +"
    echo "                                                  |                               +"
    echo "                                           \|/    |                               +"
}

# Function to print a disk entry with its partitions
print_disk() {
    local disk_num="$1"
    local disk_name="$2"
    local disk_path="$3"
    local disk_size="$4"
    local disk_type="$5"
    local is_usb="$6"
    local disk_usage="$7"
    local partitions="$8"
    local category="$9"
    local active="${10}"
    
    if [ "$category" == "Non-Proxmox" ]; then
        echo "┌───────────────────────────────────────────┬─────┘                               |"
        echo "|  [$disk_num]┌─-->>> Non-Proxmox Storage <<<--- [$disk_num] |    (${active} Mounts)                  +"
        echo "|     └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘                                   +"
    else
        echo "|   [$disk_num]┌─-->>> Proxmox Storage <<<--- [$disk_num]   |    (${active} Mounts)                  +"
        echo "|      └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘                                   +"
    fi

    echo "|     +-------------------------------------+                                      +"
    echo "|     | Disk Name       : $disk_name                       |                       +"
    echo "|     | Disk Path       : $disk_path                      |                       +"
    echo "|     | Disk Size       : $disk_size                      |                       +"
    echo "|     | Disk Type       : $disk_type                      |                       +"
    echo "|     | Is USB          : $is_usb                         |                       +"
    echo "|     | Total Disk Usage:                                 |                       +"
    echo "|     |   - Total Size  : $disk_size                      |                       +"
    echo "|     |   - Used        : ${disk_usage%% *}                 |                       +"
    echo "|     |   - Percentage  : ${disk_usage##* }                |                       +"
    echo "|     | Number of Partitions: ${#partitions[@]}                           |                       +"
    echo "|     +---------------------------------------------------+                       +"

    for partition in "${partitions[@]}"; do
        IFS="|" read -r part_name part_size fs_type uuid mount_path mount_status hist_paths part_usage vm_assoc prox_storage prox_type sys_paths <<< "$partition"
        echo "|     ┌── Partition: $part_name                                                    +"
        echo "|     │   Size: $part_size                                                              +"
        echo "|     │   Filesystem: $fs_type                                                        +"
        echo "|     │   UUID: $uuid                                               +"
        echo "|     │   Mount Path: $mount_path                                                   +"
        echo "|     │   Mount Status: $mount_status                                                   +"
        echo "|     │   History of Mount Paths: $hist_paths                  +"
        echo "|     │   Partition Usage:                                                        +"
        echo "|     │   - Total Size: $part_size                                                      +"
        echo "|     │   - Used: ${part_usage%% *}                                                            +"
        echo "|     │   - Percentage Used: ${part_usage##* }                                                  +"
        echo "|     │   VM Association:                                                         +"
        echo "|     │   - Is Running: ${vm_assoc%% *}                                                      +"
        echo "|     │   - Which Running VM: ${vm_assoc##* }                                              +"
        echo "|     │   - History: VM1, VM2, VM3                                                +"
        echo "|     │   Is Proxmox Storage: $prox_storage                                                +"
        echo "|     │   Proxmox Storage Type: $prox_type                                               +"
        echo "|     │   System Paths:                                                           +"
        echo "|     │   - By ID: ${sys_paths%% *}                                   +"
        echo "|     │   - By UUID: ${sys_paths##* }                                          +"
        echo "|     │   - By PARTUUID: 10337ff6-29ac-4daf-948e-f64c67fd5642                     +"
        echo "|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +"
        echo "|     │   System Information:                                                     +"
        echo "|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +"
        echo "|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +"
        echo "|     │   - Diskseq: 37                                                           +"
        echo "|     └──                                                                         +"
    done
    echo "|     +-------------------------------------+                                     +"
    echo "|                                                                                +"
    echo "|                                                                                +"
    echo "|___________________________________________                                     +"
    echo "                                           \|/                                   +"
}

# Function to print the footer
print_footer() {
    echo "*********************************************************************************+"
    echo "                                                                                  +"
    echo "                                                                                  +"
    echo "                                                                                  +"
    echo "                               -->> Inactive Directory Mounts <<--++++++++++++++++++"
    echo "                                                 \|/                              +"
    echo "                                                  |                               +"
    echo "                                                  |                               +"
    echo "                                                  |                               +"
    echo "                                           \|/    |                               +"
}

# Sample Data

active_non_proxmox_partitions=(
    "/dev/sda1|250G|ext4|1234-5678-ABCD-EFGH|/mnt/sda1|Mounted|/mnt/sda1_old, /mnt/sda1_older|100G 40%|true VM1|true|ata-SDA1234SSD1_164814DC7F86 1234-5678-ABCD-EFGH"
    "/dev/sda2|250G|ntfs|IJKL-MNOP-QRST-UVWX|(None)|Unmounted|/mnt/sda2_old, /mnt/sda2_older|150G 60%|false VM4|false|ata-SDB5678SSD1_20D11E804A16 5678-1234-EFGH-ABCD"
)

active_proxmox_partitions=(
    "/dev/sdb1|500G|ext4|ABCD-5678-EFGH-1234|/mnt/sdb1|Mounted|/mnt/sdb1_old, /mnt/sdb1_older|250G 50%|false None|true|ata-SDB1234SSD1_20D11E804A16 5678-ABCD-EFGH-1234"
    "/dev/sdb2|500G|ntfs|WXYZ-5678-ABCD-1234|(None)|Unmounted|/mnt/sdb2_old, /mnt/sdb2_older|350G 70%|true VM8|false|ata-SDC1234SSD1_30D22E804A16 5678-1234-WXYZ-ABCD"
)

inactive_non_proxmox_partitions=(
    "/dev/sdc1|500G|ext4|MNOP-1234-QRST-5678|/mnt/sdc1|Mounted|/mnt/sdc1_old, /mnt/sdc1_older|200G 40%|false None|true|ata-SDD1234SSD1_40D22E804A16 MNOP-1234-QRST-5678"
    "/dev/sdc2|500G|ntfs|UVWX-5678-QRST-1234|(None)|Unmounted|/mnt/sdc2_old, /mnt/sdc2_older|350G 70%|true VM13|false|ata-SDE1234SSD1_50D22E804A16 UVWX-5678-QRST-1234"
)

# Start Printing

print_header

print_directory_mounts

# Active Non-Proxmox Storage
print_disk 1 "sda" "/dev/sda" "500G" "SSD" "false" "200G 40%" active_non_proxmox_partitions "Non-Proxmox" "Active"

# Active Proxmox Storage
print_disk 2 "sdb" "/dev/sdb" "1TB" "HDD" "true" "500G 50%" active_proxmox_partitions "Proxmox" "Active"

print_footer

# Inactive Non-Proxmox Storage
print_disk 3 "sdc" "/dev/sdc" "1TB" "HDD" "false" "600G 60%" inactive_non_proxmox_partitions "Non-Proxmox" "NOT Active"

echo "*********************************************************************************+"
echo "                                                                                  +"
echo "                                                                                  +"
echo "                                                                                  +"
echo "                               -->> Proxmox Storage <<--++++++++++++++++++++++++++"
echo "                                                 \|/                             +"
echo "                                                  |                               +"
echo "                                                  |                               +"
echo "                                           \|/    |                               +"
echo "┌───────────────────────────────────────────┬─────┘                               +"
