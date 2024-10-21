#' Find a project on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Finds an RDR project name. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param pattern Character vector. Project name pattern(s). Must be a regular expression; print ?base::regex for help. Default is NULL, which returns results for all files.
#' @param program Optional character string. Program prefix to help narrow search results. Options include "fes", "mbm", "nwrs", "osm", and "sa".
#' @param full.path Logical. Whether to return full folder path. Default is FALSE, and only the folder name is returned.
#' @return Returns a vector of paths or names of project folders which match the search criteria.
#' @keywords USFWS, repository
#' @seealso ```find.files()```
#' @export
#' @examples
#' # e.g.project.names<- find.project(pattern = c("red.*knot","alaska"), full.path = FALSE)



find.project <-
  function(pattern, program, full.path) {
    if (missing(pattern)) {
      pattern <- NULL
    }
    if (missing(program)) {
      program <- NULL
    }
    if (missing(full.path)) {
      full.path <- FALSE
    }

    if (dir.exists("//ifw7ro-file.fws.doi.net/datamgt/") == FALSE) {
      stop("Unable to connect to the RDR. Check your network and VPN connection.\n")
    }

    if(is.null(program)==FALSE) {
      if (!program %in% c("fes", "mbm", "nwrs", "osm", "sa")) {
        message(cat(
          paste0(
            "'",
            program,
            "' is not a valid program on the RDR and will be ignored.\n"
          )
        ))

        program <- c("fes", "mbm", "nwrs", "osm", "sa")
      }
    } else {
      program <- c("fes", "mbm", "nwrs", "osm", "sa")
    }

    folder.url <- c()

    for (a in pattern) {
      for (b in program) {
        message(
          paste0(
            "Searching for projects in '",
            b,
            "' with the pattern '",
            a,
            "'...\n"
          )
        )

        folder.url <- c(
          folder.url,
          dir(
            path = paste0("//ifw7ro-file.fws.doi.net/datamgt/", b, "/"),
            pattern = a,
            full.names = TRUE,
            recursive = FALSE,
            ignore.case = TRUE
          )
        )

      }
    }

    folder.url <- unique(folder.url)

    if (full.path == FALSE) {
      return(basename(folder.url))
    } else {
      return(folder.url)
    }

  }
