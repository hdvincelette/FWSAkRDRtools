# Find projects on the USFWS Alaska Regional Data Repository (RDR)

Finds RDR project name(s). Remote users must be connected to one of the
Service’s approved remote connection technologies, such as a Virtual
Private Network (VPN).

## Usage

``` r
find.projects(pattern, program, full.path)
```

## Arguments

- pattern:

  Character vector. Project folder name pattern(s). Must be a regular
  expression; print ?base::regex for help. Not case-sensitive. Spaces
  are automatically replaced with ".\*?" to improve search results.
  Default is NULL, which returns results for all project folders.

- program:

  Optional character string. Program prefix to help narrow search
  results. Options include "fes", "mbm", "nwrs", "osm", and "sa".

- full.path:

  Logical. Whether to return full folder path. Default is FALSE, and
  only the folder name is returned.

## Value

Returns a vector of paths or names of project folders which match the
search criteria.

## See also

[`find.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/find.files.md)

## Examples

``` r
# e.g.project.names<- find.projects(pattern = c("red.*knot","alaska"), program = "mbm", full.path = FALSE)
```
