#' Commit files to the "incoming" project subfolder on the USFWS Alaska Regional Data Repository (RDR)
#'
#' Copies local file(s) to the "incoming" subfolder of a specified RDR project and updates the changelog to document changes. Remote users must be connected the Service’s approved remote connection technologies, such as a Virtual Private Network (VPN) AND be granted write permission to the project’s “incoming" subfolder (i.e., be an authorized "data steward").
#' @param project Character string. Name of the project folder.
#' @param local.path Character string. Directory name or path where the uncommitted files are located. Default is the working directory, getwd().
#' @param recursive Logical. Whether to search for and commit files in subdirectories. Default is TRUE.
#' @param review.duplicate Logical. Whether to review local duplicate files (identical file name and extension, different subfolder path). Default is TRUE, and duplicate files are reviewed and selected individually. If FALSE, all files are automatically selected for commit.
#' @param rdr.overwrite Logical. Whether to overwrite rdr files (identical file name, extension, and subfolder path) betweent local and RDR folders. Default is FALSE. If TRUE, overwrites must be reviewed and approved individually. Only files in the "incoming" subfolder of the RDR may be immediately overwritten, while those in the main project subfolders will only be overwritten at the discretion of the Data Manager.
#' @return Returns a vector of the committed files.
#' @keywords USFWS, repository
#' @seealso ```summarize.files()```
#' @export
#' @examples
#' # e.g.commit<- commit.files(project = "mbmlb_010_Grey_headed_chickadee_hybridization", local.path = getwd(), recursive = TRUE, review.duplicate = TRUE, rdr.overwrite = FALSE)

# alternative to amatch - compare against RDR paths with same first level folder

commit.files <-
  function(project,
           local.path,
           recursive,
           review.duplicate,
           rdr.overwrite) {
    ## Parameter arguments
    if (missing(local.path)) {
      local.path <- getwd()
    }
    if (missing(recursive)) {
      recursive <- TRUE
    }
    if (missing(review.duplicate)) {
      review.duplicate <- TRUE
    }
    if (missing(rdr.overwrite)) {
      rdr.overwrite <- FALSE
    }

    if(dir.exists("//ifw7ro-file.fws.doi.net/datamgt/")==FALSE){
      stop("Unable to connect to the RDR. Check your network and VPN connection.")
    }

    # ## Determine program prefix
    # program.list <- c("^fes", "^mbm", "^nwrs", "^osm", "^sa")
    # program <- NA
    # for (a in 1:length(program.list)) {
    #   if (grepl(program.list[a], project) == TRUE) {
    #     program <- sub('.', '', program.list[a])
    #   }
    # }
    # if (is.na(program) == TRUE) {
    #   stop("Project folder name must contain the program prefix (e.g., mbmlb_)")
    # }
    #
    # if (dir.exists(path = paste0(
    #   "//ifw7ro-file.fws.doi.net/datamgt/",
    #   program,
    #   "/",
    #   project,
    #   "/"
    # )) == FALSE) {
    #   stop(
    #     paste0(
    #       "Project folder '",
    #       project,
    #       "' not found. Check the folder name and network connection."
    #     )
    #   )
    # }

    ## Find files ####
    local.file.url <- character(0)
    message(paste0("Searching for local files..."))
    local.file.loc <-
      list.files(
        path = local.path,
        pattern = NULL,
        recursive = recursive,
        full.names = TRUE
      )
    if (rlang::is_empty(local.file.loc) == TRUE) {
      message(paste0(" - 0 files found"))
      next
    } else{
      message(paste0(" - ", length(local.file.loc), " file(s) found"))
      local.file.url <- local.file.loc
    }
    local.file.list <- gsub(local.path,
                            "",
                            local.file.url)
    RDR.file.url <- character(0)
    message(paste0("Searching for RDR files..."))
    suppressMessages(
      RDR.file.url <- FWSAkRDRtools::find.files(
        pattern = NULL,
        project,
        subfolder.path = "",
        main = TRUE,
        incoming = TRUE,
        recursive,
        full.path = TRUE
      )
    )
    if (rlang::is_empty(RDR.file.url) == TRUE) {
      message(paste0(" - 0 files found"))
      next
    } else{
      message(paste0(" - ", length(RDR.file.url), " file(s) found"))
    }
    RDR.file.list <-
      gsub(
        paste0("//ifw7ro-file.fws.doi.net/datamgt/",
               program,
               "/",
               project),
        "",
        RDR.file.url
      )
    ## Create list of file elements ####
    local.file.elements <-
      strsplit(local.file.list, "/(?!.*/)", perl = TRUE)
    for (a in 1:length(local.file.elements)) {
      local.file.elements[[a]] <-
        c(local.path, local.file.elements[[a]][1], local.file.elements[[a]])
    }
    local.files <- sapply(local.file.elements, "[", 4)
    RDR.file.elements <-
      strsplit(RDR.file.list, "/(?!.*/)", perl = TRUE)
    RDR.path <- paste0("//ifw7ro-file.fws.doi.net/datamgt/",
                       program,
                       "/",
                       project)
    for (a in 1:length(RDR.file.elements)) {
      RDR.file.elements[[a]] <- c(RDR.path, RDR.file.elements[[a]])
    }
    RDR.files <- sapply(RDR.file.elements, "[", 3)


    if ("changelog.txt" %in% sapply(local.file.elements, "[", 4)) {
      new.local.file.elements <- c()
      for (d in 1:length(local.file.elements)) {
        if (local.file.elements[[d]][4] != "changelog.txt") {
          new.local.file.elements <-
            c(new.local.file.elements, local.file.elements[d])
        }
      }
      local.file.elements <- new.local.file.elements
    }

    local.files <- sapply(local.file.elements, "[", 4)

    ## Check for local incoming subfolder ####
    if (TRUE %in% stringr::str_starts(sapply(local.file.elements, "[", 2), "/incoming")) {
      incoming.choice <- utils::menu(
        c(
          "Only files in the 'incoming' subfolder",
          "Only files in the main subfolders",
          "All files"
        ),
        title = cat(
          paste0(
            "\n[INPUT NEEDED]\nThe local folder has files in an 'incoming' subfolder.\nWhich files do you want to commit?"
          )
        )
      )
      if (incoming.choice == 1) {
        local.file.elements <-
          local.file.elements[stringr::str_starts(sapply(local.file.elements, "[", 2), "/incoming")]
      } else if (incoming.choice == 2) {
        local.file.elements <-
          local.file.elements[stringr::str_starts(sapply(local.file.elements, "[", 2),
                                                  "/incoming",
                                                  negate = TRUE)]
      }
    }
    local.files <- sapply(local.file.elements, "[", 4)

    ## Check for duplicate files within the local folder ####
    duplicate.files <- unique(local.files[duplicated(local.files)])
    if (length(duplicate.files) != 0) {
      for (a in 1:length(duplicate.files)) {
        local.dup.elements <- c()
        for (b in 1:length(local.file.elements)) {
          if (local.file.elements[[b]][4] == duplicate.files[a]) {
            local.dup.elements[[length(local.dup.elements) + 1]] <-
              local.file.elements[[b]]
          }
        }
        local.dup.locs <- sapply(local.dup.elements, "[", 2)
        for (d in 1:length(local.dup.locs)) {
          if (local.dup.locs[d] == "") {
            local.dup.locs[d] <- "/"
          }
        }

        if (review.duplicate == TRUE) {
          file.choice <- utils::select.list(
            c(local.dup.locs, "Skip these files"),
            multiple = TRUE,
            graphics = TRUE,
            title = cat(
              paste0(
                "\n[INPUT NEEDED]\nMultiple copies of '",
                duplicate.files[a],
                "' were found in the local folder.\nWhich file(s) should be commited to the RDR project folder?"
              )
            )
          )
          for (d in 1:length(local.dup.locs)) {
            if (local.dup.locs[d] == "/") {
              local.dup.locs[d] <- ""
            }
          }
          for (d in 1:length(file.choice)) {
            if (file.choice[d] == "/") {
              file.choice[d] <- ""
            }
          }
          if ("Skip these files" %in% file.choice) {
            new.local.file.elements <- c()
            for (d in 1:length(local.file.elements)) {
              if (local.file.elements[[d]][4] != duplicate.files[a]) {
                new.local.file.elements <-
                  c(new.local.file.elements, local.file.elements[d])
              }
            }
            local.file.elements <- new.local.file.elements
          } else if (identical(file.choice, local.dup.locs) == FALSE) {
            remove.locs <-
              local.dup.locs[!local.dup.locs %in% file.choice]
            for (c in 1:length(remove.locs)) {
              new.local.file.elements <- c()
              for (d in 1:length(local.file.elements)) {
                if (local.file.elements[[d]][4] == duplicate.files[a] &
                    local.file.elements[[d]][2] == remove.locs[c]) {
                  next
                } else {
                  new.local.file.elements <-
                    c(new.local.file.elements, local.file.elements[d])
                }
              }
              local.file.elements <- new.local.file.elements
            }
          }
        }
      }
    }
    message(cat(""))
    local.files <- sapply(local.file.elements, "[", 4)

    ## Check for duplicate files between local folder and RDR folder ####
    duplicate.files <- intersect(local.files, RDR.files)
    if (length(duplicate.files) != 0) {

      for (a in 1:length(duplicate.files)) {
        local.dup.elements <- c()
        for (b in 1:length(local.file.elements)) {
          if (local.file.elements[[b]][4] == duplicate.files[a]) {
            local.dup.elements[[length(local.dup.elements) + 1]] <-
              local.file.elements[[b]]
          }
        }
        local.dup.locs <- sapply(local.dup.elements, "[", 2)
        RDR.dup.elements <- c()
        for (b in 1:length(RDR.file.elements)) {
          if (RDR.file.elements[[b]][3] == duplicate.files[a]) {
            RDR.dup.elements[[length(RDR.dup.elements) + 1]] <-
              RDR.file.elements[[b]]
          }
        }
        RDR.dup.locs <-
          sapply(RDR.dup.elements, "[", 2)
        if (rdr.overwrite == TRUE) {
          file.choice <- utils::menu(c("Yes", "No"),
                                     title =
                                       cat(
                                         paste0(
                                           "\n[INPUT NEEDED]\n'",
                                           duplicate.files[a],
                                           "' already exists in the following RDR subfolder(s):\n"
                                         ),
                                         paste0(RDR.dup.locs, sep = "\n"),
                                         "\nDo you still want to commit this file?"
                                       ))
          if (file.choice == 2) {
            local.file.elements <-
              local.file.elements[!local.file.elements %in% local.dup.elements]
          }
        } else if (rdr.overwrite == FALSE){
          local.file.elements <-
            local.file.elements[!local.file.elements %in% local.dup.elements]
        }
      }
    }
    local.files <- sapply(local.file.elements, "[", 4)

    if(length(local.files)!=0){


    ## Check if local subfolders match existing RDR incoming subfolders ####
    local.subfolders <- unique(sapply(local.file.elements, "[", 2))
    message("\nFinding RDR subfolders...")
    RDR.subfolders <- gsub(
      paste0("//ifw7ro-file.fws.doi.net/datamgt/",
             program,
             "/",
             project),
      "",
      list.dirs(path = RDR.path,
                recursive = TRUE)
    )
    RDR.main.subfolders <-
      RDR.subfolders[stringr::str_starts(RDR.subfolders, "/incoming", negate = TRUE)]
    for (a in 1:length(local.subfolders)) {
      if (stringr::str_starts(local.subfolders[a], "/incoming") == TRUE) {
        subfolder.ref <- "'incoming' subfolder"
      } else {
        subfolder.ref <- "main"
      }
      gsub.local.subfolder <-
        gsub("^/incoming", "", local.subfolders[a])
      if (!gsub.local.subfolder %in% RDR.main.subfolders) {
        RDR.match <-
          RDR.main.subfolders[stringdist::amatch(gsub.local.subfolder,
                                                 RDR.main.subfolders,
                                                 maxDist = Inf)]
        add.subfolders <- gsub(RDR.match, "", gsub.local.subfolder)
        files.missing.subfolder <- c()
        for (c in 1:length(local.file.elements)) {
          if (local.file.elements[[c]][2] == local.subfolders[a]) {
            files.missing.subfolder <-
              c(files.missing.subfolder, local.file.elements[[c]][4])
          }
        }
        subfolder.choice <-
          utils::menu(
            c(
              paste0("Use the closest matching RDR path: '", RDR.match, "'"),
              paste0(
                "Create the necessary subfolder(s) - '",
                add.subfolders,
                "' - in the closest matching RDR path: '",
                RDR.match,
                "'"
              ),
              "Provide a new path",
              "Skip these files"
            ),
            title =
              cat(
                paste0(
                  "\n[INPUT NEEDED]\nThe local ",
                  subfolder.ref,
                  " path '",
                  gsub.local.subfolder,
                  "' was not found in the RDR folder.\nThis path contains the following files:\n"
                ),
                paste0(files.missing.subfolder, sep = "\n"),
                "\nHow would you like to proceed?"
              )
          )
        if (subfolder.choice == 1) {
          for (b in 1:length(local.file.elements)) {
            if (local.file.elements[[b]][2] == local.subfolders[a]) {
              if (subfolder.ref != "main") {
                local.file.elements[[b]][3] <- paste0("/incoming", RDR.match)
              } else {
                local.file.elements[[b]][3] <- RDR.match
              }
            }
          }
        } else if (subfolder.choice == 2) {
          new.path <- paste0(RDR.match, add.subfolders)
          for (b in 1:length(local.file.elements)) {
            if (local.file.elements[[b]][2] == local.subfolders[a]) {
              if (subfolder.ref != "main") {
                local.file.elements[[b]][3] <- paste0("/incoming", new.path)
              } else {
                local.file.elements[[b]][3] <- new.path
              }
            }
          }

          # if (dir.exists(paste0(RDR.path, "/incoming", new.path)) == FALSE) {
          #   dir.create(paste0(RDR.path, "/incoming", new.path))
          # }

          RDR.main.subfolders <-
            c(RDR.main.subfolders, new.path)
        }
        else if (subfolder.choice == 3) {
          message(
            cat(
              "Enter a file path separated by '/'. Make sure to begin at the root directory (i.e., '/' or '/data/final_data'):"
            )
          )
          new.subfolder <-
            readline(prompt =)
          new.subfolder <- as.character(new.subfolder)
          if (startsWith(new.subfolder, "/") == FALSE) {
            new.subfolder <- paste0("/", new.subfolder)
          }
          if (endsWith(new.subfolder, "/") == TRUE) {
            new.subfolder <- sub("/$", "", new.subfolder)
          }

          # RDR.match <-
          #   RDR.main.subfolders[stringdist::amatch(new.subfolder,
          #                                          RDR.main.subfolders,
          #                                          maxDist = Inf)]
          #
          #
          # add.subfolders <- gsub(RDR.match, "", new.subfolder)

          new.path <- new.subfolder

          # if (dir.exists(paste0(RDR.path, "/incoming", new.path)) == FALSE) {
          #   dir.create(paste0(RDR.path, "/incoming", new.path))
          # }

          RDR.main.subfolders <- c(RDR.main.subfolders, new.path)
          for (b in 1:length(local.file.elements)) {
            if (local.file.elements[[b]][2] == local.subfolders[a]) {
              if (subfolder.ref != "main") {
                local.file.elements[[b]][3] <- paste0("/incoming", new.path)
              } else {
                local.file.elements[[b]][3] <- new.path
              }
            }
          }
        } else if (subfolder.choice == 4) {
          new.local.file.elements <- c()
          for (d in 1:length(local.file.elements)) {
            if (local.file.elements[[d]][2] != local.subfolders[a]) {
              new.local.file.elements <-
                c(new.local.file.elements, local.file.elements[d])
            }
          }
          local.file.elements <- new.local.file.elements
        }
      }
    }
    local.files <- sapply(local.file.elements, "[", 4)
    local.subfolders <- sapply(local.file.elements, "[", 2)


    ## Summarize commit ####

    for (a in 1:length(local.file.elements)) {
      local.file.elements[[a]][3] <-
        paste0("/incoming",
               gsub("^/incoming", "", local.file.elements[[a]][3]))
    }

    duplicate.files <- unique(local.files[duplicated(local.files)])

    if (length(duplicate.files) != 0) {
      for (a in 1:length(duplicate.files)) {
        RDR.dup.elements <- c()
        for (b in 1:length(local.file.elements)) {
          if (local.file.elements[[b]][4] == duplicate.files[a]) {
            RDR.dup.elements[[length(RDR.dup.elements) + 1]] <-
              local.file.elements[[b]]
          }
        }

        RDR.dup.locs <- sapply(RDR.dup.elements, "[", 3)


        if (TRUE %in% duplicated(RDR.dup.locs)) {
          RDR.dup.locs.conflict <-
            unique(RDR.dup.locs[duplicated(RDR.dup.locs)])

          for (c in 1:length(RDR.dup.locs.conflict)) {
            gsub.RDR.dup.locs.conflict <-
              gsub("^/incoming", "", RDR.dup.locs.conflict[c])

            for (d in 1:length(gsub.RDR.dup.locs.conflict)) {
              if (gsub.RDR.dup.locs.conflict[c] == "") {
                gsub.RDR.dup.locs.conflict[d] <- "/"
              }
            }

            dup.commit.choice <-
              utils::menu(c("Select file to commit",
                            "Skip these files"),
                          title = cat(
                            paste0(
                              "\n[INPUT NEEDED]\nMultiple copies of '",
                              duplicate.files[a],
                              "' are going to be committed to '",
                              gsub.RDR.dup.locs.conflict,
                              "'.\n\nHow do you want to proceed?"
                            )
                          ))

            if (dup.commit.choice == 1) {
              local.ref.locs <- c()

              for (d in 1:length(local.file.elements)) {
                if (local.file.elements[[d]][4] == duplicate.files[a] &
                    local.file.elements[[d]][3] == RDR.dup.locs.conflict[c]) {
                  local.ref.locs <- c(local.ref.locs, local.file.elements[[d]][2])
                }
              }

              for (d in 1:length(local.ref.locs)) {
                if (local.ref.locs[d] == "") {
                  local.ref.locs[d] <- "/"
                }
              }

              dup.commit.selection <-
                utils::menu(c(local.ref.locs),
                            title = cat(paste0(
                              "\n[INPUT NEEDED]\nCommit which file(s)?"
                            )))

              for (d in 1:length(local.ref.locs)) {
                if (local.ref.locs[d] == "/") {
                  local.ref.locs[d] <- ""
                }
              }

              remove.locs <-
                local.ref.locs[!local.ref.locs %in% local.ref.locs[dup.commit.selection]]
            } else {
              remove.locs <- local.ref.locs
            }


            new.local.file.elements <- c()
            for (b in 1:length(local.file.elements)) {
              if (local.file.elements[[b]][4] == duplicate.files[a] &
                  local.file.elements[[b]][2] %in% remove.locs) {
                next
              } else {
                new.local.file.elements <-
                  c(new.local.file.elements,
                    local.file.elements[b])
              }
            }
            local.file.elements <- new.local.file.elements
          }
        }
      }
    }




    # gsub.commit.to.file.list <-
    #   mapply(
    #     c,
    #     gsub("^/incoming", "", commit.to.file.list),
    #     commit.to.file.list,
    #     SIMPLIFY = FALSE,
    #     USE.NAMES = FALSE
    #   )


    commit.from.file.list <-
      paste0(sapply(local.file.elements, "[", 2),
             "/",
             sapply(local.file.elements, "[", 4))
    commit.to.file.list <-
      paste0(sapply(local.file.elements, "[", 3),
             "/",
             sapply(local.file.elements, "[", 4))

    gsub.commit.to.file.list <-
      gsub("^/incoming", "", commit.to.file.list)

    commit.choice <-
      utils::menu(
        c("Commit all files",
          "Select files to commit",
          "Cancel commit"),
        title =
          cat(
            paste0(
              "\n[INPUT NEEDED]\nThe following local files are ready to be committed in the respective RDR 'incoming' subfolders:\n"
            ),
            paste0(gsub.commit.to.file.list, sep = "\n"),
            "\nHow do you want to proceed?"
          )
      )
    if (commit.choice == 1) {

    } else if (commit.choice == 2) {
      commit.selection <- utils::select.list(
        c(gsub.commit.to.file.list),
        multiple = TRUE,
        graphics = TRUE,
        title = cat(paste0(
          "\n[INPUT NEEDED]\nCommit which file(s)?"
        ))
      )
      for (a in 1:length(gsub.commit.to.file.list)) {
        if (!gsub.commit.to.file.list[[a]][1] %in% commit.selection) {
          commit.from.file.list[a] <- NA
          commit.to.file.list[a] <- NA
        }
      }
      commit.from.file.list <-
        commit.from.file.list[!is.na(commit.from.file.list)]
      commit.to.file.list <-
        commit.to.file.list[!is.na(commit.to.file.list)]
    } else if (commit.choice == 3) {
      stop("Operation halted.")
    }
    ## Commit files ####
    message(paste0("\n\nCommitting files..."))
    for (a in 1:length(commit.to.file.list)) {
      commit.from.path <-
        sapply(strsplit(commit.from.file.list[a], "/(?!.*/)", perl = TRUE),
               "[",
               1)
      commit.from.file <-
        sapply(strsplit(commit.from.file.list[a], "/(?!.*/)", perl = TRUE),
               "[",
               2)
      commit.to.path <-
        gsub("^/incoming", "", sapply(
          strsplit(commit.to.file.list[a], "/(?!.*/)", perl = TRUE),
          "[",
          1
        ))
      commit.to.file <-
        sapply(strsplit(commit.to.file.list[a], "/(?!.*/)", perl = TRUE),
               "[",
               2)
      if (dir.exists(paste0(RDR.path, "/incoming", commit.to.path)) ==
          FALSE) {
        dir.create(paste0(RDR.path, "/incoming", commit.to.path))
      }
      invisible(file.copy(
        from = paste0(local.path, commit.from.path, "/", commit.from.file),
        to = paste0(RDR.path, "/incoming", commit.to.path, "/", commit.to.file),
        recursive = FALSE
      ))
    }
    ## Update incoming changelog ####
    message(cat("\n[INPUT NEEDED]\nProvide an email for the changelog:"))
    user.email <-
      readline(prompt =)
    date <- format(Sys.Date(), format = "%Y%m%d")
    local.location <-
      sapply(strsplit(commit.from.file.list, "/(?!.*/)", perl = TRUE),
             "[",
             1)
    RDR.location <-
      paste0("/incoming", gsub("^/incoming", "", sapply(
        strsplit(commit.to.file.list, "/(?!.*/)", perl = TRUE),
        "[",
        1
      )))
    file <-
      sapply(strsplit(commit.from.file.list, "/(?!.*/)", perl = TRUE),
             "[",
             2)
    commit.summary <- data.frame(local.path, local.location,
                                 RDR.path, RDR.location, file)
    commit.summary <- commit.summary %>%
      dplyr::mutate_at(c("local.location", "RDR.location"),  dplyr::na_if, "") %>%
      dplyr::mutate_at(c("local.location", "RDR.location"),
                       ~ replace(., is.na(.), "/")) %>%
      dplyr::mutate("message" =
                      paste0("  -- ", file, " (", gsub("^/incoming", "", RDR.location), ")"))
    commit.summary <-
      commit.summary[order(commit.summary$RDR.location, decreasing = FALSE),]
    invisible(if (file.exists(paste0(RDR.path, "/incoming/changelog.txt")) == FALSE) {
      file.create(paste0(RDR.path, "/incoming/changelog.txt"))
    })
    write(
      x = c(
        "",
        paste0(date, " (", user.email, ")"),
        "  - Added the following files:",
        commit.summary$message
      ),
      append = TRUE,
      file = paste0(RDR.path, "/incoming/changelog.txt"),
      sep = "\n"
    )

    message(cat(paste0("\nFile commit to '",project,"' is complete.")))


    if (Sys.info()["sysname"] == "Windows") {
      shell.exec(
        paste0(
          "file:////ifw7ro-file.fws.doi.net/datamgt/",
          program,
          "/",
          project,
          "/incoming/changelog.txt"
        )
      )
    }

    return(subset(commit.summary, select = -c(message)))

    } else {
      message(cat("\nExecution halted: No files to commit."))
    }
  }
