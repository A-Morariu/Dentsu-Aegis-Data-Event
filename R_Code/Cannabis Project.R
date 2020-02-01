library(ggplot2)
library(plyr)
setwd("/Users/ethanjohnson-skinner/Documents/R Files/Cannabis Project")

year_cost = read.csv("/Users/ethanjohnson-skinner/Documents/R Files/Cannabis Project/consumer_prices.csv", header = TRUE)
quater_consumption = read.csv("/Users/ethanjohnson-skinner/Documents/R Files/Cannabis Project/HouseHold_spend.csv", header = TRUE)
main_data = read.csv("/Users/ethanjohnson-skinner/Documents/GitHub/Dentsu-Aegis-Data-Event/Cannabis_Data/m2018_flat.csv", header = TRUE)


# Year cost 

attach(year_cost)

year_cost_filter <- year_cost[year_cost$GEO %in% c('Atlantic','Canada','Ontario','Prairies','Quebec','Territories'),]
year_cost_filter <- year_cost_filter[year_cost_filter$Characteristics == 'Non-medical purposes',]

ggplot(data = year_cost_filter,mapping = aes(x= REF_DATE, y=VALUE)) +
  geom_line(aes(color = GEO))

#Legal vs illegal cannbis prediction 

attach(quater_consumption)

quater_filter <- quater_consumption[quater_consumption$Estimates %in% c('Cannabis products for non-medical use (licensed)','Cannabis products for non-medical use (unlicensed)'),]
quater_filter[is.na(quater_filter)] <- 0
ggplot(data = quater_filter,mapping = aes(x= Quarter, y=VALUE)) +
  geom_line(aes(color = Estimates))

# fit linear model 

{
  attach(quater_filter)
  to_fit <- quater_filter[quater_filter$Estimates == 'Cannabis products for non-medical use (licensed)',]
  attach(to_fit)
  model <- lm(VALUE ~ I(log(Index)),to_fit)
  
  
  # Predict the old data
  old_data <- data.frame('Index'=c(1,2,3,4,5))
  p_olddata <- predict(model,old_data)
  # Predict the new data
  
  newdata <- data.frame('Index'=c(6,7,8,9,10))
  p_newdata <- predict.lm(model,newdata, type='response')

  }# Log fit for Licensed
{
attach(quater_filter)
to_fit1 <- quater_filter[quater_filter$Estimates == 'Cannabis products for non-medical use (unlicensed)',]
attach(to_fit1)
model1 <- lm(VALUE ~ I(log(Index)),to_fit1)


# Predict the old data
old_data1 <- data.frame('Index'=c(1,2,3,4,5))
p_olddata1 <- predict(model1,old_data1)
# Predict the new data

newdata1 <- data.frame('Index'=c(6,7,8,9,10))
p_newdata1 <- predict.lm(model1,newdata1, type='response')

} # fit for UnLicensed

# Ploting Old and new data
plot(x=c(old_data$Index,newdata$Index,old_data1$Index,newdata1$Index),
     y=c(p_olddata,p_newdata,p_olddata1,p_newdata1),
     col=c(rep("blue",length(p_olddata)),rep("green",length(p_olddata)),rep("red",length(p_olddata1)),rep("cyan",length(p_olddata1))),
     xlab="x",
     ylab="y")
lines(to_fit$Index,predict(model))


plot(to_fit$Index, to_fit$VALUE, pch = 16, cex = 1.3, col = "blue", main = "Cannabis products for non-medical use (licensed)", xlab = "Quarter", ylab = "CAD - Millions")
lines(to_fit$Index,predict(model))

# inelastic anaylsis https://rpubs.com/cyobero/elasticity

total <- to_fit$VALUE + to_fit1$VALUE

#Five data ponits from cost/gram data
to_fit_year <- dplyr::filter( year_cost,GEO == "Canada" , Characteristics == "Non-medical purposes")
to_fit_year$REF_DATE <- as.numeric(to_fit_year$REF_DATE)

newdat <- data.frame('REF_DATE'=c(2018,2019))
model <- lm(to_fit_year$VALUE ~ to_fit_year$REF_DATE)

diff <- (model$coefficients[2]*newdat + model$coefficients[1])
x <- c(2018.5,2018.75,2019,2019.25,2019.5)
y <- seq(from = diff$REF_DATE[1],to = diff$REF_DATE[2],by = ((diff$REF_DATE[2]-diff$REF_DATE[1])/4))

toplot <- data.frame('x'=total,'y'=y)

theme_set(theme_bw())

elastic_plot <- ggplot(data = toplot, aes(y = y, x = x))  + geom_point(col = 'blue') + geom_smooth(method = 'lm', col = 'red', size = 0.5) # fitted regression line
print(elastic_plot + labs(y="Sellng Price/Gram", x = "Total Consumption (legal & Illeagal) $Millons")  + ggtitle("Total Consumption (legal & Illeagal) $Millons vs Sellng Price/Gram"))
food.lm <- lm(toplot$y ~ toplot$x, data = toplot)
summary(food.lm)

food.lm$coefficients[2]*(mean(toplot$x)/mean(toplot$y))

# For an inelastic market we know demand is constant with price changes thefore focusing on high end more processed prodcuts 
# 










