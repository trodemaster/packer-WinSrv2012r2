packer-WinSrv2012r2
===================

packer.io template and related scripts for building Windows Server 2012 r2 ESXi virtual machines. 

Based off of https://github.com/joefitzgerald/packer-windows

This is a simplified version of our Windows Server 2012 r2 packer template for ESXi/vCloud Director. I'm posting this to share some different approaches to building the windows image and related code. 

Interesting parts of this template
1. Boot from pvscsi virtual disk adapter. 
2. Use vmxnet3 virtual network adapter.
3. Build the image using a commercial ssh server from http://www.bitvise.com/ssh-server
4. Running windows updates from a packer shell provisioner.
5. Using -var-file to hold final windows password and wsus server settings per packer build machine. 
6. Uninstalling the SSH server on shutdown. 
7. Improved cleanup of the disk using dism for smaller vmdk size.
8. Setting a wsus group and local IP to speed up build time. 
9. Installing VMware tools from a specific installer with powershell.

Populating the FILES directory is required before build. 
<pre>
├── SDelete.zip              http://download.sysinternals.com/files/SDelete.zip
├── certmgr.exe              Part of VMware tools install
├── pvscsi                   Extract from VMware tools installer http://kb.vmware.com/kb/2032184
│   ├── pvscsi.cat
│   ├── pvscsi.inf
│   ├── pvscsi.sys
│   └── txtsetup.oem
├── setup64.exe              VMware tools installer
├── ultradefrag-portable-6.0.4.bin.amd64.zip    http://sourceforge.net/projects/ultradefrag/files/stable-release/6.0.4/ultradefrag-portable-6.0.4.bin.amd64.zip
├── vmware.cer               Part of VMware tools install
└── vmxnet3                  Extract from VMware tools installer http://kb.vmware.com/kb/2032184
    ├── vmxnet3n61x64.sys
    ├── vmxnet3n61x86.sys
    ├── vmxnet3ndis6.cat
    ├── vmxnet3ndis6.inf
    └── vmxnet3ndis6ver.dll</pre>

VMware tools install info..
http://pubs.vmware.com/vsphere-55/topic/com.vmware.vsphere.vm_admin.doc/GUID-7E1225DC-9CC6-401A-BE40-D78110F9441C.html

Building the image
I recommend getting ahold of a Windows Server 2012 r2 with update .iso to use. You will need to place the .iso into the ISO directory and make sure the checksum and file names match the template .json file.  To specify your local wsus Server
you will need to make a copy of the Example-privatedata.json file. In this privatedata.json file add your windows image password, wsus IP and wsus group. You will need to have a wsus server setup with the groups and configured to allow the registry settings of the client to specify the group. 


packer build --force -var-file privatedata.json WinSrv2012r2.json
