# AzureFilesVPN
If you have ever been blocked using Azure Files due to your ISP's port 445, you can setup a Point to Site VPN to your Azure Files. The following high level steps tells you how to do so.

* Follow the steps listed here [https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal](https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal)
* Changes that you make to above are:
    * Add a service endpoint while creating VNet
    * Skip #3 – Its an optional step
    * When on #7 – Choose only sstp (uncheck IKEv2)
    * And Replace Step #12 with running [RouteUpdatingScript.ps1](RouteUpdatingScript.ps1) powershell script.  In the script - Make sure to replace the VNet Id and the file share information with your own.

To test out if the configuration is working fine, use the firewall enable/disable port 445

![How to enable/disable firewall for port 445 testing](/images/FirewallSettingsEnableDisable.jpg)
