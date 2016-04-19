function Compress-ToZip
{
    param( $zipfilename, $sourcedir )
    Add-Type -Assembly System.IO.Compression.FileSystem 
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $true) 
}

# Define the custom rules
$CustomRules = @(
    @{lang="nodejs";uri="https://raw.githubusercontent.com/awslabs/aws-config-rules/master/node/cloudtrail_enabled_all_regions-periodic.js"},
    @{lang="nodejs";uri="https://raw.githubusercontent.com/awslabs/aws-config-rules/master/node/iam_mfa_require_root-periodic.js"}
    @{lang="nodejs";uri="https://raw.githubusercontent.com/awslabs/aws-config-rules/master/node/iam_password_minimum_length-periodic.js"}
    @{lang="python2.7";uri="https://raw.githubusercontent.com/awslabs/aws-config-rules/master/python/ec2-exposed-instance.py"}
)

# Prepare directory
$CurFolder = Split-Path -parent $PSCommandPath
$TempRoot = "$CurFolder\temp"
New-Item $TempRoot -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Loop through the custom rules to download and package them
foreach($CustomRule in $CustomRules){
    
    $FileName = Split-Path $CustomRule.uri -Leaf
    $ZipName = $FileName -replace '\.\w*$',".zip"
    $TempFolder = "$TempRoot\$FileName\"

    # Cleanup & Prepare
    New-Item $TempFolder -ItemType Directory -ErrorAction SilentlyContinue | out-null
    Remove-Item "$TempRoot\$ZipName" -Force -ErrorAction SilentlyContinue

    # Download & Zip
    Invoke-WebRequest -Uri $CustomRule.uri -OutFile "$TempFolder\$FileName"
    Compress-ToZip -zipfilename "$TempRoot\$ZipName" -sourcedir $TempFolder
}