#!/bin/bash
set -x
# Step 1: Get the list of disks (excluding LVM, loop, and unwanted entries)
get_disks() {
    lsblk -dn -o NAME | grep -vE "loop|lvm--|local--lvm" > disk_list.txt
}

# Step 2: Get the list of partitions (excluding LVM and unwanted entries)
get_partitions() {
    lsblk -ln -o NAME | grep -vE "loop|lvm--|local--lvm" > partition_list.txt
    sed -i '/lvm-vm/d' partition_list.txt    # Remove LVM virtual machine partitions
    sed -i '/pve-root/d' partition_list.txt  # Remove Proxmox root partitions
    sed -i '/pve-swap/d' partition_list.txt  # Remove Proxmox swap partitions
}

# Step 3: Map disks to partitions and generate the file
map_disks_to_partitions() {
    > mapped_disks_and_partitions.txt  # Clear or create the file

    while IFS= read -r disk; do
        echo "$disk:" >> mapped_disks_and_partitions.txt

        # Capture the partitions and check if any exist directly under this disk
        partitions=$(grep "^$disk" partition_list.txt | grep -v "^$disk$")

        if [ -n "$partitions" ]; then
            # If partitions are found, write them under the disk
            echo "$partitions" | while read -r partition; do
                echo "  - $partition" >> mapped_disks_and_partitions.txt
            done
        else
            # No partitions found, add the disk itself as a partition
            echo "  - $disk" >> mapped_disks_and_partitions.txt
        fi
    done < disk_list.txt
}

# Function to extract information for disks
extract_info_disk() {
    local device=$1
    local key=$2

    case $key in
        # 1
        "uuid")
            blkid -s PTUUID -o value "/dev/$device" 2>/dev/null || echo ""
            ;;
        # 2
        "fs_type")
            echo ""  # No fs_type for entire disks
            ;;
        # 3
        "mount_path")
            echo ""  # Disks generally do not have mount paths
            ;;
        # 4
        "size" | "total_size")
            lsblk -no SIZE "/dev/$device" | head -n 1
            ;;
        # 5
        "id_serial")
            udevadm info --query=property --name="/dev/$device" | grep "ID_SERIAL_SHORT=" | cut -d '=' -f2 | head -n 1
            ;;
        # 6
        "id_model")
            udevadm info --query=property --name="/dev/$device" | grep "ID_MODEL=" | cut -d '=' -f2 | head -n 1
            ;;
        # 7
        "pcie_path")
            udevadm info --query=path --name="/dev/$device" | head -n 1
            ;;
        # 8
        "devpath")
            echo "/dev/$device"
            ;;
        # 9
        "diskseq")
            udevadm info --query=property --name="/dev/$device" | grep "DISKSEQ=" | cut -d '=' -f2 | head -n 1
            ;;
        # 10
        "used" | "percentage_used")
            df -h "/dev/$device" 2>/dev/null | awk 'NR==2 {print $3}'
            ;;
        # 11
        "is_usb")
            udevadm info --query=property --name="/dev/$device" | grep -q "ID_BUS=usb" && echo true || echo false
            ;;
        *)
            echo "Unknown key: $key"
            ;;
    esac
}

# Function to extract information for partitions
extract_info_partition() {
    local device=$1
    local key=$2

    case $key in
        # 1
        "uuid")
            blkid -s UUID -o value "/dev/$device" | head -n 1
            ;;
        # 2
        "fs_type")
            blkid -s TYPE -o value "/dev/$device" | head -n 1
            ;;
        # 3
        "mount_path")
            mount | grep "/dev/$device" | awk '{print $3}' | head -n 1
            ;;
        # 4
        "size")
            lsblk -no SIZE "/dev/$device" | head -n 1
            ;;
        # 5
        "id_serial")
            udevadm info --query=property --name="/dev/$device" | grep "ID_SERIAL_SHORT=" | cut -d '=' -f2 | head -n 1
            ;;
        # 6
        "id_model")
            udevadm info --query=property --name="/dev/$device" | grep "ID_MODEL=" | cut -d '=' -f2 | head -n 1
            ;;
        # 7
        "pcie_path")
            udevadm info --query=path --name="/dev/$device" | head -n 1
            ;;
        # 8
        "devpath")
            echo "/dev/$device"
            ;;
        # 9
        "diskseq")
            udevadm info --query=property --name="/dev/$device" | grep "DISKSEQ=" | cut -d '=' -f2 | head -n 1
            ;;
        *)
            echo "Unknown key: $key"
            ;;
    esac
}

# Function to generate script file for each disk
generate_variables() {
    local disk_name="$1"
    shift
    local partitions=("$@")

    # Create the script file name
    local file_name="${disk_counter}_${disk_name}.sh"

    # Write the variables to the script file
    {
        # Disk-level information
        # 1
        echo "disk_number_${disk_counter}=${disk_counter}_${disk_name}"
        # 2
        echo "disk_name_${disk_counter}=$disk_name"
        # 3
        echo "disk_size_${disk_counter}=$(extract_info_disk "$disk_name" "size")"
        # 4
        echo "disk_type_${disk_counter}=$(extract_info_disk "$disk_name" "fs_type")"
        # 5
        echo "is_usb_${disk_counter}=$(extract_info_disk "$disk_name" "is_usb")"
        # 6
        echo "total_size_${disk_counter}=$(extract_info_disk "$disk_name" "total_size")"
        # 7
        echo "used_${disk_counter}=$(extract_info_disk "$disk_name" "used")"
        # 8
        echo "percentage_used_${disk_counter}=$(extract_info_disk "$disk_name" "percentage_used")"
        # 9
        echo "uuid_${disk_counter}=$(extract_info_disk "$disk_name" "uuid")"
        # 10
        echo "mount_path_${disk_counter}=""
        # 11
        echo "mount_status_${disk_counter}=unmounted"
        # 12
        echo "id_serial_${disk_counter}=$(extract_info_disk "$disk_name" "id_serial")"
        # 13
        echo "id_model_${disk_counter}=$(extract_info_disk "$disk_name" "id_model")"
        # 14
        echo "pcie_path_${disk_counter}=$(extract_info_disk "$disk_name" "pcie_path")"
        # 15
        echo "devpath_${disk_counter}=/dev/$disk_name"
        # 16
        echo "diskseq_${disk_counter}=$(extract_info_disk "$disk_name" "diskseq")"

        # Partition-level information
        partition_counter=1
        for partition in "${partitions[@]}"; do
            # 17
            echo "partition_name_${disk_counter}_${partition_counter}=$partition"
            # 18
            echo "uuid_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "uuid")"
            # 19
            echo "part_size_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "size")"
            # 20
            echo "fs_type_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "fs_type")"
            
            mount_path="$(extract_info_partition "$partition" "mount_path")"
            if [ -n "$mount_path" ]; then
                # 21
                echo "mount_path_${disk_counter}_${partition_counter}=$mount_path"
                # 22
                echo "mount_status_${disk_counter}_${partition_counter}=mounted"
            else
                # 23
                echo "mount_path_${disk_counter}_${partition_counter}=""
                # 24
                echo "mount_status_${disk_counter}_${partition_counter}=unmounted"
            fi

            # 25
            echo "id_serial_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "id_serial")"
            # 26
            echo "id_model_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "id_model")"
            # 27
            echo "pcie_path_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "pcie_path")"
            # 28
            echo "devpath_${disk_counter}_${partition_counter}=/dev/$partition"
            # 29
            echo "diskseq_${disk_counter}_${partition_counter}=$(extract_info_partition "$partition" "diskseq")"

            partition_counter=$((partition_counter + 1))
        done
    } > "$file_name"

    mkdir -p disk_command_substitutes
    mv "$file_name" disk_command_substitutes/
    disk_counter=$((disk_counter + 1))
}

# Main execution
get_disks
get_partitions
map_disks_to_partitions

# Identify disks with no partitions and mark them
disks_without_partitions=$(awk -F: '$2 ~ /^ *- *$/ {print $1}' mapped_disks_and_partitions.txt)
for disk in $disks_without_partitions; do
    echo "$disk" >> disks_without_partitions.txt

done

generate_from_mapping() {
    disk_counter=1
    while IFS= read -r disk; do
        partitions=($(grep -E "^  - " mapped_disks_and_partitions.txt | grep "$disk" | cut -d'-' -f2 | tr -d ' '))
        generate_variables "$disk" "${partitions[@]}"
    done < disk_list.txt
}

generate_from_mapping

echo "Command substitutes have been generated and saved in the 'disk_command_substitutes' directory."
cd disk_command_substitutes
