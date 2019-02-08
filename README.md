
# AzureFilesVPN - Point-to-Site Gateway
Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol. Azure file shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS.  While connecting from on-prem, sometimes ISPs block port 445.Azure VPN Gateway connects your on-premises networks to Azure through Point-to-Site VPNs in a similar way that you set up and connect to a remote branch office. The connectivity is secure and uses the industry-standard protocols SSTP.

With this tutorial, one will be able to work around port 445 block by sending SMB traffic over a secure tunnel instead of on internet.


## Step 1

Run the [generatecert.ps1](/generatecert.ps1) as Admin

![how to generate certs](/images/generatecertpowershell.jpg)

The Certificate Signature will be an input to the ARM template.

## Step 2 

Deploy the following ARM Template with sample parameters in [azuredeploy.parameters.json](azuredeploy.parameters.json)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

![deploy ARM Template](/images/ARMTemplateSample.png)

This template creates a VNet with a Gateway subnet. It then creates a public IP which is used to create a VPN Gateway in the VNet. Finally it configures a Dynamic Routing gateway with Point-to-Site configuration including VPN client address pool, client root certificates and revoked certificates and then creates the Gateway.

Modify parameters file to change default values.

* [https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal)

## Step 3

Download the VPN client

![download VPN client](/images/downloadvpnclient.jpg)

## Step 4

Unzip the VPN client and go to **Generic** folder. Open the **VpnSettings**

![VPNSetting](/images/GenericVpnSettings.JPG)

Copy the **VNetId**. It will be used in step below.

![VPNSetting](/images/howtocopyvnetid.JPG)

## Step 5

Run [RouteUpdatingScript.ps1](RouteUpdatingScript.ps1) powershell script.  In the script - Make sure to replace the VNet Id that was copiued in the step above and the file share information with your own.

## Step 6

To test out if the configuration is working fine, use the firewall enable/disable port 445

![How to enable/disable firewall for port 445 testing](/images/FirewallSettingsEnableDisable.jpg)