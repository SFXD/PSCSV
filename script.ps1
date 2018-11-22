<#
 Declares all Original variables. These need to be set before run.
 If file is in the same folder, simply reference the name.        
 Csvinput is the file that you need treated                       
 Csvoutput is the file you generate at the end.                   
 Please remember to check the delimiter and encoding of the file  
 that you are importing.                                          
#>

$configdir = ".\Config"
$mapsconfigdir = ".\Maps"
$csvinput = ".\input.csv"
$csvoutput = ".\output.csv"
$inputfile = Import-CSV $csvinput -Encoding UTF8 -Delimiter ","

<#
 Iterate through file and apply map.csv on a specific column.      
 Remember to specify which column.                                 
#>
Get-ChildItem $configdir -Filter mapconf.csv | 
ForEach-Object {
    Import-csv $_.FullName |
    ForEach-Object {
        $csvmap = join-path -path $mapsconfigdir -childpath $_.map
        $column = $_.column
        $mapping = Import-CSV $csvmap -Encoding UTF8 -Delimiter ","
        foreach ($item in $mapping) {
            $linenb = 0
            try{
                $inputfile | ForEach-Object {
                    $linenb = $linenb +1
                    $_.$column = $_.$column.replace($item.old,$item.new)
                }
            }catch{
            "error:"
            echo "line" $linenb
            echo "column" $_.$column
            echo "old" $item.old
            echo "new" $item.new
            }
        }
    }
}


<#
 Sanitize dates                                                     
#>

Get-ChildItem $configdir -Filter dateconf.csv | 
ForEach-Object {
    Import-csv $_.FullName |
    ForEach-Object {
        $column = $_.column
        [regex]$format = $_.format
        [regex]$output = $_.output
        $linenb = 0
        try{
            $inputfile | ForEach-Object {
                $_.$column = $_.$column -replace $format, $output
        }
        }catch{
        "error:"
        echo "line" $linenb
        echo "column" $_.$column
        echo "format" $format
        echo "output" $output
        }
    }
}

<#
 Sanitize nulls                                                     
#>

Get-ChildItem $configdir -Filter nullconf.csv | 
ForEach-Object {
    Import-csv $_.FullName |
    ForEach-Object {
        $column = $_.column
        [regex]$format = $_.format
        $linenb = 0
        try{
            $inputfile | ForEach-Object {
               $_.$column = $_.$column -replace $format, ''
            }
        }catch{
        "error:"
        echo "line" $linenb
        echo "column" $_.$column
        echo "format" $format
        }
    }
}

<#
 Export results                                                   
#>
$inputfile | Export-CSV -Path $csvoutput -NoTypeInformation -Encoding UTF8 -Delimiter ","