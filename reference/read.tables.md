# Read a tabular project file on the USFWS Alaska Regional Data Repository (RDR) into R

Reads in tabular data file(s) from a specified RDR project folder.
Currently reads xls/xlsx (via readxl::read_excel) and csv (via
utils::read.csv) table formats. Remote users must be connected to one of
the Service’s approved remote connection technologies, such as a Virtual
Private Network (VPN).

## Usage

``` r
read.tables(
  pattern,
  project,
  subfolder.path,
  main,
  incoming,
  recursive,
  header,
  na.strings,
  sep
)
```

## Arguments

- pattern:

  Character vector. File name pattern(s). Must be a regular expression;
  print ?base::regex for help. Default is NULL, which allows a selection
  from all files.

- project:

  Character string. Name of the project folder.

- subfolder.path:

  Character string. Project subfolder path.

- main:

  Logical. Whether to return results from the main project subolders
  (all subfolders except "incoming"). Default is TRUE.

- incoming:

  Logical. Whether to return results from the "incoming" project
  subfolder. Default is TRUE.

- recursive:

  Logical. Whether to search for and read in files in subdirectories.
  Default is TRUE.

- header:

  Logical. Whether the first line contains variable names. Default is
  TRUE. Only applies to csv files.

- na.strings:

  Character vector. Strings which are to be interpreted as NA values.

## Value

Returns a data frame (if only one file selected), or list of selected
tabular data files.

## See also

[`find.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/find.files.md)

## Examples

``` r
# e.g.tabular.data<- read.tables(pattern = c("\.csv","\.xlsx"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "", main = TRUE, incoming = TRUE, recursive = TRUE, header = TRUE, na.strings = "")
```
