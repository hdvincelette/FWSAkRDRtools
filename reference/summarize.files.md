# Summarize project files on the USFWS Alaska Regional Data Repository (RDR)

Summarizes files in a specified RDR project folder. Remote users must be
connected to one of the Service’s approved remote connection
technologies, such as a Virtual Private Network (VPN).

## Usage

``` r
summarize.files(
  project,
  subfolder = NULL,
  main = TRUE,
  incoming = TRUE,
  recursive = TRUE
)
```

## Arguments

- project:

  Character string. Name of the project folder.

- subfolder:

  Optional character vector. Project subfolder(s) to summarize. Default
  is NULL, which returns results for all subfolders.

- main:

  Logical. Whether to return results from the main project subfolders
  (all subfolders except incoming). Default is TRUE.

- incoming:

  Logical. Whether to return results from the "incoming" project
  subfolder. Default is TRUE.

- recursive:

  Logical. Whether to search for files in subdirectories. Default is
  TRUE.

## Value

Returns a data frame summarizing subfolder contents.

## See also

[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)

## Examples

``` r
# e.g.summary<- summarize.files(project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder = c("/", "final_data", "metadata"), main = FALSE, incoming = TRUE, recursive = TRUE)
```
