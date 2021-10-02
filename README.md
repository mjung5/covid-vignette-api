covid-vignette-api
================
Min-Jung Jung
9/20/2021

-   [Reqired pakages](#reqired-pakages)
-   [JSON Data](#json-data)
-   [Packages used for reading JSON data in
    R](#packages-used-for-reading-json-data-in-r)
-   [Contact the Covid Data API](#contact-the-covid-data-api)
    -   [country name](#country-name)
    -   [`Confirmed Cases by different contries` from March 1st, 2020 to
        September 21st,
        2021](#confirmed-cases-by-different-contries-from-march-1st-2020-to-september-21st-2021)
    -   [`Death Cases by different contries` from March 1st, 2020 to
        September 21st,
        2021](#death-cases-by-different-contries-from-march-1st-2020-to-september-21st-2021)
    -   [`Recovered Cases by different contries` from March 1st, 2020 to
        September 21st,
        2021](#recovered-cases-by-different-contries-from-march-1st-2020-to-september-21st-2021)
    -   [`U.S.A cases by state`](#usa-cases-by-state)
-   [Exploratory Data Analysis](#exploratory-data-analysis)
    -   [Contigency Tables/ Numerical
        Summaries](#contigency-tables-numerical-summaries)
    -   [Graphical Summaries](#graphical-summaries)
-   [Bar plot](#bar-plot)
-   [Histogram](#histogram)

This project is to create a vignette about contacting an API. I created
functions to download data via interacting endpoints. I will show this
process with COVID API.

# Reqired pakages

I used following packages to set up function, data manipulation, and
analysis with COVID API:

-   `knitr`: to generate pretty tables of date using the `kable()`
    function.  
-   `tidyverse`: to manipulate data, generate plots (via `ggplot2`), and
    to use piping/chaining.
-   `rmarkdown`: to knit output files manually using the `render()`
    function.  
-   `jsonlite`: to pull data from various endpoints of the Covid 19
    APIs.

# JSON Data

JSON, also known as [*Java Script Object
Notation*](https://www.json.org/json-en.html) is a text based format for
storing and/or transporting data. JSON is used across the internet and
databases because of its text based format for storing data. In
addition, JSON can represent 2D data, [hierarchical
data](https://en.wikipedia.org/wiki/Hierarchical_database_model), and
use key-value pairs.

Since JSON is a text based format, we need to load in R packages that
can handle the text based format.

# Packages used for reading JSON data in R

Here are R packages that can be used to work with JSON data:

-   `rjson`
-   `RJSONIO`
-   `jsonlite`

For this project, `rjson` and `jsonlite` is used.

Couple resources for understanding the functionality of `rjson` and
`jsonlite`:

1.  <https://cran.r-project.org/web/packages/rjson/rjson.pdf>

2.  <https://cran.r-project.org/web/packages/jsonlite/jsonlite.pdf>

# Contact the Covid Data API

To access the [Covid
Data](https://documenter.getpostman.com/view/10808728/SzS8rjbc), we need
to get a URL with the name of the table and attributes we want to pull
from it.

In addition, I wrote 6 more functions that take different endpoints.

\#Base url

``` r
base_url = "https://api.covid19api.com"
```

## country name

\#This function is to generate data.frame of country name and Slug.

``` r
country_Name <- function(){
  country <- GET("https://api.covid19api.com/countries")
  countrylist <- fromJSON(rawToChar(country$content))
  countrylist1 <- as_tibble(data.frame(Country = countrylist$Country, Slug = countrylist$Slug))
  return(countrylist1)
}
```

countryName &lt;- countryName()

## `Confirmed Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint.

``` r
get_confirmed_cases <- function(country){
     if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/confirmed?from=2020-03-01T00:00:00Z&to=2021-09-21T00:00:00Z")
  confirmed_cases_text = content(GET(url=full_url),"text")
  confirmed_cases_json = fromJSON(confirmed_cases_text)
  return(confirmed_cases_json)
     }
        else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

confirmed &lt;- get\_confirmed\_cases()

confirmed

## `Death Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint, but
modified the status as deaths.

``` r
get_deaths_cases <- function(country){
    if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/deaths?from=2020-03-01T00:00:00Z&to=2021-09-21T00:00:00Z")
  deaths_cases_text = content(GET(url=full_url),"text")
  deaths_cases_json = fromJSON(deaths_cases_text)
  return(deaths_cases_json)
    }
        else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

deaths &lt;- get\_deaths\_cases(“india”)

deaths

get\_deaths\_cases(“canada”)

## `Recovered Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint, but
modified the status as recovered.

``` r
get_recovered_cases <- function(country){
  if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/", country,"/status/recovered?from=2020-03-01T00:00:00Z&to=2021-09-21T00:00:00Z")
  recovered_cases_text = content(GET(url=full_url),"text")
  recovered_cases_json = fromJSON(recovered_cases_text)
  return(recovered_cases_json)
  }
      else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

recovered &lt;- get\_recovered\_cases(“united-states”) recovered

## `U.S.A cases by state`

\#This function interacts with the `Day One Live` endpoint. confrimed
cases only

``` r
get_cases_bystate <- function(state_name){
  state_name <- tolower(state_name)
  two_word_states = list("new hampshire", "new jersey", "new mexico","new york","north carolina","north dakota","south carolina","south dakota", "distrct of columbia", "puerto rico","Northern Mariana Islands", "Virgin Islands", "Rhode Island")
  if (state_name %in% two_word_states){
     full_url = paste0(base_url,"/dayone/country/united-states/status/confirmed/live?province=",state_name)
     URLencode(full_url)
    covid_cases_by_states_text = content(GET(url=URLencode(full_url)),"text")
    covid_cases_by_states_json = fromJSON(covid_cases_by_states_text)
  }
    else{
    full_url = paste0(base_url,"/dayone/country/united-states/status/confirmed/live?province=",state_name)
    covid_cases_by_states_text = content(GET(url=full_url),"text")
    covid_cases_by_states_json = fromJSON(covid_cases_by_states_text)
    }
     covid_cases_by_states <- covid_cases_by_states_json %>% select(Country, Province, City, Cases, Status, Date) 
  return(covid_cases_by_states)
}

stateCases <- get_cases_bystate("North Carolina")
```

    ## No encoding supplied: defaulting to UTF-8.

``` r
stateCases
```

    ##                      Country       Province         City Cases    Status                 Date
    ## 1   United States of America North Carolina        Union  7255 confirmed 2020-11-22T00:00:00Z
    ## 2   United States of America North Carolina       Person   894 confirmed 2020-11-22T00:00:00Z
    ## 3   United States of America North Carolina     Mitchell   472 confirmed 2020-11-22T00:00:00Z
    ## 4   United States of America North Carolina      Robeson  7045 confirmed 2020-11-22T00:00:00Z
    ## 5   United States of America North Carolina    Edgecombe  2404 confirmed 2020-11-22T00:00:00Z
    ## 6   United States of America North Carolina       Craven  2924 confirmed 2020-11-22T00:00:00Z
    ## 7   United States of America North Carolina       Greene  1146 confirmed 2020-11-22T00:00:00Z
    ## 8   United States of America North Carolina         Polk   454 confirmed 2020-11-22T00:00:00Z
    ## 9   United States of America North Carolina     Guilford 15355 confirmed 2020-11-22T00:00:00Z
    ## 10  United States of America North Carolina      Jackson  1335 confirmed 2020-11-22T00:00:00Z
    ## 11  United States of America North Carolina      Tyrrell   138 confirmed 2020-11-22T00:00:00Z
    ## 12  United States of America North Carolina   Rockingham  2805 confirmed 2020-11-22T00:00:00Z
    ## 13  United States of America North Carolina    Cleveland  4014 confirmed 2020-11-22T00:00:00Z
    ## 14  United States of America North Carolina       Pender  1800 confirmed 2020-11-22T00:00:00Z
    ## 15  United States of America North Carolina         Clay   275 confirmed 2020-11-22T00:00:00Z
    ## 16  United States of America North Carolina   Cumberland  8868 confirmed 2020-11-22T00:00:00Z
    ## 17  United States of America North Carolina       Orange  3704 confirmed 2020-11-22T00:00:00Z
    ## 18  United States of America North Carolina        Surry  2589 confirmed 2020-11-22T00:00:00Z
    ## 19  United States of America North Carolina         Ashe   710 confirmed 2020-11-22T00:00:00Z
    ## 20  United States of America North Carolina    Alleghany   375 confirmed 2020-11-22T00:00:00Z
    ## 21  United States of America North Carolina       Bladen  1265 confirmed 2020-11-22T00:00:00Z
    ## 22  United States of America North Carolina        Wayne  5476 confirmed 2020-11-22T00:00:00Z
    ## 23  United States of America North Carolina      Forsyth 12101 confirmed 2020-11-22T00:00:00Z
    ## 24  United States of America North Carolina     Johnston  7133 confirmed 2020-11-22T00:00:00Z
    ## 25  United States of America North Carolina      Halifax  1863 confirmed 2020-11-22T00:00:00Z
    ## 26  United States of America North Carolina    Currituck   307 confirmed 2020-11-22T00:00:00Z
    ## 27  United States of America North Carolina     Franklin  1838 confirmed 2020-11-22T00:00:00Z
    ## 28  United States of America North Carolina        Macon   906 confirmed 2020-11-22T00:00:00Z
    ## 29  United States of America North Carolina      Chatham  2270 confirmed 2020-11-22T00:00:00Z
    ## 30  United States of America North Carolina       Wilkes  2489 confirmed 2020-11-22T00:00:00Z
    ## 31  United States of America North Carolina        Swain   365 confirmed 2020-11-22T00:00:00Z
    ## 32  United States of America North Carolina       Gaston  9555 confirmed 2020-11-22T00:00:00Z
    ## 33  United States of America North Carolina        Jones   247 confirmed 2020-11-22T00:00:00Z
    ## 34  United States of America North Carolina       Duplin  3218 confirmed 2020-11-22T00:00:00Z
    ## 35  United States of America North Carolina     Caldwell  3278 confirmed 2020-11-22T00:00:00Z
    ## 36  United States of America North Carolina     Scotland  1865 confirmed 2020-11-22T00:00:00Z
    ## 37  United States of America North Carolina    Henderson  2976 confirmed 2020-11-22T00:00:00Z
    ## 38  United States of America North Carolina   Unassigned    10 confirmed 2020-11-22T00:00:00Z
    ## 39  United States of America North Carolina  Northampton   761 confirmed 2020-11-22T00:00:00Z
    ## 40  United States of America North Carolina     McDowell  1698 confirmed 2020-11-22T00:00:00Z
    ## 41  United States of America North Carolina   Perquimans   312 confirmed 2020-11-22T00:00:00Z
    ## 42  United States of America North Carolina        Burke  3548 confirmed 2020-11-22T00:00:00Z
    ## 43  United States of America North Carolina        Rowan  5243 confirmed 2020-11-22T00:00:00Z
    ## 44  United States of America North Carolina      Lincoln  3175 confirmed 2020-11-22T00:00:00Z
    ## 45  United States of America North Carolina Transylvania   503 confirmed 2020-11-22T00:00:00Z
    ## 46  United States of America North Carolina     Cabarrus  6384 confirmed 2020-11-22T00:00:00Z
    ## 47  United States of America North Carolina   Pasquotank  1022 confirmed 2020-11-22T00:00:00Z
    ## 48  United States of America North Carolina   Rutherford  2211 confirmed 2020-11-22T00:00:00Z
    ## 49  United States of America North Carolina     Alamance  6614 confirmed 2020-11-22T00:00:00Z
    ## 50  United States of America North Carolina   Montgomery  1345 confirmed 2020-11-22T00:00:00Z
    ## 51  United States of America North Carolina      Watauga  1733 confirmed 2020-11-22T00:00:00Z
    ## 52  United States of America North Carolina          Lee  2380 confirmed 2020-11-22T00:00:00Z
    ## 53  United States of America North Carolina        Moore  2730 confirmed 2020-11-22T00:00:00Z
    ## 54  United States of America North Carolina       Bertie   851 confirmed 2020-11-22T00:00:00Z
    ## 55  United States of America North Carolina       Lenoir  1965 confirmed 2020-11-22T00:00:00Z
    ## 56  United States of America North Carolina         Hyde   182 confirmed 2020-11-22T00:00:00Z
    ## 57  United States of America North Carolina       Martin   785 confirmed 2020-11-22T00:00:00Z
    ## 58  United States of America North Carolina      Iredell  5066 confirmed 2020-11-22T00:00:00Z
    ## 59  United States of America North Carolina       Durham 10743 confirmed 2020-11-22T00:00:00Z
    ## 60  United States of America North Carolina         Dare   590 confirmed 2020-11-22T00:00:00Z
    ## 61  United States of America North Carolina     Hertford   941 confirmed 2020-11-22T00:00:00Z
    ## 62  United States of America North Carolina         Wake 26464 confirmed 2020-11-22T00:00:00Z
    ## 63  United States of America North Carolina     Carteret  1592 confirmed 2020-11-22T00:00:00Z
    ## 64  United States of America North Carolina      Sampson  3421 confirmed 2020-11-22T00:00:00Z
    ## 65  United States of America North Carolina      Pamlico   373 confirmed 2020-11-22T00:00:00Z
    ## 66  United States of America North Carolina  Mecklenburg 40754 confirmed 2020-11-22T00:00:00Z
    ## 67  United States of America North Carolina     Randolph  5004 confirmed 2020-11-22T00:00:00Z
    ## 68  United States of America North Carolina      Madison   457 confirmed 2020-11-22T00:00:00Z
    ## 69  United States of America North Carolina        Vance  1585 confirmed 2020-11-22T00:00:00Z
    ## 70  United States of America North Carolina     Buncombe  5193 confirmed 2020-11-22T00:00:00Z
    ## 71  United States of America North Carolina       Graham   268 confirmed 2020-11-22T00:00:00Z
    ## 72  United States of America North Carolina       Camden   169 confirmed 2020-11-22T00:00:00Z
    ## 73  United States of America North Carolina       Wilson  3796 confirmed 2020-11-22T00:00:00Z
    ## 74  United States of America North Carolina     Beaufort  1623 confirmed 2020-11-22T00:00:00Z
    ## 75  United States of America North Carolina      Haywood  1001 confirmed 2020-11-22T00:00:00Z
    ## 76  United States of America North Carolina    Brunswick  2768 confirmed 2020-11-22T00:00:00Z
    ## 77  United States of America North Carolina       Yadkin  1374 confirmed 2020-11-22T00:00:00Z
    ## 78  United States of America North Carolina    Granville  2405 confirmed 2020-11-22T00:00:00Z
    ## 79  United States of America North Carolina        Davie  1125 confirmed 2020-11-22T00:00:00Z
    ## 80  United States of America North Carolina       Chowan   586 confirmed 2020-11-22T00:00:00Z
    ## 81  United States of America North Carolina        Gates   197 confirmed 2020-11-22T00:00:00Z
    ## 82  United States of America North Carolina       Onslow  4769 confirmed 2020-11-22T00:00:00Z
    ## 83  United States of America North Carolina         Pitt  7457 confirmed 2020-11-22T00:00:00Z
    ## 84  United States of America North Carolina      Catawba  6261 confirmed 2020-11-22T00:00:00Z
    ## 85  United States of America North Carolina     Davidson  4888 confirmed 2020-11-22T00:00:00Z
    ## 86  United States of America North Carolina     Richmond  1758 confirmed 2020-11-22T00:00:00Z
    ## 87  United States of America North Carolina       Yancey   497 confirmed 2020-11-22T00:00:00Z
    ## 88  United States of America North Carolina  New Hanover  6564 confirmed 2020-11-22T00:00:00Z
    ## 89  United States of America North Carolina     Cherokee   897 confirmed 2020-11-22T00:00:00Z
    ## 90  United States of America North Carolina       Warren   591 confirmed 2020-11-22T00:00:00Z
    ## 91  United States of America North Carolina       Stanly  2816 confirmed 2020-11-22T00:00:00Z
    ## 92  United States of America North Carolina         Hoke  1880 confirmed 2020-11-22T00:00:00Z
    ## 93  United States of America North Carolina         Nash  4206 confirmed 2020-11-22T00:00:00Z
    ## 94  United States of America North Carolina   Washington   298 confirmed 2020-11-22T00:00:00Z
    ## 95  United States of America North Carolina        Anson   866 confirmed 2020-11-22T00:00:00Z
    ## 96  United States of America North Carolina       Stokes  1040 confirmed 2020-11-22T00:00:00Z
    ## 97  United States of America North Carolina    Alexander  1455 confirmed 2020-11-22T00:00:00Z
    ## 98  United States of America North Carolina        Avery   865 confirmed 2020-11-22T00:00:00Z
    ## 99  United States of America North Carolina      Harnett  3709 confirmed 2020-11-22T00:00:00Z
    ## 100 United States of America North Carolina     Columbus  2508 confirmed 2020-11-22T00:00:00Z
    ## 101 United States of America North Carolina      Caswell   789 confirmed 2020-11-22T00:00:00Z
    ## 102 United States of America North Carolina        Rowan  5316 confirmed 2020-11-23T00:00:00Z
    ## 103 United States of America North Carolina       Warren   592 confirmed 2020-11-23T00:00:00Z
    ## 104 United States of America North Carolina        Macon   905 confirmed 2020-11-23T00:00:00Z
    ## 105 United States of America North Carolina        Swain   367 confirmed 2020-11-23T00:00:00Z
    ## 106 United States of America North Carolina      Tyrrell   139 confirmed 2020-11-23T00:00:00Z
    ## 107 United States of America North Carolina      Pamlico   376 confirmed 2020-11-23T00:00:00Z
    ## 108 United States of America North Carolina     Columbus  2521 confirmed 2020-11-23T00:00:00Z
    ## 109 United States of America North Carolina        Moore  2757 confirmed 2020-11-23T00:00:00Z
    ## 110 United States of America North Carolina         Clay   276 confirmed 2020-11-23T00:00:00Z
    ## 111 United States of America North Carolina  Mecklenburg 41073 confirmed 2020-11-23T00:00:00Z
    ## 112 United States of America North Carolina      Chatham  2279 confirmed 2020-11-23T00:00:00Z
    ## 113 United States of America North Carolina   Rockingham  2824 confirmed 2020-11-23T00:00:00Z
    ## 114 United States of America North Carolina       Onslow  4809 confirmed 2020-11-23T00:00:00Z
    ## 115 United States of America North Carolina        Burke  3589 confirmed 2020-11-23T00:00:00Z
    ## 116 United States of America North Carolina       Gaston  9637 confirmed 2020-11-23T00:00:00Z
    ## 117 United States of America North Carolina       Duplin  3228 confirmed 2020-11-23T00:00:00Z
    ## 118 United States of America North Carolina   Cumberland  8933 confirmed 2020-11-23T00:00:00Z
    ## 119 United States of America North Carolina     Scotland  1874 confirmed 2020-11-23T00:00:00Z
    ## 120 United States of America North Carolina        Union  7319 confirmed 2020-11-23T00:00:00Z
    ## 121 United States of America North Carolina       Person   904 confirmed 2020-11-23T00:00:00Z
    ## 122 United States of America North Carolina   Pasquotank  1031 confirmed 2020-11-23T00:00:00Z
    ## 123 United States of America North Carolina   Washington   300 confirmed 2020-11-23T00:00:00Z
    ## 124 United States of America North Carolina       Yancey   499 confirmed 2020-11-23T00:00:00Z
    ## 125 United States of America North Carolina         Hyde   182 confirmed 2020-11-23T00:00:00Z
    ## 126 United States of America North Carolina    Henderson  2994 confirmed 2020-11-23T00:00:00Z
    ## 127 United States of America North Carolina      Haywood  1012 confirmed 2020-11-23T00:00:00Z
    ## 128 United States of America North Carolina         Polk   459 confirmed 2020-11-23T00:00:00Z
    ## 129 United States of America North Carolina   Unassigned     4 confirmed 2020-11-23T00:00:00Z
    ## 130 United States of America North Carolina      Catawba  6322 confirmed 2020-11-23T00:00:00Z
    ## 131 United States of America North Carolina        Jones   251 confirmed 2020-11-23T00:00:00Z
    ## 132 United States of America North Carolina       Camden   170 confirmed 2020-11-23T00:00:00Z
    ## 133 United States of America North Carolina         Ashe   718 confirmed 2020-11-23T00:00:00Z
    ## 134 United States of America North Carolina        Vance  1606 confirmed 2020-11-23T00:00:00Z
    ## 135 United States of America North Carolina       Greene  1153 confirmed 2020-11-23T00:00:00Z
    ## 136 United States of America North Carolina        Gates   197 confirmed 2020-11-23T00:00:00Z
    ## 137 United States of America North Carolina   Perquimans   316 confirmed 2020-11-23T00:00:00Z
    ## 138 United States of America North Carolina    Granville  2417 confirmed 2020-11-23T00:00:00Z
    ## 139 United States of America North Carolina      Halifax  1874 confirmed 2020-11-23T00:00:00Z
    ## 140 United States of America North Carolina     Cherokee   903 confirmed 2020-11-23T00:00:00Z
    ## 141 United States of America North Carolina    Alleghany   376 confirmed 2020-11-23T00:00:00Z
    ## 142 United States of America North Carolina     Guilford 15485 confirmed 2020-11-23T00:00:00Z
    ## 143 United States of America North Carolina         Wake 26635 confirmed 2020-11-23T00:00:00Z
    ## 144 United States of America North Carolina         Hoke  1885 confirmed 2020-11-23T00:00:00Z
    ## 145 United States of America North Carolina       Bertie   857 confirmed 2020-11-23T00:00:00Z
    ## 146 United States of America North Carolina     Franklin  1843 confirmed 2020-11-23T00:00:00Z
    ## 147 United States of America North Carolina     Mitchell   472 confirmed 2020-11-23T00:00:00Z
    ## 148 United States of America North Carolina      Iredell  5107 confirmed 2020-11-23T00:00:00Z
    ## 149 United States of America North Carolina      Harnett  3741 confirmed 2020-11-23T00:00:00Z
    ## 150 United States of America North Carolina      Jackson  1336 confirmed 2020-11-23T00:00:00Z
    ## 151 United States of America North Carolina     Buncombe  5232 confirmed 2020-11-23T00:00:00Z
    ## 152 United States of America North Carolina         Pitt  7498 confirmed 2020-11-23T00:00:00Z
    ## 153 United States of America North Carolina       Craven  2934 confirmed 2020-11-23T00:00:00Z
    ## 154 United States of America North Carolina     Hertford   948 confirmed 2020-11-23T00:00:00Z
    ## 155 United States of America North Carolina    Edgecombe  2421 confirmed 2020-11-23T00:00:00Z
    ## 156 United States of America North Carolina      Sampson  3442 confirmed 2020-11-23T00:00:00Z
    ## 157 United States of America North Carolina      Caswell   795 confirmed 2020-11-23T00:00:00Z
    ## 158 United States of America North Carolina   Montgomery  1350 confirmed 2020-11-23T00:00:00Z
    ## 159 United States of America North Carolina    Currituck   309 confirmed 2020-11-23T00:00:00Z
    ## 160 United States of America North Carolina     McDowell  1725 confirmed 2020-11-23T00:00:00Z
    ## 161 United States of America North Carolina       Stokes  1059 confirmed 2020-11-23T00:00:00Z
    ## 162 United States of America North Carolina       Orange  3714 confirmed 2020-11-23T00:00:00Z
    ## 163 United States of America North Carolina       Pender  1817 confirmed 2020-11-23T00:00:00Z
    ## 164 United States of America North Carolina        Davie  1131 confirmed 2020-11-23T00:00:00Z
    ## 165 United States of America North Carolina        Wayne  5513 confirmed 2020-11-23T00:00:00Z
    ## 166 United States of America North Carolina       Graham   268 confirmed 2020-11-23T00:00:00Z
    ##  [ reached 'max' / getOption("max.print") -- omitted 31434 rows ]

%&gt;% select(Country, NewConfirmed, TotalConfirmed, NewDeaths,
TotalDeaths, Date) %&gt;% as\_tibble()

``` r
covid_summary_cases <- function(){
   full_url = paste0(base_url,"/summary")
   covid_summary <- GET(url=full_url)
   covid_cases_summary <- fromJSON(rawToChar(covid_summary$content))
   covid_cases_summary1 <- covid_cases_summary$Countries %>% select(Country, NewConfirmed, TotalConfirmed, NewDeaths, TotalDeaths, Date) 
   return(covid_cases_summary1)
}

covidSummary <- covid_summary_cases()
covidSummary
```

    ##                             Country NewConfirmed TotalConfirmed NewDeaths TotalDeaths                     Date
    ## 1                       Afghanistan            0         155191         0        7206 2021-10-02T06:19:02.949Z
    ## 2                           Albania            0         170778         0        2705 2021-10-02T06:19:02.949Z
    ## 3                           Algeria            0         203517         0        5815 2021-10-02T06:19:02.949Z
    ## 4                           Andorra            0          15222         0         130 2021-10-02T06:19:02.949Z
    ## 5                            Angola            0          58076         0        1567 2021-10-02T06:19:02.949Z
    ## 6               Antigua and Barbuda            0           3336         0          81 2021-10-02T06:19:02.949Z
    ## 7                         Argentina            0        5258466         0      115225 2021-10-02T06:19:02.949Z
    ## 8                           Armenia            0         262631         0        5339 2021-10-02T06:19:02.949Z
    ## 9                         Australia         2335         109516        10        1321 2021-10-02T06:19:02.949Z
    ## 10                          Austria            0         744964         0       11014 2021-10-02T06:19:02.949Z
    ## 11                       Azerbaijan            0         484591         0        6543 2021-10-02T06:19:02.949Z
    ## 12                          Bahamas            0          21114         0         533 2021-10-02T06:19:02.949Z
    ## 13                          Bahrain            0         275130         0        1389 2021-10-02T06:19:02.949Z
    ## 14                       Bangladesh            0        1556758         0       27531 2021-10-02T06:19:02.949Z
    ## 15                         Barbados            0           8609         0          78 2021-10-02T06:19:02.949Z
    ## 16                          Belarus            0         540079         0        4159 2021-10-02T06:19:02.949Z
    ## 17                          Belgium         2243        1247197        10       25612 2021-10-02T06:19:02.949Z
    ## 18                           Belize            0          21003         0         418 2021-10-02T06:19:02.949Z
    ## 19                            Benin            0          23890         0         159 2021-10-02T06:19:02.949Z
    ## 20                           Bhutan            0           2601         0           3 2021-10-02T06:19:02.949Z
    ## 21                          Bolivia            0         500823         0       18750 2021-10-02T06:19:02.949Z
    ## 22           Bosnia and Herzegovina            0         235536         0       10635 2021-10-02T06:19:02.949Z
    ## 23                         Botswana            0         179220         0        2368 2021-10-02T06:19:02.949Z
    ## 24                           Brazil        18578       21445651       506      597255 2021-10-02T06:19:02.949Z
    ## 25                Brunei Darussalam            0           7326         0          43 2021-10-02T06:19:02.949Z
    ## 26                         Bulgaria            0         504253         0       20969 2021-10-02T06:19:02.949Z
    ## 27                     Burkina Faso            0          14262         0         184 2021-10-02T06:19:02.949Z
    ## 28                          Burundi            0          17979         0          38 2021-10-02T06:19:02.949Z
    ## 29                         Cambodia            0         112883         0        2336 2021-10-02T06:19:02.949Z
    ## 30                         Cameroon            0          92303         0        1459 2021-10-02T06:19:02.949Z
    ## 31                           Canada         4164        1337613        46       25242 2021-10-02T06:19:02.949Z
    ## 32                       Cape Verde            0          37604         0         340 2021-10-02T06:19:02.949Z
    ## 33         Central African Republic            0          11371         0         100 2021-10-02T06:19:02.949Z
    ## 34                             Chad            0           5042         0         174 2021-10-02T06:19:02.949Z
    ## 35                            Chile          807        1655071         8       37476 2021-10-02T06:19:02.949Z
    ## 36                            China           45         108495         0        4849 2021-10-02T06:19:02.949Z
    ## 37                         Colombia         1867        4959144        37      126336 2021-10-02T06:19:02.949Z
    ## 38                          Comoros            0           4147         0         147 2021-10-02T06:19:02.949Z
    ## 39              Congo (Brazzaville)            0          14359         0         197 2021-10-02T06:19:02.949Z
    ## 40                 Congo (Kinshasa)            0          56997         0        1084 2021-10-02T06:19:02.949Z
    ## 41                       Costa Rica            0         533873         0        6413 2021-10-02T06:19:02.949Z
    ## 42                          Croatia            0         406307         0        8650 2021-10-02T06:19:02.949Z
    ## 43                             Cuba            0         882477         0        7486 2021-10-02T06:19:02.949Z
    ## 44                           Cyprus            0         120272         0         552 2021-10-02T06:19:02.949Z
    ## 45                   Czech Republic            0        1692412         0       30475 2021-10-02T06:19:02.949Z
    ## 46                   CÃ´te d'Ivoire            0          60335         0         631 2021-10-02T06:19:02.949Z
    ## 47                          Denmark            0         360999         0        2661 2021-10-02T06:19:02.949Z
    ## 48                         Djibouti            0          12870         0         167 2021-10-02T06:19:02.949Z
    ## 49                         Dominica            0           3555         0          21 2021-10-02T06:19:02.949Z
    ## 50               Dominican Republic            0         359597         0        4049 2021-10-02T06:19:02.949Z
    ## 51                          Ecuador            0         509238         0       32762 2021-10-02T06:19:02.949Z
    ## 52                            Egypt            0         305269         0       17367 2021-10-02T06:19:02.949Z
    ## 53                      El Salvador            0         104348         0        3245 2021-10-02T06:19:02.949Z
    ## 54                Equatorial Guinea            0          12362         0         147 2021-10-02T06:19:02.949Z
    ## 55                          Eritrea            0           6722         0          42 2021-10-02T06:19:02.949Z
    ## 56                          Estonia            0         156986         0        1357 2021-10-02T06:19:02.949Z
    ## 57                         Ethiopia            0         347084         0        5630 2021-10-02T06:19:02.949Z
    ## 58                             Fiji            0          51130         0         631 2021-10-02T06:19:02.949Z
    ## 59                          Finland            0         142114         0        1078 2021-10-02T06:19:02.949Z
    ## 60                           France            0        7111154         0      117535 2021-10-02T06:19:02.949Z
    ## 61                            Gabon            0          30648         0         190 2021-10-02T06:19:02.949Z
    ## 62                           Gambia            0           9935         0         338 2021-10-02T06:19:02.949Z
    ## 63                          Georgia            0         614763         0        8976 2021-10-02T06:19:02.949Z
    ## 64                          Germany         9288        4249061        66       93781 2021-10-02T06:19:02.949Z
    ## 65                            Ghana            0         127482         0        1156 2021-10-02T06:19:02.949Z
    ## 66                           Greece            0         658368         0       14860 2021-10-02T06:19:02.949Z
    ## 67                          Grenada            0           5236         0         150 2021-10-02T06:19:02.949Z
    ## 68                        Guatemala            0         563257         0       13625 2021-10-02T06:19:02.949Z
    ## 69                           Guinea            0          30420         0         379 2021-10-02T06:19:02.949Z
    ## 70                    Guinea-Bissau            0           6110         0         135 2021-10-02T06:19:02.949Z
    ## 71                           Guyana            0          32055         0         792 2021-10-02T06:19:02.949Z
    ## 72                            Haiti            0          21916         0         611 2021-10-02T06:19:02.949Z
    ## 73    Holy See (Vatican City State)            0             27         0           0 2021-10-02T06:19:02.949Z
    ## 74                         Honduras            0         367275         0        9854 2021-10-02T06:19:02.949Z
    ## 75                          Hungary            0         823384         0       30199 2021-10-02T06:19:02.949Z
    ## 76                          Iceland            0          11839         0          33 2021-10-02T06:19:02.949Z
    ## 77                            India        24354       33791061       234      448573 2021-10-02T06:19:02.949Z
    ## 78                        Indonesia            0        4216728         0      142026 2021-10-02T06:19:02.949Z
    ## 79        Iran, Islamic Republic of            0        5601565         0      120663 2021-10-02T06:19:02.949Z
    ## 80                             Iraq            0        2005991         0       22302 2021-10-02T06:19:02.949Z
    ## 81                          Ireland            0         390989         0        5249 2021-10-02T06:19:02.949Z
    ## 82                           Israel            0        1285570         0        7766 2021-10-02T06:19:02.949Z
    ## 83                            Italy         3403        4675758        52      130973 2021-10-02T06:19:02.949Z
    ## 84                          Jamaica            0          84069         0        1877 2021-10-02T06:19:02.949Z
    ## 85                            Japan         1451        1703706        34       17698 2021-10-02T06:19:02.949Z
    ## 86                           Jordan            0         824697         0       10727 2021-10-02T06:19:02.949Z
    ## 87                       Kazakhstan            0         965080         0       15907 2021-10-02T06:19:02.949Z
    ## 88                            Kenya            0         249725         0        5128 2021-10-02T06:19:02.949Z
    ## 89                         Kiribati            0              2         0           0 2021-10-02T06:19:02.949Z
    ## 90                    Korea (South)            0         316020         0        2504 2021-10-02T06:19:02.949Z
    ## 91                           Kuwait            0         411690         0        2450 2021-10-02T06:19:02.949Z
    ## 92                       Kyrgyzstan            0         178608         0        2607 2021-10-02T06:19:02.949Z
    ## 93                          Lao PDR            0          24310         0          20 2021-10-02T06:19:02.949Z
    ## 94                           Latvia            0         159418         0        2721 2021-10-02T06:19:02.949Z
    ## 95                          Lebanon            0         624743         0        8333 2021-10-02T06:19:02.949Z
    ## 96                          Lesotho            0          21320         0         633 2021-10-02T06:19:02.949Z
    ## 97                          Liberia            0           5799         0         286 2021-10-02T06:19:02.949Z
    ## 98                            Libya            0         341091         0        4664 2021-10-02T06:19:02.949Z
    ## 99                    Liechtenstein            0           3448         0          60 2021-10-02T06:19:02.949Z
    ## 100                       Lithuania            0         333690         0        5014 2021-10-02T06:19:02.949Z
    ## 101                      Luxembourg            0          78326         0         835 2021-10-02T06:19:02.949Z
    ## 102          Macedonia, Republic of            0         191820         0        6683 2021-10-02T06:19:02.949Z
    ## 103                      Madagascar            0          42898         0         958 2021-10-02T06:19:02.949Z
    ## 104                          Malawi            0          61597         0        2282 2021-10-02T06:19:02.949Z
    ## 105                        Malaysia        11889        2257584       121       26456 2021-10-02T06:19:02.949Z
    ## 106                        Maldives            0          84866         0         231 2021-10-02T06:19:02.949Z
    ## 107                            Mali            0          15255         0         549 2021-10-02T06:19:02.949Z
    ## 108                           Malta            0          37163         0         458 2021-10-02T06:19:02.949Z
    ## 109                Marshall Islands            0              4         0           0 2021-10-02T06:19:02.949Z
    ## 110                      Mauritania            0          36079         0         776 2021-10-02T06:19:02.949Z
    ## 111                       Mauritius            0          15695         0          84 2021-10-02T06:19:02.949Z
    ## 112                          Mexico         7388        3671611       471      277978 2021-10-02T06:19:02.949Z
    ## 113 Micronesia, Federated States of            0              1         0           0 2021-10-02T06:19:02.949Z
    ## 114                         Moldova            0         295681         0        6803 2021-10-02T06:19:02.949Z
    ## 115                          Monaco            0           3314         0          33 2021-10-02T06:19:02.949Z
    ## 116                        Mongolia            0         306603         0        1295 2021-10-02T06:19:02.949Z
    ## 117                      Montenegro            0         131946         0        1928 2021-10-02T06:19:02.949Z
    ## 118                         Morocco            0         934007         0       14290 2021-10-02T06:19:02.949Z
    ## 119                      Mozambique            0         150759         0        1918 2021-10-02T06:19:02.949Z
    ## 120                         Myanmar            0         465922         0       17789 2021-10-02T06:19:02.949Z
    ## 121                         Namibia            0         127680         0        3514 2021-10-02T06:19:02.949Z
    ## 122                           Nepal            0         795959         0       11148 2021-10-02T06:19:02.949Z
    ## 123                     Netherlands         1713        2004763         6       18176 2021-10-02T06:19:02.949Z
    ## 124                     New Zealand            0           4320         0          27 2021-10-02T06:19:02.949Z
    ## 125                       Nicaragua            0          14448         0         204 2021-10-02T06:19:02.949Z
    ## 126                           Niger            0           6025         0         203 2021-10-02T06:19:02.949Z
    ## 127                         Nigeria            0         205940         0        2724 2021-10-02T06:19:02.949Z
    ## 128                          Norway            0         189915         0         861 2021-10-02T06:19:02.949Z
    ## 129                            Oman            0         303769         0        4096 2021-10-02T06:19:02.949Z
    ## 130                        Pakistan         1664        1248202        46       27831 2021-10-02T06:19:02.949Z
    ## 131                           Palau            0              5         0           0 2021-10-02T06:19:02.949Z
    ## 132           Palestinian Territory            0         405056         0        4120 2021-10-02T06:19:02.949Z
    ## 133                          Panama            0         467338         0        7230 2021-10-02T06:19:02.949Z
    ## 134                Papua New Guinea            0          20455         0         234 2021-10-02T06:19:02.949Z
    ## 135                        Paraguay            0         459967         0       16198 2021-10-02T06:19:02.949Z
    ## 136                            Peru         1978        2177283        56      199423 2021-10-02T06:19:02.949Z
    ## 137                     Philippines            0        2565487         0       38493 2021-10-02T06:19:02.949Z
    ## 138                          Poland            0        2908432         0       75666 2021-10-02T06:19:02.949Z
    ## 139                        Portugal            0        1069975         0       17979 2021-10-02T06:19:02.949Z
    ## 140                           Qatar            0         236735         0         606 2021-10-02T06:19:02.949Z
    ## 141              Republic of Kosovo            0         160114         0        2955 2021-10-02T06:19:02.949Z
    ## 142                         Romania            0        1244555         0       37210 2021-10-02T06:19:02.949Z
    ## 143              Russian Federation        23953        7425057       875      204424 2021-10-02T06:19:02.949Z
    ## 144                          Rwanda            0          97695         0        1276 2021-10-02T06:19:02.949Z
    ## 145           Saint Kitts and Nevis            0           1965         0          13 2021-10-02T06:19:02.949Z
    ## 146                     Saint Lucia            0          11573         0         207 2021-10-02T06:19:02.949Z
    ## 147    Saint Vincent and Grenadines            0           3563         0          26 2021-10-02T06:19:02.949Z
    ## 148                           Samoa            0              3         0           0 2021-10-02T06:19:02.949Z
    ## 149                      San Marino            0           5440         0          91 2021-10-02T06:19:02.949Z
    ## 150           Sao Tome and Principe            0           3504         0          51 2021-10-02T06:19:02.949Z
    ## 151                    Saudi Arabia            0         547134         0        8716 2021-10-02T06:19:02.949Z
    ## 152                         Senegal            0          73782         0        1858 2021-10-02T06:19:02.949Z
    ## 153                          Serbia            0         949260         0        8280 2021-10-02T06:19:02.949Z
    ## 154                      Seychelles            0          21507         0         112 2021-10-02T06:19:02.949Z
    ## 155                    Sierra Leone            0           6394         0         121 2021-10-02T06:19:02.949Z
    ## 156                       Singapore            0          99430         0         103 2021-10-02T06:19:02.949Z
    ## 157                        Slovakia            0         413723         0       12649 2021-10-02T06:19:02.949Z
    ## 158                        Slovenia            0         294335         0        4565 2021-10-02T06:19:02.949Z
    ## 159                 Solomon Islands            0             20         0           0 2021-10-02T06:19:02.949Z
    ## 160                         Somalia            0          19980         0        1111 2021-10-02T06:19:02.949Z
    ## 161                    South Africa            0        2904307         0       87705 2021-10-02T06:19:02.949Z
    ## 162                     South Sudan            0          12021         0         130 2021-10-02T06:19:02.949Z
    ## 163                           Spain         2037        4961128        48       86463 2021-10-02T06:19:02.949Z
    ## 164                       Sri Lanka            0         518775         0       12964 2021-10-02T06:19:02.949Z
    ## 165                           Sudan            0          38283         0        2902 2021-10-02T06:19:02.949Z
    ## 166                        Suriname            0          41631         0         884 2021-10-02T06:19:02.949Z
    ##  [ reached 'max' / getOption("max.print") -- omitted 26 rows ]

covid\_cases\_summary1 &lt;- covid\_cases\_summary$Countries

``` r
get_live_cases <- function(country){
       if(country %in% countryName$Slug){
   full_url = paste0(base_url,"/live/country/",country,"/status/confirmed/date/2021-08-31T00:00:00Z")
    covid_cases_live_text = content(GET(url=full_url),"text")
    covid_cases_live_json = fromJSON(covid_cases_live_text)
  return(covid_cases_live_json)
       }
      else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}

liveCase <- get_live_cases("united-states")
liveCase
```

    ##                                      ID                  Country CountryCode                 Province City CityCode   Lat     Lon Confirmed Deaths Recovered  Active
    ## 1  05cb350d-c864-47f2-ba35-3f1f37692714 United States of America          US                   Oregon               44.57 -122.07    276176   3190         0  272986
    ## 2  073ff190-666e-473a-a517-eb9059ee59e9 United States of America          US                Minnesota               45.69   -93.9    649964   7904         0  642060
    ## 3  0a4101da-72c4-40a4-8ee5-79fe8dd2f459 United States of America          US                  Indiana               39.85  -86.26    858566  14491         0  844075
    ## 4  0fc2be26-aef2-4339-92c6-ec7f719af04d United States of America          US                 Kentucky               37.67  -84.67    577051   7764         0  569287
    ## 5  0fe58c58-92d7-4588-8f42-d58438961262 United States of America          US            Massachusetts               42.23  -71.53    759869  18246         0  741623
    ## 6  120163fd-159e-4cd2-8360-6d3183c9f4bb United States of America          US               New Mexico               34.84 -106.25    232614   4518         0  228096
    ## 7  1674d4c4-ec0d-404d-b8d0-b5a806bdc1b5 United States of America          US               Washington                47.4 -121.49    563041   6574         0  556467
    ## 8  18f09433-30ec-4f36-8ee1-0c985144c752 United States of America          US                    Idaho               44.24 -114.48    221373   2360         0  219013
    ## 9  19ad2640-e377-4c63-8866-451590704a15 United States of America          US             South Dakota                44.3  -99.44    132259   2071         0  130188
    ## 10 2a46a683-aba7-4a55-a37c-3eb806e210a7 United States of America          US               New Jersey                40.3  -74.52   1091966  26882         0 1065084
    ## 11 2b6addc4-4b9e-478f-bb34-82b4482d4a76 United States of America          US                   Kansas               38.53  -96.73    369916   5560         0  364356
    ## 12 2e112000-ccd2-455a-b4a0-feb9ac083857 United States of America          US                     Ohio               40.39  -82.76   1220900  20866         0 1200034
    ## 13 355d864e-5371-423d-8fdd-4be7f02e5764 United States of America          US              Puerto Rico               18.22  -66.59    170452   2860         0  167592
    ## 14 37702eb5-4afc-484d-bc59-17f51dc9a75b United States of America          US                 Maryland               39.06   -76.8    497002  10014         0  486988
    ## 15 38f2ab57-48c3-495b-a0e0-db8070c8eaaf United States of America          US                 Michigan               43.33  -84.54   1060343  21547         0 1038796
    ## 16 3c7136d9-3e66-44c8-8aa0-f673f4cd13dc United States of America          US           South Carolina               33.86  -80.95    735287  10598         0  724689
    ## 17 48188a56-d574-4b99-aced-a7e479fe12a1 United States of America          US               California               36.12 -119.68   4358735  65855         0 4292880
    ## 18 4c6c4d1d-d501-4b3d-a55d-191a5644fe31 United States of America          US                  Montana               46.92 -110.45    127223   1798         0  125425
    ## 19 4eef166f-006a-45fc-9cd2-7073f8693372 United States of America          US            West Virginia               38.49  -80.95    189690   3084         0  186606
    ## 20 53d89046-91e4-45f3-a974-e67d21675bd8 United States of America          US            New Hampshire               43.45  -71.56    107689   1417         0  106272
    ## 21 5b6516d4-3c46-4e6b-abcb-c87af63b1d9b United States of America          US Northern Mariana Islands                15.1  145.67       183      2         0     181
    ## 22 5d227f66-73c6-46fe-a981-c45d4f73a551 United States of America          US           Virgin Islands               18.34   -64.9      5864     54         0    5810
    ## 23 5db64ec4-c171-4106-96aa-f4000f900c74 United States of America          US                   Nevada               38.31 -117.06    390600   6510         0  384090
    ## 24 5e92a55d-dc1e-4281-8125-2d26d81eae66 United States of America          US                 Colorado               39.06 -105.31    615873   7140         0  608733
    ## 25 667c13c3-a668-462e-829b-791da169c902 United States of America          US                Tennessee               35.75  -86.69   1051809  13478         0 1038331
    ## 26 6d15893d-95fa-4ff6-9411-9cc623ae4d19 United States of America          US             Pennsylvania               40.59  -77.21   1300368  28235         0 1272133
    ## 27 74f59bf3-e471-42de-b4b1-1f50c3835e58 United States of America          US                Wisconsin               44.27  -89.62    733940   8462         0  725478
    ## 28 79f6c9d2-d699-4426-a9af-9184bb654251 United States of America          US                 New York               42.17  -74.95   2278590  54254         0 2224336
    ## 29 7a8f0ccf-a96d-49d6-98e0-bbdbf4dfdc8f United States of America          US                     Guam               13.44  144.79     10559    149         0   10410
    ## 30 7da497d3-da5c-4569-8273-e4fbad53ac69 United States of America          US                     Utah               40.15 -111.86    464422   2634         0  461788
    ## 31 824a8a60-c28d-4528-93e5-03fdfec0df71 United States of America          US           North Carolina               35.63  -79.81   1213627  14462         0 1199165
    ## 32 83fca3a5-fed7-45de-b416-578d483c84c4 United States of America          US                  Wyoming               42.76  -107.3     75117    855         0   74262
    ## 33 88cf3698-952f-4882-9ce3-2878d5b3e506 United States of America          US                Louisiana               31.17  -91.87    679796  12359         0  667437
    ## 34 8c9a2e6e-3c46-41b1-9cb2-3a796e384053 United States of America          US                 Illinois               40.35  -88.99   1522942  26386         0 1496556
    ## 35 8cfee6d9-3290-4310-9ffb-b19276dca9f0 United States of America          US                  Florida               27.77  -81.69   3223249  43979         0 3179270
    ## 36 95b7e9af-5de3-4186-bf15-5d99eaddba84 United States of America          US                   Hawaii               21.09  -157.5     63502    589         0   62913
    ## 37 a704baec-aa0d-4a5a-8b3c-a284d01fe1ae United States of America          US             Rhode Island               41.68  -71.51    162617   2770         0  159847
    ## 38 a9efa79d-21d3-4eec-865e-23849bc9a870 United States of America          US                 Virginia               37.77  -78.17    766435  11842         0  754593
    ## 39 ad4538f9-e959-4590-8719-3b7d28b308ed United States of America          US              Connecticut                41.6  -72.76    373072   8358         0  364714
    ## 40 ad94afba-aae4-4663-b553-97b975f992e4 United States of America          US                    Maine               44.69  -69.38     75856    932         0   74924
    ## 41 aec1b1a3-afc4-45f4-80bf-f45a7b7457e5 United States of America          US                  Georgia               33.04  -83.64   1403582  22740         0 1380842
    ## 42 b60c5c70-651a-4cef-ac14-3fcc95484bc1 United States of America          US                     Iowa               42.01  -93.21    400082   6268         0  393814
    ## 43 b6cc7d68-d1c6-46cc-bfb8-b11a0b5d5534 United States of America          US                    Texas               31.05  -97.56   3612119  57042         0 3555077
    ## 44 bdf8100e-f1db-4480-a1ea-9986bed186d0 United States of America          US                 Nebraska               41.13  -98.27    244254   2322         0  241932
    ## 45 c788652c-41b5-47e0-8bc4-a05629ff32d0 United States of America          US              Mississippi               32.74  -89.68    436722   8409         0  428313
    ## 46 d123dc26-e58e-4891-adea-6cccf66a259f United States of America          US             North Dakota               47.53  -99.78    117497   1592         0  115905
    ## 47 d1c65832-0caa-4186-9a13-090da4475c75 United States of America          US                  Arizona               33.73 -111.43   1011923  18786         0  993137
    ## 48 d6450683-8ca7-4e01-b5aa-24a1db65ac3e United States of America          US                 Arkansas               34.97  -92.37    452891   6934         0  445957
    ## 49 db60a648-fa97-4578-8d1e-e68310715035 United States of America          US                   Alaska               61.37  -152.4     88547    444         0   88103
    ## 50 dfb48b66-8bad-4b1e-81d8-76237132c880 United States of America          US     District of Columbia                38.9  -77.03     55431   1160         0   54271
    ## 51 e5649ebb-b7c3-45b8-a45e-57596065eb40 United States of America          US                 Delaware               39.32  -75.51    119852   1880         0  117972
    ## 52 e7d270cf-557d-469e-8df5-4ae2ad29eb2f United States of America          US                 Missouri               38.46  -92.29    763799  11048         0  752751
    ## 53 ef15acae-523c-425f-8059-2f0357a0f58f United States of America          US                  Alabama               32.32   -86.9    699729  12283         0  687446
    ## 54 f6a9fe5b-564c-4b8d-a324-3f28d85eda31 United States of America          US                  Vermont               44.05  -72.71     28200    276         0   27924
    ## 55 f6eda084-fd1f-444f-bfd5-de2de33af3b3 United States of America          US                 Oklahoma               35.57  -96.93    551958   7812         0  544146
    ## 56 04333d21-b96b-4211-a6e1-677c7ab9db7a United States of America          US                  Wyoming               42.76  -107.3     76007    858         0   75149
    ## 57 08c5719c-9e23-4981-9234-33ea3ecb6674 United States of America          US                 Delaware               39.32  -75.51    120180   1887         0  118293
    ## 58 119b83a6-2024-4d9c-af8d-219e545d91ed United States of America          US                  Montana               46.92 -110.45    128098   1803         0  126295
    ## 59 137b8f75-130a-4fef-8b2f-63c968d86dd0 United States of America          US               California               36.12 -119.68   4377219  65968         0 4311251
    ## 60 18b6b483-f8be-4b1a-8a18-3d77f6e07a77 United States of America          US                   Hawaii               21.09  -157.5     63957    602         0   63355
    ## 61 25051143-f8b6-40a1-9f25-fd795d86c4dd United States of America          US                 New York               42.17  -74.95   2282836  54282         0 2228554
    ## 62 297c9792-f0ec-4ec7-83d6-133842bed1ef United States of America          US                 Colorado               39.06 -105.31    618072   7151         0  610921
    ## 63 29c0227e-efa1-4dc1-ac83-5813fa1b331c United States of America          US                 Arkansas               34.97  -92.37    455781   6969         0  448812
    ## 64 29ca2ab3-1518-442b-9bb2-934710046eb0 United States of America          US             Rhode Island               41.68  -71.51    162969   2772         0  160197
    ## 65 2ac5c2f3-d2fa-4fc0-8ede-9a66fd3e2a25 United States of America          US                     Guam               13.44  144.79     10740    150         0   10590
    ## 66 38809035-282f-4812-91fd-51c231f1f511 United States of America          US                  Florida               27.77  -81.69   3223249  43979         0 3179270
    ## 67 3a9de205-901a-4cc5-a04d-56f34fc7b35d United States of America          US                 Michigan               43.33  -84.54   1065671  21616         0 1044055
    ## 68 3bfa3752-7f35-4f62-8fc5-fb68ff3f72fb United States of America          US               New Jersey                40.3  -74.52   1094249  26902         0 1067347
    ## 69 405de324-b279-4f25-b71a-f5f1f9ed810e United States of America          US                  Alabama               32.32   -86.9    704420  12291         0  692129
    ## 70 449e3f3d-d6af-42ec-88b6-bd81d2941c22 United States of America          US            Massachusetts               42.23  -71.53    761906  18257         0  743649
    ## 71 47769a8d-8441-46ae-b06a-1a31dcfdbad6 United States of America          US                  Georgia               33.04  -83.64   1413284  22870         0 1390414
    ## 72 4ac2bc43-226c-48fc-a249-fb103443452e United States of America          US                   Kansas               38.53  -96.73    374122   5584         0  368538
    ## 73 4bf42510-ca72-4f2f-bdf8-d648e7da32ff United States of America          US                Wisconsin               44.27  -89.62    736263   8496         0  727767
    ## 74 4fcb8413-b48f-4bc5-9561-a979811b45f0 United States of America          US                    Idaho               44.24 -114.48    222552   2371         0  220181
    ## 75 53ed766f-97c5-4c58-b790-362dd35a432c United States of America          US                 Virginia               37.77  -78.17    769842  11861         0  757981
    ## 76 64ad5ccc-aa1a-4976-87e7-af12dffaf7aa United States of America          US           South Carolina               33.86  -80.95    740634  10684         0  729950
    ##                    Date
    ## 1  2021-09-01T00:00:00Z
    ## 2  2021-09-01T00:00:00Z
    ## 3  2021-09-01T00:00:00Z
    ## 4  2021-09-01T00:00:00Z
    ## 5  2021-09-01T00:00:00Z
    ## 6  2021-09-01T00:00:00Z
    ## 7  2021-09-01T00:00:00Z
    ## 8  2021-09-01T00:00:00Z
    ## 9  2021-09-01T00:00:00Z
    ## 10 2021-09-01T00:00:00Z
    ## 11 2021-09-01T00:00:00Z
    ## 12 2021-09-01T00:00:00Z
    ## 13 2021-09-01T00:00:00Z
    ## 14 2021-09-01T00:00:00Z
    ## 15 2021-09-01T00:00:00Z
    ## 16 2021-09-01T00:00:00Z
    ## 17 2021-09-01T00:00:00Z
    ## 18 2021-09-01T00:00:00Z
    ## 19 2021-09-01T00:00:00Z
    ## 20 2021-09-01T00:00:00Z
    ## 21 2021-09-01T00:00:00Z
    ## 22 2021-09-01T00:00:00Z
    ## 23 2021-09-01T00:00:00Z
    ## 24 2021-09-01T00:00:00Z
    ## 25 2021-09-01T00:00:00Z
    ## 26 2021-09-01T00:00:00Z
    ## 27 2021-09-01T00:00:00Z
    ## 28 2021-09-01T00:00:00Z
    ## 29 2021-09-01T00:00:00Z
    ## 30 2021-09-01T00:00:00Z
    ## 31 2021-09-01T00:00:00Z
    ## 32 2021-09-01T00:00:00Z
    ## 33 2021-09-01T00:00:00Z
    ## 34 2021-09-01T00:00:00Z
    ## 35 2021-09-01T00:00:00Z
    ## 36 2021-09-01T00:00:00Z
    ## 37 2021-09-01T00:00:00Z
    ## 38 2021-09-01T00:00:00Z
    ## 39 2021-09-01T00:00:00Z
    ## 40 2021-09-01T00:00:00Z
    ## 41 2021-09-01T00:00:00Z
    ## 42 2021-09-01T00:00:00Z
    ## 43 2021-09-01T00:00:00Z
    ## 44 2021-09-01T00:00:00Z
    ## 45 2021-09-01T00:00:00Z
    ## 46 2021-09-01T00:00:00Z
    ## 47 2021-09-01T00:00:00Z
    ## 48 2021-09-01T00:00:00Z
    ## 49 2021-09-01T00:00:00Z
    ## 50 2021-09-01T00:00:00Z
    ## 51 2021-09-01T00:00:00Z
    ## 52 2021-09-01T00:00:00Z
    ## 53 2021-09-01T00:00:00Z
    ## 54 2021-09-01T00:00:00Z
    ## 55 2021-09-01T00:00:00Z
    ## 56 2021-09-02T00:00:00Z
    ## 57 2021-09-02T00:00:00Z
    ## 58 2021-09-02T00:00:00Z
    ## 59 2021-09-02T00:00:00Z
    ## 60 2021-09-02T00:00:00Z
    ## 61 2021-09-02T00:00:00Z
    ## 62 2021-09-02T00:00:00Z
    ## 63 2021-09-02T00:00:00Z
    ## 64 2021-09-02T00:00:00Z
    ## 65 2021-09-02T00:00:00Z
    ## 66 2021-09-02T00:00:00Z
    ## 67 2021-09-02T00:00:00Z
    ## 68 2021-09-02T00:00:00Z
    ## 69 2021-09-02T00:00:00Z
    ## 70 2021-09-02T00:00:00Z
    ## 71 2021-09-02T00:00:00Z
    ## 72 2021-09-02T00:00:00Z
    ## 73 2021-09-02T00:00:00Z
    ## 74 2021-09-02T00:00:00Z
    ## 75 2021-09-02T00:00:00Z
    ## 76 2021-09-02T00:00:00Z
    ##  [ reached 'max' / getOption("max.print") -- omitted 1629 rows ]

URLencode() //Replace space with %20 for url to understand $new =
str\_replace(’ ‘,’%20’, $your\_string);

``` r
countryName <- country_Name()

confirmed <- get_confirmed_cases("canada")

deaths <- get_deaths_cases("india")

recovered <- get_recovered_cases("united-states")

stateCases <- get_cases_bystate("North Carolina")
```

    ## No encoding supplied: defaulting to UTF-8.

``` r
caseSum <- get_cases_summary() 

covidSummary <- covid_summary_cases()

caseWorld <- get_cases_world()

country_liveCase <- get_live_cases("united-states")
```

# Exploratory Data Analysis

## Contigency Tables/ Numerical Summaries

``` r
# kable(stateCases)

# kable(confirmed)
# kable(deaths)
# kable(recovered)
# kable(caseSum)
# kable(liveCase)
```

## Graphical Summaries

# Bar plot

top\_state\_09\_30\_2021 &lt;- country\_liveCase %&gt;% filter(Date ==
“2021-09-30T00:00:00Z”) %&gt;% arrange(desc(Active))
top\_10\_state\_09\_30\_2021 &lt;- top\_state\_09\_30\_2021\[1:10,\]

ggplot(data=top\_10\_state\_09\_30\_2021, aes(x=Province, y=Active)) +
geom\_bar(stat=“identity”, fill=“green”)

geom\_text(aes(label=Cases), vjust=1.6, color=“black”, size=3.5)+
theme\_minimal()+ ggtitle(“Top 10 North Carolina Cities Confirmed Covid
Cases on September 23rd, 2021.”)

``` r
# Bar plot
top_country<- covidSummary %>% arrange(desc(TotalConfirmed))
top_10_country <- top_country[1:10,]

ggplot(data=top_10_country, aes(x=Country, y=TotalConfirmed)) +
  geom_bar(stat="identity", fill="yellowgreen") + geom_text(aes(label=TotalConfirmed), vjust=1.6, color="black", size=3.5) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + labs(x = "Country", title = "Top 10 countries on Total Confirmed case")
```

![](README_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

``` r
# Bar plot
top_country<- covidSummary %>% arrange(desc(NewDeaths))
top_10_country <- top_country[1:10,]

ggplot(data=top_10_country, aes(x=Country, y=NewDeaths)) +
  geom_bar(stat="identity", fill="orange") +
  labs(x = "Country", title = "Top 10 countries on newDeath case") + geom_text(aes(label=NewDeaths), vjust=1.6, color="black", size=3.5) +
  theme(axis.text.x = element_text(angle = 45, hjust=1))
```

![](README_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

``` r
# Bar plot
top_city_09_30_2021 <- stateCases %>% filter(Date == "2021-09-30T00:00:00Z") %>% arrange(desc(Cases))
top_10_city_09_30_2021 <- top_city_09_30_2021[1:10,]

ggplot(data=top_10_city_09_30_2021, aes(x=City, y=Cases)) +
  geom_bar(stat="identity", fill="steelblue") + geom_text(aes(label=Cases), vjust=1.6, color="white", size=3.5) +
  theme(axis.text.x = element_text(angle = 45, hjust=1)) + labs(x = "NC CITY", title = "Top 10 City in North Carolina on Confirmed case")
```

![](README_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

geom\_text(aes(label=Cases), vjust=1.6, color=“white”, size=3.5)+
stat=“identity”, theme\_minimal()

-   ggtitle(“Top 10 North Carolina Cities Confirmed Covid Cases on
    September 30, 2020.”) stateCases

# Histogram

``` r
top_country<- covidSummary %>% arrange(desc(TotalConfirmed))
top_20_country <- top_country[1:20,]
```

``` r
ggplot(covidSummary, aes(x=NewDeaths)) + geom_histogram(color="orange2", fill="red", size = 2, binwidth=40)+geom_vline(aes(xintercept=mean(NewDeaths)),color="blue", linetype="dashed", size=1) + labs(x = "New Death Case", title = "Histogram of new death cases today: 192 countries")
```

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

``` r
#Blue line is the mean line.
```

``` r
# Histogram
ggplot(top_city_09_30_2021, aes(x=Cases)) + geom_histogram(color="darkblue",fill="red",binwidth=1000)+geom_vline(aes(xintercept=mean(Cases)),color="blue", linetype="dashed", size=1)+ggtitle("Histogram of Confirmed Cases in North Carolina Cities on September 30, 2021")
```

![](README_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->

``` r
#Blue line is the mean line.
```
