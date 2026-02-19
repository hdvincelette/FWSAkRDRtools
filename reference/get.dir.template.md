# Get the USFWS Alaska Regional Data Repository (RDR) project directory tree template.

Creates the RDR project folder structure in a specified location.

## Usage

``` r
get.dir.template(project, local.path, main = TRUE, incoming = FALSE)
```

## Arguments

- project:

  Character string. Name of the project folder.

- local.path:

  Character string. Directory path where the project will be located.
  Default is the working directory, getwd().

- main:

  Logical. Whether to include the main project subfolders (all
  subfolders except "incoming"). Default is TRUE.

- incoming:

  Logical. Whether to include the "incoming" project subfolder. Default
  is FALSE.

## Value

Returns a download of the project directory tree template.

## See also

[`clone.project()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/clone.project.md)

## Examples

``` r
# get.dir.template(project = "mbmlb_909_Eskimo_Curlew_study", local.path = getwd(), main = TRUE, incoming = TRUE)
```
