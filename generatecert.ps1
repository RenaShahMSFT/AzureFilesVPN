# Variables

$parentcertname = "CN=P2SRootCert"
$clientcertname = "CN=P2SChildCert"
$certLocation = "Cert:\CurrentUser\My"
$pathtostoreoutputfiles = "C:\"
$clientcertpassword = "1234"
$exportedencodedrootcertpath = $pathtostoreoutputfiles + "P2SRootCertencoded.cer"
$exportedrootcertpath = $pathtostoreoutputfiles + "P2SRootCert.cer"
$exportedclientcertpath = $pathtostoreoutputfiles + "P2SClientCert.pfx"

# Create, install and Export Self-Signed Root Certificate Signature

$parentcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject $parentcertname -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation $certLocation -KeyUsageProperty Sign -KeyUsage CertSign
Export-Certificate -Cert $parentcert -FilePath $exportedencodedrootcertpath -NoClobber
certutil -encode $exportedencodedrootcertpath  $exportedrootcertpath
Get-Content -Path $exportedrootcertpath

# Create, install and export Client Certificate pfx file

$clientcert = New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature -Subject $clientcertname -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation $certLocation -Signer $parentcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
$mypwd = ConvertTo-SecureString -String $clientcertpassword -Force -AsPlainText
Export-PfxCertificate -FilePath $exportedclientcertpath -Password $mypwd -Cert $clientcert

# Cleanup unwanted files

Remove-Item -Path $exportedencodedrootcertpath
Remove-Item -Path $exportedrootcertpath
