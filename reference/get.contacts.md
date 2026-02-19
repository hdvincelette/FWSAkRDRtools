# Get contacts from an mdEditor metadata file

Generates a table of contacts for individuals and organizations
associated with a set of metadata records.

## Usage

``` r
get.contacts(x)
```

## Arguments

- x:

  An mdEditor metadata file containing one or more contact records

## Value

Returns a data frame summarizing all contacts found within the metadata
file, including the contactId, name, and email address.

## Examples

``` r
# get.contacts(file = "AK-contacts-mdeditor-20241210-111268.json")
```
