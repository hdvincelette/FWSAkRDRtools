% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/commit.files.R
\name{commit.files}
\alias{commit.files}
\title{Commit files to the "incoming" project subfolder on the USFWS Alaska Regional Data Repository (RDR)}
\usage{
commit.files(project, local.path, recursive, review.duplicate, rdr.overwrite)
}
\arguments{
\item{project}{Character string. Name of the project folder.}

\item{local.path}{Character string. Directory name or path where the uncommitted files are located. Default is the working directory, getwd().}

\item{recursive}{Logical. Whether to search for and commit files in subdirectories. Default is TRUE.}

\item{review.duplicate}{Logical. Whether to review local duplicate files (identical file name and extension, different subfolder path). Default is TRUE, and duplicate files are reviewed and selected individually. If FALSE, all files are automatically selected for commit.}

\item{rdr.overwrite}{Logical. Whether to overwrite RDR files (identical file name, extension, and subfolder path) betweent local and RDR folders. Default is FALSE. If TRUE, overwrites must be reviewed and approved individually. Only files in the "incoming" folder of the RDR may be immediately overwritten, while those in the main project subfolders will only be overwritten at the discretion of the data manager.}
}
\value{
Returns a data frame summarizing the committed files.
}
\description{
Copies local file(s) to the "incoming" folder of a specified RDR project and updates the changelog to document changes. Remote users must be connected the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN) AND be granted write permission to the project’s “incoming" subfolder (i.e., be an authorized "data steward").
}
\examples{
# e.g.commit<- commit.files(project = "mbmlb_010_Grey_headed_chickadee_hybridization", local.path = getwd(), recursive = TRUE, review.duplicate = TRUE, rdr.overwrite = FALSE)
}
\seealso{
\code{summarize.files()}
}
\keyword{USFWS,}
\keyword{repository}
