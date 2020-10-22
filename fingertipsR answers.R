
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
# Note, it is always good to sense check the number of records if possible
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
# Notice how the indicator appears in multiple different profiles
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
# Notice there are many more AreaTypeIDs than the website offers. That's because this same indicator might be in a different profile/domain which has a different geographical focus
indicator_areatypes(IndicatorID = 20101) %>% 
        left_join(area_types(), by = "AreaTypeID") %>%
        distinct(IndicatorID, AreaTypeID, AreaTypeName) %>% 
        View()

# You now have enough information to get some data
## Using the fingertips_data() function, export data for Low Birth Weight of Term Babies for the geographical region Upper tier local authorities (post 4/20)
df <- fingertips_data(IndicatorID = 20101,
                      AreaTypeID = 302)

## What happens if you change the AreaTypeID to Sustainability and Transformation Footprints (use area_types() to find out the correct AreaTypeID)?
## Do you understand why you get the number of records that are returned?
df <- fingertips_data(IndicatorID = 20101,
                      AreaTypeID = 220)
nrow(df)

# fingertips_data has a ParentAreaTypeID argument. This exercise helps you understand what this is.
## Go to this url: https://fingertips.phe.org.uk/profile/public-health-outcomes-framework/data#page/0/gid/1000042/pat/6/par/E12000009/ati/102/are/E06000053/iid/90244/age/168/sex/4/cid/4/page-options/car-do-0_ovw-do-0
## Click the drop down for "Areas grouped by". See how that list changes when you select different "Area types"


## Now look at the outputs of the area_types() function again. You can see that each AreaTypeID maps to multiple ParentAreaTypeIDs
area_types() %>% 
        View()

## Execute this line of code and inspect the different AreaTypes that are in the data:
# Note, each indicator-area type combination has a default parent area type
df <- fingertips_data(IndicatorID = 91337,
                      AreaTypeID = 165) # CCGs unchanged plus new 2019
View(df)
table(df$AreaType)

## Now execute this code and compare the AreaTypes in what is returned:
df <- fingertips_data(IndicatorID = 91337,
                      AreaTypeID = 165, # CCGs unchanged plus new 2019
                      ParentAreaTypeID = 219) 
View(df)
table(df$AreaType)


