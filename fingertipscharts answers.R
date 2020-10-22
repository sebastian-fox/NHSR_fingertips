
# Libraries ---------------------------------------------------------------

if (!require(fingertipscharts)) install.packages("fingertipscharts")
if (!require(dplyr)) install.packages("dplyr")

# Note, fingertipsR is not on CRAN and won't be for the foreseeable future
if (!require(fingertipsR)) install.packages("fingertipsR", repos = "https://dev.ropensci.org")

# For this part of the workshop we'll use the Oral Health domain from the Child and Maternal Health profile
## Execute this code
df <- fingertips_data(DomainID = 1938133263,
                      AreaTypeID = 202)


# This workshop will work through the visualisations available on Fingertips
# All the function names available in fingertipscharts are identical to the name on the  Fingertips website

# To start with, we will use a function from fingertipsR to understand the order of the indicators in different presentations
ind_order <- indicator_order(DomainID = 1938133263,
                             AreaTypeID = 202,
                             ParentAreaTypeID = 6) %>% 
        select(IndicatorID, Sequence)

indicator_levels <- df %>% 
        left_join(ind_order, by = "IndicatorID") %>% 
        distinct(IndicatorName, Sequence) %>% 
        arrange(Sequence) %>% 
        pull(IndicatorName)

# We apply these levels to the IndicatorName field, when turning it into a factor
df <- df %>% 
        mutate(IndicatorName = factor(IndicatorName,
                                      levels = indicator_levels))

# Overview (or tartan rug) ------------------------------------------------
## Look at the documentation for the overview() function
?overview


parent <- "South West region"
fixed_areas <- c("England", parent)
p <- df %>% 
        group_by(IndicatorID) %>% 
        filter((ParentName == parent |
                        AreaName %in% fixed_areas),
               TimeperiodSortable == max(TimeperiodSortable)) %>% 
        ungroup() %>% 
        mutate(Value = round(Value, 1)) %>% 
        overview(area = AreaName,
                 indicator = IndicatorName,
                 value = Value,
                 fill = ComparedtoEnglandvalueorpercentiles,
                 timeperiod = Timeperiod,
                 top_areas = fixed_areas,
                 wrap_length = 35,
                 legend_position = "bottom")
p
