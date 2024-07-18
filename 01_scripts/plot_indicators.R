##NONSOV TRAVEL PLOTS

# Plot indicator values over time
nonsov_travel_latest <- nonsov_travel %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

nonsov_travel_targets <- tribble(
  ~year, ~nonsov_pct,
  2025,  0.324,
  2050,  0.373
)
nonsov_travel_targets <- bind_rows(nonsov_travel_latest, nonsov_travel_targets)

# Without targets
ggplot(nonsov_travel, aes(x=year, y=nonsov_pct, label=sprintf("%.1f%%", 100*nonsov_pct))) +
  ggtitle("Share of trips to work via non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Share of trips to work", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B08006)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.25, 0.35)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=nonsov_travel_latest) +
  geom_text_repel(data=nonsov_travel_latest, direction="y", fontface="bold")

# With targets
ggplot(nonsov_travel, aes(x=year, y=nonsov_pct, label=sprintf("%.1f%%", 100*nonsov_pct))) +
  ggtitle("Share of trips to work via non-SOV modes, with targets",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Share of trips to work", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B08006)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.25, 0.40)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_line(data=nonsov_travel_targets, linetype="dashed") +
  geom_point(data=nonsov_travel_targets) +
  geom_text_repel(data=nonsov_travel_targets, direction="y", fontface="bold")

# Plot share of specific modes over time
nonsov_travel2 <- nonsov_travel %>%
  gather(carpool_pct, pub_trans_pct, bike_pct, walk_pct, work_home_pct,
         key="mode", value="share") %>%
  mutate(mode = case_when(
    mode == "carpool_pct" ~ "Carpool",
    mode == "pub_trans_pct" ~ "Public transportation",
    mode == "bike_pct" ~ "Bicycle",
    mode == "walk_pct" ~ "Walk",
    mode == "work_home_pct" ~ "Work at home"
  )) %>%
  select(year, mode, share, nonsov_pct)

ggplot(nonsov_travel2, aes(x=year, y=share, fill=mode)) +
  ggtitle("Share of trips to work via specific non-SOV modes",
          subtitle="among workers aged 16 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Share of trips to work", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B08006)",
       fill="Mode") +
  theme_minimal() +
  scale_fill_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0, 0.35)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_bar(stat="identity") +
  geom_text(aes(label=sprintf("%.1f%%", 100*share)), position=position_stack(vjust=0.5), color="white", size=3.5) +
  geom_text(aes(y=nonsov_pct, label=sprintf("%.1f%%", 100*nonsov_pct)), vjust=-1, fontface="bold")

## WORKFORCE PARTICIPATION PLOTS

# Plot indicator values over time
workforce_participation_latest <- workforce_participation %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

workforce_participation_targets <- tribble(
  ~year, ~lbr_frc_pct,
  2025,  0.809,
  2050,  0.834
)
workforce_participation_targets <- bind_rows(workforce_participation_latest, workforce_participation_targets)

# Without targets
ggplot(workforce_participation, aes(x=year, y=lbr_frc_pct, label=sprintf("%.1f%%", 100*lbr_frc_pct))) +
  ggtitle("Workforce participation rate",
          subtitle="among people aged 20-64 in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Workforce participation rate", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B23001)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.75, 0.85)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=workforce_participation_latest) +
  geom_text_repel(data=workforce_participation_latest, direction="y", fontface="bold")

# With targets
ggplot(workforce_participation, aes(x=year, y=lbr_frc_pct, label=sprintf("%.1f%%", 100*lbr_frc_pct))) +
  ggtitle("Workforce participation rate, with targets",
          subtitle="among people aged 20-64 in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Workforce participation rate", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B23001)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.75, 0.9)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_line(data=workforce_participation_targets, linetype="dashed") +
  geom_point(data=workforce_participation_targets) +
  geom_text_repel(data=workforce_participation_targets, direction="y", fontface="bold")

## WORKFORCE PARTICIPATION RATE BY RACE/ETHNICITY PLOTS 
# Plot indicator values over time
workforce_participation_re2 <- workforce_participation_re %>%
  gather(lbr_frc_pct_all, lbr_frc_pct_blk, lbr_frc_pct_asn, lbr_frc_pct_hsp, lbr_frc_pct_wht,
         key="race_eth", value="lbr_frc_pct") %>%
  mutate(race_eth = case_when(
    race_eth == "lbr_frc_pct_all" ~ "All",
    race_eth == "lbr_frc_pct_blk" ~ "Black",
    race_eth == "lbr_frc_pct_asn" ~ "Asian",
    race_eth == "lbr_frc_pct_hsp" ~ "Hispanic/Latino",
    race_eth == "lbr_frc_pct_wht" ~ "White (non-Hispanic)"
  )) %>%
  select(year, race_eth, lbr_frc_pct)

workforce_participation_re2_latest <- workforce_participation_re2 %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(workforce_participation_re2, aes(x=year, y=lbr_frc_pct, color=race_eth, label=sprintf("%.1f%%", 100*lbr_frc_pct))) +
  ggtitle("Workforce participation rate by race & ethnicity",
          subtitle="among people aged 16 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Workforce participation rate", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table S2301)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0.55, 0.75)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=workforce_participation_re2_latest) +
  geom_text_repel(data=workforce_participation_re2_latest, direction="y", fontface="bold")


## UNEMPLOYMENT BY RACE/ETHNICITY PLOTS 
# Plot indicator values over time
unemployment_re2 <- unemployment_re %>%
  gather(unemp_pct_all, unemp_pct_blk, unemp_pct_asn, unemp_pct_hsp, unemp_pct_wht,
         key="race_eth", value="unemp_pct") %>%
  mutate(race_eth = case_when(
    race_eth == "unemp_pct_all" ~ "All",
    race_eth == "unemp_pct_blk" ~ "Black",
    race_eth == "unemp_pct_asn" ~ "Asian",
    race_eth == "unemp_pct_hsp" ~ "Hispanic/Latino",
    race_eth == "unemp_pct_wht" ~ "White (non-Hispanic)"
  )) %>%
  select(year, race_eth, unemp_pct)

unemployment_re2_latest <- unemployment_re2 %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(unemployment_re2, aes(x=year, y=unemp_pct, color=race_eth, label=sprintf("%.1f%%", 100*unemp_pct))) +
  ggtitle("Unemployment rate by race & ethnicity",
          subtitle="among people aged 16 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Unemployment rate", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table S2301)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0, 0.25)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=unemployment_re2_latest) +
  geom_text_repel(data=unemployment_re2_latest, direction="y", fontface="bold")

## EDUCATIONAL ATTAINMENT PLOTS
# Plot indicator values over time
educational_attainment_latest <- educational_attainment %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

educational_attainment_targets <- tribble(
  ~year, ~assoc_plus_pct,
  2025,  0.502,
  2050,  0.649
)
educational_attainment_targets <- bind_rows(educational_attainment_latest, educational_attainment_targets)

# Without targets
ggplot(educational_attainment, aes(x=year, y=assoc_plus_pct, label=sprintf("%.1f%%", 100*assoc_plus_pct))) +
  ggtitle("Share of population with an associate's degree or higher",
          subtitle="among people aged 25 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Share of population", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B15003)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.4, 0.5)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=educational_attainment_latest) +
  geom_text_repel(data=educational_attainment_latest, direction="y", fontface="bold")

# With targets
ggplot(educational_attainment, aes(x=year, y=assoc_plus_pct, label=sprintf("%.1f%%", 100*assoc_plus_pct))) +
  ggtitle("Share of population with an associate's degree or higher, with targets",
          subtitle="among people aged 25 and over in the CMAP region") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=TARGET_YEARS) +
  scale_y_continuous("Share of population", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B15003)") +
  theme_minimal() +
  coord_cartesian(ylim=c(0.3, 0.7)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_line(data=educational_attainment_targets, linetype="dashed") +
  geom_point(data=educational_attainment_targets) +
  geom_text_repel(data=educational_attainment_targets, direction="y", fontface="bold")

##EDUCATIONAL ATTAINMENT BY RACE/ETHNICITY PLOTS
# Plot indicator values over time
educational_attainment_re_latest <- educational_attainment_re %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(educational_attainment_re, aes(x=year, y=assoc_plus_pct, color=race_eth, label=sprintf("%.1f%%", 100*assoc_plus_pct))) +
  ggtitle("Share of population with an associate's degree or higher by race & ethnicity",
          subtitle="among people aged 25 and over in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Share of population", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (tables B15002, B15002B, B15002D, B15002H, B15002I)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0.0, 1.0)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=educational_attainment_re_latest) +
  geom_text_repel(data=educational_attainment_re_latest, direction="y", fontface="bold")

##MEDIAN HHOLD INCOME PLOTS 
# Plot indicator values over time
med_hh_inc_re_latest <- med_hh_inc_re %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(med_hh_inc_re, aes(x=year, y=real_med_hh_inc, color=race_eth, label=paste0("$", format(real_med_hh_inc, big.mark=",")))) +
  ggtitle("Median household income by race & ethnicity",
          subtitle=paste0("in ", base_year, " dollars, for households in the Chicago MSA")) +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Real median household income", minor_breaks=NULL, labels=scales::dollar) +
  labs(caption="Source: American Community Survey (tables B19013, B19013B, B19013D, B19013H, B19013I)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(0, 100000)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=med_hh_inc_re_latest) +
  geom_text_repel(data=med_hh_inc_re_latest, direction="y", fontface="bold")

## MEAN HHOLD INCOME PLOTS

# Plot indicator values over time
hh_inc_quintiles2 <- hh_inc_quintiles %>%
  gather(mean_hh_inc_change_q1, mean_hh_inc_change_q2, mean_hh_inc_change_q3, mean_hh_inc_change_q4, mean_hh_inc_change_q5, mean_hh_inc_change_top5pct,
         key="quintile", value="mean_hh_inc_change") %>%
  filter(quintile != "mean_hh_inc_change_top5pct") %>%
  mutate(quintile = case_when(
    quintile == "mean_hh_inc_change_q1" ~ "1st quintile (lowest income)",
    quintile == "mean_hh_inc_change_q2" ~ "2nd quintile",
    quintile == "mean_hh_inc_change_q3" ~ "3rd quintile",
    quintile == "mean_hh_inc_change_q4" ~ "4th quintile",
    quintile == "mean_hh_inc_change_q5" ~ "5th quintile (highest income)"
  )) %>%
  select(year, quintile, mean_hh_inc_change)

hh_inc_quintiles2_latest <- hh_inc_quintiles2 %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(hh_inc_quintiles2, aes(x=year, y=mean_hh_inc_change, color=quintile, label=sprintf("%+.1f%%", 100*mean_hh_inc_change))) +
  ggtitle(paste("Real mean household income by quintile relative to", base_year),
          subtitle="among households in the Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Real mean household income relative to 2006", minor_breaks=NULL, labels=scales::percent) +
  labs(caption="Source: American Community Survey (table B19081)",
       color="Income quintile") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(-0.2, 0.1)) +
  geom_hline(yintercept=0, color="#888888") +  # Emphasize y=0 for reference (if in plot)
  geom_line(size=1) +
  geom_point(data=hh_inc_quintiles2_latest) +
  geom_text_repel(data=hh_inc_quintiles2_latest, direction="y", fontface="bold")

## GINI COEFF PLOTS
# Plot indicator values over time
gini_latest <- gini %>%
  filter(year == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(gini, aes(x=year, y=gini_coeff, color=region, label=sprintf("%.3f", gini_coeff))) +
  ggtitle("Gini coefficient",
          subtitle="for the Chicago MSA and selected peer regions") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
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

## COMMUTE TIME BY RACE/ETHNICITY PLOTS
# Plot indicator values over time
commute_time_re2 <- commute_time_re %>%
  pivot_longer(cols = starts_with("COMMUTE_MINS_"), names_to = "race_eth",
               names_prefix = "COMMUTE_MINS_", values_to = "commute_time") %>%
  mutate(race_eth = case_when(
    race_eth == "BLACK" ~ "Black",
    race_eth == "ASIAN" ~ "Asian",
    race_eth == "HISPANIC" ~ "Hispanic/Latino",
    race_eth == "WHITE" ~ "White (non-Hispanic)"
  )) %>%
  select(YEAR, race_eth, commute_time)

commute_time_re2_latest <- commute_time_re2 %>%
  filter(YEAR == max(ACS_YEARS))  # Get only latest data points for labeling

ggplot(commute_time_re2, aes(x=YEAR, y=commute_time, color=race_eth, label=sprintf("%.1f", commute_time))) +
  ggtitle("Commute time by race & ethnicity",
          subtitle="among workers in the (PUMA-approximated) Chicago MSA") +
  scale_x_continuous("Year", minor_breaks=NULL, breaks=ACS_YEARS) +
  scale_y_continuous("Commute time (minutes)", minor_breaks=NULL) +
  labs(caption="Source: American Community Survey Public Use Microdata Sample (PUMS)",
       color="Race/ethnicity") +
  guides(color=guide_legend(override.aes=list(label=""))) +
  theme_minimal() +
  scale_color_brewer(palette="Set1") +
  coord_cartesian(ylim=c(25, 40)) +
  geom_line(size=1) +
  geom_point(data=commute_time_re2_latest) +
  geom_text_repel(data=commute_time_re2_latest, direction="y", fontface="bold")




