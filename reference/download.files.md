# Download project file(s) from the USFWS Alaska Regional Data Repository (RDR)

Searches for file name patterns in a specified RDR project folder and
downloads all matching files. Remote users must be connected to one of
the Service’s approved remote connection technologies, such as a Virtual
Private Network (VPN).

## Usage

``` r
download.files(
  pattern,
  project,
  subfolder.path,
  local.path,
  main,
  incoming,
  recursive,
  download.file.method
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

- local.path:

  Character string. Directory path where the downloaded files will be
  saved. Default is the working directory, getwd().

- main:

  Logical. Whether to return results from the main project subfolders
  (all subfolders except "incoming"). Default is TRUE.

- incoming:

  Logical. Whether to return results from the "incoming" project
  subfolder. Default is TRUE.

- recursive:

  Logical. Whether to search for and download files in subdirectories.
  Default is TRUE.

- download.file.method:

  Character string. Method to use for downloading files. Print
  ?download.file for available methods. Default is "auto".

## Value

Returns file download(s) which match the search criteria.

## See also

[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)

## Examples

``` r
# download.files(pattern = c("template","dictionary","\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "metadata, local.path = getwd(), main = TRUE, incoming = TRUE, recursive = TRUE, download.file.method = "curl")
```
