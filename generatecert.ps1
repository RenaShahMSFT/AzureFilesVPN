$parentcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=P2SRootCert" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
$clientcert = New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature -Subject "CN=P2SChildCert" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -Signer $parentcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
Export-Certificate -Cert $parentcert -FilePath c:\P2SRootCertencoded.cer -NoClobber
certutil -encode c:\P2SRootCertencoded.cer c:\P2SRootCert.cer 
Get-Content -Path c:\P2SRootCert.cer
Remove-Item -Path c:\P2SRootCertencoded.cer
Remove-Item -Path c:\P2SRootCert.cer