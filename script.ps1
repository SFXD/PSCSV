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
$iovars="$configdir\iovars.txt"
Get-Content $iovars | Foreach-Object{
   $var = $_.Split('=')
   $var[0] = $var[1]
}
$csvinput = $csvinput -replace '"', ""
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
        #create hash table
        $mappingTable = @{}
        foreach ($item in $mapping) {
            $mappingTable.add($item.old,$item.new)
        }

        #replace values
        $inputfile | ForEach-Object {
            $linenb ++
            $_.$column = $mappingTable[$_.$column]
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
                $_.$column = [datetime]::parseexact($_.$column, $format, $null).ToString($output)
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
