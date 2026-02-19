# FWSAkRDRtools Tutorial

The ‘FWSAkRDRtools’ R package is meant to help users access and manage
files on the U.S. Fish & Wildlife Service Alaska Regional Data
Repository (RDR). The RDR is a “network drive serving as a central
location for authoritative project data and deliverables”. Currently,
the RDR is internally maintained and can only be accessed by FWS
employees connected to the Service’s network onsite or through approved
remote connection technologies, such as a [Virtual Private Network
(VPN)](https://doimspp.sharepoint.com/sites/fws-FF10T00000/SitePages/GlobalProtect-Secure-Technology-Application.aspx).
Connected users can navigate to the RDR by pasting the link
<file://ifw7ro-file.fws.doi.net/datamgt/> in File Explorer or a web
browser (e.g., Microsoft Edge or Chrome). Please refer to the [Draft
Regional Data Repository Guidance
Document](https://ecos.fws.gov/ServCat/Reference/Profile/150400) on
ServCat for more information on the overall organization and management
of the RDR. Most ‘FWSAkRDRtools’ functions require an FWS network
connection, and one function also requires write permission to the
relevant ‘incoming’ project folder.

  

###### The Alaska Regional Data Repository in File Explorer (left) and Microsoft Edge (right)

![](https://github.com/hdvincelette/FWSAkRDRtools/raw/main/vignettes/images/RDR_file_explorer.png)![](https://github.com/hdvincelette/FWSAkRDRtools/raw/main/vignettes/images/RDR_web_browser.png)

  

###### Function requirements

| function         | FWS network connection | ‘incoming’ write permission |
|:-----------------|:----------------------:|:---------------------------:|
| get.dir.template |                        |                             |
| find.projects    |           X            |                             |
| find.files       |           X            |                             |
| download.files   |           X            |                             |
| read.tables      |           X            |                             |
| clone.project    |           X            |                             |
| summarize.files  |           X            |                             |
| commit.files     |           X            |              X              |

  
  

## **Workspace**

### Uninstall

If you have installed ‘FWSAkRDRtools’ previously and want to update to
the latest version, you may need to uninstall the package first.
Occasionally R hits a roadblock and needs you to manually remove a
package before it can proceed.

``` r
remove.packages("FWSAkRDRtools")
.rs.restartR()
```

  

### Install

Install the development version of ‘FWSAkRDRtools’ from GitHub. The R
package ‘remotes’ (demonstrated here) or ‘devtools’ is required to
install packages from GitHub.

``` r
if (!require("remotes")) install.packages("remotes")

Sys.setenv(R_REMOTES_STANDALONE="true")
remotes::install_github("hdvincelette/FWSAkRDRtools")
```

  

### Load

Load ‘FWSAkRDRtools’ into the R library and set the working directory
(where you would like files to be saved and/or copied from).

``` r
library(FWSAkRDRtools)

wd<- "C:/Users/hvincelette/OneDrive - DOI/Documents/Data_management/Test"
```

Run the following to access information about ‘FWSAkRDRtools’ in the
Help pane, including documentation pages for each function. This is a
useful quick reference for function usage, arguments, and expected
output.

``` r
help(package = "FWSAkRDRtools")
```

  
  

## **Functions**

### `get.dir.template()`: get the directory tree template

RDR project folders follow a standardized folder structure:

    -- admin
    -- changelog.txt
    -- code
    -- data
       |__final_data
       |__raw_data
    -- documents
       |__posters
       |__protocols
       |__publications
       |__reports
       |__talks
    -- incoming
    -- metadata

[`get.dir.template()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/get.dir.template.md)
can help organize a local project to be archived in the RDR. The project
name (`project`) is unrestricted, but a prompt requests approval to
overwrite an existing folder with the same name in the local path. The
new directory will be created in the local path (`local.path`). By
default, only main project folders are included (`main = TRUE` &
`incoming = FALSE`) . Normally, only data stewards have write permission
to the ‘incoming’ folder of an RDR project, while data managers have
write and modify permissions to all folders. This helps ensure files are
not accidentally overwritten and/or lost. Use `incoming = TRUE` to
include the “incoming” folder in the new directory.

``` r
get.dir.template(
  project = "mbmlb_909_Eskimo_Curlew_study",
  local.path = wd,
  main = TRUE,
  incoming = FALSE
)
```

  

### `find.projects()`: find RDR projects

[`find.projects()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/find.projects.md)
queries the RDR for existing project folder names. Pattern(s)
(`pattern)` can be a character string or vector of search term(s). The
default is `pattern = NULL`, which returns results for all project
folders. Patterns must be formatted as “regular expressions”, but spaces
within a string (e.g., “red knot”) are automatically replaced with
“.\*?” (e.g., “red.\*?knot”) to improve search results. Patterns are not
case-sensitive. Print
[`?base::regex`](https://rdrr.io/r/base/regex.html) to view the regular
expressions R documentation. The program code (`program`) is an optional
argument to fine-tune search results within RDR program folders (fes,
mbm, nwrs, osm, sa). The output will either be the full folder path
(`full.path = TRUE`) or just the project folder name(s)
(`full.path = FALSE`).

``` r
?base::regex

project.folders <- find.projects(
  pattern = c("red.*knot", "alaska"),
  program = "mbm",
  full.path = FALSE
)
```

  

### `find.files()`: find RDR project files

[`find.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/find.files.md)
allows you to query a specific RDR project folder for individual files.
Pattern(s) (`pattern)` can be a character string or vector of search
term(s). The default is `pattern = NULL`, which returns results for all
files. Patterns must be formatted as “regular expressions”, but spaces
within a string (e.g., “data dictionary”) are automatically replaced
with “.\*?” (e.g., “data.\*?dictionary”) to improve search results.
Patterns are not case-sensitive. Print
[`?base::regex`](https://rdrr.io/r/base/regex.html) to view the regular
expressions R documentation. A project name or pattern (`project`) is
required. If a pattern is provided and more than one project is found, a
menu will ask for a selection. The subfolder path (`subfolder.path`) can
be specified to fine-tune search results (e.g., search in the “metadata”
subfolder for a file name containing “dictionary”). The search can be
restricted to the top level of a specified subfolder path
(`recursive = FALSE`). Otherwise, the function will search subsequent
subfolders (`recursive = TRUE`). The search will include both the main
(`main = TRUE`) and “incoming” (`incoming = TRUE`) folders unless one or
the other is excluded by changing the argument to `FALSE`. The output
will either be the full file path (`full.path = TRUE`) or just the
subfolder path(s) and file name(s) (`full.path = FALSE`).

``` r
?base::regex

file.locs <- find.files(
  pattern = c("template", "dictionary", "\\.csv", "hello"),
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder.path = "metadata",
  main = TRUE,
  incoming = FALSE,
  recursive = TRUE,
  full.path = FALSE
)
```

  

### `download.files()`: download RDR project files

[`download.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/download.files.md)
enables you to download files from specified RDR project folder onto
your local drive. Arguments for
[`download.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/download.files.md)
operate in the same way as
[`find.files()`](https://hdvincelette.github.io/FWSAkRDRtools/articles/01_FWSAkRDRtools_Tutorial.html#find-files-find-rdr-project-files),
with a few additions. The files will be saved to the local path
(`local.path`). `download.file.method` is the method for downloading
files. The default (`"auto"`) chooses an appropriate method for the
operating system, but the method may need to be specified if the
download fails (e.g., `"internal"`, `"libcurl"`, `"wget"`, `"curl"`,
`"wininet"`). Print
[`?download.file`](https://rdrr.io/r/utils/download.file.html) for more
details on download file methods. Print `browseURL(wd)` to view the
downloaded files.

``` r
?download.file

download.files(
  pattern = c("banding", "dictionary"),
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder.path = "",
  local.path = wd,
  main = TRUE,
  incoming = FALSE,
  recursive = TRUE,
  download.file.method = "auto"
)

browseURL(wd)
```

  

### `read.tables()`: read RDR project tables into R

[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)
enables you to read tabular data files from a specified RDR project
folder directly into R. Arguments for
[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)
operate in the same way as
[`find.files()`](https://hdvincelette.github.io/FWSAkRDRtools/articles/01_FWSAkRDRtools_Tutorial.html#find-files-find-rdr-project-files),
with a few additions.
[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)
currently only reads XLS/XLSX (via readxl::read_excel) and CSV (via
utils::read.csv) table formats. `na.strings` are any strings to be
interpreted as NA values. `header` indicates whether the first line
contains variable names. `header` only applies to CSV formats, and the
default is `TRUE`.
[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)
should be used cautiously as most arguments in the dependent functions
are set to default values. Tables should be reviewed for errors and
re-imported as needed using the file URLs printed with the output.
[`read.tables()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/read.tables.md)
will return a data frame if only one file is selected or a list of data
frames if multiple files are selected.

``` r
df <- read.tables(
  pattern = c("dictionary"),
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder.path = "metadata",
  main = TRUE,
  incoming = FALSE,
  recursive = TRUE,
  header = TRUE,
  na.strings = ""
)

df.list <- read.tables(
  pattern = c("\\.csv", "\\.xlsx"),
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder.path = "",
  main = TRUE,
  incoming = FALSE,
  recursive = TRUE,
  header = TRUE,
  na.strings = ""
)
```

  

### `clone.project()`: clone an RDR project

[`clone.project()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/clone.project.md)
creates an exact copy of an RDR project on your local drive. A project
name or pattern (`project`) is required. If a pattern is provided and
more than one project is found, a menu will ask for a selection. The
cloned folders will be saved to the local path (`local.path`). Both the
main (`main = TRUE`) and “incoming” (`incoming = TRUE`) folders will be
cloned unless one or the other is excluded by changing the argument to
`FALSE`.

``` r
clone.project(
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  local.path = wd,
  main = TRUE,
  incoming = TRUE
  )
```

  

### `summarize.files()`: summarize files in an RDR project

[`summarize.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/summarize.files.md)
provides a summary of a specific RDR project folder. A project name or
pattern (`project`) is required. If a pattern is provided and more than
one project is found, a menu will ask for a selection. One or more
subfolders (`subfolder`) can be specified to fine-tune and speed up
summary results (e.g., summarize only the “raw_data” and “final_data”
subfolders). The summary can be restricted to the top level of a
specified subfolder (`recursive = FALSE`). Otherwise, the function will
summarize subsequent subfolders (`recursive = TRUE`). The summary will
include both the main (`main = TRUE`) and “incoming” (`incoming = TRUE`)
folders unless one or the other is excluded by changing the argument to
`FALSE`.

``` r
all.summary<- summarize.files(
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder = "",
  main = TRUE,
  incoming = TRUE,
  recursive = TRUE
)

data.summary<- summarize.files(
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  subfolder = c("raw_data","final_data"),
  main = TRUE,
  incoming = FALSE,
  recursive = TRUE
)
```

  

### `commit.files()`: commit files to an RDR project

[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)
helps you submit files to the RDR. Note, you must be the data steward of
the relevant RDR project and/or have write permission to the “incoming”
folder. Refer to the program data manager to understand your project
roles and permissions. A project name or pattern (`project`) is
required. If a pattern is provided and more than one project is found, a
menu will ask for a selection. The local path (`local.path`) should
contain files to commit in the same folder structure as the RDR project
folder. Therefore, it is recommended to create an local directory using
[`get.dir.template()`](https://hdvincelette.github.io/FWSAkRDRtools/articles/01_FWSAkRDRtools_Tutorial.html#get-dir-template-get-the-directory-tree-template)
or clone the RDR project folder to the local drive with
[`clone.project()`](https://hdvincelette.github.io/FWSAkRDRtools/articles/01_FWSAkRDRtools_Tutorial.html#clone-project-clone-an-rdr-project)
before managing file additions. The local file search will include
subfolders in the local path (`recursive = TRUE`) unless otherwise
specified (`recursive = FALSE`). If a local file is contained in an
unfamiliar subfolder path,
[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)
will attempt to find the closest matching RDR subfolder path. If
incorrect, a new subfolder path can be created.
[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)
runs numerous tests to ensure files are committed to the correct
“incoming” folder. You can run
[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)
more prudently by reviewing local duplicate files
(`review.duplicate = TRUE`) and prohibiting the overwrite of RDR files
(`rdr.overwrite = FALSE`). These are the recommended defaults. File
overwrites (`rdr.overwrite = TRUE`) must be individually reviewed and
approved. Only files in the “incoming” folder of the RDR may be
immediately overwritten, while those in the main folders will only be
overwritten at the discretion of the data manager.
[`commit.files()`](https://hdvincelette.github.io/FWSAkRDRtools/reference/commit.files.md)
will provide an overview of the files to commit. If approved, a summary
of the commit is printed to the R Console and sent to the changelog in
the RDR project “incoming” folder. You may want to add additional
details to the changelog, including the contents of each file.

``` r
commit.summary<- commit.files(
  project = "mbmlb_010_Grey_headed_chickadee_hybridization",
  local.path = paste0(wd,"/mbmlb_010_Grey_headed_chickadee_hybridization"),
  recursive = TRUE,
  review.duplicate = TRUE,
  rdr.overwrite = FALSE
  )
```
