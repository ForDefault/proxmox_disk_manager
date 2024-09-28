#!/bin/bash

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
        # Find partitions that belong to this disk, ensuring not to list the disk itself
        grep "^$disk" partition_list.txt | grep -v "^$disk$" | while read -r partition; do
            echo "  - $partition" >> mapped_disks_and_partitions.txt
        done
    done < disk_list.txt
}

# Function to extract information using blkid, lsblk, and udevadm
extract_info() {
    local device=$1
    local key=$2

    case $key in
        "uuid")
            blkid -s UUID -o value "/dev/$device" | head -n 1
            ;;
        "partuuid")
            blkid -s PARTUUID -o value "/dev/$device" | head -n 1
            ;;
        "fs_type")
            blkid -s TYPE -o value "/dev/$device" | head -n 1
            ;;
        "mount_path")
            lsblk -no MOUNTPOINT "/dev/$device" | head -n 1
            ;;
        "size")
            lsblk -no SIZE "/dev/$device" | head -n 1
            ;;
        "id_serial")
            udevadm info --query=property --name="/dev/$device" | grep "ID_SERIAL_SHORT=" | cut -d '=' -f2 | head -n 1
            ;;
        "id_model")
            udevadm info --query=property --name="/dev/$device" | grep "ID_MODEL=" | cut -d '=' -f2 | head -n 1
            ;;
        "pcie_path")
            udevadm info --query=path --name="/dev/$device" | head -n 1
            ;;
        "devpath")
            udevadm info --query=property --name="/dev/$device" | grep "DEVPATH=" | cut -d '=' -f2 | head -n 1
            ;;
        "diskseq")
            udevadm info --query=property --name="/dev/$device" | grep "DISKSEQ=" | cut -d '=' -f2 | head -n 1
            ;;
        "used")
            df -h | grep "^/dev/$device" | awk '{print $3}' | head -n 1
            ;;
        "percentage_used")
            df -h | grep "^/dev/$device" | awk '{print $5}' | head -n 1
            ;;
        "total_size")
            lsblk -dn -o SIZE "/dev/$device" | head -n 1
            ;;
        "is_usb")
            udevadm info --query=property --name="/dev/$device" | grep -q "ID_BUS=usb" && echo true || echo false
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
        echo "disk_number_${disk_counter}=\"${disk_counter}_${disk_name}\""
        echo "disk_name_${disk_counter}=\"$disk_name\""
        echo "disk_size_${disk_counter}=\"$(extract_info "$disk_name" "size")\""
        echo "disk_type_${disk_counter}=\"$(extract_info "$disk_name" "fs_type")\""
        echo "is_usb_${disk_counter}=\"$(extract_info "$disk_name" "is_usb")\""
        echo "total_size_${disk_counter}=\"$(extract_info "$disk_name" "total_size")\""
        echo "used_${disk_counter}=\"$(extract_info "$disk_name" "used")\""
        echo "percentage_used_${disk_counter}=\"$(extract_info "$disk_name" "percentage_used")\""
        echo "num_partitions_${disk_counter}=\"${#partitions[@]}\""

        partition_counter=1
        for partition in "${partitions[@]}"; do
            echo "partition_name_${disk_counter}_${partition_counter}=\"$partition\""
            echo "uuid_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "uuid")\""
            echo "part_size_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "size")\""
            echo "fs_type_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "fs_type")\""
            echo "mount_path_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "mount_path")\""
            echo "mount_status_${disk_counter}_${partition_counter}=\"mounted\""  # Can be dynamically checked with `mount | grep`
            echo "id_serial_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "id_serial")\""
            echo "id_model_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "id_model")\""
            echo "pcie_path_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "pcie_path")\""
            echo "devpath_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "devpath")\""
            echo "diskseq_${disk_counter}_${partition_counter}=\"$(extract_info "$partition" "diskseq")\""
            partition_counter=$((partition_counter + 1))
        done
    } > "$file_name"

    mkdir -p disk_command_substitutes
    mv "$file_name" disk_command_substitutes/
    disk_counter=$((disk_counter + 1))
}

# Function to generate script files for all disks
generate_from_mapping() {
    disk_counter=1
    while IFS= read -r disk; do
        partitions=($(grep -E "^  - " mapped_disks_and_partitions.txt | grep "$disk" | cut -d'-' -f2 | tr -d ' '))
        generate_variables "$disk" "${partitions[@]}"
    done < disk_list.txt
}

# Main execution
get_disks
get_partitions
map_disks_to_partitions
generate_from_mapping

echo "Command substitutes have been generated and saved in the 'disk_command_substitutes' directory."
