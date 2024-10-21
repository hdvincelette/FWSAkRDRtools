#' Find the location(s) of project file(s) on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Finds data file(s) from a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which returns results for all files.
#' @param project Character string. Name of the project folder.
#' @param subfolder.path Character string. Project subfolder path.
#' @param main Logical. Whether to return results from the "main" project folder (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for files in subdirectories. Default is TRUE.
#' @param full.path Logical. Whether to return full file path. Default is FALSE
#' @return Returns a vector of paths to files which match the search criteria.
#' @keywords USFWS, repository
#' @seealso ```download.files()```
#' @export
#' @examples
#' # e.g.file.locs<- find.files(pattern = c("template","dictionary","\\.csv","hello"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", incoming = TRUE, main = FALSE, recursive = TRUE, full.path = FALSE)


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

    if(dir.exists("//ifw7ro-file.fws.doi.net/datamgt/")==FALSE){
      stop("Unable to connect to the RDR. Check your network and VPN connection.")
    }

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


    if (!project %in%  list.dirs(
      path = paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                    program,
                    "/"),
      full.names = FALSE,
      recursive = FALSE
    )) {
      stop("Project '",project,"' not found.")
    }


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


    file.url <- character(0)

    if (is.null(pattern) == TRUE) {
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

