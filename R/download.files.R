#' Download project file(s) from the USFWS Alaska Regional Data Repository (RDR)
#'
#' Searches for file name patterns in a specified RDR project folder and downloads all matching files. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which allows a selection from all files.
#' @param project Character string. Name of the project folder.
#' @param path  	Character string. Directory path where the downloaded files will be saved. Default is the working directory, getwd().
#' @param main Logical. Whether to return results from the main project folder (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for and download files in subdirectories. Default is TRUE.
#' @param download.file.method Character string. Method to be used for downloading files. Print ?options for available methods. Default is "auto".
#' @return Returns file download(s) which match the search criteria.
#' @keywords USFWS, repository, download, files
#' @seealso ```download.files()```
#' @export
#' @examples
#' # download.files(pattern = c("template","dictionary","\\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", path = getwd(), incoming = TRUE, main = TRUE, recursive = TRUE, download.file.method = "curl")


download.files <-
  function(pattern,
           project,
           path,
           main,
           incoming,
           recursive,
           download.file.method) {
    ## Parameter arguments
    if (missing(pattern)) {
      pattern <- NULL
    }
    if (missing(path))
      path <- getwd()
    if (missing(main)) {
      main <- TRUE
    }
    if (missing(incoming)) {
      incoming <- TRUE
    }
    if (missing(recursive)) {
      recursive <- FALSE
    }
    if (missing(download.file.method))
      download.file.method <- "auto"

    options(download.file.method = download.file.method)

    program.list <- c("^fes", "^mbm", "^nwrs", "^osm", "^sa")

    program <- NA

    for (a in 1:length(program.list)) {
      if (grepl(program.list[a], project) == TRUE) {
        program <- sub('.', '', program.list[a])
      }
    }

    if (is.na(program) == TRUE) {
      stop("Project folder name must contain the program prefix (e.g., mbmlb_)")
    }

    file.url <- FWSAkRDRtools::find.files(pattern,
                                          project,
                                          main,
                                          incoming,
                                          full.path = TRUE)

    file.list <- gsub(paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                             program,
                             "/",
                             project),
                      "",
                      file.url)

    if (rlang::is_empty(file.list) == TRUE) {
      stop("Operation halted.")
    }

    file.choice <- utils::select.list(
      c(file.list),
      multiple = TRUE,
      graphics = TRUE,
      title = "Download which file(s)?"
    )

    selected.url <- paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                           program,
                           "/",
                           project,
                           file.choice)

    for (b in 1:length(selected.url)) {
      download.file(
        url = paste0("File:", selected.url[b]),
        file.path(path, destfile = basename(selected.url[b])),
        mode = "auto",
        quiet = FALSE
      )
    }
    message(cat("\n", "The files were downloaded to: ", "\n", path))

    return(invisible(NULL))

  }










