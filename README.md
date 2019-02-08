
# Azure Files - Point-to-Site VPN Tunnel
Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol. 

Azure file shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS.  

While connecting from on-prem, sometimes ISPs block port 445.Azure VPN Gateway connects your on-premises networks to Azure through Point-to-Site VPNs in a similar way that you set up and connect to a remote branch office. The connectivity is secure and uses the industry-standard protocols SSTP.

With this tutorial, one will be able to work around port 445 block by sending SMB traffic from a Windows machine over a secure tunnel instead of on internet.

>> Full instructions with step by step tutorial is available at [Point to Site Setup in Portal doc](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal). Make the following minor modifications while following the tutorial from docs site:
>> * Add a Azure Storage service endpoint while creating virtual network.
 >>* Skip optional step #3 to "Specify a DNS server"
 >>* When on step #7 "Configure tunnel type", choose Tunnel Type to be only SSTP.
>>* Continue until step # 11 from the tutorial and then replace Step #12 "Connect to Azure Step" onwards with running the RouteUpdatingScript.ps1 as indicated below in this tutorial.

## Prerequisite
 * You have a valid Subscription with admin permissions
 * A storage account
 * An Azure File Share
 * A Windows machine on which you would like to mount Azure file share


## Step 1 - Generate Root Certificate

* Run the [generatecert.ps1](/generatecert.ps1) powershell script **as Admin**
* **Copy** the certificate signature from output window (the highlighted portion in screenshot below).The Certificate Signature will be an input to the ARM template.

  ![how to generate certs](/images/generatecertpowershell.png)



## Step 2 - Deploy ARM Template
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRenaShahMSFT%2FAzureFilesVPN%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

* Click **Deploy To Azure** button 
* Make sure the **clientRootCert** name and signature is the one you created and copied from previous step
* Fill other necessary info and click **Purchase**.
* This deployment takes ~30-45 minutes to complete.

This template creates a VNet with a Gateway subnet associated to Azure Storage Service endpoint. It then creates a public IP which is used to create a VPN Gateway in the VNet. Finally it configures a Dynamic Routing gateway with Point-to-Site configuration with tunnel type SSTP including VPN client address pool, client root certificates and revoked certificates and then creates the Gateway.

## Step 3 - Download and install the VPN client

* Once the deployment fully completes, click on your gateway and go to the **Point to site** tab from the left pane. **Download VPN client** by clicking the button on the top.

  ![download VPN client](/images/downloadvpnclient.png)

* Unzip the client and browse into the folder.

* If you are running amd64 - Run **VpnClientSetupAmd64.exe** from downloaded **WindowsAmd64** folder, run the x86 version in case your client is x86.

  ![Install VPN Client](/images/installvpnclient.png)

## Step 4 - Configure VPN route so that traffic to specified Storage account(s) goes through the VPN Tunnel and connect to VPN

* Open [RouteUpdatingScript.ps1](RouteUpdatingScript.ps1) powershell script.

  ![Run Routing Script](/images/runroutingscript.png)

* Replace the **VNetId** value in RouteUpdatingScript.ps1 by copying it from the **VPN client folder path\Generic\VpnSettings.xml**.

  ![VPNSetting](/images/GenericVpnSettings.png)

  ![VPNSetting](/images/howtocopyvnetid.png)

* Replace the **FileShareHostList**.  and the **Azure Storage file endpoint** information with your own. `You can give multiple accounts separated by comma.`
* Run the RouteUpdatingScript.ps1 script. RouteUpdatingScript.ps1 ideally needs to be run at every startup as Storage Account IP can get updated

This script will fetch the IP address of the Storage account in which your file share resides and update the routes.txt located under C:\users\<username>\AppData\Roaming\Microsoft\Network\Connections\Cm folder. This script will also connect to VPN.

## Step 5 - Test Connection 

* To test out if the configuration is working fine disable port 445

  ![How to enable/disable firewall for port 445 testing](/images/FirewallSettingsEnableDisable.png)

* Mount file share - It should now succeed.