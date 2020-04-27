<#
 Declares all original variables from the configuration files. These need to be set before run.                                        
#>
$root = $PSScriptRoot
$configdir = "$root\Config"
$mapsconfigdir = "$root\Maps"
$toproot = (Split-Path $root -Parent)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$vars = Get-Content -Path $configdir\vars.json | ConvertFrom-Json
$inputfile = Import-CSV $vars."input-csv" -Encoding $vars."input-encoding" -Delimiter $vars."input-delimiter"
$parseculture = [Globalization.CultureInfo]::CreateSpecificCulture($vars."culture")


<#
 Uses mapconf.csv and all mapfiles defined therein as configuration.
 For each column defined, applies the map.csv defined.
 the maps are always from column "old" to column "new".                           
#>

function remap {
   Write-Host "Entering Remap Mode"
    Import-csv "$configdir\mapconf.csv" |
        ForEach-Object {
            $csvmap = join-path -path $mapsconfigdir -childpath $_.map
            $column = $_.column
            $mapping = Import-CSV $csvmap -Encoding UTF8 -Delimiter ","
            $linenb = 0
            try{
                #create hash table
                $mappingTable = @{}
                foreach ($item in $mapping) {
                    $mappingTable.add($item.old,$item.new)
                }

                #replace values
                $inputfile | ForEach-Object {
                    $linenb ++
                    If( $mappingTable.ContainsKey($_.$column)) {
                        $_.$column = $mappingTable[$_.$column]
                    }
                }
                }catch{
                "error:"
                echo "line" $linenb
                echo "column" $_.$column
                echo "old" $item.old
                echo "new" $item.new
                echo "Exception" $_.Exception.Message
            }
        }
    Write-Host  "Done Remapping data !"
}



<#
 Uses dateconf.csv as a configuration file.
 In the Column defined, searches for a date in the format defined.
 Format can be written using the standard dd MMMM yy or any variation thereof.
 Always outputs salesforce-compatible yyyy-mm-dd.                                                 
#>
function clean-dates {
    echo "Entering Clean Dates mode"
    Import-csv "$configdir\dateconf.csv" |
        ForEach-Object {
            $column = $_.column
            [String]$format = $_.format
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                    $linenb = $linenb +1
                    if ($_.$column -ne "NULL" -and $_.$column -ne "") {
                        [String]$currentitem = $_.$column
                        $_.$column = [datetime]::parseexact($_.$column, $format, $parseculture).ToString('yyyy-MM-dd')
                    }
            }
            }catch{
                echo "column": $column
                echo "data" $currentitem
                echo "line" $linenb
                echo "error:" $Error
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
    echo "Entering Clean DateTimes mode"
    Import-csv "$configdir\datetimeconf.csv" |
        ForEach-Object {
            $column = $_.column
            [String]$format = $_.format
            $linenb = 0
                try{
                    $inputfile | ForEach-Object {
                        $linenb = $linenb +1
                        if ($_.$column -ne "NULL" -and $_.$column -ne $null) {
                        [String]$currentitem = $_.$column
                            $_.$column = ([datetime]::parseexact($_.$column, $format, $parseculture).ToString('yyyy-MM-ddThh:mm:ssZ'))
                         }
                }
                }catch{
                echo "column": $column
                echo "data" $currentitem
                echo "line" $linenb
                echo "error:" $Error
                }
        }
    }



<#
 Uses nullconf.csv as a configuration file.
 In the Column defined, matches the exact regex that is written in the format.
 Matches are then replaced with "".                                                    
#>
function clean-nulls {
    echo "Entering Clean Nulls mode"
    Import-csv "$configdir\nullconf.csv" |
        ForEach-Object {
            $column = $_.column
            [regex]$format = $_.format
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                   $linenb = $linenb +1
                   [String]$currentitem = $_.$column
                   $_.$column = $_.$column -replace $format, ''
                }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $column
            echo "format" $format
            echo "data" $currentitem
            pause
            }
        }
    }


<#
 Uses fillnullconf.csv as a configuration file.
 In the specified column, checks if the data is null, and if so populates the static text specified.                                                    
#>
function fill-nulls {
    echo "Entering Fill Nulls mode"
    Import-csv "$configdir\fillnullsconf.csv" |
        ForEach-Object {
            $column = $_.column
            $fillvalue = $_.fillvalue
            $linenb = 0
            try{
                #replace values
                $inputfile | ForEach-Object {
                    $linenb ++
                    If( $_.$column -eq "") {
                        $_.$column = $fillvalue
                    }
                }
                }catch{
                "error:"
                echo "line" $linenb
                echo "column" $_.$column
                echo "old" $item.old
                echo "new" $item.new
                echo "Exception" $_.Exception.Message
            }
        }
    }

<# Manual stuff goes here. Uncomment to use. Elements left for examples. Done after all functions run.#>

function manual {
<# Adds a column with a calculated value to CSV file 
            $inputfile | ForEach-Object {
                $linenb = $linenb +1
                If ($_.LeadStatus -eq "R") {
                    $_.LeadStatus = "Working"
                    $_ | Add-Member -NotePropertyName Rating -NotePropertyValue Cold
                }
            }
#>

<# Merges two CSV files, filtering some data out based on column values, adding a new column with information, and exporting it directly. Should be done before any other operation.
    Import-csv $CSVName -Encoding UTF8 -Delimiter "`t" | where {$_.COLUMN -eq "0"} | Select-Object *,@{Name='NewColumn';Expression={$_.COLUMN_A + $_.COLUMN_B}} |
    Export-CSV -Path $output -Encoding UTF8 -Delimiter "," -NoTypeInformation -Append

#>
}



<#
 Export results of all previous operations. Voodoo magic happens to remove the BOM.                                               
#>
function export {
    write-Host "Exporting Results"
    $inputfile | Export-CSV -Path $vars."output-csv" -NoTypeInformation -Encoding $vars."output-encoding" -Delimiter $vars."output-delimiter"
}

<#
  Cast the output to No-BOM format because Dataloader hates BOMs
#>
function no-bom {
    Write-Host "Finished processing-outputing no-BOM file"
    $temp = Get-Content $vars."output-csv"
    $output = [System.IO.File]::WriteAllLines($vars."output-csv", $temp, $Utf8NoBomEncoding)

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

if ($vars."operation-fill-nulls" -eq "true") {
    fill-nulls
}

manual

export
no-bom