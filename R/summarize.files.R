#' Summarize project files on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Summarizes files in a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param project Character string. Name of the project folder.
#' @param subfolder Optional character vector. Project subfolder(s) to summarize. Default is NULL, which returns results for all subfolders.
#' @param main Logical. Whether to return results from the "main" project folder (all subfolders except incoming). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for files in subdirectories. Default is TRUE.
#' @return Returns a data frame summarizing subfolder contents.
#' @keywords USFWS, repository, summary, snapshot
#' @seealso ```commit.files()```
#' @export
#' @examples
#' # e.g.summary<- summarize.files(project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder = c("/", "final_data", "metadata"), incoming = TRUE, main = FALSE, recursive = TRUE)

# progress bar digiart

summarize.files <-
  function(project,
           subfolder = NULL,
           main = TRUE,
           incoming = TRUE,
           recursive = TRUE) {
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
    if (missing(recursive)) {
      recursive <- TRUE
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

    if (dir.exists(paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                          program,
                          "/",
                          project)) == FALSE) {
      stop(paste0("Project folder '", project, "' not found"))
    }

    if (is.null(subfolder.pattern) == FALSE) {
      subfolder.list <- c()
      for (a in 1:length(subfolder.pattern)) {

        message(paste0(
          "Searching for subfolder '",
          subfolder.pattern[a],
          "' in '",
          project,
          "'..."
        ))

        if (subfolder.pattern[a] == "/") {
          subfolder.list <-
            c(
              subfolder.list,
              paste0(
                "//ifw7ro-file.fws.doi.net/datamgt/",
                program,
                "/",
                project,
                "/"
              ),
              paste0(
                "//ifw7ro-file.fws.doi.net/datamgt/",
                program,
                "/",
                project,
                "/incoming/"
              )
            )
        } else {
          subfolder.list <-  as.vector(c(
            subfolder.list,
            fs::dir_ls(
              path = paste0(
                "//ifw7ro-file.fws.doi.net/datamgt/",
                program,
                "/",
                project
              ),
              type = "directory",
              recurse  = TRUE,
              regexp = subfolder.pattern[a]
            )
          ))
        }
      }
      subfolder.list <- unique(subfolder.list)

      if (length(subfolder.list) == 0) {
        stop(
          paste0(
            "Subfolder '",
            subfolder.pattern,
            "' not found in project folder ",
            project
          )
        )
      }

    } else{
      message(paste0("Finding subfolders in '", project, "'..."))

      subfolder.list <- fs::dir_ls(
        path = paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                      program,
                      "/",
                      project),
        type = "directory",
        recurse  = TRUE,
      )
    }

    files.sum <- data.frame(
      subfolder = character(0),
      numfiles = numeric(0),
      size = numeric(0),
      last.file.modification = as.POSIXct(character(0)),
      last.file.creation =  as.POSIXct(character(0)),
      stringsAsFactors = FALSE
    )

    for (a in 1:length(subfolder.list)) {

      subfolder <- sub(paste0(".*", project), "", subfolder.list[a])


      if (!startsWith(subfolder, "/incoming") &
          main == FALSE) {
        next
      } else if (startsWith(subfolder, "/incoming") &
                 incoming == FALSE) {
        next
      }

      message(paste0("Searching for files in '", subfolder, "'..."))

      subfolder <-
        sub(paste0(".*", project), "", subfolder.list[a])

      file.list <- fs::dir_ls(
        path = paste0(
          "//ifw7ro-file.fws.doi.net/datamgt/",
          program,
          "/",
          project,
          subfolder
        ),
        type = "file"
      )


      if (subfolder == "") {
        subfolder <- "/"
      }

      if (length(file.list) == 0) {
        message(paste0(" - 0 files(s) found"))

        files.sum <- files.sum %>% dplyr::add_row(
          subfolder = subfolder,
          numfiles = 0,
          size = 0,
          last.file.modification = NA,
          last.file.creation = NA
        )
      } else {


        file.info.list<-c()

        message(paste0(" - Summarizing ",
                       length(file.list),
                       " files(s)..."))

        pb <- txtProgressBar(0, length(file.list), style = 3)

        for (b in 1:length(file.list)) {
          file.info.add <- file.list[b] %>% fs::file_info()
          file.info.list <-
            dplyr::bind_rows(file.info.list, file.info.add)

          setTxtProgressBar(pb, b)
          file.list[b]
          Sys.sleep(time = 1)
        }

        message(cat(" "))


        files.sum <- files.sum %>% dplyr::add_row(
          subfolder = subfolder,
          numfiles = nrow(file.info.list),
          size = sum(file.info.list$size),
          last.file.modification = max(file.info.list$modification_time),
          last.file.creation = max(file.info.list$birth_time)
        )

      }
    }
    return(files.sum)
  }





