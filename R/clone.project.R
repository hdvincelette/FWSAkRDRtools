#' Clone a project from the USFWS Alaska Regional Data Repository (RDR)
#'
#' Creates a copy of a RDR project folder in a specified location. Remote users must be connected to one of the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN).
#' @param project Character string. Name of the project folder.
#' @param local.path Character string. Directory path where the cloned project will be located. Default is the working directory, getwd().
#' @param main Logical. Whether to return results from the main project subfolders (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to return results from the "incoming" project subfolder. Default is TRUE.
#' @return Returns a download of the project folder and all its contents.
#' @keywords USFWS, repository, download, clone
#' @seealso ```get.dir.template()```
#' @export
#' @examples
#' # clone.project(project = "mbmlb_010_Grey_headed_chickadee_hybridization", local.path = getwd(), main = TRUE, incoming = TRUE)


clone.project <-
  function(project, local.path, main, incoming) {
    ## Parameter arguments
    if (missing(local.path)) {
      new.path <- getwd()
    } else {
      new.path <- local.path
    }
    if (missing(main)) {
      main <- TRUE
    }
    if (missing(incoming)) {
      incoming <- TRUE
    }

    if(dir.exists("//ifw7ro-file.fws.doi.net/datamgt/")==FALSE){
      stop("Unable to connect to the RDR. Check your network and VPN connection.")
    }

    # program.list <- c("^fes", "^mbm", "^nwrs", "^osm", "^sa")
    #
    # for (a in 1:length(program.list)) {
    #   if (grepl(program.list[a], project) == TRUE) {
    #     program <- sub('.', '', program.list[a])
    #   }
    # }
    #
    # if (dir.exists(paste0("//ifw7ro-file.fws.doi.net/datamgt/",
    #                       program,
    #                       "/",
    #                       project)) == FALSE) {
    #   stop(paste0("Project folder '", project, "' not found"))
    # }


    current.path <- paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                           program,
                           "/",
                           project)


    if (dir.exists(paste0(new.path, "/", project))) {
      selection.overwrite <-
        utils::menu(c("Yes", "No"), title = "Overwrite existing folder?")

      if (selection.overwrite == 1) {
        unlink(paste0(new.path, "/", project),recursive = TRUE)
        dir.create(paste0(new.path, "/", project))
      } else {
        stop("Operation halted.")
      }
    } else {
      dir.create(paste0(new.path, "/", project))
    }


    subfolder.list <- list.dirs(path = current.path,
                                recursive = FALSE)


    for (a in 1:length(subfolder.list)) {
      subfolder <- sub(paste0(".*", project), "", subfolder.list[a])
      if (subfolder != "/incoming" & main == FALSE) {
        next
      } else if (subfolder == "/incoming" & incoming == FALSE) {
        next
      }
      else {
        message(paste0("Cloning files in '", subfolder, "'..."))

        dir.create(paste0(new.path, "/", project, subfolder))
        file.copy(
          from = subfolder.list[a],
          to = paste0(new.path, "/", project),
          recursive = TRUE
        )
      }
    }


    return(invisible(NULL))

  }
