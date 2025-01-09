#' Get Contacts
#'
#' Generates a table of contacts for individuals and organizations associated with a set of metadata records.
#'
#' @param x An mdEditor metadata file containing one or more contact records
#' @return Returns a data frame summarizing all contacts found within the metadata file, including the contactId, name, and email address.
#' @export
#' @examples
#' # get.contacts(file = "AK-contacts-mdeditor-20241210-111268.json")

get.contacts <- function(x) {

  # read in JSON file containing list of contacts
  mdjson <- jsonlite::fromJSON(txt = x)

  data <- dplyr::bind_rows( # bind into dataframe

    # cycle through json and extract contactId, name, and email
    lapply(

      # cycle through contacts and read json
      lapply(
        mdjson$data$attributes$json,
        jsonlite::fromJSON)[mdjson[["data"]][["type"]]=="contacts"],

      function(x) {
        data.frame(
          contactId = x$contactId,
          name = x$name,
          electronicMailAddress = ifelse(
            length(x$electronicMailAddress) > 0,
            x$electronicMailAddress,
            NA
          )
        )
      })) |>

    # Get rid of duplicate entries
    dplyr::distinct()

}
