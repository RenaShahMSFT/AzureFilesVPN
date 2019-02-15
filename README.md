# Azure Files - Point-to-Site VPN Tunnel
Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol. 

Azure file shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS.  

While connecting from on-prem, sometimes ISPs block port 445.Azure VPN Gateway connects your on-premises networks to Azure through Point-to-Site VPNs in a similar way that you set up and connect to a remote branch office. The connectivity is secure and uses the industry-standard protocols SSTP.

With this tutorial, one will be able to work around port 445 block by sending SMB traffic from a Windows machine over a secure tunnel instead of on internet.

## Prerequisite
 * You have a valid Subscription with admin permissions
 * A storage account
 * An Azure File Share
 * A Windows machine on which you would like to mount Azure file share


## Step 1 - Generate Root and Client Certificate

The steps below heps you create a Self-Signed certificate. If you're using an enterprise solution, you can use your existing certificate chain. Acquire the .cer file for the root certificate that you want to use.

* Run the [generatecert.ps1](/generatecert.ps1) powershell script **as Admin**
* **Copy** the certificate signature from output window (the highlighted portion in screenshot below).The Certificate Signature will be an input to the ARM template.

  ![how to generate certs](/images/generatecertpowershell.png)

This powershell script will generate self-signed root and client certificates and also export the root certificate signature and client certificate file. 

Certificates are used by Azure to authenticate clients connecting to a VNet over a Point-to-Site VPN connection. Once you obtain a root certificate, you upload the public key information to Azure. The root certificate is then considered 'trusted' by Azure for connection over P2S to the virtual network. You also generate client certificates from the trusted root certificate, and then install them on each client computer. The client certificate is used to authenticate the client when it initiates a connection to the VNet.

>> NOTE
>>
>> In case you are using an enterprise root certificate, modify the script accordingly and execute.

>> NOTE
>>
>> Client cert needs to be installed on every connecting client. You can either install the same client cert (after it is created and exported as done in the script above) or create one for each client using root cert.

## Step 2 - Deploy ARM Template to create VNet and P2S VPN Gateway
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

* Open [RouteSetupAndConnectToVPN.ps1](RouteSetupAndConnectToVPN.ps1) powershell script.

  ![Run Routing Script](/images/runroutingscript.png)

* Replace the **VNetId** value in RouteSetupAndConnectToVPN.ps1 by copying it from the **VPN client folder path\Generic\VpnSettings.xml**.

  ![VPNSetting](/images/GenericVpnSettings.png)

  ![VPNSetting](/images/howtocopyvnetid.png)

* Replace the **FileShareHostList**.  and the **Azure Storage file endpoint** information with your own. `You can give multiple accounts separated by comma.`
* Run the RouteSetupAndConnectToVPN.ps1 script **as ADMIN**.

>> NOTE
>>
>> Storage Account IP can get updated. RouteSetupAndConnectToVPN.ps1 should be run as a scheduled task at startup to reconnect the VPN if a constant connection is desired. It must be run with admin permissions.

This script will fetch the IP address of the Storage account in which your file share resides and update the routes.txt located under C:\users\<username>\AppData\Roaming\Microsoft\Network\Connections\Cm folder. This script will also connect to VPN.

## Conclusion

Thats it. This will get you to a Point to Site VPN setup that works well with Azure Files.

>> NOTE
>>
>> General instructions is available at [Point to Site Setup in Portal doc](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal). The above instructions are specific to Azure Files Point to Site VPN interop. In order for Point to Site VPN to work well with Azure Files, following considerations are necessary:
>> * Adding an Azure Storage service endpoint while creating virtual network is mandatory.
>>* Tunnel Type should only be SSTP.
>>* The running of RouteSetupAndConnectToVPN.ps1 is a mandatory step.