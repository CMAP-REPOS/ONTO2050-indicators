

# 1. Setup ----------------------------------------------------------------

## 1a. Load libraries -----

# Basics
library(tidyverse);library(lubridate)
# Spatial
library(sf);library(mapview)
# Data viz
library(ggplot2);library(ggrepel)
# CMAP packages
library(cmapgeo);library(cmapplot)
# Utility
library(here);library(janitor);library(purrr)



## 1b. Options -----

# Options, call stored Census API key, load fonts
options(scipen = 1000, stringsAsFactors = FALSE, tigris_use_cache = TRUE)
mapviewOptions(basemaps = c("CartoDb.Positron",
                            "OpenStreetMap"))
invisible(Sys.getenv("CENSUS_API_KEY"))
# Prevent RPlots empty PDF
if(!interactive()) pdf(NULL)

# CMAP theme/aesthetic defaults
apply_cmap_default_aes()

# Sequence of year labels for charts showing targets.
TARGET_YEARS <- seq(2010, 2050, 5) 


# 2. Ingest data ----------------------------------------------------------

# Data directory
DATA_DIR <- here("02_script_outputs", "01_data", "development")

# Read in development data
med_hh_inc_re <- read_csv(paste0(DATA_DIR, "/", "median_hh_income_by_race_eth_2012_2022.csv"))
hh_inc_quintiles <- read_csv(paste0(DATA_DIR, "/", "mean_hh_income_by_quintile_2012_2022.csv"))
nonsov_travel <- read_csv(paste0(DATA_DIR, "/", "nonsov_travel_2012_2022.csv"))
workforce_participation <- read_csv(paste0(DATA_DIR, "/", "workforce_participation_2012_2022.csv"))
workforce_participation_re <- read_csv(paste0(DATA_DIR, "/", "workforce_participation_by_race_eth_2012_2022.csv"))
unemployment_re <- read_csv(paste0(DATA_DIR, "/", "unemployment_by_race_eth_2012_2022.csv"))
educational_attainment <- read_csv(paste0(DATA_DIR, "/", "educational_attainment_2012_2022.csv"))
educational_attainment_re <- read_csv(paste0(DATA_DIR, "/", "educational_attainment_by_race_eth_2012_2022.csv"))
gini <- read_csv(paste0(DATA_DIR, "/", "gini_coefficient_2012_2022.csv"))
commute_time_re <- read_csv(paste0(DATA_DIR, "/", "commute_time_by_race_eth_2012_2022.csv"))



# 3. Plots ----------------------------------------------------------------

## 3a. Median household income -----

# CMAP ggplot object
plot_med_hh_inc_re <- med_hh_inc_re %>% 
  # Reshape data for plotting
  pivot_longer(cols = -c(YEAR, ACTUAL_OR_TARGET),
               names_to = c("temp", "race_eth"),
               names_pattern = "^(.*)_(.*)$",
               values_to = "MED_HH_INC") %>% 
  mutate("race_eth" = str_to_title(race_eth)) %>% 
  select(-temp) %>% 
  # Plot basics
  ggplot(aes(x = YEAR, y = MED_HH_INC,
             color = race_eth,
             label = paste0("$", format(MED_HH_INC, big.mark = ",")))) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     labels = scales::dollar,
                     limits = c(-1, 100000),
                     expand = c(0, 0)) +
  # Chart title/legend
  ggtitle("Median household income by race & ethnicity",
          subtitle = paste0("in 2016 dollars, for households in the Chicago MSA")) +
  labs(caption = "Source: American Community Survey (tables B19013, B19013B, B19013D, B19013H, B19013I)",
       color = "Race/ethnicity") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Median Household Income (2016 $)",
             axisticks = "x") +
  cmap_color_race(white = "White",
                  black = "Black",
                  hispanic = "Hispanic",
                  asian = "Asian",
                  other = "All") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = scales::dollar(MED_HH_INC)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_med_hh_inc_re

# Finalize
plot_med_hh_inc_re_export <- finalize_plot(
  plot = plot_med_hh_inc_re,
  title = "Median household income by race & ethnicity in 2016 dollars, for households in the Chicago MSA",
  caption = "Source: American Community Survey (tables B19013, B19013B, B19013D, B19013H, B19013I)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "01_median_household_income_race_ethnicity.png"),
       plot = plot_med_hh_inc_re_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)



## 3b. Mean household income ratio compared to 2006  -----

# reshape data for plotting
hh_inc_quintiles <- hh_inc_quintiles %>%
  gather(MEAN_INC_REL2006_QUINT1, MEAN_INC_REL2006_QUINT2, MEAN_INC_REL2006_QUINT3, MEAN_INC_REL2006_QUINT4, MEAN_INC_REL2006_QUINT5,
         key="quintile", value="MEAN_INC_REL2006") %>%
  mutate(quintile = case_when(
    quintile == "MEAN_INC_REL2006_QUINT1" ~ "1st quintile (lowest income)",
    quintile == "MEAN_INC_REL2006_QUINT2" ~ "2nd quintile",
    quintile == "MEAN_INC_REL2006_QUINT3" ~ "3rd quintile",
    quintile == "MEAN_INC_REL2006_QUINT4" ~ "4th quintile",
    quintile == "MEAN_INC_REL2006_QUINT5" ~ "5th quintile (highest income)")) %>%
  select(YEAR, quintile, MEAN_INC_REL2006)

# Get only latest data points for labeling
hh_inc_quintiles_latest <- hh_inc_quintiles %>%
  filter(YEAR == max(YEAR)) %>%
  mutate(MEAN_INC_REL2006 = round(MEAN_INC_REL2006, 3))

#plot code
ggplot(hh_inc_quintiles, aes(x=YEAR, y=MEAN_INC_REL2006, color=quintile, label=MEAN_INC_REL2006)) + 
  ggtitle("Real mean household income by quintile relative to 2006",
          subtitle="among households in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=hh_inc_quintiles$YEAR) +
  scale_y_continuous("Real mean household income relative to 2006", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B19081)",
       color="Income quintile") +
  
  #additional styling
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  geom_line(size=1) +
  geom_hline(yintercept=1, color="#888888") +  # Emphasize y=100% for reference (if in plot)
  geom_point(data=hh_inc_quintiles_latest) +
  geom_text_repel(data=hh_inc_quintiles_latest, direction="y", fontface="bold")


## 3c. Non-SOV Travel  -----

# Get only latest data points for labeling
nonsov_travel_latest <- nonsov_travel %>%
  filter(YEAR == max(YEAR))  

#set nonsov targets
nonsov_travel_targets <- tribble(
  ~YEAR, ~PCT_NONSOV_TOTAL,
  2025,  32.4,
  2050,  37.3
)

#bind targets to latest year data
nonsov_travel_targets <- bind_rows(nonsov_travel_latest, nonsov_travel_targets)

# create plot Without targets
ggplot(nonsov_travel, aes(x=YEAR, y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL))) +
  ggtitle("Share of trips to work via non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=nonsov_travel$YEAR) +
  scale_y_continuous("Share of trips to work", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B08006)") +
  theme_minimal() +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=nonsov_travel_latest) +
  geom_text_repel(data=nonsov_travel_latest, direction="y", fontface="bold")

# plot With targets
ggplot(nonsov_travel, aes(x=YEAR, y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL))) +
  ggtitle("Share of trips to work via non-SOV modes, with targets",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Share of trips to work (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B08006)") +
  theme_minimal() +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_line(data=nonsov_travel_targets, linetype="dashed") +
  geom_point(data=nonsov_travel_targets) +
  geom_text_repel(data=nonsov_travel_targets, direction="y", fontface="bold")

#reshape data to plot share of specific modes
nonsov_travel <- nonsov_travel %>%
  gather(PCT_NONSOV_CARPOOL, PCT_NONSOV_TRANSIT, PCT_NONSOV_BIKE, PCT_NONSOV_WALK, PCT_NONSOV_HOME,
         key="mode", value="PCT_NONSOV") %>%
  mutate(mode = case_when(
    mode == "PCT_NONSOV_CARPOOL" ~ "Carpool",
    mode == "PCT_NONSOV_TRANSIT" ~ "Public transportation",
    mode == "PCT_NONSOV_BIKE" ~ "Bicycle",
    mode == "PCT_NONSOV_WALK" ~ "Walk",
    mode == "PCT_NONSOV_HOME" ~ "Work at home")) %>%
  select(YEAR, mode, PCT_NONSOV, PCT_NONSOV_TOTAL)

# plot share of specific modes
ggplot(nonsov_travel, aes(x=YEAR, y=PCT_NONSOV, fill=mode)) +
  ggtitle("Share of trips to work via specific non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=nonsov_travel$YEAR) +
  scale_y_continuous("Share of trips to work (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B08006)",
       fill="Mode") +
  theme_minimal() +
  scale_fill_brewer(palette="Set1") +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_bar(stat="identity") +
  geom_text(aes(label=sprintf("%.1f%%", PCT_NONSOV)), position=position_stack(vjust=0.5), color="white", size=3.5) +
  geom_text(aes(y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL)), vjust=-1, fontface="bold")

## 3d. Workforce Participation -----

# Get only latest data points for labeling
workforce_participation_latest <- workforce_participation %>%
  filter(YEAR == max(YEAR))  

#set targets
workforce_participation_targets <- tribble(
  ~YEAR, ~WORKFORCE_PARTIC_RATE,
  2025,  80.9,
  2050,  83.4)

#bind targets to latest dataframe
workforce_participation_targets <- bind_rows(workforce_participation_latest, workforce_participation_targets)

# plot Without targets
ggplot(workforce_participation, aes(x=YEAR, y=WORKFORCE_PARTIC_RATE, label=sprintf("%.1f%%", WORKFORCE_PARTIC_RATE))) +
  ggtitle("Workforce participation rate",
          subtitle="among people aged 20-64 in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=workforce_participation$YEAR) +
  scale_y_continuous("Workforce participation rate", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B23001)") +
  theme_minimal() +
  coord_cartesian(ylim=c(75, 90)) +
  geom_line(size=1) +
  geom_point(data=workforce_participation_latest) +
  geom_text_repel(data=workforce_participation_latest, direction="y", fontface="bold")

# plot With targets
ggplot(workforce_participation, aes(x=YEAR, y=WORKFORCE_PARTIC_RATE, label=sprintf("%.1f%%", WORKFORCE_PARTIC_RATE))) +
  ggtitle("Workforce participation rate, with targets",
          subtitle="among people aged 20-64 in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Workforce participation rate", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B23001)") +
  theme_minimal() +
  coord_cartesian(ylim=c(75, 90)) +
  geom_line(size=1) +
  geom_line(data=workforce_participation_targets, linetype="dashed") +
  geom_point(data=workforce_participation_targets) +
  geom_text_repel(data=workforce_participation_targets, direction="y", fontface="bold")

## 3e.Workforce Participation by Race and Ethnicity  -----

# reshape data for plotting
workforce_participation_re <- workforce_participation_re %>%
  gather(WORKFORCE_PARTIC_RATE_ALL, WORKFORCE_PARTIC_RATE_BLACK, WORKFORCE_PARTIC_RATE_ASIAN, WORKFORCE_PARTIC_RATE_HISPANIC, WORKFORCE_PARTIC_RATE_WHITE,
         key="race_eth", value="WORKFORCE_PARTIC_RATE") %>%
  mutate(race_eth = case_when(
    race_eth == "WORKFORCE_PARTIC_RATE_ALL" ~ "All",
    race_eth == "WORKFORCE_PARTIC_RATE_BLACK" ~ "Black",
    race_eth == "WORKFORCE_PARTIC_RATE_ASIAN" ~ "Asian",
    race_eth == "WORKFORCE_PARTIC_RATE_HISPANIC" ~ "Hispanic/Latino",
    race_eth == "WORKFORCE_PARTIC_RATE_WHITE" ~ "White (non-Hispanic)")) %>%
  select(YEAR, race_eth, WORKFORCE_PARTIC_RATE)

# Get only latest data points for labeling
workforce_participation_re_latest <- workforce_participation_re %>%
  filter(YEAR == max(YEAR))  

#create plot
ggplot(workforce_participation_re, 
       aes(x=YEAR, y=WORKFORCE_PARTIC_RATE, color=race_eth, label=sprintf("%.1f%%", WORKFORCE_PARTIC_RATE))) +
  ggtitle("Workforce participation rate by race & ethnicity",
          subtitle="among people aged 16 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=workforce_participation_re$YEAR) +
  scale_y_continuous("Workforce participation rate (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table S2301)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(55, 75)) +
  geom_line(size=1) +
  geom_point(data=workforce_participation_re_latest) +
  geom_text_repel(data=workforce_participation_re_latest, direction="y", fontface="bold")


## 3f. Unemployment by race and ethnicity -----

#reshape data for plotting
unemployment_re <- unemployment_re %>%
  gather(PCT_UNEMPLOYED_ALL, PCT_UNEMPLOYED_BLACK, PCT_UNEMPLOYED_ASIAN, PCT_UNEMPLOYED_HISPANIC, PCT_UNEMPLOYED_WHITE,
         key="race_eth", value="PCT_UNEMPLOYED") %>%
  mutate(race_eth = case_when(
    race_eth == "PCT_UNEMPLOYED_ALL" ~ "All",
    race_eth == "PCT_UNEMPLOYED_BLACK" ~ "Black",
    race_eth == "PCT_UNEMPLOYED_ASIAN" ~ "Asian",
    race_eth == "PCT_UNEMPLOYED_HISPANIC" ~ "Hispanic/Latino",
    race_eth == "PCT_UNEMPLOYED_WHITE" ~ "White (non-Hispanic)")) %>%
  select(YEAR, race_eth, PCT_UNEMPLOYED)

# Get only latest data points for labeling
unemployment_re_latest <- unemployment_re %>%
  filter(YEAR == max(YEAR))  

#create plot
ggplot(unemployment_re, aes(x=YEAR, y=PCT_UNEMPLOYED, color=race_eth, label=sprintf("%.1f%%", PCT_UNEMPLOYED))) +
  ggtitle("Unemployment rate by race & ethnicity",
          subtitle="among people aged 16 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=unemployment_re$YEAR) +
  scale_y_continuous("Unemployment rate", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table S2301)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0, 25)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=unemployment_re_latest) +
  geom_text_repel(data=unemployment_re_latest, direction="y", fontface="bold")

## 3g. Educational attainment -----

# Get only latest data points for labeling
educational_attainment_latest <- educational_attainment %>%
  filter(YEAR == max(YEAR))  

#set targets
educational_attainment_targets <- tribble(
  ~YEAR, ~PCT_ASSOC_DEG_PLUS,
  2025,  50.2,
  2050,  64.9)

#bind targets to most recent year's data
educational_attainment_targets <- bind_rows(educational_attainment_latest, educational_attainment_targets)

#plot without targets
ggplot(educational_attainment, aes(x=YEAR, y=PCT_ASSOC_DEG_PLUS, label=sprintf("%.1f%%", PCT_ASSOC_DEG_PLUS))) +
  ggtitle("Share of population with an associate's degree or higher",
          subtitle="among people aged 25 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=educational_attainment$YEAR) +
  scale_y_continuous("Share of population (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B15003)") +
  theme_minimal() +
  coord_cartesian(ylim=c(40, 50)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=educational_attainment_latest) +
  geom_text_repel(data=educational_attainment_latest, direction="y", fontface="bold")

#plot with targets
ggplot(educational_attainment, aes(x=YEAR, y=PCT_ASSOC_DEG_PLUS, label=sprintf("%.1f%%", PCT_ASSOC_DEG_PLUS))) +
  ggtitle("Share of population with an associate's degree or higher, with targets",
          subtitle="among people aged 25 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Share of population (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B15003)") +
  theme_minimal() +
  coord_cartesian(ylim=c(30, 70)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_line(data=educational_attainment_targets, linetype="dashed") +
  geom_point(data=educational_attainment_targets) +
  geom_text_repel(data=educational_attainment_targets, direction="y", fontface="bold")

## 3h. Educational attainment by Race/Ethnicity -----

#reshape data for plotting each individual race as its own line
educational_attainment_re <- educational_attainment_re %>%
  gather(PCT_ASSOC_DEG_PLUS_ALL, PCT_ASSOC_DEG_PLUS_BLACK, PCT_ASSOC_DEG_PLUS_ASIAN, PCT_ASSOC_DEG_PLUS_HISPANIC, PCT_ASSOC_DEG_PLUS_WHITE,
         key="race_eth", value="PCT_ASSOC_DEG_PLUS") %>%
  mutate(race_eth = case_when(
    race_eth == "PCT_ASSOC_DEG_PLUS_ALL" ~ "All",
    race_eth == "PCT_ASSOC_DEG_PLUS_BLACK" ~ "Black",
    race_eth == "PCT_ASSOC_DEG_PLUS_ASIAN" ~ "Asian",
    race_eth == "PCT_ASSOC_DEG_PLUS_HISPANIC" ~ "Hispanic/Latino",
    race_eth == "PCT_ASSOC_DEG_PLUS_WHITE" ~ "White (non-Hispanic)")) %>%
  select(YEAR, race_eth, PCT_ASSOC_DEG_PLUS)

# Get only latest data points for labeling
educational_attainment_re_latest <- educational_attainment_re %>%
  filter(YEAR == max(YEAR))  

#create plot
ggplot(educational_attainment_re, aes(x=YEAR, y=PCT_ASSOC_DEG_PLUS, color=race_eth, label=sprintf("%.1f%%", PCT_ASSOC_DEG_PLUS))) +
  ggtitle("Share of population with an associate's degree or higher by race & ethnicity",
          subtitle="among people aged 25 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=educational_attainment_re$YEAR) +
  scale_y_continuous("Share of population (%)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (tables B15002, B15002B, B15002D, B15002H, B15002I)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  geom_line(size=1) +
  geom_point(data=educational_attainment_re_latest) +
  geom_text_repel(data=educational_attainment_re_latest, direction="y", fontface="bold")



## 3i. Gini Coefficient/Income Inequality -----

#reshape data for plotting each individual peer MSA as its own line
gini <- gini %>%
  gather(GINI_COEFF_CHI, GINI_COEFF_BOS, GINI_COEFF_LA, GINI_COEFF_NY, GINI_COEFF_WAS,
         key="region", value="GINI_COEFF") %>%
  mutate(region = case_when(
    region == "GINI_COEFF_CHI" ~ "Chicago",
    region == "GINI_COEFF_BOS" ~ "Boston",
    region == "GINI_COEFF_LA" ~ "Los Angeles",
    region == "GINI_COEFF_NY" ~ "NYC",
    region == "GINI_COEFF_WAS" ~ "Washington, D.C.")) %>%
  select(YEAR, region, GINI_COEFF)

# Get only latest data points for labeling
gini_latest <- gini %>%
  filter(YEAR == max(YEAR))  

#create plot
ggplot(gini, aes(x=YEAR, y=GINI_COEFF, color=region, label=sprintf("%.3f", GINI_COEFF))) +
  ggtitle("Gini coefficient",
          subtitle="for the Chicago MSA and selected peer regions") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=gini$YEAR) +
  scale_y_continuous("Gini coefficient", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey (table B19083)",
       color="Metropolitan Statistical Area") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0.4, 0.55)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=gini_latest) +
  geom_text_repel(data=gini_latest, direction="y", fontface="bold")

## 3j. Commute Time by Race/Ethnicity -----

#reshape data for plotting each individual race as its own line
commute_time_re <- commute_time_re %>%
  gather(COMMUTE_MINS_ASIAN, COMMUTE_MINS_BLACK, COMMUTE_MINS_HISPANIC, COMMUTE_MINS_WHITE,
         key="race_eth", value="COMMUTE_MINS") %>%
  mutate(race_eth = case_when(
    race_eth == "COMMUTE_MINS_ASIAN" ~ "Asian",
    race_eth == "COMMUTE_MINS_BLACK" ~ "Black",
    race_eth == "COMMUTE_MINS_HISPANIC" ~ "Hispanic/Latino",
    race_eth == "COMMUTE_MINS_WHITE" ~ "White (non-Hispanic)")) %>%
  select(YEAR, race_eth, COMMUTE_MINS)

# Get only latest data points for labeling
commute_time_re_latest <- commute_time_re %>%
  filter(YEAR == max(YEAR)) 

#create plot
ggplot(commute_time_re, aes(x=YEAR, y=COMMUTE_MINS, color=race_eth, label=sprintf("%.1f", COMMUTE_MINS))) +
  ggtitle("Commute time by race & ethnicity",
          subtitle="among workers in the (PUMA-approximated) Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=commute_time_re$YEAR) +
  scale_y_continuous("Commute time (minutes)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey Public Use Microdata Sample (PUMS)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  geom_line(size=1) +
  geom_point(data=commute_time_re_latest) +
  geom_text_repel(data=commute_time_re_latest, direction="y", fontface="bold")