#' Read a tabular project file on the USFWS Alaska Regional Data Repository (RDR) into R
#'
#' Reads in tabular data file(s) from a specified RDR project folder. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. File name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which allows a selection from all files.
#' @param project Character string. Name of the project folder.
#' @param main Logical. Whether to return results from the main project folder (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @param recursive Logical. Whether to search for and read in files in subdirectories. Default is TRUE.
#' @return Returns a data frame of one or more selected tabular data files.
#' @keywords USFWS, repository
#' @seealso ```read.tables()```
#' @export
#' @examples
#' # e.g.tabular.data<- read.tables(pattern = c("\\.csv","\\.xlsx"), project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey", incoming = TRUE, main = TRUE, recursive = TRUE)


read.tables <-
  function(pattern,
           project,
           main,
           incoming,
           recursive) {
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
      recursive <- FALSE
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

    file.url <- FWSAkRDRtools::find.files(pattern,
                                          project,
                                          main,
                                          incoming,
                                          full.path = TRUE)



    tabular.formats <- c("\\.csv", "\\.xls")

    tabular.list <- c()

    for (a in 1:length(tabular.formats)) {
      tabular.files <-
        file.url[grepl(tabular.formats[a], file.url, ignore.case = TRUE)]
      tabular.list <- c(tabular.list, tabular.files)
    }

    file.choice <- utils::select.list(c(gsub(
      paste0("//ifw7ro-file.fws.doi.net/datamgt/",
             program,
             "/",
             project),
      "",
      tabular.list
    )),
    multiple = TRUE,
    graphics = TRUE,
    title = "Read in which file(s)?")

    tabular.list<- paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                      program,
                      "/",
                      project,file.choice)

    file.format <- c()

    if (length(file.choice)>1) {

      for (a in 1:length(file.choice)) {
        file.format[a] <- file.choice[a] %>%
          strsplit(".", fixed = TRUE) %>%
          unlist %>%
          dplyr::last()
      }

      if (length(unique(file.format)) > 1) {
        stop(paste0(
          "Files with more than one extension selected: ",
          unique(file.format)
        ))
      } else if (unique(file.format) %in% c("csv", "CSV")) {
        selected.files = lapply(tabular.list, function(i) {
          read.csv(i, header = TRUE)
        })

      } else if (unique(file.format) %in% c("xls", "XLS", "xlsx", "XLSX")) {
        selected.files = lapply(tabular.list, function(i) {
          readxl::read_excel(i, header = TRUE)
        })

      }

      names(selected.files) <-
        gsub(
          paste0(
            "//ifw7ro-file.fws.doi.net/datamgt/",
            program,
            "/",
            project
          ),
          "",
          file.choice
        )
      table.output <- plyr::ldply(selected.files)
      message(
        cat(
          "The files have been read into the R Environment.\nIf the files were not read correctly, re-execute import with the file urls: ",
          "\n",
          paste0(tabular.list, "\n")
        )
      )

    } else {
      file.format <- file.choice %>%
        strsplit(".", fixed = TRUE) %>%
        unlist %>%
        dplyr::last()

      if (file.format %in% c("csv", "CSV")) {
        table.output <- utils::read.csv(file = tabular.list)
        message(
          cat(
            "The file has been read into the R Environment.\nIf the file was not read correctly, re-execute import with the file url: ",
            "\n",
            paste0(tabular.list)
          )
        )

      } else if (file.format %in% c("xls", "xlsx", "XLS", "XLSX")) {
        table.output <-
          readxl::read_excel(path = tabular.list)
        message(
          cat(
            "The file has been read into the R Environment.\nIf the file was not read correctly, re-execute import with the file url: ",
            "\n",
            paste0(tabular.list)
          )
        )
      } else {
        message(
          cat(
            "The file format is not supported.\nTry using another function with the file url: ",
            "\n",
            paste0(tabular.list)
          )
        )
      }
    }

    return(table.output)

  }
