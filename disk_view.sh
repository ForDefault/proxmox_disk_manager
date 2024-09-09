#!/bin/bash

mkdir -p disk_view_folder
cd disk_view_folder

# Function to get detailed information for each disk and partition independently
get_disk_partition_info() {
    lsblk -lnpo NAME,SIZE,MOUNTPOINT,FSTYPE,UUID,PARTUUID | while read -r line; do
        disk_name=$(echo "$line" | awk '{print $1}' | xargs -n1 basename)
        size=$(echo "$line" | awk '{print $2}')
        mount_point=$(echo "$line" | awk '{print $3}')
        filesystem_type=$(echo "$line" | awk '{print $4}')
        uuid=$(echo "$line" | awk '{print $5}')
        partuuid=$(echo "$line" | awk '{print $6}')
        
        # Exclude any partitions with unwanted naming patterns
        if echo "$disk_name" | grep -qE "local--lvm-vm|pve-root|pve-swap|loop"; then
            continue
        fi

        # Handle empty fields
        [[ -z "$mount_point" ]] && mount_point="null"
        [[ -z "$filesystem_type" ]] && filesystem_type="null"
        [[ -z "$size" ]] && size="null"
        [[ -z "$uuid" ]] && uuid="null"
        [[ -z "$partuuid" ]] && partuuid="null"

        # Create partition JSON structure for each disk/partition independently
        cat <<EOF > "${disk_name}.json"
{
    "partition_name": "$disk_name",
    "uuid": "$uuid",
    "size": "$size",
    "filesystem_type": "$filesystem_type",
    "current_mount_path": "$mount_point",
    "mount_status": "mounted",
    "history_of_mount_paths": [],
    "partition_usage": {
        "total_size": "$size",
        "used": "",
        "percentage_used": ""
    },
    "vm_association": {
        "is_running": false,
        "which_running_vm": null,
        "history": []
    },
    "is_proxmox_storage": false,
    "proxmox_storage_type": null,
    "system_paths": {
        "by_id": [],
        "by_uuid": "$uuid",
        "by_partuuid": "$partuuid",
        "by_path": []
    }
}
EOF

    done
}

get_disk_partition_info
