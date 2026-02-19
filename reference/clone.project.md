# Clone a project from the USFWS Alaska Regional Data Repository (RDR)

Creates a copy of a RDR project folder in a specified location. Remote
users must be connected to one of the Service’s approved remote
connection technologies, such as a Virtual Private Network (VPN).

## Usage

``` r
clone.project(project, local.path, main, incoming)
```

## Arguments

- project:

  Character string. Name of the project folder.

- local.path:

  Character string. Directory path where the cloned project will be
  located. Default is the working directory, getwd().

- main:

  Logical. Whether to return results from the main project subfolders
  (all subfolders except "incoming"). Default is TRUE.

- incoming:

  Logical. Whether to return results from the "incoming" project
  subfolder. Default is TRUE.

## Value

Returns a download of the project folder and all its contents.

## See also

[`get.dir.template()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/get.dir.template.md)

## Examples

``` r
# clone.project(project = "mbmlb_010_Grey_headed_chickadee_hybridization", local.path = getwd(), main = TRUE, incoming = TRUE)
```
