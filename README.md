# proxmox_disk_manager
Interact with Proxmox disks- showing Active Directory Mounts, InActive Directory Mounts, Proxmox Storage

> **`Active Directory Mounts`**
    -

Example Of OutputView:
```

Proxmox Storage Management (Default View)
================================================

                                                         -> Directory Mounts <┐
                                                      +--------------------------+
                                                                   \|/            +
                                                                    └────────────++
                                                                                  +
                                 -->> Active Directory Mounts <<--+++++++++++++++++
                                                 \|/                              +
                                                  |                               +
                                                  |                               +
                                                  |                               +
                                           \|/    |                               +
┌───────────────────────────────────────────┬─────┘          					  +
|  [1]┌─-->>> Non-Proxmox Storage <<<--- [1] |    (Active Mounts)                 +
|     └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘                                     +
|     +-------------------------------------+                                     +
|     | Disk Name       : sda                             |                       +
|     | Disk Path       : /dev/sda                        |                       +
|     | Disk Size       : 500G                            |                       +
|     | Disk Type       : SSD                             |                       +
|     | Is USB          : false                           |                       +
|     | Total Disk Usage:                                 |                       +
|     |   - Total Size  : 500G                            |                       +
|     |   - Used        : 200G                            |                       +
|     |   - Percentage  : 40%                             |                       +
|     | Number of Partitions: 2                           |                       +
|     +---------------------------------------------------+                       +
|     ┌── Partition: /dev/sda1                                                    +
|     │   Size: 250G                                                              +
|     │   Filesystem: ext4                                                        +
|     │   UUID: 1234-5678-ABCD-EFGH                                               +
|     │   Mount Path: /mnt/sda1                                                   +
|     │   Mount Status: Mounted                                                   +
|     │   History of Mount Paths: /mnt/sda1_old, /mnt/sda1_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 250G                                                      +
|     │   - Used: 100G                                                            +
|     │   - Percentage Used: 40%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: true                                                      +
|     │   - Which Running VM: VM1                                                 +
|     │   - History: VM1, VM2, VM3                                                +
|     │   Is Proxmox Storage: true                                                +
|     │   Proxmox Storage Type: ZFS                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDA1234SSD1_164814DC7F86                                   +
|     │   - By UUID: 1234-5678-ABCD-EFGH                                          +
|     │   - By PARTUUID: 10337ff6-29ac-4daf-948e-f64c67fd5642                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 37                                                           +
|     └──                                                                         +
|     ┌── Partition: /dev/sda2                                                    +
|     │   Size: 250G                                                              +
|     │   Filesystem: ntfs                                                        +
|     │   UUID: IJKL-MNOP-QRST-UVWX                                               +
|     │   Mount Path: (None)                                                      +
|     │   Mount Status: Unmounted                                                 +
|     │   History of Mount Paths: /mnt/sda2_old, /mnt/sda2_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 250G                                                      +
|     │   - Used: 150G                                                            +
|     │   - Percentage Used: 60%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: false                                                     +
|     │   - Which Running VM: (None)                                              +
|     │   - History: VM4, VM5                                                     +
|     │   Is Proxmox Storage: false                                               +
|     │   Proxmox Storage Type: N/A                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDB5678SSD1_20D11E804A16                                   +
|     │   - By UUID: 5678-1234-EFGH-ABCD                                          +
|     │   - By PARTUUID: 5678efgh-1234-abcd-5678-efgh1234abcd                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 38                                                           +
|     └──                                                                         +
|     +-------------------------------------+                                     +
|                                                                                 +
|                                                                                 +
|___________________________________________                                      +
                                           \|/                                    +
┌───────────────────────────────────────────┤                                     +
|   [2]┌─-->>> Proxmox Storage <<<--- [2]   |    (Active Mounts)                  +
|      └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘                                     +
|     +-------------------------------------+                                     +
|     | Disk Name       : sdb                             |                       +
|     | Disk Path       : /dev/sdb                        |                       +
|     | Disk Size       : 1TB                             |                       +
|     | Disk Type       : HDD                             |                       +
|     | Is USB          : true                            |                       +
|     | Total Disk Usage:                                 |                       +
|     |   - Total Size  : 1TB                             |                       +
|     |   - Used        : 500G                            |                       +
|     |   - Percentage  : 50%                             |                       +
|     | Number of Partitions: 2                           |                       +
|     +---------------------------------------------------+                       +
|     ┌── Partition: /dev/sdb1                                                    +
|     │   Size: 500G                                                              +
|     │   Filesystem: ext4                                                        +
|     │   UUID: ABCD-5678-EFGH-1234                                               +
|     │   Mount Path: /mnt/sdb1                                                   +
|     │   Mount Status: Mounted                                                   +
|     │   History of Mount Paths: /mnt/sdb1_old, /mnt/sdb1_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 500G                                                      +
|     │   - Used: 250G                                                            +
|     │   - Percentage Used: 50%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: false                                                     +
|     │   - Which Running VM: (None)                                              +
|     │   - History: VM6, VM7                                                     +
|     │   Is Proxmox Storage: true                                                +
|     │   Proxmox Storage Type: LVM                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDB1234SSD1_20D11E804A16                                   +
|     │   - By UUID: 5678-ABCD-EFGH-1234                                          +
|     │   - By PARTUUID: 5678abcd-1234-efgh-5678-abcd1234efgh                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 39                                                           +
|     └──                                                                         +
|     ┌── Partition: /dev/sdb2                                                    +
|     │   Size: 500G                                                              +
|     │   Filesystem: ntfs                                                        +
|     │   UUID: WXYZ-5678-ABCD-1234                                               +
|     │   Mount Path: (None)                                                      +
|     │   Mount Status: Unmounted                                                 +
|     │   History of Mount Paths: /mnt/sdb2_old, /mnt/sdb2_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 500G                                                      +
|     │   - Used: 350G                                                            +
|     │   - Percentage Used: 70%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: true                                                      +
|     │   - Which Running VM: VM8                                                 +
|     │   - History: VM9, VM10                                                    +
|     │   Is Proxmox Storage: false                                               +
|     │   Proxmox Storage Type: N/A                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDC1234SSD1_30D22E804A16                                   +
|     │   - By UUID: 5678-1234-WXYZ-ABCD                                          +
|     │   - By PARTUUID: 5678wxyz-1234-abcd-5678-wxyz1234abcd                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 40                                                           +
|     └──                                                                         +
|     +-------------------------------------+                                     +
|                                                                                +
|                                                                                +
|__________________________________________                                      +
*********************************************************************************+
                                                                                  +
                                                                                  +
                                                                                  +
                               -->> Inactive Directory Mounts <<--++++++++++++++++++
                                                 \|/                              +
                                                  |                               +
                                                  |                               +
                                                  |                               +
                                           \|/    |                               +
┌───────────────────────────────────────────┬─────┘                               +
|  [3]┌─-->>> Non-Proxmox Storage <<<--- [3] |      (NOT Active Mounts)            +
|     └┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┘                                     +
|     +-------------------------------------+                                      +
|     | Disk Name       : sdc                             |                       +
|     | Disk Path       : /dev/sdc                        |                       +
|     | Disk Size       : 1TB                             |                       +
|     | Disk Type       : HDD                             |                       +
|     | Is USB          : false                           |                       +
|     | Total Disk Usage:                                 |                       +
|     |   - Total Size  : 1TB                             |                       +
|     |   - Used        : 600G                            |                       +
|     |   - Percentage  : 60%                             |                       +
|     | Number of Partitions: 2                           |                       +
|     +---------------------------------------------------+                       +
|     ┌── Partition: /dev/sdc1                                                    +
|     │   Size: 500G                                                              +
|     │   Filesystem: ext4                                                        +
|     │   UUID: MNOP-1234-QRST-5678                                               +
|     │   Mount Path: /mnt/sdc1                                                   +
|     │   Mount Status: Mounted                                                   +
|     │   History of Mount Paths: /mnt/sdc1_old, /mnt/sdc1_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 500G                                                      +
|     │   - Used: 200G                                                            +
|     │   - Percentage Used: 40%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: false                                                     +
|     │   - Which Running VM: (None)                                              +
|     │   - History: VM11, VM12                                                   +
|     │   Is Proxmox Storage: true                                                +
|     │   Proxmox Storage Type: ZFS                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDD1234SSD1_40D22E804A16                                   +
|     │   - By UUID: MNOP-1234-QRST-5678                                          +
|     │   - By PARTUUID: mnop1234-5678-qrst-1234-mnop5678qrst                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 41                                                           +
|     └──                                                                         +
|     ┌── Partition: /dev/sdc2                                                    +
|     │   Size: 500G                                                              +
|     │   Filesystem: ntfs                                                        +
|     │   UUID: UVWX-5678-QRST-1234                                               +
|     │   Mount Path: (None)                                                      +
|     │   Mount Status: Unmounted                                                 +
|     │   History of Mount Paths: /mnt/sdc2_old, /mnt/sdc2_older                  +
|     │   Partition Usage:                                                        +
|     │   - Total Size: 500G                                                      +
|     │   - Used: 350G                                                            +
|     │   - Percentage Used: 70%                                                  +
|     │   VM Association:                                                         +
|     │   - Is Running: true                                                      +
|     │   - Which Running VM: VM13                                                +
|     │   - History: VM14, VM15                                                   +
|     │   Is Proxmox Storage: false                                               +
|     │   Proxmox Storage Type: N/A                                               +
|     │   System Paths:                                                           +
|     │   - By ID: ata-SDE1234SSD1_50D22E804A16                                   +
|     │   - By UUID: UVWX-5678-QRST-1234                                          +
|     │   - By PARTUUID: uvwx5678-1234-qrst-5678-uvwx1234qrst                     +
|     │   - By Path: /dev/disk/by-path/pci-0000:0e:00.0-usb-0:5:1.0-scsi-0:0:0:0  +
|     │   System Information:                                                     +
|     │   - PCIE Path: /sys/devices/pci0000:00/0000:00:14.0                       +
|     │   - Devpath: /devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1.4              +
|     │   - Diskseq: 42                                                           +
|     └──                                                                         +
|__________________________________________                                       +
********************************************************************************* +
                                                                                  +
                                                                                  +
                                                                                  +
                                      -->> Proxmox Storage <<--++++++++++++++++++++
                                                 \|/                              +
                                                  |                               +
                                                  |                               +
                                           \|/    |                               +
┌───────────────────────────────────────────┬─────┘                               +
```
