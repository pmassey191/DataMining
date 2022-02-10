library(tidyverse)
library(gt)

# Reading in data
Barley_price <- read.csv("~/Files for Applicant/Barley_price.csv")
barley_production <- read.csv("~Files for Applicant/Barley_production.csv")


# Section 3: Data Exploration

# Cleaning data and converting Value to numeric
# to be used in following functions
prod = barley_production%>%
  group_by(Year,State)%>%
  select(Value)%>%
  mutate(Value = as.numeric(gsub(",","",Value)))

pric = Barley_price%>%
  group_by(Year,State)%>%
  mutate(Price = as.numeric(gsub(",","",Value)))%>%
  select(Price)

# Sums total production across different regions
# to get a statewide total for each year
state_prod = aggregate(prod$Value,
                       by = list(State = prod$State, Year=prod$Year),
                       FUN=sum)



# 3.1 Time Series Plot

# Summing over years to get total production for each year
year_prod = aggregate(state_prod$x,
                      by = list(Year = state_prod$Year), FUN=sum)


# Joining our data frames for price and production, cleaning the
# column name as well
total_prod_pric = state_prod%>%
  full_join(pric)%>%
  mutate(Prod = x)%>%
  select(State, Year, Price, Prod)

# Joining previous data frame with the full year production in order
# to calculate each state's share of the weighted average per year
total_prod_pric = total_prod_pric%>%
  full_join(year_prod)%>%
  mutate(Total_Prod=x)%>%
  select(State, Year, Price, Prod, Total_Prod)%>%
  mutate(w_avg = Prod*Price/Total_Prod)


# Aggregating to find weighted average for each year
wavg_year = aggregate(total_prod_pric$w_avg,
                      by = list(Year = total_prod_pric$Year),
                      FUN=sum, na.rm=TRUE)

# Plotting our data
ggplot(wavg_year)+
  geom_line(aes(x = Year,y = x), color = 'dark green',size = 1.25)+
  ylab('Weighted Average')+
  labs(title = 'Weighted Average of Price \n over years 1990-2017')


# 3.2 Summary Table:

# Creating vector of the states of interest
state_id = c('IDAHO','MINNESOTA','MONTANA','NORTH DAKOTA','WYOMING')

# This chunk filters out the production data for the states of interest
# and also adds a column to identify the decade for each year
prod_state_id = state_prod%>%
  filter(State %in% state_id)%>%
  mutate(Prod = x/1000000)%>%
  select(State,Year,Prod)%>%
  mutate(decade = case_when(Year >= 1990 & Year <= 1999 ~ 1,
                            Year >= 2000 & Year <= 2009 ~ 2,
                            Year >= 2010 ~ 3,
                            TRUE ~ 0))

# Aggregating over all the years and calculating the mean to return
# a single average for each state in each decade
prod_state_id_ = aggregate(prod_state_id$Prod
                 , by=list(Decade=prod_state_id$decade
                           ,State=prod_state_id$State),
                 FUN=mean, na.rm=TRUE)

# Creating decade specific vectors of mean values to use in
# summary table output
decade_90s = prod_state_id_[seq(1,nrow(prod_state_id_),3),3] 
decade_00s = prod_state_id_[seq(2,nrow(prod_state_id_),3),3]
decade_10s = prod_state_id_[seq(3,nrow(prod_state_id_),3),3] 

# Creating data frame with the desired information for the 
# summary table
dat_tab = data.frame(state_id,decade_90s,decade_00s,decade_10s)

# Creating summary table
dat_tab%>%
  gt()%>%
  tab_header(title = 'Average Production by State and Decade',
             subtitle = 'Millions of Bushels')%>%
  tab_spanner(label = 'Decades',
              columns = c(decade_90s,decade_00s,
                          decade_10s))%>%
  fmt_engineering(columns = c(decade_90s,decade_00s,decade_10s),
                  decimals = 3)%>%
  cols_label(decade_90s = '1990-1999',
             decade_00s = '2000-2009',
             decade_10s = '2010-2017',
             state_id = 'State')
  
# 4.4 Regression

# Preparing data frame for regression
full_data = prod%>%
  full_join(pric)%>%
  mutate(ln_prod = log(Value),ln_price = log(Price))%>%
  mutate(Year = as.factor(Year),State = as.factor(State))


# Regression commands, note that State and Year are factors,
# the lm() function knows to automatically create dummy variables
lm1 = lm(ln_prod ~ ln_price + State + Year, 
   data = full_data, x=TRUE)
summary(lm1)
