covid-vignette-api
================
Min-Jung Jung
9/20/2021

-   [Reqired pakages](#reqired-pakages)
-   [JSON Data](#json-data)
-   [Packages used for reading JSON data in
    R](#packages-used-for-reading-json-data-in-r)
-   [Contact the Covid Data API](#contact-the-covid-data-api)
-   [Base url](#base-url)
    -   [country name](#country-name)
    -   [Summary data](#summary-data)
    -   [confirmed cases](#confirmed-cases)
-   [Death cases](#death-cases)
-   [Recovered cases](#recovered-cases)
    -   [Us confirmed cases by state](#us-confirmed-cases-by-state)
    -   [Us Death cases by state](#us-death-cases-by-state)
    -   [live cases by country](#live-cases-by-country)
    -   [Date manipulation](#date-manipulation)
-   [Exploratory Data Analysis](#exploratory-data-analysis)
    -   [Contigency Tables](#contigency-tables)
    -   [Numerical Summaries](#numerical-summaries)
    -   [Graphical Summaries](#graphical-summaries)

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

# Base url

``` r
base_url = "https://api.covid19api.com"
```

## country name

\#This helper function is to generate data.frame of country name and
Slug.

``` r
country_Name <- function(){
  country <- GET("https://api.covid19api.com/countries")
  countrylist <- fromJSON(rawToChar(country$content))
  countrylist1 <- as_tibble(data.frame(Country = countrylist$Country, Slug = countrylist$Slug))
  return(countrylist1)
}

countryName <- country_Name()
```

## Summary data

\#This function interacts with the `Summary` endpoint.

``` r
covid_summary_cases <- function(){
   full_url = paste0(base_url,"/summary")
   covid_summary_text <- content(GET(url=full_url),"text")
   covid_cases_summary_json <- fromJSON(covid_summary_text)
   covid_cases_summary1 <- data.frame(covid_cases_summary_json$Countries) 
   return(covid_cases_summary1)
}

covidSum <- covid_summary_cases()
```

## confirmed cases

\#This function interacts with the `By Country Total` endpoint.

``` r
get_confirmed_cases <- function(country){
     if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/confirmed?from=2020-07-01T00:00:00Z&to=2021-09-30T00:00:00Z")
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

confirmed_cases <- get_confirmed_cases("united-states")
```

# Death cases

\#This function interacts with the `By Country Total` endpoint with
status changed to deaths.

``` r
get_deaths_cases <- function(country){
    if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/",country,"/status/deaths?from=2020-07-01T00:00:00Z&to=2021-09-30T00:00:00Z")
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
death_cases <- get_deaths_cases("united-states")
```

# Recovered cases

\#This function interacts with the `By Country Total` endpoint with
status changed to recovered.

``` r
get_recovered_cases <- function(country){
  if(country %in% countryName$Slug){
  full_url = paste0(base_url,"/total/country/", country,"/status/recovered?from=2020-07-01T00:00:00Z&to=2021-09-30T00:00:00Z")
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
recovered_cases <- get_recovered_cases("united-states")
```

``` r
us_all_cases <- rbind(confirmed_cases, death_cases)
```

## Us confirmed cases by state

\#This function interacts with the `Day One Live` endpoint with status
changed to confirmed

``` r
confirmed_cases_bystate <- function(state_name){
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

nc_confirmedData <- confirmed_cases_bystate("North Carolina")
nc_confirmedData1 <- nc_confirmedData %>% filter(row_number() <= n()-1)
```

## Us Death cases by state

\#This function interacts with the `Day One Live` endpoint with status
changed to deaths.

``` r
deaths_cases_bystate <- function(state_name){
  state_name <- tolower(state_name)
  two_word_states = list("new hampshire", "new jersey", "new mexico","new york","north carolina","north dakota","south carolina","south dakota", "distrct of columbia", "puerto rico","Northern Mariana Islands", "Virgin Islands", "Rhode Island")
  if (state_name %in% two_word_states){
     full_url = paste0(base_url,"/dayone/country/united-states/status/deaths/live?province=",state_name)
     URLencode(full_url)
    covid_cases_by_states_text = content(GET(url=URLencode(full_url)),"text")
    covid_cases_by_states_json = fromJSON(covid_cases_by_states_text)
  }
    else{
    full_url = paste0(base_url,"/dayone/country/united-states/status/deaths/live?province=",state_name)
    covid_cases_by_states_text = content(GET(url=full_url),"text")
    covid_cases_by_states_json = fromJSON(covid_cases_by_states_text)
    }
     covid_cases_by_states <- covid_cases_by_states_json %>% select(Country, Province, City, Cases, Status, Date) 
  return(covid_cases_by_states)
}

nc_deathData <- deaths_cases_bystate("North Carolina")
nc_deathData1 <- nc_deathData %>% filter(row_number() <= n()-1)
```

``` r
nc_all_cases <- rbind(nc_confirmedData1, nc_deathData1)
```

## live cases by country

endpoint `Live By Country And Status After Date`

``` r
live_cases <- function(country){
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

us_liveCases <- live_cases("united-states")
```

## Date manipulation

\#This function helps to manipulate date column to date formation and
create one variable with time span by quater.

``` r
get_date_case <- function(dataset){
dataset$Date <- as.Date(dataset$Date)
dataset <- dataset %>% 
                  mutate("Time_span" = if_else(Date <= as.Date("2020-09-30"), "2020Q3",
                                        if_else(Date <= as.Date("2020-12-31"), "2020Q4",
                                          if_else(Date <= as.Date("2021-03-31"), "2021Q1", 
                                            if_else(Date <= as.Date("2021-06-30"), "2021Q2", 
                                              if_else(Date <= as.Date("2021-09-30"),"2021Q3","2021Q4")))))
                         )

                  dataset$Time_span <- as.factor(dataset$Time_span)
  return(dataset)
}              

confirmed_month <- get_date_case(confirmed_cases)

us_all_cases_month <- get_date_case(us_all_cases)

nc_all_cases_month<- get_date_case(nc_all_cases)
```

``` r
#As of July 28,2020 CDC covid case map
#https://twitter.com/cdcgov/status/1288609081696169990

#we can create a function that will manipulate our data to prepare for data summaries and visualization
usRiskyData <- function(dataset){
  dataset <- dataset %>% 
            mutate("DeathRate"= (Deaths/Confirmed)*100, 
                   "DeathRateStatus"= if_else(DeathRate > 2, "4.High",
                                  if_else(DeathRate > 1, "3.Medium", 
                                          if_else(DeathRate >0.5, "2.Low", "1.Very low"))), 
                   "RiskStatus" = if_else(Confirmed > 1250000, "5.Veryhigh",
                                    if_else(Confirmed > 750000, "4.High", 
                                      if_else(Confirmed > 350000, "3.Medium", 
                                        if_else(Confirmed > 150000, "2.Low", "1.Very Low"))))
                                  )            
  return(dataset)
}
```

``` r
#need to change the name of file later.
us_newlive <- us_liveCases %>% filter(Date == "2021-10-01T00:00:00Z")

us_newlive_risk <- usRiskyData(us_newlive) %>% as_tibble()
us_live_risk <- get_date_case(us_newlive_risk)
```

# Exploratory Data Analysis

## Contigency Tables

``` r
# Contingency table 
#United Status
usDeathRate_status <- table(us_live_risk$RiskStatus, us_live_risk$DeathRateStatus)
usDeathRate_status
```

    ##             
    ##              2.Low 3.Medium 4.High
    ##   1.Very Low     4        9      0
    ##   2.Low          1        7      0
    ##   3.Medium       1       12      1
    ##   4.High         0        9      2
    ##   5.Veryhigh     0        7      2

``` r
us_live_risk1 <- us_live_risk %>% arrange(desc(Confirmed))
us_live_risk2 <- us_live_risk1[1:10,]

state_deathrate <- table(us_live_risk2$Province, us_live_risk2$DeathRateStatus)
state_deathrate
```

    ##                 
    ##                  3.Medium 4.High
    ##   California            1      0
    ##   Florida               1      0
    ##   Georgia               1      0
    ##   Illinois              1      0
    ##   New York              0      1
    ##   North Carolina        1      0
    ##   Ohio                  1      0
    ##   Pennsylvania          0      1
    ##   Tennessee             1      0
    ##   Texas                 1      0

## Numerical Summaries

``` r
#summary table
summary_us_state <- us_live_risk %>% summarise(Min = min(Confirmed), Max = max(Confirmed), Avg = mean(Confirmed), Med = median(Confirmed), IQR = IQR(Confirmed), Var = var(Confirmed))
summary_us_state
```

    ## # A tibble: 1 x 6
    ##     Min     Max     Avg    Med    IQR           Var
    ##   <int>   <int>   <dbl>  <int>  <dbl>         <dbl>
    ## 1   269 4718816 790137. 508494 753095 922760829412.

``` r
Summary_us_all <- us_all_cases_month %>% group_by(Status) %>% summarise(Avg = mean(Cases), Med = median(Cases), IQR = IQR(Cases), Var = var(Cases)) 

Summary_us_all
```

    ## # A tibble: 2 x 5
    ##   Status          Avg      Med      IQR     Var
    ##   <chr>         <dbl>    <int>    <dbl>   <dbl>
    ## 1 confirmed 22878859. 27762171 24926891 1.60e14
    ## 2 deaths      423587.   487599   373278 3.45e10

``` r
Summary_nc_all <- nc_all_cases_month %>% group_by(City) %>% summarise(Avg = mean(Cases), Med = median(Cases), IQR = IQR(Cases), Var = var(Cases)) 
Summary_nc_all
```

    ## # A tibble: 101 x 5
    ##    City        Avg   Med    IQR       Var
    ##    <chr>     <dbl> <dbl>  <dbl>     <dbl>
    ##  1 Alamance  8490. 3462  17467. 77628520.
    ##  2 Alexander 2067.  783   4240.  4519739.
    ##  3 Alleghany  487.  190    999    265211.
    ##  4 Anson     1210.  470   2464.  1551427.
    ##  5 Ashe      1020.  378   2028.  1124366.
    ##  6 Avery      977.  448.  2070.   997500.
    ##  7 Beaufort  2194.  872.  4417   5086720.
    ##  8 Bertie     857.  450   1700.   722017.
    ##  9 Bladen    1621.  678.  3168.  2969086.
    ## 10 Brunswick 4362. 1492   8826. 22190292.
    ## # ... with 91 more rows

``` r
Summary_us_risk <- us_live_risk %>% group_by(RiskStatus) %>% summarise(Avg = mean(Confirmed), Med = median(Confirmed), IQR = IQR(Confirmed), Var = var(Confirmed)) 

Summary_us_risk
```

    ## # A tibble: 5 x 5
    ##   RiskStatus      Avg      Med      IQR     Var
    ##   <chr>         <dbl>    <dbl>    <dbl>   <dbl>
    ## 1 1.Very Low   78554.   89989    86058  2.60e 9
    ## 2 2.Low       231486.  246742.   80623. 3.52e 9
    ## 3 3.Medium    556041.  520417   206788. 1.48e10
    ## 4 4.High      959810.  866776   303044  2.72e10
    ## 5 5.Veryhigh 2471329. 1627508  2152867  1.71e12

``` r
Summary_us_DR <- us_live_risk %>% group_by(DeathRateStatus) %>% summarise(Avg = mean(Confirmed), Med = median(Confirmed), Var = var(Confirmed), IQR = IQR(Confirmed))
Summary_us_DR
```

    ## # A tibble: 3 x 5
    ##   DeathRateStatus      Avg      Med     Var     IQR
    ##   <chr>              <dbl>    <dbl>   <dbl>   <dbl>
    ## 1 2.Low            167124.   96936. 3.65e10 183455 
    ## 2 3.Medium         823666   573052. 1.02e12 711804.
    ## 3 4.High          1242698. 1154570  5.89e11 617989

``` r
summary_us_deathRate <- us_live_risk %>% group_by(DeathRateStatus) %>% summarise(Avg = mean(DeathRate), Med = median(DeathRate), Var = var(DeathRate), IQR = IQR(DeathRate))
summary_us_deathRate
```

    ## # A tibble: 3 x 5
    ##   DeathRateStatus   Avg   Med    Var    IQR
    ##   <chr>           <dbl> <dbl>  <dbl>  <dbl>
    ## 1 2.Low           0.777 0.827 0.0411 0.316 
    ## 2 3.Medium        1.48  1.47  0.0747 0.426 
    ## 3 4.High          2.24  2.28  0.0144 0.0835

``` r
cor(us_live_risk$Confirmed, us_live_risk$Deaths)
```

    ## [1] 0.975353

``` r
cov(us_live_risk$Confirmed, us_live_risk$Deaths)
```

    ## [1] 14895461139

## Graphical Summaries

``` r
#Scatter plot country summary
ggplot(data = confirmed_month, aes(x = Date, y = Cases))+
  geom_point() + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of Confirmed Covid Cases by Confirmed Covid Cases") + geom_smooth(method = lm, color = "blue")  
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/unnamed-chunk-23-1.png)<!-- -->

``` r
#Bar plot
top_states<- nc_all_cases_month %>% filter(Status == "confirmed") %>% filter(Date == "2021-10-01") %>% arrange(desc(Cases))
top_10counties <- top_states[1:10,]

ggplot(data=top_10counties, aes(x=City, y=Cases)) +
  geom_bar(stat="identity", fill="orange") +
  labs(x = "City", title = "Top 10 Counties on Confirmed case") + geom_text(aes(label=Cases), vjust=1.6, color="black", size=3.5) +
  theme(axis.text.x = element_text(angle = 45, hjust=1))
```

![](README_files/figure-gfm/unnamed-chunk-24-1.png)<!-- -->

``` r
#Bar plot

ggplot(data = us_live_risk, aes(x=RiskStatus)) +
  geom_bar(aes(fill = as.factor(DeathRateStatus))) + labs(x = " Risk Status", title = "Bar plot of Risk status in 55 states") + theme(axis.text.x = element_text(angle = 45, hjust=1)) + scale_fill_discrete(name = "DeathRate Status")
```

![](README_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

``` r
# Scatter plot 

ggplot(data = us_all_cases_month, aes(x = Date, y = Cases))+
  geom_point() + facet_wrap(~ Status) + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of U.S. Cases by date") + geom_smooth(method = lm, color = "blue")  
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/unnamed-chunk-26-1.png)<!-- -->

``` r
# Scatter plot county
Wake_cases <- nc_all_cases_month %>% filter(City=="Wake") 
Mecklenburg_cases <- nc_all_cases_month %>% filter(City=="Mecklenburg") 
ncst_cases <- nc_all_cases_month %>% filter(Date == "2021-10-01") %>% arrange(desc(Cases))

top10_ncst_cases <- ncst_cases[1:10,]
# Scatter plot nc state summary
ggplot(data = Wake_cases, aes(x = Date, y = Cases))+
  geom_point() + facet_wrap(~ Status) + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of  Wake county Cases by date") + geom_smooth(method = lm, color = "blue")  
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/unnamed-chunk-27-1.png)<!-- -->

``` r
ggplot(data = Mecklenburg_cases, aes(x = Date, y = Cases))+
  geom_point() + facet_wrap(~ Status) + theme(axis.text.x = element_text(angle = 45,hjust=1)) + 
  ggtitle("Scatterplot of  Mecklenburg county Cases by date") + geom_smooth(method = lm, color = "blue") 
```

    ## `geom_smooth()` using formula 'y ~ x'

![](README_files/figure-gfm/unnamed-chunk-27-2.png)<!-- -->

``` r
# Box plot
us_confirmed_states<- us_all_cases_month %>% filter(Status == "confirmed") 


boxplot(Cases~Time_span,data=us_confirmed_states, main="Us Covid confirmed Cases Comparison by Time span using Box plot",xlab="Timespan", ylab="Cases",col=(c("blue","orange","green","gold","purple")))
```

![](README_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

``` r
us_deaths_states<- us_all_cases_month %>% filter(Status == "deaths") 


boxplot(Cases~Time_span,data=us_deaths_states, main="Us Covid death Cases Comparison by Time span using Box plot",xlab="Timespan", ylab="Cases",col=(c("blue","orange","green","gold","purple")))
```

![](README_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

``` r
# Box plot


boxplot(Cases~Status,data=us_all_cases_month, main="Us Covid Cases Comparison by Status using Box plot",xlab="Status", ylab="Cases",col=(c("gold","darkgreen")))
```

![](README_files/figure-gfm/unnamed-chunk-30-1.png)<!-- -->

``` r
# Histogram plot

#need to change title and name of the x axis

ncst_confirmed_cases <- nc_all_cases_month %>% filter(Status == "confirmed") %>% filter(City == "Wake")
ncst_deaths_cases <- nc_all_cases_month %>% filter(Status == "deaths") %>% filter(City == "Wake")

ggplot(ncst_confirmed_cases, aes(Cases)) + geom_histogram(color = "blue", fill = "lightblue")
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](README_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

``` r
ggplot(ncst_deaths_cases, aes(Cases)) + geom_histogram(color = "blue", fill = "lightblue")
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](README_files/figure-gfm/unnamed-chunk-31-2.png)<!-- -->

``` r
#boxplot(Cases~City,data=ncst_confirmed_cases, main="Us Covid Cases Comparison by City using Box plot",xlab="City", ylab="Cases",col=(c("gold","darkgreen")))
```
