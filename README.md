
# AzureFilesVPN - Point-to-Site Gateway
Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol. Azure file shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS.  While connecting from on-prem, sometimes ISPs block port 445.Azure VPN Gateway connects your on-premises networks to Azure through Point-to-Site VPNs in a similar way that you set up and connect to a remote branch office. The connectivity is secure and uses the industry-standard protocols SSTP.

With this tutorial, one will be able to work around port 445 block by sending SMB traffic over a secure tunnel instead of on internet.

## Prerequisite
 * You have a valid Subscription with admin permissions
 * A storage account
 * An Azure File Share
 * A windows machine on which you would like to mount Azure file share


## Step 1 - Generate Root Certificate

Run the [generatecert.ps1](/generatecert.ps1) as Admin

![how to generate certs](/images/generatecertpowershell.png)

The Certificate Signature will be an input to the ARM template.

## Step 2 - Deploy ARM Template


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Deploy the ARM Template by clicking above button - fill sample parameters from[azuredeploy.parameters.json](azuredeploy.parameters.json), however, make sure the root certificate signature is the one you created above.

This deployment takes ~20 minutes to complete.

![deploy ARM Template](/images/ARMTemplateSample.png)

This template creates a VNet with a Gateway subnet associated to Azure Storage Service endpoint. It then creates a public IP which is used to create a VPN Gateway in the VNet. Finally it configures a Dynamic Routing gateway with Point-to-Site configuration with protocol auth type SSTP including VPN client address pool, client root certificates and revoked certificates and then creates the Gateway.

Modify parameters file to change default values.

[https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal)

If you decide to instead follow the steps in guidance above, make the following minor modifications:

    * Add a service endpoint while creating VNet
    * Skip #3 – Its an optional step
    * When on #7 – Choose only sstp
    * Continue until step # 11 from the tutorial and then replace Step #12 onwards with process below. 

## Step 3 - Download the VPN client

Click on your gateway and go to the **Point to site** tab from the left pane. Download VPN client by clicking the button on the top.

![download VPN client](/images/downloadvpnclient.png)

## Step 4 - Copy VNetId

Unzip the VPN client and go to **Generic** folder. Open the **VpnSettings**

![VPNSetting](/images/GenericVpnSettings.png)

Copy the **VNetId**. It will be used in step below.

![VPNSetting](/images/howtocopyvnetid.png)

## Step 5 - Run the Script at every startup as Storage Account IP can get updated

Run [RouteUpdatingScript.ps1](RouteUpdatingScript.ps1) powershell script.  In the script - update the **VNetId** and **FileShareHostList**. Make sure to replace the **VNet Id** that was copied in the step above and the **Azure file share** information with your own.

## Step 6 - Test Connection 

To test out if the configuration is working fine, use the firewall enable/disable port 445

![How to enable/disable firewall for port 445 testing](/images/FirewallSettingsEnableDisable.png)