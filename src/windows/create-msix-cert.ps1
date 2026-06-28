# create-msix-cert.ps1
# Creates a self-signed code-signing certificate for MSIX sideloading.
# Run as Administrator so the cert can be installed to LocalMachine\TrustedPeople.
#
# Usage:
#   .\create-msix-cert.ps1 [-Subject "CN=RaspberryPiImager"] [-PfxPassword "changeme"]
#
# The Subject must match the MSIX_PUBLISHER_DN CMake option exactly.

param(
    [string]$Subject     = "CN=RaspberryPiImager",
    [string]$PfxPassword = "rpiimager",
    [string]$OutputDir   = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$pfxPath = Join-Path $OutputDir "RpiImager-test.pfx"
$cerPath = Join-Path $OutputDir "RpiImager-test.cer"

Write-Host "Creating self-signed certificate: $Subject"

$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject $Subject `
    -KeyUsage DigitalSignature `
    -FriendlyName "Raspberry Pi Imager (MSIX Test)" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

Write-Host "Thumbprint: $($cert.Thumbprint)"

$pwd = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" `
    -FilePath $pfxPath -Password $pwd | Out-Null
Write-Host "PFX: $pfxPath"

Export-Certificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" `
    -FilePath $cerPath | Out-Null
Write-Host "CER: $cerPath"

# Install public cert to LocalMachine\TrustedPeople so Windows accepts the MSIX
try {
    Import-Certificate -FilePath $cerPath `
        -CertStoreLocation Cert:\LocalMachine\TrustedPeople | Out-Null
    Write-Host "Installed to LocalMachine\TrustedPeople - sideloading enabled."
} catch {
    Write-Warning "Could not install to LocalMachine\TrustedPeople (needs Administrator)."
    Write-Warning "Manually install $cerPath there, or re-run this script as Administrator."
}

Write-Host ""
Write-Host "Configure CMake with these options to enable MSIX signing:"
Write-Host "  -DENABLE_MSIX=ON"
Write-Host "  -DMSIX_PUBLISHER_DN=`"$Subject`""
Write-Host "  -DMSIX_SIGN_PFX=`"$pfxPath`""
Write-Host "  -DMSIX_SIGN_PFX_PASSWORD=`"$PfxPassword`""
Write-Host ""
Write-Host "Then build the 'msix_package' target."
