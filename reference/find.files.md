# Find the location(s) of project file(s) on the USFWS Alaska Regional Data Repository (RDR)

Finds data file(s) from a specified RDR project folder. Remote users
must be connected to one of the Service’s approved remote connection
technologies, such as a Virtual Private Network (VPN).

## Usage

``` r
find.files(
  pattern,
  project,
  subfolder.path,
  main,
  incoming,
  recursive,
  full.path
)
```

## Arguments

- pattern:

  Character vector. File name pattern(s). Must be a regular expression;
  print ?base::regex for help. Not case-sensitive. Spaces are
  automatically replaced with ".\*?" to improve search results. Default
  is NULL, which returns results for all files.

- project:

  Character string. Project folder name. Can be a partial name formatted
  as a regular expression. Not case-sensitive.

- subfolder.path:

  Character string. Project subfolder path.

- main:

  Logical. Whether to return results from the main project subfolders
  (all subfolders except "incoming"). Default is TRUE.

- incoming:

  Logical. whether to return results from the "incoming" project
  subfolder. Default is TRUE.

- recursive:

  Logical. Whether to search for files in subdirectories. Default is
  TRUE.

- full.path:

  Logical. Whether to return full file path. Default is FALSE

## Value

Returns a vector of paths to files which match the search criteria.

## See also

[`download.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/download.files.md)

## Examples

``` r
# e.g.file.locs<- find.files(pattern = c("template","dictionary","\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "", main = FALSE, incoming = TRUE, recursive = TRUE, full.path = FALSE)
```
