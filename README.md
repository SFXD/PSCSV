# PSCSV
![Version](https://img.shields.io/badge/Version-1.1-blue.svg)

A powershell script to help Salesforce admins and consultant to save tim and do data load operations without having to rely on Excel.

# Function

This script takes no arguments. Due to how paths are parsed, it may be necessary to run it in a folder where the path does not have spaces in it.

The Config dir contains configuration files.

* iovars.txt defines the input file and the output file
* mapconf.csv defines which column in the csv should be replaced by which map (itself a csv file)
* dateconf.csv defines a regex that is used to replace dates in a specified column, and the output it should be formatted in
* nullconf.csv defines a regex that is used to select what to delete in a specified column.

If the script encounters an error, it will dump the line number and the values of the mapping.

Be default the script expects comma-separated values in UTF 8 though you can change that by editing the script itself.

# Advantages

The script does not care for column order as it uses the columns header to target replacements.
It does not requires formulas, that's what it does.
Unlike spreadsheet software, it won't fuck up your dates or phone numbers.
It only does what is written above, but it does it well.
Even non scripters can use it thanks to the config file.

The script can, with minor modification, open a file with a wrong delimiter or encoding, and save it back to proper UTF8 csv.
