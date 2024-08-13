

folder.path <- "C:/Users/hvincelette/OneDrive - DOI/Documents/GitHub/landbird-dp-workflow/"
subfolder <- "downloads/"
pattern <- "mbmlb"
replacement <- "mbm7lb"
index.name<- "identifier"
quiet <- TRUE

metadata.files <-
  list.files(
    path = paste0(folder.path,subfolder),
    pattern = "\\.json$",
    full.names = FALSE,
    recursive = FALSE,
    ignore.case = TRUE
  )

metadata.choice <- utils::select.list(
  c(metadata.files),
  multiple = FALSE,
  graphics = TRUE,
  title = cat(paste0("\nSelect a metadata file to import."))
)

metadata.file <-
  rjson::fromJSON(file = paste0(folder.path, subfolder, metadata.choice))

for(a in 1:length(metadata.file[["data"]])) {
 record<- rjson::fromJSON(metadata.file[["data"]][[a]][["attributes"]][["json"]])

  indices <- rrapply::rrapply(
    record,
    classes = "ANY",
    condition = function(x, .xname)
      .xname == index.name,
    f = function(x, .xpos)
      .xpos,
    how = "flatten"
  )

  if (length(indices) != 0) {
    indices <- sapply(1:length(indices), function(x) {
      purrr::flatten_int(indices[x])
    })

    values <- sapply(1:length(indices), function(x) {
      record[[purrr::flatten_int(indices[x])]]
    })

    indices <- indices[which(grepl(pattern, values, ignore.case = TRUE))]


    if (quiet == FALSE) {
      index.choice <-
        utils::select.list(
          c(sapply(1:length(indices), function(x) {
            record[[indices[[x]]]]
          })),
          multiple = TRUE,
          graphics = TRUE,
          title = cat(paste0(
            "\nSelect values to correct in the metadata file.\n"
          ))
        )

      indices <- indices[which(sapply(1:length(indices), function(x) {
        record[[indices[[x]]]]
      }) %in% index.choice)]
    }


    for (b in 1:length(indices)) {
      record[[c(indices[[b]])]] <- gsub(pattern, replacement, record[[c(indices[[b]])]], ignore.case = TRUE)

    }

    date.update <- paste0(strftime(as.POSIXlt(Sys.time(), Sys.timezone()), "%Y-%m-%dT%H:%M"),
                          ":00.000Z",
                          collapse = "")

    last.update.index <- which(sapply(record[["metadata"]][["metadataInfo"]][["metadataDate"]], "[", "dateType") ==
                                 "lastUpdate")

    if (length(last.update.index) != 0) {
      record[["metadata"]][["metadataInfo"]][["metadataDate"]][[last.update.index]][["date"]] <- date.update
    } else {
      record[["metadata"]][["metadataInfo"]][["metadataDate"]][[length(record[["metadata"]][["metadataInfo"]][["metadataDate"]]) +
                                                                  1]] <-
        list(date = date.update, dateType = "lastUpdate")

    }


    newstring<- rjson::toJSON(x = record)

    for (b in c(
      "status",
      "accessConstraint",
      "useLimitation",
      "useConstraint",
      "otherConstraint",
      "mdDictionary",
      "path",
      "subject"
    )) {
      if (grepl(paste0(".*\"", b, "\":\"(\\w+.*?)\".*"), newstring) == TRUE) {
        oldsyntax <-
          paste0('\"', b, '\":\"', gsub(paste0(".*\"", b, "\":\"(\\w+.*?)\".*"), "\\1", newstring), '\"')
        newsyntax <-
          paste0('\"', b, '\":[\"', gsub(paste0(".*\"", b, "\":\"(\\w+.*?)\".*"), "\\1", newstring), '\"]')
        newstring <- gsub(oldsyntax, newsyntax, newstring)
      }
    }

    metadata.file[["data"]][[a]][["attributes"]][["json"]] <-  newstring
  }
}


file.name <- gsub("\\_mdeditor.*", "", metadata.choice, ignore.case = TRUE)


write(
  x = rjson::toJSON(metadata.file),
  file = paste0(
    folder.path,
    subfolder,
    file.name,
    "_mdeditor-",
    format(
      as.POSIXct(date.update, tz = "UTC", "%Y-%m-%dT%H:%M:%OS"),
      '%Y%m%d-%H%M%S'
    ),
    ".json"
  )
)


listviewer::jsonedit(record)

diffobj::diffDeparse(metadata.file, metadata.file.2)

download.file(
  "https://github.com/adiwg/mdJson-schemas/archive/refs/heads/develop.zip",
  destfile = "mdJson-schemas-develop.zip"
)

file.list<- list.files("mdJson-schemas-develop/schema", full.names=TRUE)

schemas<- lapply(file.list, function(x) jsonlite::read_json(path = x))
names(schemas)<- sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(file.list))

properties.type <- sapply(names(schemas), function(x)  {
  lapply(schemas[[x]][["properties"]], "[[", "type")
}) %>% lapply(., purrr::compact)


arrays<- sapply(names(properties.type), function(x)
  purrr::keep(properties.type[[x]], ~ .x == "array")) %>%
  purrr::compact() %>%
  purrr::map_depth(., 1, names)

purrr::list_c(arrays)

# keyword
# identifier
# date



