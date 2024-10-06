#!/bin/bash

# Output files
running_vm_list="running_vm_list.txt"
unmounted_devices_list="unmounted_devices_list.txt"

# Clear previous results
> "$running_vm_list"
> "$unmounted_devices_list"

# Step 1: Extract all Mass Storage Devices (MMS) from storage_devices.txt
mass_storage_device_ids=$(grep -B 1 "Mass storage device" storage_devices.txt | grep -oP 'output_\K[0-9]+(?=_)' | sort -u)

# Create an associative array to track devices
declare -A mms_tracking_list  
for device_id in $mass_storage_device_ids; do
    mms_tracking_list["$device_id"]=0  # Initialize all devices as untracked
done

# Function to extract device info (description, product, vendor, serial, bus_info)
# Function to extract device info (description, product, vendor, serial, bus_info)
get_device_info() {
    device_id=$1
    source storage_devices.txt

    description_var="output_${device_id}_1"
    product_var="output_${device_id}_2"
    vendor_var="output_${device_id}_3"
    bus_info_var="output_${device_id}_5"

    # Check primary and fallback serials
    serial_var="output_${device_id}_7"
    serial=${!serial_var}

    # If serial contains "usb" or a dot, try the next position
    if [[ $serial == *"usb"* || $serial == *"."* ]]; then
        serial_var="output_${device_id}_8"
        serial=${!serial_var}
    fi

    description=${!description_var}
    product=${!product_var}
    vendor=${!vendor_var}
    bus_info=${!bus_info_var}

    echo "description: $description"
    echo "product: $product"
    echo "vendor: $vendor"
    echo "serial: $serial"
    echo "bus_info: $bus_info"
}


# Function to convert bus_info for comparison with VM configs
convert_bus_info_format() {
    bus_info=$1
    echo "$bus_info" | sed 's/usb@//;s/:/-/'
}

# Function to check if device is passed to an active VM
check_active_vm() {
    device_id=$1
    bus_info_var="output_${device_id}_5"
    bus_info=$(eval echo \$$bus_info_var | tr -d '()')

    # Convert bus_info to match VM config format (host=)
    bus_info_converted=$(convert_bus_info_format "$bus_info")
    vm_match=$(grep "$bus_info_converted" /etc/pve/qemu-server/*.conf)

    if [[ -n "$vm_match" ]]; then
        for vm_conf in $(echo "$vm_match" | awk -F':' '{print $1}'); do
            vm=$(basename "$vm_conf" .conf)
            vm_status=$(qm status "$vm" | grep -q "running" && echo "Running" || echo "Stopped")
            vm_name=$(qm config "$vm" | grep -w "name" | awk '{print $2}')

            if [[ "$vm_status" == "Running" ]]; then
                echo "Mass Storage Device $device_id"
                get_device_info "$device_id"
                echo "   VM Number: $vm"
                echo "   VM Config: $vm_conf"
                echo "   VM Name: $vm_name"
                echo "   VM Status: $vm_status"
                echo "   Mass Storage Device $device_id is passed through to an active VM"

                # Append info to running VM list
                echo "Mass Storage Device $device_id" >> "$running_vm_list"
                get_device_info "$device_id" >> "$running_vm_list"
                echo "   VM Number: $vm" >> "$running_vm_list"
                echo "   VM Config: $vm_conf" >> "$running_vm_list"
                echo "   VM Name: $vm_name" >> "$running_vm_list"
                echo "   VM Status: $vm_status" >> "$running_vm_list"
                echo "" >> "$running_vm_list"

                mms_tracking_list["$device_id"]=1  # Mark as accounted for
                return 0
            fi
        done
    fi
    return 1
}

# Function to check if device is mounted
check_mount_status() {
    device_id=$1
    serial_var="output_${device_id}_7"
    serial=$(eval echo \$$serial_var | tr -d '()')

    mount_check=$(lsblk -o NAME,SERIAL | grep "$serial")

    if [[ -n "$mount_check" ]]; then
        echo "Mass Storage Device $device_id is mounted"
        get_device_info "$device_id"
        echo "Mounted on: $mount_check"
        mms_tracking_list["$device_id"]=1  # Mark as accounted for
        return 0
    fi
    return 1
}

# Step 2: Loop through the list of mass storage devices
for device_id in $mass_storage_device_ids; do
    echo "Processing Mass Storage Device ID: $device_id"
    check_active_vm "$device_id" || check_mount_status "$device_id"
done

# Step 3: At the end, check which devices were not accounted for (unmounted)
for device_id in "${!mms_tracking_list[@]}"; do
    if [[ "${mms_tracking_list[$device_id]}" == 0 ]]; then
        echo "Mass Storage Device $device_id"
        get_device_info "$device_id"
        echo "No VM or mount information found for device $device_id"
        echo "Mass Storage Device $device_id" >> "$unmounted_devices_list"
        get_device_info "$device_id" >> "$unmounted_devices_list"
        echo "No VM or mount information found for device $device_id" >> "$unmounted_devices_list"
        echo "" >> "$unmounted_devices_list"
    fi
done

# Step 4: Display the results
echo "========Virtual Machine USB Device========"
cat "$running_vm_list"
echo ""
echo "========Unmounted Devices========"
cat "$unmounted_devices_list"
# Step 3: At the end, check which devices were not accounted for (unmounted)
for device_id in "${!mms_tracking_list[@]}"; do
    if [[ "${mms_tracking_list[$device_id]}" == 0 ]]; then
        echo "Mass Storage Device $device_id"
        get_device_info "$device_id"
        echo "No VM or mount information found for device $device_id"

        # Calculate the +2 device ID
        next_device_id=$(printf "%03d" $((10#$device_id + 2)))

        # Search for configuration for the +2 device ID
        mount_info=$(grep -A 10 "configuration_${next_device_id}" storage_devices.txt | grep "lastmountpoint")

        if [[ -n "$mount_info" ]]; then
            # Extract the mount point
            mount_point=$(echo "$mount_info" | grep -oP 'lastmountpoint=\K[^ ]+')
            echo "Checking last mount point: $mount_point"

            # Check if the mount point exists
            if [[ -z "$(ls $mount_point 2>/dev/null)" ]]; then
                echo "Mount point $mount_point not currently mounted"
            else
                echo "Mount point $mount_point is currently mounted"
            fi
        else
            echo "No mount information found for the +2 device ID ($next_device_id)"
        fi

        # Append to unmounted devices list
        echo "Mass Storage Device $device_id" >> "$unmounted_devices_list"
        get_device_info "$device_id" >> "$unmounted_devices_list"
        echo "No VM or mount information found for device $device_id" >> "$unmounted_devices_list"
        echo "" >> "$unmounted_devices_list"
    fi
done
