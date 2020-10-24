
# Libraries ---------------------------------------------------------------

if (!require(fingertipscharts)) install.packages("fingertipscharts")
if (!require(dplyr)) install.packages("dplyr")
if (!require(tidyr)) install.packages("tidyr")
if (!require(stringr)) install.packages("stringr")

# Note, fingertipsR is not on CRAN and won't be for the foreseeable future
if (!require(fingertipsR)) install.packages("fingertipsR", repos = "https://dev.ropensci.org")

# For this part of the workshop we'll use the Oral Health domain from the Child and Maternal Health profile
## Execute this code
df <- fingertips_data(DomainID = 1938133263,
                      AreaTypeID = 202)


# This workshop will work through the visualisations available on Fingertips
# All the function names available in fingertipscharts are identical to the name on the  Fingertips website

# To start with, we will use a function from fingertipsR to understand the order of the indicators in the overview and the area profiles visualisations
ind_order <- indicator_order(DomainID = 1938133263,
                             AreaTypeID = 202,
                             ParentAreaTypeID = 6) %>% 
        select(IndicatorID, Sequence)

indicator_levels <- df %>% 
        left_join(ind_order, by = "IndicatorID") %>% 
        distinct(IndicatorName, Sequence) %>% 
        arrange(Sequence) %>% # arrange in order of the sequence
        pull(IndicatorName)

# This is the order the indicators should be displayed
print(indicator_levels)

# Apply these levels to the IndicatorName field when turning it into a factor
df <- df %>% 
        mutate(IndicatorName = factor(IndicatorName,
                                      levels = indicator_levels))

# Overview (or tartan rug) ------------------------------------------------


parent <- "South West region"
fixed_areas <- c("England", parent)
df_overview <- df %>% 
        group_by(IndicatorID) %>% 
        filter((ParentName == parent | # keep all areas whose parent is "South West region"
                        AreaName %in% fixed_areas), # also keep "England" and "South West region"
               TimeperiodSortable == max(TimeperiodSortable)) %>% # keep the latest time period available for each indicator
        ungroup() %>% 
        mutate(Value = round(Value, 1))# round values to 1 decimal place

## Look at the documentation for the overview() function
?overview

# This example demonstrates the principle of how all of the fingertipscharts functions work
p <- overview(data = df_overview,
              area = AreaName,
              indicator = IndicatorName,
              value = Value,
              fill = ComparedtoEnglandvalueorpercentiles,
              timeperiod = Timeperiod,
              top_areas = fixed_areas,
              wrap_length = 35,
              legend_position = "bottom")
p
## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/0/gid/1938133263/pat/6/par/E12000009/ati/202/are/E06000022/cid/4/page-options/ovw-do-0

# Compare indicators ------------------------------------------------------

plot_data <- df %>% 
        group_by(IndicatorID) %>% 
        filter(IndicatorID %in% c(10101, 93563),
               TimeperiodSortable == max(TimeperiodSortable)) %>% 
        ungroup() %>% 
        select(IndicatorName, AreaCode, Value) %>% 
        pivot_wider(names_from = IndicatorName, # this function turns long data into wide data
                    values_from = Value) %>% 
        rename(Ind1 = `Percentage of 5 year olds with experience of visually obvious dental decay`,
               Ind2 = `Children in low income families (under 16s)`)
        
View(plot_data) # this is the data structure required for the compare_areas function

## complete x, y and area in the code below so that Ind1 is on the x axis and Ind2 is on the y axis
p <- compare_indicators(data = plot_data,
                        x = Ind1,
                        y = Ind2,
                        xlab = "Percentage of 5 year olds with experience of visually obvious dental decay",
                        ylab = "Children in low income families (under 16s)",
                        highlight_area = c("E92000001", "E08000012"),
                        area = AreaCode,
                        add_R2 = TRUE)
p

# Map ---------------------------------------------------------------------

map_data <- df %>% 
        group_by(IndicatorID) %>% 
        filter(IndicatorID == 10101,
               TimeperiodSortable == max(TimeperiodSortable)) %>% # keep the latest time period for the indicator
        ungroup() %>% 
        mutate(ComparedtoEnglandvalueorpercentiles = factor(ComparedtoEnglandvalueorpercentiles,
                                                            levels = c("Better", "Similar", "Worse", "Not compared"))) # make sure the order of the levels is correct

# Shape files are freely available at the open geography portal in the "Boundaries" section
## Go to this url: https://geoportal.statistics.gov.uk/
## Click Boundaries --> Administrative boundaries --> Counties and Unitary Authorities -->? 2019 boundaries
## Have a read of the descriptions of the available boundaries. Note that the difference is the resolution (which impacts the size of the file)
## Select one of the layers --> Select APIs (on the right) then copy the GEOjson url and paste it below. Compare it with the link already provided
new_ons_api <- "https://opendata.arcgis.com/datasets/b216b4c8a4e74f6fb692a1785255d777_0.geojson"
ons_api <- "https://opendata.arcgis.com/datasets/b216b4c8a4e74f6fb692a1785255d777_0.geojson"


## Complete area_code and fill in the map code below
# Note, I have written "fingertipscharts::" below because this forces the "map" function to come from the fingertipscharts package. There are a few common "map" functions available from other packages too
p <- fingertipscharts::map(data = map_data,
                           ons_api = ons_api,
                           area_code = AreaCode,
                           fill = ComparedtoEnglandvalueorpercentiles,
                           title = "Children in low income families (under 16s)",
                           subtitle = "Upper Tier Local Authorities in England",
                           copyright_year = 2019)

p

## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/8/gid/1938133263/pat/6/par/E12000009/ati/202/are/E06000022/iid/10101/age/169/sex/4/cid/4/page-options/ovw-do-0_cin-ci-4_map-ao-4

## Complete area_code, fill, value, name_for_label
p <- map(data = map_data,
         ons_api = ons_api,
         area_code = AreaCode,
         fill = ComparedtoEnglandvalueorpercentiles,
         type = "interactive",
         value = Value,
         name_for_label = AreaName,
         title = "Children in low income families (under 16s)")

p



# Trends ------------------------------------------------------------------

df_trend <- df %>%
        filter(IndicatorID == 10101)

## Complete timeperiod, value, area, fill, lowerci, upperci
p <- trends(data = df_trend,
            timeperiod = Timeperiod,
            value = Value,
            area = AreaCode,
            comparator = "E92000001",
            area_name = "E08000010",
            fill = ComparedtoEnglandvalueorpercentiles,
            lowerci = LowerCI95.0limit,
            upperci = UpperCI95.0limit,
            title = "Trend of Children in low income families (under 16s)\ncompared to England",
            subtitle = "Wigan",
            xlab = "Year",
            ylab = "Percent (%)")
p

## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/4/gid/1938133263/pat/6/par/E12000002/ati/202/are/E08000010/iid/10101/age/169/sex/4/cid/4/page-options/ovw-do-0_cin-ci-4


# Compare areas -----------------------------------------------------------

parent <- "South West region"
fixed_areas <- c("England", parent)
ordered_levels <- c("Better",
                    "Similar",
                    "Worse",
                    "Not compared")
df_ca <- df %>%
        group_by(IndicatorID) %>% 
        filter(IndicatorID == 93563,
               (AreaName %in% fixed_areas |
                        ParentName == parent),
               TimeperiodSortable == max(TimeperiodSortable)) %>% 
        ungroup()

## Complete the arguments for area, value, fill, lowerci, upperci
p <- compare_areas(data = df_ca, 
                   area = AreaName, 
                   value = Value,
                   fill = ComparedtoEnglandvalueorpercentiles,
                   lowerci = LowerCI95.0limit,
                   upperci = UpperCI95.0limit,
                   order = "desc",
                   top_areas = fixed_areas,
                   title = "Percentage of 5 year olds with experience of visually obvious dental decay")
p
## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/3/gid/1938133263/pat/6/par/E12000009/ati/202/are/E06000022/iid/93563/age/34/sex/4/cid/4/page-options/ovw-do-0_cin-ci-4_car-do-0


# Population --------------------------------------------------------------
pop_data <- fingertips_data(IndicatorID = 92708,
                            AreaTypeID = 302)

pops <- pop_data %>% 
        filter(Age != "All ages",
               Sex %in% c("Male", "Female"),
               AreaName %in% c("England", "South East region", "Southampton")) %>% 
        mutate(Age = factor(Age, 
                            levels = c("0-4 yrs", "5-9 yrs", "10-14 yrs", 
                                       "15-19 yrs", "20-24 yrs", "25-29 yrs",
                                       "30-34 yrs", "35-39 yrs", "40-44 yrs",
                                       "45-49 yrs", "50-54 yrs", "55-59 yrs",
                                       "60-64 yrs", "65-69 yrs", "70-74 yrs",
                                       "75-79 yrs", "80-84 yrs", "85-89 yrs", 
                                       "90+ yrs"))) # this orders the age bands correctly

## Complete the arguments for value, sex, age, area and area_name (try doing Southampton)
p <- population(data = pops,
                value = Value,
                sex = Sex,
                age = Age,
                area = AreaName,
                area_name = "Southampton",
                comparator_1 = "South East region",
                comparator_2 = "England",
                title = "Age Profile of Southampton compared to England and the South East region",
                subtitle = "2018",
                xlab = "% of total population")
p
## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/child-health-profiles/data#page/12/gid/1938133263/pat/6/par/E12000008/ati/202/are/E06000045/iid/93563/age/34/sex/4/cid/4/page-options/ovw-do-0_cin-ci-4_car-do-0


# Boxplot -----------------------------------------------------------------

df_box <- df %>%
        filter(IndicatorID == 93563,
               AreaType == "County & UA (4/19-3/20)")

## Complete the arguments for timeperiod and value
p <- box_plots(df_box,
               timeperiod = Timeperiod,
               value = Value,
               title = "Percentage of 5 year olds with experience of visually obvious dental decay",
               subtitle = "In England",
               ylab = "Proportion (%)")

p

# Area profiles (spine chart)-----------------------------------------------------------

inhale <- fingertips_data(DomainID = 8000009,
                          AreaTypeID = 154,
                          ParentAreaTypeID = 219,
                          rank = TRUE)  # this is needed for polarity

# This gets the sequence of the indicators that is the same as on the website
ind_order <- indicator_order(DomainID = 8000009,
                             AreaTypeID = 154,
                             ParentAreaTypeID = 219)

indicator_levels <- inhale %>% 
        left_join(ind_order, by = "IndicatorID") %>% 
        distinct(IndicatorName, Sequence) %>% 
        arrange(Sequence) %>% 
        pull(IndicatorName) %>% 
        rev() %>% 
        str_wrap(30)

# We apply these levels to the IndicatorName field, when turning it into a factor
inhale <- inhale %>% 
        mutate(IndicatorName = factor(str_wrap(IndicatorName, 30),
                                      levels = indicator_levels))

df_spine <- inhale %>% 
        inner_join(ind_order, by = c("IndicatorID", "Age", "Sex")) %>% # inner_join because there are some indicators that have multiple sex/ages
        group_by(IndicatorID) %>% 
        filter(TimeperiodSortable == max(TimeperiodSortable)) %>% 
        ungroup()

# With trend arrow
## Complete value, count, area_code, indicator, timeperiod, trend, polarity, significance, area_type
p <- area_profiles(data = df_spine,
                   value = Value,
                   count = Count,
                   area_code = AreaCode,
                   local_area_code = "E38000172",
                   indicator = IndicatorName,
                   timeperiod = Timeperiod,
                   trend = RecentTrend,
                   polarity = Polarity,
                   significance = ComparedtoEnglandvalueorpercentiles,
                   area_type = AreaType,
                   comparator_area_code = "E54000008")

p

## Compare your outputs to this one:
## https://fingertips.phe.org.uk/profile/inhale/data#page/1/gid/8000009/pat/44/par/E40000010/ati/154/are/E38000172/cid/4/page-options/ovw-do-0

# Without trend arrow
## Try changing the some of the values for header_positions and seeing what effect this has on your plot when you print it to your plot window
p <- area_profiles(data = df_spine,
                   value = Value,
                   count = Count,
                   area_code = AreaCode,
                   local_area_code = "E38000172",
                   indicator = IndicatorName,
                   timeperiod = Timeperiod,
                   # trend = RecentTrend,
                   polarity = Polarity,
                   significance = ComparedtoEnglandvalueorpercentiles,
                   area_type = AreaType,
                   header_positions = c(-1.83, -1, -1, -0.7, -0.5, -0.25, -0.05, 1.05),
                   header_labels = c("Indicator", "", "Time\nperiod", "Local\ncount",
                                     "Local\nvalue", "England\nvalue", "Worst/\nLowest", "Best/\nHighest"),
                   comparator_area_code = "E54000008")

p
