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
    -   [`Summary cases by Countries`](#summary-cases-by-countries)
-   [Exploratory Data Analysis](#exploratory-data-analysis)
    -   [Contigency Tables/ Numerical
        Summaries](#contigency-tables-numerical-summaries)
    -   [Graphical Summaries](#graphical-summaries)
-   [Bar plot](#bar-plot)
-   [Histogram](#histogram)
-   [Scatter plot - U.S. live case](#scatter-plot---us-live-case)

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

countryName <- country_Name()
countryName
```

    ## # A tibble: 248 x 2
    ##    Country                   Slug                     
    ##    <chr>                     <chr>                    
    ##  1 Poland                    poland                   
    ##  2 Comoros                   comoros                  
    ##  3 Djibouti                  djibouti                 
    ##  4 Turks and Caicos Islands  turks-and-caicos-islands 
    ##  5 Bulgaria                  bulgaria                 
    ##  6 Honduras                  honduras                 
    ##  7 San Marino                san-marino               
    ##  8 Niue                      niue                     
    ##  9 Tuvalu                    tuvalu                   
    ## 10 US Minor Outlying Islands us-minor-outlying-islands
    ## # ... with 238 more rows

## `Confirmed Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint.

``` r
get_confirmed_cases <- function(country){
     if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/confirmed?from=2020-03-01T00:00:00Z&to=2021-09-30T00:00:00Z")
  confirmed_cases_text = content(GET(url=full_url),"text")
  confirmed_cases_json = fromJSON(confirmed_cases_text)
      covid_confirmed_cases <- confirmed_cases_json %>% select(Country, Cases, Status, Date) #%>% rename(ConfirmedCases =  Cases) 
  return(covid_confirmed_cases)
     }
        else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

## `Death Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint, but
modified the status as deaths.

``` r
get_deaths_cases <- function(country){
    if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/deaths?from=2020-03-01T00:00:00Z&to=2021-09-30T00:00:00Z")
  deaths_cases_text = content(GET(url=full_url),"text")
  deaths_cases_json = fromJSON(deaths_cases_text)
       covid_deaths_cases <- deaths_cases_json  %>% select(Country, Cases, Status, Date) #%>% rename(DeathsCases =  Cases) 
  return(covid_deaths_cases)
    }
        else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

## `Recovered Cases by different contries` from March 1st, 2020 to September 21st, 2021

\#This function interacts with the `By Country Total` endpoint, but
modified the status as recovered.

``` r
get_recovered_cases <- function(country){
  if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/", country,"/status/recovered?from=2020-03-01T00:00:00Z&to=2021-09-30T00:00:00Z")
  recovered_cases_text = content(GET(url=full_url),"text")
  recovered_cases_json = fromJSON(recovered_cases_text)
       covid_recovered_cases <- recovered_cases_json  %>% select(Country, Cases, Status, Date) #%>% rename(RecoveredCases =  Cases)
  return(covid_recovered_cases)
  }
      else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}
```

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

nc_stateData <- get_cases_bystate("North Carolina")
nc_stateData 
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

## `Summary cases by Countries`

covid\_summary\_cases &lt;- function(){ full\_url =
paste0(base\_url,“/summary”) covid\_summary &lt;- GET(url=full\_url)
covid\_cases\_summary &lt;-
fromJSON(rawToChar(covid\_summary*c**o**n**t**e**n**t*))*c**o**v**i**d*<sub>*c*</sub>*a**s**e**s*<sub>*s*</sub>*u**m**m**a**r**y*1 &lt;  − *d**a**t**a*.*f**r**a**m**e*(*c**o**v**i**d*<sub>*c*</sub>*a**s**e**s*<sub>*s*</sub>*u**m**m**a**r**y*Countries)
\#covid\_cases\_summary2 &lt;- data.frame(covid\_cases\_summary1)
return(covid\_cases\_summary1) }

covidSum &lt;- covid\_summary\_cases() covidSum

``` r
covid_summary_cases <- function(){
   full_url = paste0(base_url,"/summary")
   covid_summary_text <- content(GET(url=full_url),"text")
   covid_cases_summary_json <- fromJSON(covid_summary_text)
   covid_cases_summary1 <- data.frame(covid_cases_summary_json$Countries)  
   covid_cases_summary2 <- as_tibble(covid_cases_summary1)
   return(covid_cases_summary2)
}

covidSum <- covid_summary_cases()
covidSum
```

    ## # A tibble: 192 x 12
    ##    ID                                   Country             CountryCode Slug      NewConfirmed TotalConfirmed NewDeaths TotalDeaths NewRecovered TotalRecovered Date      Premium 
    ##    <chr>                                <chr>               <chr>       <chr>            <int>          <int>     <int>       <int>        <int>          <int> <chr>     <named >
    ##  1 15aa5e35-b345-4173-98ab-9b61888cdb04 Afghanistan         AF          afghanis~            0         155191         0        7206            0              0 2021-10-~ <NULL>  
    ##  2 26cb4723-635f-4a65-a900-d7aa5237799b Albania             AL          albania            549         171327         5        2710            0              0 2021-10-~ <NULL>  
    ##  3 2553b71f-393f-47cd-b2da-cdfd6b8ed9d0 Algeria             DZ          algeria            140         203657         4        5819            0              0 2021-10-~ <NULL>  
    ##  4 a6647cef-ac64-4516-91b5-905c37a9ac6b Andorra             AD          andorra              0          15222         0         130            0              0 2021-10-~ <NULL>  
    ##  5 9403ffd5-2fa0-4b0d-9fbf-ea5eaf635f5d Angola              AO          angola             527          58603         7        1574            0              0 2021-10-~ <NULL>  
    ##  6 c3991c09-522c-4452-be78-8df67e347a6d Antigua and Barbuda AG          antigua-~            0           3336         0          81            0              0 2021-10-~ <NULL>  
    ##  7 2e53a35b-e709-4f69-a764-d75de9201869 Argentina           AR          argentina          886        5259352        14      115239            0              0 2021-10-~ <NULL>  
    ##  8 3bc3f309-52ab-4473-aa39-26d1837adb15 Armenia             AM          armenia           1152         263783        15        5354            0              0 2021-10-~ <NULL>  
    ##  9 4aca024c-18c6-4916-9e29-0fb76675b6e2 Australia           AU          australia         2335         109516        10        1321            0              0 2021-10-~ <NULL>  
    ## 10 fe8adf3e-8876-48ee-8c4d-6e63da6d7d4d Austria             AT          austria           1416         746380         7       11021            0              0 2021-10-~ <NULL>  
    ## # ... with 182 more rows

``` r
get_live_cases <- function(country){
       if(country %in% countryName$Slug){
   full_url = paste0(base_url,"/live/country/",country,"/status/confirmed/date/2021-07-01T00:00:00Z")
    covid_cases_live_text = content(GET(url=full_url),"text")
    covid_cases_live_json = fromJSON(covid_cases_live_text)
      covid_state_cases <- covid_cases_live_json  %>% select(Country, Province, Confirmed, Deaths, Active, Date) #%>% rename(RecoveredCases =  Cases)
      return(covid_state_cases)
       }
      else {
      message <- paste("ERROR: Argument for country was not found in the Slug.", 
                       "Look up countryName to find the country you are looking for and use Slug.")
      stop(message)
    }
}

us_liveCases <- get_live_cases("united-states")
us_liveCases
```

    ##                      Country                 Province Confirmed Deaths  Active                 Date
    ## 1   United States of America             Rhode Island    152618   2730  149888 2021-07-02T00:00:00Z
    ## 2   United States of America                  Florida   2365464  37772 2327692 2021-07-02T00:00:00Z
    ## 3   United States of America                   Nevada    334255   5692  328563 2021-07-02T00:00:00Z
    ## 4   United States of America                   Alaska     71275    377   70898 2021-07-02T00:00:00Z
    ## 5   United States of America                  Wyoming     62353    747   61606 2021-07-02T00:00:00Z
    ## 6   United States of America                  Georgia   1135093  21428 1113665 2021-07-02T00:00:00Z
    ## 7   United States of America               Washington    452072   5938  446134 2021-07-02T00:00:00Z
    ## 8   United States of America           South Carolina    597021   9826  587195 2021-07-02T00:00:00Z
    ## 9   United States of America                  Vermont     24412    257   24155 2021-07-02T00:00:00Z
    ## 10  United States of America           Virgin Islands      3895     30    3865 2021-07-02T00:00:00Z
    ## 11  United States of America               New Mexico    205629   4343  201286 2021-07-02T00:00:00Z
    ## 12  United States of America                 Michigan   1000241  21013  979228 2021-07-02T00:00:00Z
    ## 13  United States of America                     Guam      8366    140    8226 2021-07-02T00:00:00Z
    ## 14  United States of America             South Dakota    124570   2038  122532 2021-07-02T00:00:00Z
    ## 15  United States of America                Louisiana    482035  10748  471287 2021-07-02T00:00:00Z
    ## 16  United States of America                 Delaware    109770   1694  108076 2021-07-02T00:00:00Z
    ## 17  United States of America Northern Mariana Islands       183      2     181 2021-07-02T00:00:00Z
    ## 18  United States of America                 Virginia    680564  11419  669145 2021-07-02T00:00:00Z
    ## 19  United States of America                 Missouri    627082   9731  617351 2021-07-02T00:00:00Z
    ## 20  United States of America               California   3817211  63706 3753505 2021-07-02T00:00:00Z
    ## 21  United States of America             Pennsylvania   1216965  27687 1189278 2021-07-02T00:00:00Z
    ## 22  United States of America                  Montana    113821   1666  112155 2021-07-02T00:00:00Z
    ## 23  United States of America                  Indiana    754317  13855  740462 2021-07-02T00:00:00Z
    ## 24  United States of America                 Oklahoma    458180   7388  450792 2021-07-02T00:00:00Z
    ## 25  United States of America     District of Columbia     49362   1141   48221 2021-07-02T00:00:00Z
    ## 26  United States of America                  Arizona    895347  17939  877408 2021-07-02T00:00:00Z
    ## 27  United States of America                 Nebraska    224488   2261  222227 2021-07-02T00:00:00Z
    ## 28  United States of America           North Carolina   1013985  13434 1000551 2021-07-02T00:00:00Z
    ## 29  United States of America                     Ohio   1111903  20309 1091594 2021-07-02T00:00:00Z
    ## 30  United States of America                     Iowa    373960   6140  367820 2021-07-02T00:00:00Z
    ## 31  United States of America                Wisconsin    677740   8134  669606 2021-07-02T00:00:00Z
    ## 32  United States of America                 Kentucky    465330   7223  458107 2021-07-02T00:00:00Z
    ## 33  United States of America            Massachusetts    710049  17995  692054 2021-07-02T00:00:00Z
    ## 34  United States of America                    Maine     69055    859   68196 2021-07-02T00:00:00Z
    ## 35  United States of America                Minnesota    605448   7692  597756 2021-07-02T00:00:00Z
    ## 36  United States of America                 Maryland    462354   9744  452610 2021-07-02T00:00:00Z
    ## 37  United States of America                  Alabama    550983  11352  539631 2021-07-02T00:00:00Z
    ## 38  United States of America            New Hampshire     99527   1372   98155 2021-07-02T00:00:00Z
    ## 39  United States of America                   Kansas    319149   5156  313993 2021-07-02T00:00:00Z
    ## 40  United States of America             North Dakota    110718   1559  109159 2021-07-02T00:00:00Z
    ## 41  United States of America                    Idaho    195089   2154  192935 2021-07-02T00:00:00Z
    ## 42  United States of America                 Colorado    558321   6798  551523 2021-07-02T00:00:00Z
    ## 43  United States of America                 Illinois   1392196  25670 1366526 2021-07-02T00:00:00Z
    ## 44  United States of America                 Arkansas    350085   5909  344176 2021-07-02T00:00:00Z
    ## 45  United States of America                   Oregon    208836   2778  206058 2021-07-02T00:00:00Z
    ## 46  United States of America                     Utah    415679   2375  413304 2021-07-02T00:00:00Z
    ## 47  United States of America            West Virginia    164097   2897  161200 2021-07-02T00:00:00Z
    ## 48  United States of America                Tennessee    867157  12568  854589 2021-07-02T00:00:00Z
    ## 49  United States of America              Mississippi    321944   7415  314529 2021-07-02T00:00:00Z
    ## 50  United States of America                    Texas   3001682  52410 2949272 2021-07-02T00:00:00Z
    ## 51  United States of America                 New York   2115377  53690 2061687 2021-07-02T00:00:00Z
    ## 52  United States of America              Puerto Rico    140058   2549  137509 2021-07-02T00:00:00Z
    ## 53  United States of America                   Hawaii     37807    518   37289 2021-07-02T00:00:00Z
    ## 54  United States of America               New Jersey   1023613  26462  997151 2021-07-02T00:00:00Z
    ## 55  United States of America              Connecticut    349387   8279  341108 2021-07-02T00:00:00Z
    ## 56  United States of America              Mississippi    322186   7419  314767 2021-07-03T00:00:00Z
    ## 57  United States of America               Washington    452483   5939  446544 2021-07-03T00:00:00Z
    ## 58  United States of America            Massachusetts    710138  17997  692141 2021-07-03T00:00:00Z
    ## 59  United States of America     District of Columbia     49378   1141   48237 2021-07-03T00:00:00Z
    ## 60  United States of America                Wisconsin    677859   8135  669724 2021-07-03T00:00:00Z
    ## 61  United States of America               New Jersey   1023923  26467  997456 2021-07-03T00:00:00Z
    ## 62  United States of America              Puerto Rico    140106   2550  137556 2021-07-03T00:00:00Z
    ## 63  United States of America                 Oklahoma    458483   7388  451095 2021-07-03T00:00:00Z
    ## 64  United States of America                 Missouri    628255   9748  618507 2021-07-03T00:00:00Z
    ## 65  United States of America                 Maryland    462439   9746  452693 2021-07-03T00:00:00Z
    ## 66  United States of America                   Kansas    319541   5158  314383 2021-07-03T00:00:00Z
    ## 67  United States of America                     Ohio   1112088  20344 1091744 2021-07-03T00:00:00Z
    ## 68  United States of America                 New York   2115880  53692 2062188 2021-07-03T00:00:00Z
    ## 69  United States of America                  Georgia   1135526  21443 1114083 2021-07-03T00:00:00Z
    ## 70  United States of America                 Arkansas    350579   5913  344666 2021-07-03T00:00:00Z
    ## 71  United States of America                    Texas   3003278  52453 2950825 2021-07-03T00:00:00Z
    ## 72  United States of America              Connecticut    349476   8279  341197 2021-07-03T00:00:00Z
    ## 73  United States of America                  Vermont     24419    258   24161 2021-07-03T00:00:00Z
    ## 74  United States of America               California   3819204  63761 3755443 2021-07-03T00:00:00Z
    ## 75  United States of America                     Guam      8373    140    8233 2021-07-03T00:00:00Z
    ## 76  United States of America                   Alaska     71384    377   71007 2021-07-03T00:00:00Z
    ## 77  United States of America             Pennsylvania   1217115  27695 1189420 2021-07-03T00:00:00Z
    ## 78  United States of America                  Wyoming     62445    747   61698 2021-07-03T00:00:00Z
    ## 79  United States of America                Louisiana    482560  10757  471803 2021-07-03T00:00:00Z
    ## 80  United States of America                Tennessee    867407  12571  854836 2021-07-03T00:00:00Z
    ## 81  United States of America                 Nebraska    224488   2261  222227 2021-07-03T00:00:00Z
    ## 82  United States of America                   Oregon    209037   2781  206256 2021-07-03T00:00:00Z
    ## 83  United States of America                 Delaware    109820   1695  108125 2021-07-03T00:00:00Z
    ## 84  United States of America                 Colorado    558820   6802  552018 2021-07-03T00:00:00Z
    ## 85  United States of America                 Kentucky    465490   7229  458261 2021-07-03T00:00:00Z
    ## 86  United States of America                  Indiana    754724  13863  740861 2021-07-03T00:00:00Z
    ## 87  United States of America                 Michigan   1000420  21013  979407 2021-07-03T00:00:00Z
    ## 88  United States of America                     Utah    416110   2378  413732 2021-07-03T00:00:00Z
    ## 89  United States of America            West Virginia    164149   2899  161250 2021-07-03T00:00:00Z
    ## 90  United States of America                  Montana    113873   1666  112207 2021-07-03T00:00:00Z
    ## 91  United States of America               New Mexico    205715   4344  201371 2021-07-03T00:00:00Z
    ## 92  United States of America                  Florida   2365464  37772 2327692 2021-07-03T00:00:00Z
    ## 93  United States of America                    Idaho    195172   2158  193014 2021-07-03T00:00:00Z
    ## 94  United States of America                     Iowa    374054   6142  367912 2021-07-03T00:00:00Z
    ## 95  United States of America                   Nevada    334763   5697  329066 2021-07-03T00:00:00Z
    ## 96  United States of America                    Maine     69070    860   68210 2021-07-03T00:00:00Z
    ## 97  United States of America                 Illinois   1392552  25678 1366874 2021-07-03T00:00:00Z
    ## 98  United States of America                   Hawaii     37886    518   37368 2021-07-03T00:00:00Z
    ## 99  United States of America            New Hampshire     99555   1372   98183 2021-07-03T00:00:00Z
    ## 100 United States of America             Rhode Island    152643   2730  149913 2021-07-03T00:00:00Z
    ## 101 United States of America                 Virginia    680744  11423  669321 2021-07-03T00:00:00Z
    ## 102 United States of America           Virgin Islands      3895     30    3865 2021-07-03T00:00:00Z
    ## 103 United States of America                Minnesota    605549   7698  597851 2021-07-03T00:00:00Z
    ## 104 United States of America           South Carolina    597261   9830  587431 2021-07-03T00:00:00Z
    ## 105 United States of America             North Dakota    110729   1559  109170 2021-07-03T00:00:00Z
    ## 106 United States of America                  Arizona    895873  17961  877912 2021-07-03T00:00:00Z
    ## 107 United States of America Northern Mariana Islands       183      2     181 2021-07-03T00:00:00Z
    ## 108 United States of America           North Carolina   1014359  13434 1000925 2021-07-03T00:00:00Z
    ## 109 United States of America             South Dakota    124592   2038  122554 2021-07-03T00:00:00Z
    ## 110 United States of America                  Alabama    551298  11358  539940 2021-07-03T00:00:00Z
    ## 111 United States of America              Mississippi    322186   7419  314767 2021-07-04T00:00:00Z
    ## 112 United States of America                    Texas   3004465  52473 2951992 2021-07-04T00:00:00Z
    ## 113 United States of America             South Dakota    124592   2038  122554 2021-07-04T00:00:00Z
    ## 114 United States of America                   Nevada    334763   5697  329066 2021-07-04T00:00:00Z
    ## 115 United States of America              Connecticut    349476   8279  341197 2021-07-04T00:00:00Z
    ## 116 United States of America              Puerto Rico    140175   2552  137623 2021-07-04T00:00:00Z
    ## 117 United States of America Northern Mariana Islands       183      2     181 2021-07-04T00:00:00Z
    ## 118 United States of America                  Vermont     24419    258   24161 2021-07-04T00:00:00Z
    ## 119 United States of America                     Iowa    374120   6146  367974 2021-07-04T00:00:00Z
    ## 120 United States of America                 Michigan   1000375  21009  979366 2021-07-04T00:00:00Z
    ## 121 United States of America                    Maine     69099    860   68239 2021-07-04T00:00:00Z
    ## 122 United States of America                 Kentucky    465490   7229  458261 2021-07-04T00:00:00Z
    ## 123 United States of America                 Maryland    462535   9749  452786 2021-07-04T00:00:00Z
    ## 124 United States of America                 Delaware    109846   1695  108151 2021-07-04T00:00:00Z
    ## 125 United States of America           South Carolina    597261   9830  587431 2021-07-04T00:00:00Z
    ## 126 United States of America                 Arkansas    350579   5913  344666 2021-07-04T00:00:00Z
    ## 127 United States of America                     Guam      8373    140    8233 2021-07-04T00:00:00Z
    ## 128 United States of America                   Oregon    209037   2781  206256 2021-07-04T00:00:00Z
    ## 129 United States of America                     Ohio   1112289  20344 1091945 2021-07-04T00:00:00Z
    ## 130 United States of America                     Utah    416110   2378  413732 2021-07-04T00:00:00Z
    ## 131 United States of America             Pennsylvania   1217288  27704 1189584 2021-07-04T00:00:00Z
    ## 132 United States of America            Massachusetts    710138  17997  692141 2021-07-04T00:00:00Z
    ## 133 United States of America                  Arizona    896518  17975  878543 2021-07-04T00:00:00Z
    ## 134 United States of America                 Oklahoma    458483   7388  451095 2021-07-04T00:00:00Z
    ## 135 United States of America               Washington    452483   5939  446544 2021-07-04T00:00:00Z
    ## 136 United States of America                  Florida   2381148  37985 2343163 2021-07-04T00:00:00Z
    ## 137 United States of America                  Alabama    551298  11358  539940 2021-07-04T00:00:00Z
    ## 138 United States of America                 New York   2116166  53692 2062474 2021-07-04T00:00:00Z
    ## 139 United States of America           Virgin Islands      3895     30    3865 2021-07-04T00:00:00Z
    ## 140 United States of America                   Hawaii     37933    518   37415 2021-07-04T00:00:00Z
    ## 141 United States of America                  Indiana    754724  13863  740861 2021-07-04T00:00:00Z
    ## 142 United States of America                 Virginia    680904  11423  669481 2021-07-04T00:00:00Z
    ## 143 United States of America               New Jersey   1024113  26472  997641 2021-07-04T00:00:00Z
    ## 144 United States of America                   Alaska     71384    377   71007 2021-07-04T00:00:00Z
    ## 145 United States of America           North Carolina   1014359  13434 1000925 2021-07-04T00:00:00Z
    ## 146 United States of America               New Mexico    205715   4344  201371 2021-07-04T00:00:00Z
    ## 147 United States of America     District of Columbia     49378   1141   48237 2021-07-04T00:00:00Z
    ## 148 United States of America                    Idaho    195172   2158  193014 2021-07-04T00:00:00Z
    ## 149 United States of America                Tennessee    867407  12571  854836 2021-07-04T00:00:00Z
    ## 150 United States of America                Louisiana    482560  10757  471803 2021-07-04T00:00:00Z
    ## 151 United States of America                  Georgia   1135526  21443 1114083 2021-07-04T00:00:00Z
    ## 152 United States of America               California   3820301  63651 3756650 2021-07-04T00:00:00Z
    ## 153 United States of America            New Hampshire     99555   1372   98183 2021-07-04T00:00:00Z
    ## 154 United States of America                 Nebraska    224488   2261  222227 2021-07-04T00:00:00Z
    ## 155 United States of America                   Kansas    319541   5158  314383 2021-07-04T00:00:00Z
    ## 156 United States of America             Rhode Island    152643   2730  149913 2021-07-04T00:00:00Z
    ## 157 United States of America                Wisconsin    677859   8135  669724 2021-07-04T00:00:00Z
    ## 158 United States of America                  Wyoming     62445    747   61698 2021-07-04T00:00:00Z
    ## 159 United States of America                  Montana    113873   1666  112207 2021-07-04T00:00:00Z
    ## 160 United States of America             North Dakota    110734   1559  109175 2021-07-04T00:00:00Z
    ## 161 United States of America            West Virginia    164149   2899  161250 2021-07-04T00:00:00Z
    ## 162 United States of America                Minnesota    605660   7703  597957 2021-07-04T00:00:00Z
    ## 163 United States of America                 Missouri    628484   9756  618728 2021-07-04T00:00:00Z
    ## 164 United States of America                 Colorado    559272   6814  552458 2021-07-04T00:00:00Z
    ## 165 United States of America                 Illinois   1392552  25678 1366874 2021-07-04T00:00:00Z
    ## 166 United States of America                Tennessee    867407  12571  854836 2021-07-05T00:00:00Z
    ##  [ reached 'max' / getOption("max.print") -- omitted 4948 rows ]

``` r
#As of July 28,2012 CDC covid case map
#https://twitter.com/cdcgov/status/1288609081696169990

#we can create a function that will manipulate our data to prepare for data summaries and visualization
newcolumnData <- function(dataset){
  dataset <- dataset %>% 
            mutate("DeathRate"= (Deaths/Confirmed)*100, 
                   "DeathRateStatus"= if_else(DeathRate > 10, "serious",
                                  if_else(DeathRate > 5, "high", 
                                          if_else(DeathRate >2, "medium", "low"))), 
                   "RiskStatus" = if_else(Confirmed > 174973, "Veryhigh",
                                    if_else(Confirmed > 82530, "high", 
                                      if_else(Confirmed > 39337, "mediumhigh", 
                                        if_else(Confirmed > 18725, "medium", 
                                          if_else(Confirmed > 6173, "mediumlow","low")))))
                                          
                                  )            

  return(dataset)
}
```

``` r
new_live_07_28_2021 <- us_liveCases %>% filter(Date == "2021-07-28T00:00:00Z")

newcolumnData1 <- newcolumnData(new_live_07_28_2021)
newcolumnData1
```

    ##                     Country                 Province Confirmed Deaths  Active                 Date DeathRate DeathRateStatus RiskStatus
    ## 1  United States of America              Mississippi    338079   7523  330556 2021-07-28T00:00:00Z 2.2252195          medium   Veryhigh
    ## 2  United States of America                  Vermont     24760    259   24501 2021-07-28T00:00:00Z 1.0460420             low     medium
    ## 3  United States of America             North Dakota    111331   1569  109762 2021-07-28T00:00:00Z 1.4093110             low       high
    ## 4  United States of America           South Carolina    611594   9883  601711 2021-07-28T00:00:00Z 1.6159413             low   Veryhigh
    ## 5  United States of America                Minnesota    610839   7749  603090 2021-07-28T00:00:00Z 1.2685830             low   Veryhigh
    ## 6  United States of America               New Jersey   1035027  26586 1008441 2021-07-28T00:00:00Z 2.5686286          medium   Veryhigh
    ## 7  United States of America             South Dakota    124960   2043  122917 2021-07-28T00:00:00Z 1.6349232             low       high
    ## 8  United States of America               Washington    470332   6096  464236 2021-07-28T00:00:00Z 1.2961057             low   Veryhigh
    ## 9  United States of America            Massachusetts    717284  18065  699219 2021-07-28T00:00:00Z 2.5185282          medium   Veryhigh
    ## 10 United States of America     District of Columbia     50228   1147   49081 2021-07-28T00:00:00Z 2.2835868          medium mediumhigh
    ## 11 United States of America                 Nebraska    226839   2284  224555 2021-07-28T00:00:00Z 1.0068815             low   Veryhigh
    ## 12 United States of America               New Mexico    209356   4402  204954 2021-07-28T00:00:00Z 2.1026386          medium   Veryhigh
    ## 13 United States of America                 Delaware    110943   1698  109245 2021-07-28T00:00:00Z 1.5305157             low       high
    ## 14 United States of America             Pennsylvania   1226157  27831 1198326 2021-07-28T00:00:00Z 2.2697746          medium   Veryhigh
    ## 15 United States of America           Virgin Islands      4450     36    4414 2021-07-28T00:00:00Z 0.8089888             low        low
    ## 16 United States of America                 Michigan   1008429  21165  987264 2021-07-28T00:00:00Z 2.0988091          medium   Veryhigh
    ## 17 United States of America                  Indiana    767409  13980  753429 2021-07-28T00:00:00Z 1.8217144             low   Veryhigh
    ## 18 United States of America                   Kansas    329683   5245  324438 2021-07-28T00:00:00Z 1.5909222             low   Veryhigh
    ## 19 United States of America                    Texas   3092405  53078 3039327 2021-07-28T00:00:00Z 1.7163987             low   Veryhigh
    ## 20 United States of America                  Wyoming     64616    775   63841 2021-07-28T00:00:00Z 1.1993933             low mediumhigh
    ## 21 United States of America Northern Mariana Islands       183      2     181 2021-07-28T00:00:00Z 1.0928962             low        low
    ## 22 United States of America                 Arkansas    378023   6087  371936 2021-07-28T00:00:00Z 1.6102195             low   Veryhigh
    ## 23 United States of America             Rhode Island    153802   2739  151063 2021-07-28T00:00:00Z 1.7808611             low       high
    ## 24 United States of America                   Oregon    216875   2843  214032 2021-07-28T00:00:00Z 1.3108934             low   Veryhigh
    ## 25 United States of America                Wisconsin    684119   8184  675935 2021-07-28T00:00:00Z 1.1962831             low   Veryhigh
    ## 26 United States of America              Puerto Rico    144321   2569  141752 2021-07-28T00:00:00Z 1.7800597             low       high
    ## 27 United States of America                  Georgia   1167405  21644 1145761 2021-07-28T00:00:00Z 1.8540267             low   Veryhigh
    ## 28 United States of America                 Maryland    466514   9810  456704 2021-07-28T00:00:00Z 2.1028308          medium   Veryhigh
    ## 29 United States of America                     Ohio   1123964  20490 1103474 2021-07-28T00:00:00Z 1.8230121             low   Veryhigh
    ## 30 United States of America            West Virginia    166297   2936  163361 2021-07-28T00:00:00Z 1.7655159             low       high
    ## 31 United States of America                   Hawaii     40984    529   40455 2021-07-28T00:00:00Z 1.2907476             low mediumhigh
    ## 32 United States of America            New Hampshire    100398   1386   99012 2021-07-28T00:00:00Z 1.3805056             low       high
    ## 33 United States of America                   Nevada    352567   5854  346713 2021-07-28T00:00:00Z 1.6603936             low   Veryhigh
    ## 34 United States of America                 Missouri    673931  10043  663888 2021-07-28T00:00:00Z 1.4902119             low   Veryhigh
    ## 35 United States of America              Connecticut    353114   8288  344826 2021-07-28T00:00:00Z 2.3471174          medium   Veryhigh
    ## 36 United States of America                 New York   2140258  53611 2086647 2021-07-28T00:00:00Z 2.5048849          medium   Veryhigh
    ## 37 United States of America                  Florida   2523510  38670 2484840 2021-07-28T00:00:00Z 1.5323894             low   Veryhigh
    ## 38 United States of America                 Virginia    691018  11515  679503 2021-07-28T00:00:00Z 1.6663821             low   Veryhigh
    ## 39 United States of America               California   3924756  64283 3860473 2021-07-28T00:00:00Z 1.6378853             low   Veryhigh
    ## 40 United States of America                 Colorado    571958   6923  565035 2021-07-28T00:00:00Z 1.2104036             low   Veryhigh
    ## 41 United States of America                Louisiana    527253  10934  516319 2021-07-28T00:00:00Z 2.0737672          medium   Veryhigh
    ## 42 United States of America                  Arizona    920084  18183  901901 2021-07-28T00:00:00Z 1.9762326             low   Veryhigh
    ## 43 United States of America           North Carolina   1038976  13590 1025386 2021-07-28T00:00:00Z 1.3080187             low   Veryhigh
    ## 44 United States of America                     Utah    429300   2441  426859 2021-07-28T00:00:00Z 0.5686000             low   Veryhigh
    ## 45 United States of America                  Montana    115665   1699  113966 2021-07-28T00:00:00Z 1.4688972             low       high
    ## 46 United States of America                Tennessee    886519  12703  873816 2021-07-28T00:00:00Z 1.4329078             low   Veryhigh
    ## 47 United States of America                     Iowa    376673   6170  370503 2021-07-28T00:00:00Z 1.6380256             low   Veryhigh
    ## 48 United States of America                 Kentucky    477882   7323  470559 2021-07-28T00:00:00Z 1.5323867             low   Veryhigh
    ## 49 United States of America                    Maine     70077    898   69179 2021-07-28T00:00:00Z 1.2814476             low mediumhigh
    ## 50 United States of America                   Alaska     74383    384   73999 2021-07-28T00:00:00Z 0.5162470             low mediumhigh
    ## 51 United States of America                     Guam      8514    143    8371 2021-07-28T00:00:00Z 1.6795866             low  mediumlow
    ## 52 United States of America                 Illinois   1413490  25847 1387643 2021-07-28T00:00:00Z 1.8285945             low   Veryhigh
    ## 53 United States of America                    Idaho    199158   2189  196969 2021-07-28T00:00:00Z 1.0991273             low   Veryhigh
    ## 54 United States of America                  Alabama    574737  11492  563245 2021-07-28T00:00:00Z 1.9995233             low   Veryhigh
    ## 55 United States of America                 Oklahoma    475578   7454  468124 2021-07-28T00:00:00Z 1.5673559             low   Veryhigh

``` r
#https://ourworldindata.org/grapher/biweekly-confirmed-covid-19-cases
#we can create a function that will manipulate our data to prepare for data summaries and visualization
newAddData_state <- function(dataset){
  dataset1 <- dataset %>% 
            mutate("TotalDeathRate"= (TotalDeaths/TotalConfirmed)*100, 
                   "TotalDeathRateStatus"= if_else(TotalDeathRate > 10, "serious",
                                  if_else(TotalDeathRate > 5, "high", 
                                          if_else(TotalDeathRate >2, "medium", "low"))), 
                   "Active" = (TotalConfirmed-TotalDeaths), 
                   "RiskStatus" = if_else(TotalConfirmed > 100000, "Veryhigh",
                                    if_else(TotalConfirmed > 50000, "high", 
                                      if_else(TotalConfirmed > 10000, "mediumhigh", 
                                        if_else(TotalConfirmed > 1000, "medium", 
                                          if_else(TotalConfirmed > 100, "mediumlow","low")))))
            )

  return(dataset1)
}




newCovidSummary <- newAddData_state(covidSum)
newCovidSummary
```

    ## # A tibble: 192 x 16
    ##    ID     Country  CountryCode Slug  NewConfirmed TotalConfirmed NewDeaths TotalDeaths NewRecovered TotalRecovered Date  Premium TotalDeathRate TotalDeathRateS~ Active RiskStatus
    ##    <chr>  <chr>    <chr>       <chr>        <int>          <int>     <int>       <int>        <int>          <int> <chr> <named>          <dbl> <chr>             <int> <chr>     
    ##  1 15aa5~ Afghani~ AF          afgh~            0         155191         0        7206            0              0 2021~ <NULL>           4.64  medium           1.48e5 Veryhigh  
    ##  2 26cb4~ Albania  AL          alba~          549         171327         5        2710            0              0 2021~ <NULL>           1.58  low              1.69e5 Veryhigh  
    ##  3 2553b~ Algeria  DZ          alge~          140         203657         4        5819            0              0 2021~ <NULL>           2.86  medium           1.98e5 Veryhigh  
    ##  4 a6647~ Andorra  AD          ando~            0          15222         0         130            0              0 2021~ <NULL>           0.854 low              1.51e4 mediumhigh
    ##  5 9403f~ Angola   AO          ango~          527          58603         7        1574            0              0 2021~ <NULL>           2.69  medium           5.70e4 high      
    ##  6 c3991~ Antigua~ AG          anti~            0           3336         0          81            0              0 2021~ <NULL>           2.43  medium           3.26e3 medium    
    ##  7 2e53a~ Argenti~ AR          arge~          886        5259352        14      115239            0              0 2021~ <NULL>           2.19  medium           5.14e6 Veryhigh  
    ##  8 3bc3f~ Armenia  AM          arme~         1152         263783        15        5354            0              0 2021~ <NULL>           2.03  medium           2.58e5 Veryhigh  
    ##  9 4aca0~ Austral~ AU          aust~         2335         109516        10        1321            0              0 2021~ <NULL>           1.21  low              1.08e5 Veryhigh  
    ## 10 fe8ad~ Austria  AT          aust~         1416         746380         7       11021            0              0 2021~ <NULL>           1.48  low              7.35e5 Veryhigh  
    ## # ... with 182 more rows

``` r
#countryName <- country_Name()

indiaConfirmed <- get_confirmed_cases("india")

usConfirmed <- get_confirmed_cases("united-states")
brazilConfirmed <- get_confirmed_cases("brazil")
ukConfirmed <- get_confirmed_cases("united-kingdom")
russiaConfirmed <- get_confirmed_cases("russia")

indiaDeaths <- get_deaths_cases("india")

usDeaths <- get_deaths_cases("united-states") 

inRecovered <- get_recovered_cases("india")
usRecovered <- get_recovered_cases("united-states")

#stateCases <- get_cases_bystate("North Carolina")

#covidSummary <- covid_summary_cases()

#us_liveCase <- get_live_cases("united-states")

in_liveCase <- get_live_cases("india") 
```

# Exploratory Data Analysis

## Contigency Tables/ Numerical Summaries

``` r
# combining three datasets

#confirm_subset <- usConfirmed %>% select(Country, Cases,Status, Date)
#death_subset <- usDeaths %>% select(Country, Cases,Status)
#recover_subset <- usRecovered %>% select(Country, Cases,Status) 
five_confirm <- rbind(usConfirmed, brazilConfirmed, indiaConfirmed, ukConfirmed, russiaConfirmed)


five_com1 <- five_confirm %>% filter(Date == "2021-09-30T00:00:00Z")
five_com1
```

    ##                    Country    Cases    Status                 Date
    ## 1 United States of America 43460343 confirmed 2021-09-30T00:00:00Z
    ## 2                   Brazil 21427073 confirmed 2021-09-30T00:00:00Z
    ## 3                    India 33766707 confirmed 2021-09-30T00:00:00Z
    ## 4           United Kingdom  7843887 confirmed 2021-09-30T00:00:00Z
    ## 5       Russian Federation  7401104 confirmed 2021-09-30T00:00:00Z

``` r
five_confirm_table <- table(five_com1$Country)
five_confirm_table
```

    ## 
    ##                   Brazil                    India       Russian Federation           United Kingdom United States of America 
    ##                        1                        1                        1                        1                        1

``` r
# Contingency table

#Worldwide

TotalDeathRate_status <- table(newCovidSummary$TotalDeathRateStatus) 

TotalDeathRate_status1 <- TotalDeathRate_status[c(4,1,3,2)]

kable(TotalDeathRate_status1) #col.names = c("Total DeathRate Status", "Count"))
```

| Var1    | Freq |
|:--------|-----:|
| serious |    2 |
| high    |    8 |
| medium  |   64 |
| low     |  118 |

``` r
TotalRisk_status <- table(newCovidSummary$RiskStatus) 

TotalRisk_status1 <- TotalRisk_status[c(5,1,4,3,2)]

kable(TotalRisk_status1) #col.names = c("Risk Status", "Count"))
```

| Var1       | Freq |
|:-----------|-----:|
| Veryhigh   |  112 |
| high       |   12 |
| mediumhigh |   38 |
| medium     |   22 |
| low        |    8 |

``` r
# Contingency table 
#United Status
usDeathRate_status <- table(newcolumnData1$RiskStatus, newcolumnData1$DeathRateStatus)
kable(usDeathRate_status)
```

|            | low | medium |
|:-----------|----:|-------:|
| high       |   8 |      0 |
| low        |   2 |      0 |
| medium     |   1 |      0 |
| mediumhigh |   4 |      1 |
| mediumlow  |   1 |      0 |
| Veryhigh   |  28 |     10 |

``` r
Summarydata_World <- newCovidSummary %>% group_by(RiskStatus) %>% summarise(Avg = mean(TotalConfirmed), Med = median((TotalConfirmed), IQR = IQR(TotalConfirmed), Var = var(TotalConfirmed)) )

Summarydata_World
```

    ## # A tibble: 5 x 3
    ##   RiskStatus        Avg     Med
    ##   <chr>           <dbl>   <dbl>
    ## 1 high         70952.    67701 
    ## 2 low              8.25      4 
    ## 3 medium        5263.     5139 
    ## 4 mediumhigh   23387.    21058.
    ## 5 Veryhigh   2073425.   507360.

``` r
newCovidSummary %>% group_by(TotalDeathRateStatus) %>% summarise(Avg = mean(TotalConfirmed), Med = median(TotalConfirmed))
```

    ## # A tibble: 4 x 3
    ##   TotalDeathRateStatus      Avg     Med
    ##   <chr>                   <dbl>   <dbl>
    ## 1 high                  846671. 172156.
    ## 2 low                  1233025. 158949 
    ## 3 medium               1278127. 219596.
    ## 4 serious                 4572.   4572.

``` r
newCovidSummary %>% group_by(TotalDeathRateStatus) %>% summarise(Avg = mean(TotalDeathRate), Med = median(TotalDeathRate), Var = var(TotalDeathRate), IQR = IQR(TotalDeathRate))
```

    ## # A tibble: 4 x 5
    ##   TotalDeathRateStatus   Avg   Med    Var   IQR
    ##   <chr>                <dbl> <dbl>  <dbl> <dbl>
    ## 1 high                  6.71  6.48  1.76  1.92 
    ## 2 low                   1.06  1.15  0.281 0.807
    ## 3 medium                2.89  2.75  0.498 1.12 
    ## 4 serious              22.0  22.0  18.2   3.01

``` r
cor(newCovidSummary$TotalConfirmed, newCovidSummary$TotalDeaths)
```

    ## [1] 0.9308892

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
ggplot(data=newCovidSummary, aes(x=RiskStatus)) +
  geom_bar(aes(fill = as.factor(TotalDeathRateStatus))) + labs(x = " Risk Status", title = "Bar plot of Risk status in 192 countries") + theme(axis.text.x = element_text(angle = 45, hjust=1)) + scale_fill_discrete(name = "DeathRate Status")
```

![](README_files/figure-gfm/unnamed-chunk-22-1.png)<!-- -->

``` r
ggplot(data=newcolumnData1, aes(x=RiskStatus)) +
  geom_bar(aes(fill = as.factor(DeathRateStatus))) + labs(x = " Risk Status", title = "Bar plot of Risk status in 52 states in the U.S") + theme(axis.text.x = element_text(angle = 45, hjust=1)) + scale_fill_discrete(name = "DeathRate Status")
```

![](README_files/figure-gfm/unnamed-chunk-23-1.png)<!-- -->

``` r
# Bar plot
top_country<- newCovidSummary %>% arrange(desc(TotalConfirmed))
top_10_country <- top_country[1:10,]

ggplot(data=top_10_country, aes(x=Country, y=TotalConfirmed)) +
  geom_bar(stat="identity", fill="yellowgreen") + geom_text(aes(label=TotalConfirmed), vjust=1.6, color="black", size=3.5) + theme(axis.text.x = element_text(angle = 45, hjust=1)) + labs(x = "Country", title = "Top 10 countries on Total Confirmed case")
```

![](README_files/figure-gfm/unnamed-chunk-24-1.png)<!-- -->

``` r
# Bar plot
top_country<- newCovidSummary %>% arrange(desc(NewDeaths))
top_10_country <- top_country[1:10,]

ggplot(data=top_10_country, aes(x=Country, y=NewDeaths)) +
  geom_bar(stat="identity", fill="orange") +
  labs(x = "Country", title = "Top 10 countries on newDeath case") + geom_text(aes(label=NewDeaths), vjust=1.6, color="black", size=3.5) +
  theme(axis.text.x = element_text(angle = 45, hjust=1))
```

![](README_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

``` r
# Bar plot
top_city_09_30_2021 <- nc_stateData %>% filter(Date == "2021-09-30T00:00:00Z") %>% arrange(desc(Cases))
top_10_city_09_30_2021 <- top_city_09_30_2021[1:10,]

ggplot(data=top_10_city_09_30_2021, aes(x=City, y=Cases)) +
  geom_bar(stat="identity", fill="steelblue") + geom_text(aes(label=Cases), vjust=1.6, color="white", size=3.5) +
  theme(axis.text.x = element_text(angle = 45, hjust=1)) + labs(x = "NC CITY", title = "Top 10 City in North Carolina on Confirmed case")
```

![](README_files/figure-gfm/unnamed-chunk-26-1.png)<!-- -->

geom\_text(aes(label=Cases), vjust=1.6, color=“white”, size=3.5)+
stat=“identity”, theme\_minimal()

-   ggtitle(“Top 10 North Carolina Cities Confirmed Covid Cases on
    September 30, 2020.”) stateCases

# Histogram

``` r
top_country<- newCovidSummary %>% arrange(desc(TotalConfirmed))
top_20_country <- top_country[1:20,]
```

``` r
ggplot(newCovidSummary, aes(x=NewDeaths)) + geom_histogram(color="orange2", fill="red", size = 1, binwidth=100)+geom_vline(aes(xintercept=mean(NewDeaths)),color="blue", linetype="dashed", size=1) + labs(x = "New Death Case", title = "Histogram of new death cases today: 192 countries")
```

![](README_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

``` r
#Blue line is the mean line.
```

``` r
# Histogram
ggplot(top_city_09_30_2021, aes(x=Cases)) + geom_histogram(color="darkblue",fill="red",binwidth=1000)+geom_vline(aes(xintercept=mean(Cases)),color="blue", linetype="dashed", size=1)+ggtitle("Histogram of Confirmed Cases in North Carolina Cities on September 30, 2021")
```

![](README_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

``` r
#Blue line is the mean line.
```

``` r
# Box plot
us_subset <- usConfirmed %>% select(Country, Cases,Status)
in_subset <- indiaConfirmed %>% select(Country, Cases,Status)
us_in <- rbind(us_subset, in_subset)

boxplot(Cases~Country,data=us_in, main="United States and India Covid Cases Comparison using Box plot",xlab="Country", ylab="Cases",col=(c("gold","darkgreen")))
```

![](README_files/figure-gfm/unnamed-chunk-30-1.png)<!-- -->

``` r
uscaselive <- us_liveCases  %>% 
  select(Country, Province, Active, Date) 
incaselive <- in_liveCase %>%
  select(Country, Province, Active, Date)
uslive_inlive <- rbind(uscaselive, incaselive )

boxplot(Active~Country,data=uslive_inlive, main="United States and India Covid live Cases Comparison using Box plot",xlab="Country", ylab="Active",col=(c("gold","darkgreen")))
```

![](README_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

``` r
# Box plot
Summary_world <- newCovidSummary %>% select(Country, TotalConfirmed, RiskStatus)

boxplot(TotalConfirmed~RiskStatus,data=Summary_world, main="World Covid Cases Box plot",
   xlab="RiskStatus", ylab="TotalConfirmed",col=(c("darkgreen")))
```

![](README_files/figure-gfm/unnamed-chunk-32-1.png)<!-- -->

``` r
# Scatter plot
covid_cases_by_states2 <- nc_stateData

covid_cases_by_states2 <- aggregate(list(Cases=covid_cases_by_states2$Cases),
                              by=list(Date=cut(as.POSIXct(covid_cases_by_states2$Date),"month")),sum)

ggplot(data = covid_cases_by_states2, aes(x = Date, y = Cases))+
  geom_point() + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of Confirmed Covid Cases in North Carolina Cities from November 2020 to September 2021") 
```

![](README_files/figure-gfm/unnamed-chunk-33-1.png)<!-- -->

``` r
# Scatter plot country summary
ggplot(data = newCovidSummary, aes(x = TotalConfirmed, y = TotalDeaths))+
  geom_point() + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of Confirmed Covid Cases by Death Covid Cases") + geom_smooth(method = lm, color = "blue")  
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/unnamed-chunk-34-1.png)<!-- -->

# Scatter plot - U.S. live case

us\_covid\_cases &lt;- liveCase

us\_covid\_cases &lt;- aggregate((activeCases =
liveCase*A**c**t**i**v**e*), *b**y* = *l**i**s**t*(*D**a**t**e* = *c**u**t*(*a**s*.*P**O**S**I**X**c**t*(*l**i**v**e**C**a**s**e*Date),
“month”)), sum)

us\_covid\_cases

stateCovidCase &lt;- stateCases stateCovidCase &lt;-
aggregate(stateCovidCase$Cases by = list()
