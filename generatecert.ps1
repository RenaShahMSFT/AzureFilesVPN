$parentcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=P2SRootCert" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
Export-Certificate -Cert $parentcert -FilePath c:\P2SRootCertencoded.cer -NoClobber
certutil -encode c:\P2SRootCertencoded.cer c:\P2SRootCert.cer 
Get-Content -Path c:\P2SRootCert.cer