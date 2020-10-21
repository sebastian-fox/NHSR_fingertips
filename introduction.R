
# Libraries ---------------------------------------------------------------

if (!require(fingertipscharts)) install.packages("fingertipscharts")
if (!require(dplyr)) install.packages("dplyr")

# Note, fingertipsR is not on CRAN and won't be for the foreseeable future
if (!require(fingertipsR)) install.packages("fingertipsR", repos = "https://dev.ropensci.org")


# Starting at the end: fingertips_data() ----------------------------------
# The minimum requirement for fingertips_data is IndicatorID and AreaTypeID

## Run the following lines
## (hint: you can move your cursor to the line of code you want to execute, and press Ctrl + Shift + Enter to run it)
df <- fingertips_data(IndicatorID = 90356,
                      AreaTypeID = 202)
View(df)

## Question: do the number of records make sense to you? (for info, there are 151 local authorities and 9 Regions)
table(df$Timeperiod, df$AreaType)



# How to get the IndicatorID value ----------------------------------------
# There are 3 ways to help users find IndicatorID
# 1. Go to the indicator definition on Fingertips website: https://fingertips.phe.org.uk/profile/cancerservices/data#page/6/gid/1938132830/pat/166/par/E38000231/ati/7/are/J83035/iid/91342/age/266/sex/4/cid/4/page-options/ovw-do-0
# 2. Use the select_indicators() function and choose it interactively
# 3. Use the indicators() function and choose it programmatically

## Go to the fingertips website and navigate to;
## Child and Maternal Health --> Start --> Click Low Birth Weight of Term Babies --> Click Definitions


## Execute the select_indicators() function and locate the Low Birth Weight of Term Babies indicator using the search feature (then click Done)
select_indicators()

## If confident with filtering data, use the indicators() function to subset the dataset for the IndicatorID you've just discovered
indicators() %>% 
        filter(IndicatorID == 20101)



# How to get AreaTypeID ---------------------------------------------------
# DANGER! Not all indicators have all AreaTypeIDs!
# There is an area_types() function which provides the codes available for AreaTypeID

## Try the area_types() function and view the results
area_types() %>% 
        View()

# So how do you know what AreaTypeIDs are available for an indicator
# There are 2 ways:
# 1. Through the website
# 2. indicator_areatypes() function

## Go to the fingertips website, where you were for Low Birth Weight of Term Babies and click on Trends: https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/4/gid/1938133228/pat/6/par/E12000009/ati/102/are/E06000053/iid/20101/age/235/sex/4/cid/4/page-options/ovw-do-0_car-do-0
## Try clicking on each of the different options in the Area type dropdown - notice, not all of them are available



## Now try using the indicator_areatypes() function and seeing what other area types are available for that indicator
indicator_areatypes(IndicatorID = 20101) %>% 
        left_join(area_types(), by = "AreaTypeID") %>%
        distinct(IndicatorID, AreaTypeID, AreaTypeName) %>% 
        View()

