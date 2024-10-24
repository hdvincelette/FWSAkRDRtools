#' Download project file(s) from the USFWS Alaska Regional Data Repository (RDR)
#'
#' Searches for file name patterns in a specified RDR project folder and downloads all matching files. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which allows a selection from all files.
#' @param project Character string. Name of the project folder.
#' @param subfolder.path Character string. Project subfolder path.
#' @param local.path Character string. Directory path where the downloaded files will be saved. Default is the working directory, getwd().
#' @param main Logical. Whether to return results from the main project subfolders (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for and download files in subdirectories. Default is TRUE.
#' @param download.file.method Character string. Method to use for downloading files. Print ?download.file for available methods. Default is "auto".
#' @return Returns file download(s) which match the search criteria.
#' @keywords USFWS, repository, download, files
#' @seealso ```read.tables()```
#' @export
#' @examples
#' # download.files(pattern = c("template","dictionary","\\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "metadata, local.path = getwd(), main = TRUE, incoming = TRUE, recursive = TRUE, download.file.method = "curl")


download.files <-
  function(pattern,
           project,
           subfolder.path,
           local.path,
           main,
           incoming,
           recursive,
           download.file.method) {
    ## Parameter arguments
    if (missing(pattern)) {
      pattern <- NULL
    }
    if (missing(local.path)) {
      local.path <- getwd()
    }
    if (missing(main)) {
      main <- TRUE
    }
    if (missing(incoming)) {
      incoming <- TRUE
    }
    if (missing(recursive)) {
      recursive <- TRUE
    }
    if (missing(download.file.method)) {
      download.file.method <- "auto"
    }

    ## Test connection ####
    if(dir.exists("//ifw7ro-file.fws.doi.net/datamgt/")==FALSE){
      stop("Unable to connect to the RDR. Check your network and VPN connection.")
    }

    ## Set download method ####
    options(download.file.method = download.file.method)


    ## Find project folder ####
    project.list <- suppressMessages(find.projects(pattern = project, full.path = TRUE))

    project.choice <- 0

    if (length(project.list) == 0) {
      stop("Project matching '", project, "' not found.")
    } else if (length(project.list) > 1) {
      while (project.choice == 0) {
        project.choice <- utils::menu(basename(project.list), title  = "Select a project folder.")
      }
    } else {
      project.choice<- 1
    }

    project <- basename(project.list)[project.choice]

    program <- basename(dirname(project.list[project.choice]))


    ## Get file urls ####
    file.url <- FWSAkRDRtools::find.files(pattern,
                                          project,
                                          subfolder.path,
                                          main,
                                          incoming,
                                          recursive,
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

    ## Select files ####
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

    ## Download files ####
    for (b in 1:length(selected.url)) {
      downloader::download(
        url = paste0("File:", selected.url[b]),
        destfile = file.path(local.path, basename(selected.url[b])),
        method= download.file.method,
        mode = "wb",
        quiet = FALSE
      )
    }
    message(cat("\n", "The files were downloaded to: ", "\n", local.path))

    return(invisible(NULL))

  }










