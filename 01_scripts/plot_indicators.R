

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
  mutate("race_eth" = str_to_title(race_eth) %>% 
           factor(., levels = c("White",
                                "Black",
                                "Hispanic",
                                "Asian",
                                "All"))) %>% 
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
  title = "Median household income (2016 dollars) by race & ethnicity",
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

# CMAP ggplot object
plot_hh_inc_quintiles <-
  ggplot(hh_inc_quintiles, 
         aes(x=YEAR, y=MEAN_INC_REL2006, color=quintile, label=MEAN_INC_REL2006)) + 
  geom_line(size=1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks=hh_inc_quintiles$YEAR) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(0.8, 1.15)) +
  # Chart title and legend
  ggtitle("Real mean household income by quintile relative to 2006",
          subtitle="among households in the Chicago MSA") +
  labs(caption="Source: American Community Survey (table B19081)",
       color="Income quintile") +
  # CMAP Styling
  theme_cmap(xlab = "Year",
             ylab = "Real mean household income relative to 2006",
             axisticks= "x",
             legend.max.columns = 3) +
  cmap_color_discrete(palette = "prosperity") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(MEAN_INC_REL2006, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# view 
plot_hh_inc_quintiles

# finalize
plot_hh_inc_quintiles_export <- finalize_plot(
  plot = plot_hh_inc_quintiles,
  title = "Change in Mean Household Income Since 2006 by Quintile",
  caption = "Source: American Community Survey (table B19081)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "02_change_median_income_2006.png"),
       plot = plot_hh_inc_quintiles_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)


## 3c. Non-SOV Travel  -----

#set nonsov targets
nonsov_travel_targets <- tribble(
  ~YEAR, ~PCT_NONSOV_TOTAL,
  2025,  32.4,
  2050,  37.3
)

# CMAP ggplot without targets
plot_nonsov_travel <-
  ggplot(nonsov_travel, 
         aes(x=YEAR, y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL))) +
  geom_line(size=1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(minor_breaks=NULL, breaks=nonsov_travel$YEAR) +
  scale_y_continuous(minor_breaks=NULL, labels = function(x)paste0(x,"%")) +
  # Chart title and legend
  ggtitle("Share of trips to work via non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  labs(caption="Source: American Community Survey (table B08006)") +
  #CMAP styling
  theme_cmap(xlab = "Year",
             ylab = "Percentage of non-SOV trips to work",
             axisticks= "x") +
  cmap_color_discrete(palette = "mobility") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = paste0(round(PCT_NONSOV_TOTAL,1),"%")), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")
#View
plot_nonsov_travel

#finalize
plot_nonsov_travel_export <- finalize_plot(
  plot = plot_nonsov_travel,
  title = "Share of trips to work via non-SOV modes",
  caption = "Source: American Community Survey (table B08006)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "03A_nonsov_travel.png"),
       plot = plot_nonsov_travel_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

#CMAP ggplot with targets
plot_nonsovtravel_targets <-
  ggplot(nonsov_travel, 
         aes(x=YEAR, y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL))) +
  geom_line(size=1) +  geom_line(data=nonsov_travel_targets, linetype="dashed") + geom_point(data=nonsov_travel_targets) +
  geom_text_repel(data=nonsov_travel_targets, direction="y", fontface="bold") +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous(minor_breaks=NULL, labels = function(x)paste0(x,"%")) +
  # Chart title and legend
  ggtitle("Share of trips to work via non-SOV modes with targets",
          subtitle="among workers aged 16 and over in the CMAP region") +
  labs(caption="Source: American Community Survey (table B08006)") +
  #CMAP styling
  theme_cmap(xlab = "Year",
             ylab = "Percentage of non-SOV trips to work",
             axisticks= "x") +
  cmap_color_discrete(palette = "mobility") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = paste0(round(PCT_NONSOV_TOTAL,1),"%")), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

#View
plot_nonsovtravel_targets

# finalize
plot_nonsovtravel_targets_export <- finalize_plot(
  plot = plot_nonsovtravel_targets,
  title = "Share of trips to work via non-SOV modes with targets",
  caption = "Source: American Community Survey (table B08006)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "03B_nonsov_travel_targets.png"),
       plot = plot_nonsovtravel_targets_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

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

#CMAP plot with share of specific modes
plot_nonsov_mode <-
  ggplot(nonsov_travel, aes(x=YEAR, y=PCT_NONSOV, fill=mode)) + geom_bar(stat="identity") +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(minor_breaks=NULL, breaks=nonsov_travel$YEAR) +
  scale_y_continuous(minor_breaks=NULL, labels = function(x)paste0(x,"%")) +
  # Chart title and legend
  ggtitle("Share of trips to work via specific non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  labs(caption="Source: American Community Survey (table B08006)",
       fill="Mode") +
  #CMAP styling
  theme_cmap(xlab = "Year",
             ylab = "Percentage of non-SOV trips to work",
             axisticks= "x") +
  cmap_fill_discrete(palette = "mobility") +
  coord_cartesian(clip = "off") +
  geom_text(aes(label=sprintf("%.1f%%", PCT_NONSOV)), position=position_stack(vjust=0.5), color="white", size=3.5) +
  geom_text(aes(y=PCT_NONSOV_TOTAL, label=sprintf("%.1f%%", PCT_NONSOV_TOTAL)), vjust=-1, fontface="bold", size = 4)

#View
plot_nonsov_mode

# finalize
plot_nonsov_mode_export <- finalize_plot(
  plot = plot_nonsov_mode,
  title = "Share of trips to work via specific non-SOV modes",
  caption = "Source: American Community Survey (table B08006)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "03_nonsov_trips_bymode.png"),
       plot = plot_nonsov_mode_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)


## 3d. Workforce Participation -----

#set targets
workforce_participation_targets <- tribble(
  ~YEAR, ~WORKFORCE_PARTIC_RATE,
  2025,  80.9,
  2050,  83.4)

# CMAP ggplot object
plot_workforce_participation <-
  # Plot basics
  ggplot(workforce_participation, 
         aes(x = YEAR, y = WORKFORCE_PARTIC_RATE,
             label = "%")) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(75, 85),
                     expand = c(0, 0)) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Workforce Participation Rate (%)",
             axisticks = "x") +
# Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(WORKFORCE_PARTIC_RATE, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_workforce_participation

# Finalize
plot_workforce_participation <- finalize_plot(
  plot = plot_workforce_participation,
  title = "Workforce Participation Rate (%)",
  caption = "Source: American Community Survey (table B23001)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "04_workforce_participation.png"),
       plot = plot_workforce_participation,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

## 3e.Workforce Participation by Race and Ethnicity  -----

# reshape data for plotting
workforce_participation_re <- workforce_participation_re %>%
  gather(WORKFORCE_PARTIC_RATE_ALL, WORKFORCE_PARTIC_RATE_BLACK, WORKFORCE_PARTIC_RATE_ASIAN, WORKFORCE_PARTIC_RATE_HISPANIC, WORKFORCE_PARTIC_RATE_WHITE,
         key="race_eth", value="WORKFORCE_PARTIC_RATE") %>%
  mutate(race_eth = case_when(
    race_eth == "WORKFORCE_PARTIC_RATE_ALL" ~ "All",
    race_eth == "WORKFORCE_PARTIC_RATE_BLACK" ~ "Black",
    race_eth == "WORKFORCE_PARTIC_RATE_ASIAN" ~ "Asian",
    race_eth == "WORKFORCE_PARTIC_RATE_HISPANIC" ~ "Hispanic",
    race_eth == "WORKFORCE_PARTIC_RATE_WHITE" ~ "White")) %>%
  select(YEAR, race_eth, WORKFORCE_PARTIC_RATE)

# CMAP ggplot object
plot_workforce_participation_re <-
  ggplot(workforce_participation_re, aes(x = YEAR, y = WORKFORCE_PARTIC_RATE,
             color = race_eth,
             label = "%")) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(57, 75),
                     expand = c(0, 0)) +
  # Chart title/legend
  labs(color = "Race/ethnicity") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Workforce Participation Rate (%)",
             axisticks = "x") +
  cmap_color_race(white = "White",
                  black = "Black",
                  hispanic = "Hispanic",
                  asian = "Asian",
                  other = "All") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(WORKFORCE_PARTIC_RATE, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_workforce_participation_re

# Finalize
plot_workforce_participation_re <- finalize_plot(
  plot = plot_workforce_participation_re,
  title = "Workforce Participation Rate by race & ethnicity",
  caption = "Source: American Community Survey (table S2301)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "05_workforce_participation_race_ethnicity.png"),
       plot = plot_workforce_participation_re,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

## 3f. Unemployment by race and ethnicity -----

#reshape data for plotting
unemployment_re <- unemployment_re %>%
  gather(PCT_UNEMPLOYED_ALL, PCT_UNEMPLOYED_BLACK, PCT_UNEMPLOYED_ASIAN, PCT_UNEMPLOYED_HISPANIC, PCT_UNEMPLOYED_WHITE,
         key="race_eth", value="PCT_UNEMPLOYED") %>%
  mutate(race_eth = case_when(
    race_eth == "PCT_UNEMPLOYED_ALL" ~ "All",
    race_eth == "PCT_UNEMPLOYED_BLACK" ~ "Black",
    race_eth == "PCT_UNEMPLOYED_ASIAN" ~ "Asian",
    race_eth == "PCT_UNEMPLOYED_HISPANIC" ~ "Hispanic",
    race_eth == "PCT_UNEMPLOYED_WHITE" ~ "White")) %>%
  select(YEAR, race_eth, PCT_UNEMPLOYED)

# CMAP ggplot object
plot_unemployment_re <-
  ggplot(unemployment_re, aes(x = YEAR, y = PCT_UNEMPLOYED,
                              color = race_eth)) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(0, 25),
                     expand = c(0, 0)) +
  # Chart title/legend
  labs(color = "Race/ethnicity") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Unemployment Rate (%)",
             axisticks = "x") +
  cmap_color_race(white = "White",
                  black = "Black",
                  hispanic = "Hispanic",
                  asian = "Asian",
                  other = "All") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(PCT_UNEMPLOYED, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_unemployment_re

# Finalize
plot_unemployment_re <- finalize_plot(
  plot = plot_unemployment_re,
  title = "Unemployment Rate by race & ethnicity",
  caption = "Source: American Community Survey (table S2301)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "06_unemployment_race_ethnicity.png"),
       plot = plot_unemployment_re,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

## 3g. Educational attainment -----

#set targets
educational_attainment_targets <- tribble(
  ~YEAR, ~PCT_ASSOC_DEG_PLUS,
  2025,  50.2,
  2050,  64.9)

# CMAP ggplot object
plot_educational_attainment <-
  # Plot basics
  ggplot(educational_attainment, 
         aes(x = YEAR, y = PCT_ASSOC_DEG_PLUS)) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(40, 51),
                     expand = c(0, 0)) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "% with an Associate Degree or Higher",
             axisticks = "x") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(PCT_ASSOC_DEG_PLUS, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_educational_attainment

# Finalize
plot_educational_attainment <- finalize_plot(
  plot = plot_educational_attainment,
  title = "Educational Attainment",
  caption = "Source: American Community Survey (table B15003)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "07_educational_attainment.png"),
       plot = plot_educational_attainment,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

## 3h. Educational attainment by Race/Ethnicity -----

#reshape data for plotting each individual race as its own line
educational_attainment_re <- educational_attainment_re %>%
  gather(PCT_ASSOC_DEG_PLUS_ALL, PCT_ASSOC_DEG_PLUS_BLACK, PCT_ASSOC_DEG_PLUS_ASIAN, PCT_ASSOC_DEG_PLUS_HISPANIC, PCT_ASSOC_DEG_PLUS_WHITE,
         key="race_eth", value="PCT_ASSOC_DEG_PLUS") %>%
  mutate(race_eth = case_when(
    race_eth == "PCT_ASSOC_DEG_PLUS_ALL" ~ "All",
    race_eth == "PCT_ASSOC_DEG_PLUS_BLACK" ~ "Black",
    race_eth == "PCT_ASSOC_DEG_PLUS_ASIAN" ~ "Asian",
    race_eth == "PCT_ASSOC_DEG_PLUS_HISPANIC" ~ "Hispanic",
    race_eth == "PCT_ASSOC_DEG_PLUS_WHITE" ~ "White")) %>%
  select(YEAR, race_eth, PCT_ASSOC_DEG_PLUS)

# CMAP ggplot object
plot_educational_attainment_re <-
  ggplot(educational_attainment_re, aes(x = YEAR, y = PCT_ASSOC_DEG_PLUS,
                              color = race_eth)) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(10, 80),
                     expand = c(0, 0)) +
  # Chart title/legend
  labs(color = "Race/ethnicity") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "% with an Associate Degree or Higher",
             axisticks = "x") +
  cmap_color_race(white = "White",
                  black = "Black",
                  hispanic = "Hispanic",
                  asian = "Asian",
                  other = "All") +
  # Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(PCT_ASSOC_DEG_PLUS, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_educational_attainment_re

# Finalize
plot_educational_attainment_re <- finalize_plot(
  plot = plot_educational_attainment_re,
  title = "Educational Attainment",
  caption = "Source: American Community Survey (table B15002)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "08_educational_attainment_race_ethnicity.png"),
       plot = plot_educational_attainment_re,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

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


# CMAP ggplot object
plot_gini <-
  ggplot(gini, aes(x = YEAR, y = GINI_COEFF,
                                        color = region)) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(0.4, 0.6),
                     expand = c(0, 0)) +
  # Chart title/legend
  labs(color = "Peer Region") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Gini Coefficient",
             axisticks = "x") +
  cmap_color_discrete(palette = "community") +
# Add text to most recent data point
  geom_text_lastonly(mapping = aes(label = round(GINI_COEFF, 2)), 
                     add_points = TRUE) +
  coord_cartesian(clip = "off")

# View
plot_gini

# Finalize
plot_gini <- finalize_plot(
  plot = plot_gini,
  title = "Income Inequality in Peer MSAs",
  caption = "Source: American Community Survey (table B19083)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "09_gini_coefficient.png"),
       plot = plot_gini,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)

## 3j. Commute Time by Race/Ethnicity -----

#reshape data for plotting each individual race as its own line
plot_commute_time_re <- commute_time_re %>%
  # Reshape data for plotting
  pivot_longer(cols = -c(YEAR, ACTUAL_OR_TARGET),
               names_to = c("temp", "race_eth"),
               names_pattern = "^(.*)_(.*)$",
               values_to = "COMMUTE_MINS") %>% 
  mutate("race_eth" = str_to_title(race_eth) %>% 
           factor(., levels = c("White",
                                "Black",
                                "Hispanic",
                                "Asian"))) %>%
  select(-temp) %>% 
  # Plot basics
  ggplot(aes(x = YEAR, y = COMMUTE_MINS,
             color = race_eth)) +
  geom_line(size = 1) +
  # Axes details (X, Y labels set in theme_cmap)
  scale_x_continuous(breaks = scales::breaks_pretty(),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(minor_breaks = NULL,
                     limits = c(-1, 40),
                     expand = c(0, 0)) +
  # Chart title/legend
  ggtitle("Average journey to work time (minutes) by race & ethnicity",
          subtitle = paste0("in 2016 dollars, for households in the Chicago MSA")) +
  labs(caption = "Source: American Community Survey Public Use Microdata Sample (PUMS)",
       color = "Race/ethnicity") +
  guides(color = guide_legend(override.aes = list(label = ""))) +
  # CMAP styling
  theme_cmap(xlab = "Year", 
             ylab = "Average Journey to Work Time (Minutes)",
             axisticks = "x") +
  cmap_color_race(white = "White",
                  black = "Black",
                  hispanic = "Hispanic",
                  asian = "Asian") +
  # Add text to most recent data point
  # geom_text_lastonly(mapping = aes(label = paste0(round(COMMUTE_MINS, 1),
  #                                                 " min")),
  #                    add_points = TRUE) +
  geom_text_lastonly_repel(mapping = aes(label = paste0(round(COMMUTE_MINS, 1),
                                                        " min")),
                           
                           add_points = TRUE,
                           # Use nudge_x argument to increase space between last point and text (default is 0.4)
                           ) +
  coord_cartesian(clip = "off")

# View
plot_commute_time_re

# Finalize
plot_commute_time_re_export <- finalize_plot(
  plot = plot_commute_time_re,
  title = "Average journey to work time (minutes) by race & ethnicity",
  caption = "Source: American Community Survey Public Use Microdata Sample (PUMS)")

# Save as image to plots output subfolder
# Ratio of height to width for pptx slide (aspect ratio) is 5 in x 7 in, so play around with needed width (9.5 inches here) to capture the full image. This makes copy and paste into slides easier.
ggsave(filename = paste0(here("02_script_outputs", "02_plots"),
                         "/", "10_commute_time_race_ethnicity.png"),
       plot = plot_commute_time_re_export,
       height = 300 * (5/ 7) * 9.5,
       width = 300 * 9.5,
       units = "px", # Pixels
       dpi = 300)
