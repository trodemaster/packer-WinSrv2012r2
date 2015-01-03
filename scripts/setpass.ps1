# This script uses a password from the privatedata.json var file.
# This way we don't store final passwords in the source code. 
#Capture pass paramater
param (
    [string]$pass = "packer1!"
 )
net user packer $pass
