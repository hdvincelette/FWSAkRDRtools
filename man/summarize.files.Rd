% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarize.files.R
\name{summarize.files}
\alias{summarize.files}
\title{Summarize project files on the USFWS Alaska Regional Data Repository (RDR)}
\usage{
summarize.files(
  project,
  subfolder = NULL,
  main = TRUE,
  incoming = TRUE,
  recursive = TRUE
)
}
\arguments{
\item{project}{Character string. Name of the project folder.}

\item{subfolder}{Optional character vector. Name(s) of subfolder(s) to summarize. Default is NULL, which returns results for all subfolders.}

\item{main}{Logical. Whether to return results from the main project folder (all subfolders except incoming). Default is TRUE.}

\item{incoming}{Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.}

\item{recursive}{Logical. Whether to search for files in subdirectories. Default is TRUE.}
}
\value{
Returns a data frame summarizing subfolder contents.
}
\description{
Summarizes files in a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
}
\examples{
# e.g.summary<- summarize.files(project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder = c("/", "final_data", "metadata"), incoming = TRUE, main = FALSE, recursive = TRUE)
}
\seealso{
\code{commit.files()}
}
\keyword{USFWS,}
\keyword{repository,}
\keyword{snapshot}
\keyword{summary,}
