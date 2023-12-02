#' Copy the USFWS Alaska Regional Data Repository (RDR) project directory tree template.
#'
#' Creates the RDR project folder structure in a specified location.
#' @param project Character string. Name of the project folder.
#' @param path  	Character string. Directory path where the project will be located. Default is the working directory, getwd().
#' @param main Logical. Whether to include the main project folder (all subfolders except "incoming"). Default is TRUE.
#' @param incoming Logical. Whether to include the "incoming" project subfolder. Default is TRUE
#' @return Returns a download of the project directory tree template.
#' @keywords USFWS, repository, download, directory tree
#' @seealso ```get.dir.template()```
#' @export
#' @examples
#' # get.dir.template(project = "mbmlb_909_Eskimo_Curlew_study", path = getwd(), main = TRUE, incoming = TRUE)


get.dir.template <- function(project,
                             path,
                             main = TRUE,
                             incoming = TRUE) {
  `%>%` <- magrittr::`%>%`

  ## Parameter arguments
  if (missing(path)) {
    new.path <- getwd()
  } else {
    new.path <- path
  }
  if (missing(main)) {
    main <- TRUE
  }
  if (missing(incoming)) {
    incoming <- TRUE
  }

  program.list <- c("^fes", "^mbm", "^nwrs", "^osm", "^sa")

  program <- NA

  for (a in 1:length(program.list)) {
    if (grepl(program.list[a], project) == TRUE) {
      program <- sub('.', '', program.list[a])
    }
  }

  if (is.na(program) == TRUE) {
    warning("Project folder name does not contain a program prefix (e.g., mbmlb_)")
  }


  if (dir.exists(paste0(new.path, "/", project))) {
    selection.overwrite <-
      utils::menu(c("Yes", "No"), title = "Overwrite existing folder?")

    if (selection.overwrite == 1) {
      unlink(paste0(new.path, "/", project), recursive = TRUE)
      dir.create(paste0(new.path, "/", project))
    } else {
      stop("Execution halted")
    }
  } else {
    dir.create(paste0(new.path, "/", project))
  }

  for (a in 1:length(dir_template)) {
    subfolder <- dir_template[a]
    if (!startsWith(subfolder, "/incoming") & main == FALSE) {
      next
    }
    else if (startsWith(subfolder, "/incoming") &
             incoming == FALSE) {
      next
    }
    else {
      suppressWarnings(dir.create(paste0(new.path, "/", project, subfolder)))
      suppressWarnings(file.copy(
        from = dir_template[a],
        to = paste0(new.path, "/", project),
        recursive = TRUE
      ))
    }
  }

  if (main == TRUE) {
    write(
      c(
        "<insert project name> Project Repository",
        "yyyymmdd (hilmar_maier@fws.gov)",
        "",
        "",
        "  - Created project repository",
        "  - Assigned Custodians <user name> (<user email>) write permissions to repository",
        "  - Assigned <user name> (<user email>) write permissions to 'incoming'"
      ),
      file = paste0(new.path, "/", project, "/changelog.txt"),
      append = FALSE,
      sep = "/n"
    )
  }

  if (incoming == TRUE) {
    write(
      c(
        "<insert project name> Project Repository",
        "yyyymmdd (hilmar_maier@fws.gov)",
        "",
        "",
        "  - Created project repository",
        "  - Assigned Custodians <user name> (<user email>) write permissions to repository",
        "  - Assigned <user name> (<user email>) write permissions to 'incoming'"
      ),
      file = paste0(new.path, "/", project, "/incoming/changelog.txt"),
      append = FALSE,
      sep = "/n"
    )
  }

  return(invisible(NULL))

}
