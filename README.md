# PSCSV
![Version](https://img.shields.io/badge/Version-1.2-blue.svg)

A powershell script to help Salesforce admins and consultant to save time and do data load operations without having to rely on Excel.

Current list of stuff the script can do:

	 - transcode a file from one encoding or separator to another
	 - remap values in a column from one to another
	 - reformat Dates from whatever format to the salesforce format
	 - reformat Date Times from whatever format to the salesforce format
	 - replace whatever you want in a column with "" - great if someone is sending you files with `null`.

# Function

This script takes no arguments. The configuration is done via one JSON file and multiple CSV files, based on what you want to do.
The Config dir contains the configuration files.

* `vars.json` contains the basic config:

	- the path to your files (windows users, replace "\" with "/");
	- the delimiter of the input and output files;
	- the encoding of the input and output files;
	- switches to control what the script will do. Switch the operations to "false" if you don't need remap for example. Operations are remap, clean-dates, clean-datetimes, clean-nulls.

* `mapconf.csv` defines which column in the csv should be replaced by which map (itself a csv file, stored in "maps" dir)
* `dateconf.csv` defines a column to look in for a date that needs to be reformatted. It understands any variation of dd-MM-YYYY or d MMMM yy, _etc_.
* `datetimeconf.csv` is the same as dateconf but reformats to datetime in format `YYYY-MM-DDTHH:MM:SSZ`.
* `nullconf.csv` defines a regex that is used to select what to delete in a specified column.

If the script encounters an error, it will dump the line number and the values of the mapping, as well as the error, before pausing the script.

You can remove or delete the pause if errors are expected and will not be remediated.

# Manual

The script references a "Manual" mode.
This is for manual operations, and is empty except for commented code by default.
The commented code serves as examples.
Just add operations you want to do in there and they will run.


# Advantages

The script does not care for column order as it uses the columns header to target replacements.
It does not requires formulas, that's what it does.
Unlike spreadsheet software, it won't fuck up your dates or phone numbers.
It only does what is written above, but it does it well.
Even non scripters can use it thanks to the config file.

The script can, with minor modification, open a file with a wrong delimiter or encoding, and save it back to proper UTF8 csv.