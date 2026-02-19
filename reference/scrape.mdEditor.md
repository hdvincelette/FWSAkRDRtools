# Scrape metadata from an mdEditor metadata file

Extracts select metadata parameters from an mdEditor file into a
dataframe.

## Usage

``` r
scrape.mdEditor(x)
```

## Arguments

- x:

  An mdEditor metadata file containing one or more record. mdJSON files
  are not compatible.

## Value

Returns a data frame summarizing the file name and select metadata
record parameters. Each row is a unique record.

## Examples

``` r
# scrape.mdEditor(x = "fescgl_001_MixedStockAnalysis-mdeditor-20240805-110842.json")
```
