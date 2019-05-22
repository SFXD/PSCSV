<#
 Declares all original variables from the configuration files. These need to be set before run.                                        
#>
$root = $PSScriptRoot
$configdir = "$root\Config"
$mapsconfigdir = "$root\Maps"
$toproot = (Split-Path $root -Parent)

$vars = Get-Content -Path $configdir\vars.json | ConvertFrom-Json

$inputfile = Import-CSV $vars."input-csv" -Encoding $vars."input-encoding" -Delimiter $vars."input-delimiter"


<#
 Uses mapconf.csv and all mapfiles defined therein as configuration.
 For each column defined, applies the map.csv defined.
 the maps are always from column "old" to column "new".                           
#>

function remap {
    Import-csv "$configdir\mapconf.csv" |
        ForEach-Object {
        $csvmap = join-path -path $mapsconfigdir -childpath $_.map
        $column = $_.column
        $mapping = Import-CSV $csvmap -Encoding UTF8 -Delimiter ","
        $linenb = 0
        try{
            foreach ($item in $mapping) {
                $inputfile | ForEach-Object {
                        $_.$column = $_.$column.replace($item.old,$item.new)
                     }
                }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $_.$column
            echo "format" $format
            echo "output" $output
            echo $Error
            pause
            }
        }
    }



<#
 Uses dateconf.csv as a configuration file.
 In the Column defined, searches for a date in the format defined.
 Format can be written using the standard dd MMMM yy or any variation thereof.
 Always outputs salesforce-compatible yyyy-mm-dd.                                                 
#>
function clean-dates {
    Import-csv "$configdir\dateconf.csv" |
        ForEach-Object {
            $column = $_.column
            [String]$format = $_.format
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                    $linenb = $linenb +1
                    $_.$column = [datetime]::parseexact($_.$column, $format, $null).ToString('yyyy-MM-dd')
 
            }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $_.$column
            echo "format" $format
            echo "output" $output
            pause
            }
        }
    }


<#
 Uses datetimeconf.csv as a configuration file.
 In the Column defined, searches for a date in the format defined.
 Format can be written using the standard dd MMMM yy hh mm ss or any variation thereof.
 Always outputs salesforce-compatible yyyy-mm-ddTHH:mm:ssZ.                                                 
#>
function clean-datetimes {
    Import-csv "$configdir\datetimeconf.csv" |
        ForEach-Object {
            $column = $_.column
            [String]$format = $_.format
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                    $linenb = $linenb +1
                    $_.$column = [datetime]::parseexact($_.$column, $format, $null).ToString('yyyy-MM-ddThh:mm:ss')
 
            }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $_.$column
            echo "format" $format
            echo "output" $output
            pause
            }
        }
    }



<#
 Uses nullconf.csv as a configuration file.
 In the Column defined, matches the exact regex that is written in the format.
 Matches are then replaced with "".                                                    
#>
function clean-nulls {
    Import-csv "$configdir\nullconf.csv" |
        ForEach-Object {
            $column = $_.column
            [regex]$format = $_.format
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                   $linenb = $linenb +1
                   $_.$column = $_.$column -replace $format, ''
                }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $_.$column
            echo "format" $format
            pause
            }
        }
    }
    


<#
 Export results of all previous operations.                                                
#>
function export {
    $inputfile | Export-CSV -Path $vars."output-csv" -NoTypeInformation -Encoding $vars."output-encoding" -Delimiter $vars."output-delimiter"
}

<#
 Call the functions based on configuration so the script does stuff.
 #>
if ($vars."operation-remap" -eq "true") {
    remap
}

if ($vars."operation-clean-dates" -eq "true") {
    clean-dates
}

if ($vars."operation-clean-datetimes" -eq "true") {
    clean-datetimes
}

if ($vars."operation-clean-nulls" -eq "true") {
    clean-nulls
}
export