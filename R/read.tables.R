#' Read a tabular project file on the USFWS Alaska Regional Data Repository (RDR) into R
#'
#' Reads in tabular data file(s) from a specified RDR project folder. Currently reads xls/xlsx (via readxl::read_excel) and csv (via utils::read.csv) table formats. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which allows a selection from all files.
#' @param project Character string. Name of the project folder.
#' @param subfolder.path Character string. Project subfolder path.
#' @param main Logical. Whether to return results from the main project subolders (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for and read in files in subdirectories. Default is TRUE.
#' @param header Logical. Whether the first line contains variable names. Default is TRUE. Only applies to csv files.
#' @param na.strings Character vector. Strings which are to be interpreted as NA values.
#' @return Returns a data frame (if only one file selected), or list of selected tabular data files.
#' @keywords USFWS, repository
#' @seealso ```find.files()```
#' @export
#' @examples
#' # e.g.tabular.data<- read.tables(pattern = c("\\.csv","\\.xlsx"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", subfolder.path = "", main = TRUE, incoming = TRUE, recursive = TRUE, header = TRUE, na.strings = "")


read.tables <-
  function(pattern,
           project,
           subfolder.path,
           main,
           incoming,
           recursive,
           header,
           na.strings,
           sep
           ) {
    ## Parameter arguments
    if (missing(pattern)) {
      pattern <- NULL
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
    if (missing(header)) {
      header <- TRUE
    }
    if (missing(na.strings)) {
      na.strings <- ""
    }
    if (missing(sep)) {
      sep <- ""
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


    ## Get file urls ####
    file.url <- FWSAkRDRtools::find.files(pattern,
                                          project,
                                          subfolder.path,
                                          main,
                                          incoming,
                                          recursive,
                                          full.path = TRUE)


    if (length(file.url) != 0) {

      ## Filter csv & xls
      tabular.formats <- c("\\.csv", "\\.xls")

      tabular.list <- c()

      for (a in 1:length(tabular.formats)) {
        tabular.files <-
          file.url[grepl(tabular.formats[a], file.url, ignore.case = TRUE)]

        tabular.list <- c(tabular.list, tabular.files)
      }

      if (length(tabular.list) != 0) {

        ## Select files ####
        if (length(tabular.list) == 1) {
          file.choice <- gsub(
            paste0(
              "//ifw7ro-file.fws.doi.net/datamgt/",
              program,
              "/",
              project
            ),
            "",
            tabular.list
          )
        } else {
          file.choice <- utils::select.list(
            c(gsub(
              paste0(
                "//ifw7ro-file.fws.doi.net/datamgt/",
                program,
                "/",
                project
              ),
              "",
              tabular.list
            )),
            multiple = TRUE,
            graphics = TRUE,
            title = "Read in which file(s)?"
          )
        }

        tabular.list <- paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                               program,
                               "/",
                               project,
                               file.choice)


        ## Import files ####
        file.ext <- tools::file_ext(file.choice)

        import.file.name <- file.choice %>%
          stringr::str_replace(., paste0(".", file.ext), "") %>%
          stringr::str_replace(.,
                               paste0(
                                 "//ifw7ro-file.fws.doi.net/datamgt/",
                                 program,
                                 "/",
                                 project
                               ),
                               "")

        file.list <- list()

        for (a in 1:length(file.ext)) {
          if (file.ext[a] %in% c("xlsx", "xls")) {
            import.file <-
              readxl::read_excel(tabular.list[a], col_names = header, na = na.strings)
            file.list[[a]] <- import.file

          } else if (file.ext[a] %in% c("csv")) {
            import.file <-
              utils::read.csv(tabular.list[a], header = header, na.strings = na.strings)
            file.list[[a]] <- import.file

          }
        }

        if(length(file.list)==1) {
          output <-
            file.list %>%
            plyr::ldply(., .id = NULL)

        } else {
          names(file.list) <- basename(tabular.list)
          output <- file.list
        }

        message(
          cat(
            "One or more files have been read into the R Environment.\nIf incorrectly read, re-execute import with the file url(s): ",
            "\n",
            paste0(tabular.list, sep = "\n")
          )
        )

        return(output)

      } else {
        warning("No supported files found.\nNote, tablar data must be formatted to csv or xls/xlsx.")
      }
    }
  }
