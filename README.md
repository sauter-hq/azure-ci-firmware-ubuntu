# Setup CI Node for Linux Docker build
```
wget https://raw.githubusercontent.com/sauter-hq/azure-ci-firmware-ubuntu/master/vsts-docker-setup.sh
sh vsts-docker-setup.sh https://dev.azure.com/sauterdevops *Personal-Access-Token* ciFirmwareUbuntu $HOSTNAME sauter
```

Those can be added to a VM Scalesets template to autoprovision the nodes for CI on startup : 

```
az vmss extension set   --publisher Microsoft.Azure.Extensions   --version 2.0   --name CustomScript   --resource-group Firmware-Group --vmss-name ciFirmwareUbuntu --settings '{
  "fileUris": [
    "https://raw.githubusercontent.com/sauter-hq/azure-ci-firmware-ubuntu/master/vsts-docker-setup.sh",
    "https://raw.githubusercontent.com/sauter-hq/azure-ci-firmware-ubuntu/master/prepare_vm_disks.sh"
  ],
  "commandToExecute": "sudo bash prepare_vm_disks.sh >> /home/sauter/datadisk.prepare.log 2>&1; sh vsts-docker-setup.sh https://dev.azure.com/sauterdevops *Personal-Access-Token* ciFirmwareUbuntu sauter /datadisks/disk1 >> /home/sauter/vsts.log.install.log 2>&1;"
}'
```

And then commiting the change to the instances : 
```
az vmss update-instances --resource-group Firmware-Group --name ciFirmwareUbuntu --instance-ids 3 4 5
```

Reimaging them might be necessary in some cases.
