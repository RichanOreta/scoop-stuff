# Usage: scoop reg list|import [<program>] [<registry file>]
# Summary: Lists and imports registry file from programs
# Help: e.g. A way to list and import registry files in programs
#
# To list all registry files from all programs that has registry files:
#      scoop reg list
#
# To list the registry files in a given program:
#      scoop reg list vscodium
#
# To import a selected registry file from a given program:
#      scoop reg import vscodium install-context.reg

# To import multiple registry files from a given program:
#      scoop reg import vscodium install-context.reg,install-associations.reg
#
# Options:
#   list              lists the programs registry files
#   import            imports the registry file selected in the program

param([String]$cmd, [String]$program, [String[]]$registry_files)

. "$PSScriptRoot\..\lib\core.ps1"

$local = installed_apps $false | ForEach-Object { @{ name = $_ } }
$global = installed_apps $true | ForEach-Object { @{ name = $_; global = $true } }
$apps = @($local) + @($global)
$search_all = $false
$reg_files = ''

if (([string]::IsNullOrEmpty($cmd))) {
    error "No command argument"
} elseif (([string]::IsNullOrEmpty($program)) -and $cmd -eq 'list') {
    $search_all = $true
    $apps | where-object { !$query -or ($_.name -match $query) } | foreach-object {
        if ($search_all) {
            $name = $_.name
            $reg_files = get-childitem -path $scoopdir\apps\$name\current *.reg -recurse -depth 0 -file -name

            if ($null -ne $reg_files) {
                write-host("$($name):")

                for ($i = 0; $i -lt $reg_files.length; $i++) {
                    write-host("    $($reg_files[$i])")
                }
                write-host("")
            }
        }
    }
} elseif ($null -ne $program -and $cmd -eq 'list') {
    if (test-path $scoopdir\apps\$program\current\) {
        $reg_files = get-childitem -path $scoopdir\apps\$program\current *.reg -recurse -depth 0 -file -name
        if ($null -ne $reg_files) {
            write-host("$($program):")

            for ($i = 0; $i -lt $reg_files.length; $i++) {
                write-host("    $($reg_files[$i])")
            }
            write-host("")
        }
    }
    else {
        error "'$($program)' does not exist"
    }
} elseif ($cmd -eq "import") {
    if (Test-Path $scoopdir\apps\$program\current) {
        try {
            foreach ($regfilename in $registry_files.split(",")) {
                if (-not $regfilename.Contains('.reg')) {
                    $regfilename = $regfilename + '.reg'
                }

                if (test-path $scoopdir\apps\$program\current\$regfilename) {
                    reg import $scoopdir\apps\$program\current\$regfilename
                }
                else {
                    error "'$($regfilename)' does not exist"
                }
            }
        }
        catch {
            error "no .reg file was passed as an argument"
        }
    }
    else {
        error "'$($program)' does not exist"
    }
}
