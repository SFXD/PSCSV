<#
 Declares all Original variables. These need to be set before run.
 If file is in the same folder, simply reference the name.        
 Map tells the script what values (old) to replace with what (new)
 Csvinput is the file that you need treated                       
 Csvoutput is the file you generate at the end.                   
 Please remember to check the delimiter and encoding of the file  
 that you are importing.                                          
#>
$root=$PSScriptRoot
$configdir = "$root\Config"
$mapsconfigdir = "$root\Maps"
$csvinput = "$root\inputfile.csv"
$csvoutput = "$root\output.csv";
$inputfile = Import-CSV $csvinput -Encoding UTF8 -Delimiter ","
echo "Finished initializing objects and data!"

<#
 Iterate through file and apply map.csv on a specific column.      
 Remember to specify which column.                                 
#>
Import-csv "$configdir\mapconf.csv" |
    ForEach-Object {
    $csvmap = join-path -path $mapsconfigdir -childpath $_.map
    $column = $_.column
    $mapping = Import-CSV $csvmap -Encoding UTF8 -Delimiter ","
    $linenb = 0
    try{
        foreach ($item in $mapping) {
                $inputfile | ForEach-Object {
                    If ($_.$column -eq $item.old) {
                        $linenb = $linenb +1
                        $_.$column = $_.$column.replace($item.old,$item.new)
                    }
                }
            }
        }catch{
        "error:"
        echo "line" $linenb
        echo "column" $_.$column
        echo "old" $item.old
        echo "new" $item.new
        echo "Exception" $_.Exception.Message
        pause
    }
    }
echo "Done Remapping data !"

<#
 Sanitize dates                                                     
#>

Import-csv "$configdir\dateconf.csv" |
    ForEach-Object {
        $column = $_.column
        [regex]$format = $_.format
        [regex]$output = $_.output
        $linenb = 0
        try{
            $inputfile | ForEach-Object {
                $linenb = $linenb +1
                $_.$column = $_.$column -replace $format, $output
        }
        }catch{
        "error:"
        echo "line" $linenb
        echo "column" $_.$column
        echo "format" $format
        echo "output" $output
        echo "Exception" $_.Exception.Message
        pause
        }
    }

echo "Done reformatting dates !"

<#
 Sanitize nulls                                                     
#>

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
        echo "Exception" $_.Exception.Message        
        pause
        }
    }

echo "Done sanitizing null values !"
<#
 Export results                                                   
#>
$inputfile | Export-CSV -Path $csvoutput -NoTypeInformation -Encoding UTF8 -Delimiter ","