### DATA CLEANING ### 

setwd("~/Documents/GitHub/Dentsu-Aegis-Data-Event") # change as needed

library(tidyverse) # data management and visualization

# Bayesian inference 
library(parallel)
library(rstan)
library(readxl)

# save local directory with name of file you want to load;  change as needed
data_location_2018 <- "~/Documents/GitHub/Dentsu-Aegis-Data-Event/Cannabis_Data/Cannabis2018.xlsx"
data_location_2019 <- "~/Documents/GitHub/Dentsu-Aegis-Data-Event/Cannabis_Data/Cannabis2019.xlsx"

cannabis_2018 <- readxl::read_excel(data_location_2018)
cannabis_2019 <- readxl::read_excel(data_location_2019)

# preview 2018 
glimpse(cannabis_2018)

# preview 2019
glimpse(cannabis_2019)

# remove useless rows from top 
cannabis_2018 <- slice(cannabis_2018, 7:n())
cannabis_2019 <- slice(cannabis_2019, 7:n())
# rename columns 
new_names <- c("Category",
               "ResponseMetric",
               "Totals",
               "User",
               "NonUser",
               "PreBoomerUser",
               "PreBoomerNonUser",
               "BoomerUser",
               "BoomerNonUser",
               "GenXUser",
               "GenXNonUser",
               "MillUser",
               "MillNonUser",
               "GenZUser",
               "GenZNonUser")

colnames(cannabis_2018) <- new_names
colnames(cannabis_2019) <- new_names

directional_extraction <- function(cannabis_dataset, response = "RowCol"){
     # response has "%Row" or "%Col" pr "RowCol"
     if(response == "%Row"){
          extraction <- cannabis_dataset %>% 
               filter(ResponseMetric == "%Row") %>% 
               select(-Totals)     
     } else if(response == "%Col") {
          extraction <- cannabis_dataset %>% 
               filter(ResponseMetric == "%Col") %>% 
               select(-Totals)     
     } else if(response == "RowCol"){
             extraction <- cannabis_dataset %>% 
                     filter(ResponseMetric == "%Col" | ResponseMetric == "%Row") %>% 
                     select(-Totals) 
     }
     
     return(extraction)
}

### use the output of this without the first 3 columns and run a PCA 
### store them as a matrix and store column 1 as a vector in order to match the questions 

### Stats Can Price Data

can_prices <- read_csv("Cannabis_Data/stats_can_cannabis_prices.csv")

can_prices <- can_prices %>% 
        dplyr::select(year = REF_DATE, region = GEO, type = "Cannabis price", price = VALUE) 

### Stats Can Supply Data

can_supply <- read_csv("Cannabis_Data/stats_can_cannabis_supply.csv")

can_supply <- can_supply %>% dplyr::select(type = "Type of use", 
                                           purpose = Indicator,
                                           year = REF_DATE, 
                                           value = VALUE) 



