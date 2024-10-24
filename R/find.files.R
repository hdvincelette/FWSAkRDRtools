#' Find the location(s) of project file(s) on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Finds data file(s) from a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Not case-sensitive. Spaces are automatically replaced with ".*?" to improve search results. Default is NULL, which returns results for all files.
#' @param project Character string. Project folder name. Can be a partial name formatted as a regular expression. Not case-sensitive.
#' @param subfolder.path Character string. Project subfolder path.
#' @param main Logical. Whether to return results from the main project subfolders (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for files in subdirectories. Default is TRUE.
#' @param full.path Logical. Whether to return full file path. Default is FALSE
#' @return Returns a vector of paths to files which match the search criteria.
#' @keywords USFWS, repository
#' @seealso ```download.files()```
#' @export
#' @examples
#' # e.g.file.locs<- find.files(pattern = c("template","dictionary","\\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "", main = FALSE, incoming = TRUE, recursive = TRUE, full.path = FALSE)

# exclude subfolders argument
# find project function

find.files <-
  function(pattern,
           project,
           subfolder.path,
           main,
           incoming,
           recursive,
           full.path) {
    ## Parameter arguments
    if (missing(pattern)) {
      pattern <- NULL
    }
    if (missing(subfolder.path)) {
      subfolder.path <- ""
    } else {
      subfolder.path <- sub("^/", "", subfolder.path)
      subfolder.path <- sub("/$", "", subfolder.path)
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
    if (missing(full.path)) {
      full.path <- FALSE
    }

    ## Test connection ####
    if(dir.exists("//ifw7ro-file.fws.doi.net/datamgt/")==FALSE){
      stop("Unable to connect to the RDR. Check your network and VPN connection.")
    }

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

    ## Check subfolder path ####
    if (!subfolder.path %in%  list.dirs(
      path = paste0(
        "//ifw7ro-file.fws.doi.net/datamgt/",
        program,
        "/",
        project,
        "/"
      ),
      full.names = FALSE,
      recursive = TRUE
    )
    ) {
      stop("Subfolder path '",subfolder.path,"' not found.")
    }


    ## Search project folder ####
    file.url <- character(0)

    if (is.null(pattern) == TRUE) {
      pattern<- sub(" ",".*?", pattern)

      message(paste0("Searching for files in ",project,"..."))

      file.loc <-
        list.files(
          path = paste0(
            "//ifw7ro-file.fws.doi.net/datamgt/",
            program,
            "/",
            project,
            "/",
            subfolder.path,
            "/"
          ),
          pattern = NULL,
          ignore.case = TRUE,
          recursive = recursive,
          full.names = TRUE
        )

      if (rlang::is_empty(file.loc) == TRUE) {
        message(paste0(" - 0 files found"))
        next
      } else{
        message(paste0(" - ", length(file.loc), " file(s) found"))
        file.url <- file.loc
      }
    } else {
      for (a in 1:length(pattern)) {
        message(paste0("Searching for files in ",project," with the pattern '", pattern[a], "'..."))

        file.loc <-
          list.files(
            path = paste0(
              "//ifw7ro-file.fws.doi.net/datamgt/",
              program,
              "/",
              project,
              "/",
              subfolder.path,
              "/"
            ),
            pattern = pattern[a],
            ignore.case = TRUE,
            recursive = recursive,
            full.names = TRUE
          )

        if (rlang::is_empty(file.loc) == TRUE) {
          message(paste0(" - 0 files found"))
          next
        } else{
          message(paste0(" - ", length(file.loc), " file(s) found"))
          file.url <- c(file.url, file.loc)
        }

      }
    }

    file.url<- unique(file.url)

    if (full.path == FALSE) {
      file.list <- gsub(
        paste0(
          "//ifw7ro-file.fws.doi.net/datamgt/",
          program,
          "/",
          project
        ),
        "",
        file.url
      )

      return(file.list)

    } else {
      return(file.url)

    }
  }

