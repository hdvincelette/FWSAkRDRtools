#' Scrape mdEditor metadata
#'
#' Extracts select metadata parameters from mdEditor file into a dataframe.
#' Note that only mdeditor files, not mdjson files, are not compatible with this
#' function.
#'
#' @param x mdEditor produced JSON file
#' @return A dataframe containing the file name and select metadata record
#' parameters. Each row is a unique record.
#' @export
#' @examples
#' # scrape_mdEditor(x = "fescgl_001_MixedStockAnalysis-mdeditor-20240805-110842.json")

scrape_mdEditor <- function(x) {

  ## Check file is mdEditor ####
  if(stringr::str_detect(x, "mdeditor") == FALSE | endsWith(x, ".json") == FALSE){

    stop("File provided must be mdEditor json file and contain mdeditor in file name")

  }

  ## Read mdEditor file ####
  data <- data.frame(filename = x, json = jsonlite::fromJSON(x)) %>%

    # map json from attribute within data
    dplyr::mutate(json = purrr::map(json.data.attributes$json, jsonlite::fromJSON)) %>%

    # pull up variables of interest
    tidyr::hoist(
      json,
      resourceType = c("metadata", "resourceInfo", "resourceType", "type"),
      resourceName = c("metadata", "resourceInfo", "resourceType", "name"),
      metadataStatus = c("metadata", "metadataInfo", "metadataStatus"),
      metadataDate = c("metadata", "metadataInfo", "metadataDate"),
      status = c("metadata", "resourceInfo", "status"),
      onlineResource = c(
        "metadata",
        "resourceInfo",
        "citation",
        "onlineResource",
        "uri"
      ),
      title = c(
        "metadata",
        "resourceInfo",
        "citation",
        "title"),
      abstract = c("metadata", "resourceInfo", "abstract"),
      startDateTime = c("metadata", "resourceInfo", "timePeriod", "startDateTime"),
      endDateTime = c("metadata", "resourceInfo", "timePeriod", "endDateTime"),
      pointOfContact = c("metadata", "resourceInfo", "pointOfContact")
    ) %>%

    # Create unique ID for each metadata record
    dplyr::mutate(row_id = dplyr::row_number()) %>%

    # Unnest metadataDate, this likely will create multiple columns for date, type, and description if present
    tidyr::unnest(metadataDate) %>%

    # If date from metadataDate is present make it a date variable, otherwise create a column for date and fill with NA
    dplyr::mutate(date = ifelse("date" %in% names(.), as.Date(date),
                                NA)) %>%

    # Group by unique metadata record
    dplyr::group_by(row_id) %>%

    # pull rows with most recent date
    dplyr::filter(date == max(date, na.rm = TRUE)) %>%

    dplyr::ungroup() %>%

    # rename date to metadataDate
    dplyr::rename(md_date = date) %>%

    # select variables of interest before export
    dplyr::select(
      filename,
      resourceType,
      resourceName,
      metadataStatus,
      md_date,
      status,
      onlineResource,
      title,
      abstract,
      startDateTime,
      endDateTime,
      pointOfContact,
      row_id
    ) %>%

    # Remove duplicates since there may be multiple rows with the same date but different dateType or description
    dplyr::distinct(row_id, .keep_all = TRUE) %>%

    # unlist online resource
    dplyr::rowwise() %>%

    dplyr::mutate(onlineResource = stringr::str_flatten_comma(unlist(onlineResource)))

}
