#' Summarize project files on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Summarizes files in a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param project Character string. Name of the project folder.
#' @param subfolder Optional character vector. Name(s) of subfolder(s) to summarize. Default is NULL, which returns results for all subfolders.
#' @param main Logical. Whether to return results from the main project folder (all subfolders except incoming). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @return Returns a data frame summarizing subfolder contents.
#' @keywords USFWS, repository, summary, snapshot
#' @seealso ```summarize.files()```
#' @export
#' @examples
#' e.g.summary<- summarize.files(project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder = c("analysis_output", "final_data", "metadata"), incoming = TRUE, main = FALSE)


summarize.files <-
  function(project,
           subfolder = NULL,
           main = TRUE,
           incoming = TRUE) {
    `%>%` <- magrittr::`%>%`

    ## Parameter arguments
    if (missing(subfolder)) {
      subfolder <- NULL
      subfolder.pattern <- NULL
    } else {
      subfolder.pattern <- subfolder
    }
    if (missing(main)) {
      main <- TRUE
    }
    if (missing(incoming)) {
      incoming <- TRUE
    }


    files.sum <- data.frame(
      subfolder = character(0),
      numfiles = numeric(0),
      size = numeric(0),
      last.file.modification = as.POSIXct(character(0)),
      last.file.addition =  as.POSIXct(character(0)),
      stringsAsFactors = FALSE
    )

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

    if (dir.exists(paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                          program,
                          "/",
                          project)) == FALSE) {
      stop(paste0("Project folder '", project, "' not found"))
    }

    message(paste0("Finding subfolders in '", project,"'..."))

    subfolder.list <- list.dirs(
      path = paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                    program,
                    "/",
                    project),
      recursive = TRUE
    )

    subfolder.list.pattern <- c()

    if (is.null(subfolder.pattern) == FALSE) {
      for (b in 1:length(subfolder.pattern)) {
        subfolder.list.pattern <-
          c(
            subfolder.list.pattern,
            stringr::str_subset(subfolder.list, subfolder.pattern[b])
          )
      }
      if (is.null(subfolder.list.pattern) == FALSE) {
        subfolder.list <- subfolder.list.pattern
      } else {
        stop(
          paste0(
            "Subfolder(s) '",
            subfolder.pattern,
            "' not found in project folder ",
            project
          )
        )
      }
    }

    for (a in 1:length(subfolder.list)) {
      subfolder <- sub(paste0(".*", project), "", subfolder.list[a])

      if (!startsWith(subfolder, "/incoming") & main == FALSE) {
        next
      }
      else if (startsWith(subfolder, "/incoming") &
               incoming == FALSE) {
        next
      } else{
        if (subfolder == "") {
          subfolder <- "main"
        }

        message(paste0("Searching for files in '", subfolder, "'..."))

        subfolder <-
          sub(paste0(".*", project), "", subfolder.list[a])

        file.list <- list.files(
          path = paste0(
            "//ifw7ro-file.fws.doi.net/datamgt/",
            program,
            "/",
            project,
            subfolder
          ),
          full.names = TRUE
        )

        if (subfolder == "") {
          subfolder <- "main"
        }

        if (length(file.list) != 0) {
          message(paste0(
            " - Summarizing ",
            length(file.list),
            " file(s)..."
          ))
        }

        file.list <- file.list %>% file.info()

        if (length(rownames(file.list)) == 0) {
          files.sum <- files.sum %>% dplyr::add_row(
            subfolder = subfolder,
            numfiles = 0,
            size = 0,
            last.file.modification = NA,
            last.file.addition = NA
          )
        } else {
          files.sum <- files.sum %>% dplyr::add_row(
            subfolder = subfolder,
            numfiles = length(rownames(file.list)),
            size = sum(file.list$size),
            last.file.modification = max(file.list$mtime),
            last.file.addition = max(file.list$ctime)
          )

        }

      }
    }

    return(files.sum)

  }


