
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fleece <img src="man/figures/logo.png" align="right" height="284" />

<!-- badges: start -->
<!-- badges: end -->

“fleece” contains helper functions for turing JSON output into tidy
data.frames. It automatically unnests all columns, deals with entries of
unequal length, and notices if data is on a single or multiple
observations.

## Installation

You can install the development version of fleece from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("thieled/fleece")
```

## Example

Here are two examples how to use fleece::rectangularize() on JSON output
from different APIs.

``` r

library(fleece)

### Example 1

# In the first example we use the "earthquake.usgs.gov" API to get data about some earthquakes:
url <- "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2023-03-01&endtime=2023-03-02&minmagnitude=5"

# Call the API and extract the content using httr
con <- httr::GET(url) |> httr::content()

# Note that httr::content already parses the JSON data into a "list" R-object.
# Often, APIs return a number of things. Pick the content that interests you:
con <- con$features

# Feed the list object into rectangularize() and voila:
df <- rectangularize(con)

dplyr::glimpse(df)
#> Rows: 6
#> Columns: 32
#> $ type                   <chr> "Feature", "Feature", "Feature", "Feature", "Fe…
#> $ id                     <chr> "us7000jgnz", "us7000jgmv", "us7000jgmu", "us70…
#> $ properties_mag         <dbl> 5.0, 5.0, 5.5, 5.0, 5.1, 6.6
#> $ properties_place       <chr> "southern Sumatra, Indonesia", "157 km ESE of K…
#> $ properties_time        <dbl> 1.677712e+12, 1.677699e+12, 1.677699e+12, 1.677…
#> $ properties_updated     <dbl> 1.683511e+12, 1.683511e+12, 1.689795e+12, 1.683…
#> $ properties_tz          <lgl> NA, NA, NA, NA, NA, NA
#> $ properties_url         <chr> "https://earthquake.usgs.gov/earthquakes/eventp…
#> $ properties_detail      <chr> "https://earthquake.usgs.gov/fdsnws/event/1/que…
#> $ properties_felt        <int> 2, NA, NA, NA, NA, 4
#> $ properties_cdi         <dbl> 3.1, NA, NA, NA, NA, 4.1
#> $ properties_mmi         <dbl> NA, NA, 2.980, NA, NA, 2.354
#> $ properties_alert       <chr> NA, NA, "green", NA, NA, "green"
#> $ properties_status      <chr> "reviewed", "reviewed", "reviewed", "reviewed",…
#> $ properties_tsunami     <int> 0, 0, 0, 0, 0, 1
#> $ properties_sig         <int> 385, 385, 465, 385, 400, 672
#> $ properties_net         <chr> "us", "us", "us", "us", "us", "us"
#> $ properties_code        <chr> "7000jgnz", "7000jgmv", "7000jgmu", "7000jgk0",…
#> $ properties_ids         <chr> ",us7000jgnz,", ",us7000jgmv,", ",pt23060001,us…
#> $ properties_sources     <chr> ",us,", ",us,", ",pt,us,", ",us,", ",us,", ",us…
#> $ properties_types       <chr> ",dyfi,origin,phase-data,", ",origin,phase-data…
#> $ properties_nst         <int> 206, 60, 103, 110, 39, 156
#> $ properties_dmin        <dbl> 3.490, 5.028, 1.965, 0.655, 17.440, 2.725
#> $ properties_rms         <dbl> 0.64, 0.64, 0.90, 0.41, 0.58, 0.76
#> $ properties_gap         <int> 28, 78, 44, 73, 95, 11
#> $ properties_magType     <chr> "mww", "mb", "mww", "mb", "mb", "mww"
#> $ properties_type        <chr> "earthquake", "earthquake", "earthquake", "eart…
#> $ properties_title       <chr> "M 5.0 - southern Sumatra, Indonesia", "M 5.0 -…
#> $ geometry_type          <chr> "Point", "Point", "Point", "Point", "Point", "P…
#> $ geometry_coordinates_1 <dbl> 100.8384, 149.5786, 146.8086, 142.7793, -27.079…
#> $ geometry_coordinates_2 <dbl> -1.5655, 44.4887, 14.1495, 27.4834, -60.3018, -…
#> $ geometry_coordinates_3 <dbl> 93.325, 35.000, 10.404, 16.780, 62.441, 600.933



### Example 2

# Let's get some information about German universities:
url_2 <- "http://universities.hipolabs.com/search?country=Germany"

# Let's use this example to demonstrate how to deal with JSON data that is plain text:
con_2 <- httr::GET(url_2) |> httr::content(as = "text", encoding = "UTF-8") 

# Use jsonlite::parse_json() to parse text as an R 'list' object:
con_2 <- con_2 |> jsonlite::parse_json()

# Here, we can use the output right away for rectangularize():
df_2 <- rectangularize(con_2)

dplyr::glimpse(df_2)
#> Rows: 622
#> Columns: 12
#> $ `state-province` <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ country          <chr> "Germany", "Germany", "Germany", "Germany", "Germany"…
#> $ alpha_two_code   <chr> "DE", "DE", "DE", "DE", "DE", "DE", "DE", "DE", "DE",…
#> $ name             <chr> "AKAD Hochschulen für Berufstätige, Fachhochschule Le…
#> $ domains_1        <chr> "akad.de", "asfh-berlin.de", "augustana.de", "bethel.…
#> $ domains_2        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ domains_3        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ domains_4        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ web_pages_1      <chr> "http://www.akad.de/", "http://www.asfh-berlin.de/", …
#> $ web_pages_2      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ web_pages_3      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ web_pages_4      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
```

## Acknowledgement

Documentation was accelerated by [ChatGPT](https://chat.openai.com/).
The Adventure-Time like drawing in the logo was created by
[Dall-E](https://openai.com/dall-e-2). The name is a
[pun](https://en.wikipedia.org/wiki/Golden_Fleece). :)
