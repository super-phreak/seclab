variable "hostname" {
  type    = string
  default = "seclab-win-server"
}

variable "username" {
  type    = string
  default = "seclab"
}

variable "password" {
  type    = string
  default = "Seclab123!"
}

variable "proxmox_hostname" {
  type    = string
  default = "starbase"
}

source "proxmox-iso" "seclab-win-server" {
  proxmox_url  = "https://${var.proxmox_hostname}:8006/api2/json"
  node         = "${var.proxmox_hostname}"
  iso_file     = "local:iso/Win-Server-2019.iso"
  iso_checksum = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"


  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-Win-Server.iso"
    iso_checksum = "sha256:730e592b2f9da8d489bf4bea607a15035ff9fc4fa5be928421000d1d14bc86fe"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:8a066741ef79d3fb66e536fb6f010ad91269364bd9b8c1ad7f2f5655caf8acd8"
    unmount      = true
  }

  insecure_skip_tls_verify  = true
  communicator = "ssh"
  ssh_username = "${var.username}"
  ssh_password = "${var.password}"
  ssh_timeout  = "30m"
  qemu_agent   = true
  // winrm_use_ssl           = true
  // guest_os_type           = "Windows2019_64"
  cores                = 2
  memory               = 4096
  vm_name              = "seclab-win-server"
  template_description = "Base Seclab Windows Server"
  
  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type              = "virtio"
    disk_size         = "50G"
    storage_pool_type = "lvm"
    storage_pool      = "local-lvm"
  }
  scsi_controller = "virtio-scsi-pci"
}


build {
  sources = ["sources.proxmox-iso.seclab-win-server"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig",
      "c:\\windows\\system32\\sysprep\\sysprep.exe /generalize /mode:vm /oobe /quiet /unattend:E:\\unattend.xml"
    ]
  }

}