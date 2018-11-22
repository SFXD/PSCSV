# PSCSV
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

A powershell script to help Salesforce admins and consultant to save tim and do data load operations without having to rely on Excel.

# Function

This script takes no arguments. Due to how paths are parsed, it may be necessary to run it in a folder where the patch does not have spaces in it.

Upon running, the script takes an input.csv file, stored in the same folder as the script, and loads it as objects in Powershell.
It will then take mapconf.csv, and using that, will replace, in the column defined by mapconf, the values defined in the "old" column by the ones in the "new" column.

If it encounters an error, it will dump the line number and the values of the mapping.

It will then use Dateconf.csv to sanitize date formats that you must specify in Regex (an example is provided in the config file).

It will finally use Nullconf.csv to remove "null" values based on formats that you must specify in regex as well.

It then outputs the result in output.csv, with commas, encoded in UTF8 in the same folder the script executed.

# Advantages

The script does not care for column order as it uses the columns header to target replacements.
It does not requires formulas, that's what it does.
Unlike spreadsheet software, it won't fuck up your dates or phone numbers.
It only does what is written above, but it does it well.

The script can, with minor modification, open a file witha  wrong delimiter or encoding, and save it back toa  proper UTF8 csv.