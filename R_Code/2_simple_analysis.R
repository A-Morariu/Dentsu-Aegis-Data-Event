### SIMPLE ANALYSIS FILE ###
source("1_data_cleaning.R")

### Price of cannabis 

head(can_prices)

producer_consumer_price_plot <- can_prices %>% 
     ggplot(aes(x = year, y = price)) +
     geom_point(aes(color = region)) + 
     geom_smooth(method = "loess", aes(color = region), se = FALSE) + 
     geom_vline(xintercept = 2017.9) +
     facet_wrap(~ type) + 
     theme_minimal()
     
producer_consumer_price_plot
ggsave("producer_consumer_price_plot.jpg")

### Supply of cannabis

head(can_supply)

cannabis_production_plot <- can_supply %>% 
     filter(purpose %in% c("Domestic production",
                           "Inventories",
                           "Total supply",
                           "Total use")) %>% 
     ggplot(aes(x = year, y = value)) + 
          geom_point(aes(color = type)) + 
          geom_smooth(method = "loess", aes(color = type), se = FALSE) +
          geom_vline(xintercept = 2017.9) +
          facet_wrap( ~purpose, scale="free_y")+
          ggtitle("Cannabis Production on Annual Basis") + 
          labs(subtitle = "*Data from StatsCan **2019 production not released") +
          xlab("Year") + 
          ylab("Value (x1,000,000 CAD)") +
          theme_minimal()

cannabis_production_plot
ggsave("cannabis_production_plot.jpg")
