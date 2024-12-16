#' Get Contacts
#'
#' Generates a table of contacts for individuals and organizations associated
#' with a set of metadata records. Primarily used within other functions.
#'
#' @param file A mdJSON metadata file containing a list of contacts
#'
#' @return A data.frame containing all contacts found within metadata file,
#' including their contactIds, names, and email addresses.
#' @export
#' @examples
#' # get_contacts(x = "AK-contacts-mdeditor-20241210-111268.json")

get_contacts <- function(file) {

  # read in JSON file containing list of contacts
  mdjson <- jsonlite::fromJSON(file)


  data <- dplyr::bind_rows( # bind into dataframe

    # cycle through json and extract contactId, name, and email
    lapply(

      # cycle through contacts and read json
      lapply(
        mdjson$data$attributes$json,
        jsonlite::fromJSON),

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
