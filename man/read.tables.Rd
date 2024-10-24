% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.tables.R
\name{read.tables}
\alias{read.tables}
\title{Read a tabular project file on the USFWS Alaska Regional Data Repository (RDR) into R}
\usage{
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
}
\arguments{
\item{pattern}{Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which allows a selection from all files.}

\item{project}{Character string. Name of the project folder.}

\item{subfolder.path}{Character string. Project subfolder path.}

\item{main}{Logical. Whether to return results from the main project subolders (all subfolders except "incoming"). Default is TRUE.}

\item{incoming}{Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.}

\item{recursive}{Logical. Whether to search for and read in files in subdirectories. Default is TRUE.}

\item{header}{Logical. Whether the first line contains variable names. Default is TRUE. Only applies to csv files.}

\item{na.strings}{Character vector. Strings which are to be interpreted as NA values.}
}
\value{
Returns a data frame (if only one file selected), or list of selected tabular data files.
}
\description{
Reads in tabular data file(s) from a specified RDR project folder. Currently reads xls/xlsx (via readxl::read_excel) and csv (via utils::read.csv) table formats. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
}
\examples{
# e.g.tabular.data<- read.tables(pattern = c("\\.csv","\\.xlsx"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "", main = TRUE, incoming = TRUE, recursive = TRUE, header = TRUE, na.strings = "")
}
\seealso{
\code{find.files()}
}
\keyword{USFWS,}
\keyword{repository}
