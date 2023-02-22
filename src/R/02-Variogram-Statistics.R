# Load the required packages tidyverse and here
library(tidyverse)
library(here)
library(DT)

# Set the working directory
wd <- here::here()

# Read in results csv
results <- read_csv(file.path(wd, "data/variogram_outputs/mwi_raw_sample_points_variograms_2023-02-22-16-37-39.csv"), progress = show_progress())

# Calculate summary statistics for the national district and EA levels
national_summary <- results |>
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    ) |>
    mutate(Admin = "National-all points") |>
    select(Admin, everything())

national_summary_inter_district <- results |>
    filter(p1_District == p2_District) %>%
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    ) |>
    mutate(Admin = "National-within District") |>
    select(Admin, everything())

national_summary_inter_ea <- results |>
    filter(p1_EACODE == p2_EACODE) %>%
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    ) |>
    mutate(Admin = "National-within EA") |>
    select(Admin, everything())



## District summary statistics
district_summary <- results |>
    filter(p1_District == p2_District) %>%
    rename(District = p1_District) |>
    group_by(District) %>%
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    ) |>
    rename(Admin = District)

## EA summary statistics
EA_summary <- results |>
    filter(p1_EACODE == p2_EACODE) %>%
    rename(EACODE = p1_EACODE) |>
    group_by(EACODE) %>%
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    ) |>
    rename(Admin = EACODE) |>
    mutate(Admin = as.character(Admin))


## Combine National the summary statistics for
combined_national_summary_stats <- bind_rows(national_summary, national_summary_inter_district, national_summary_inter_ea)


# plot the pH variogram (National)
pH_semivariogram <- results %>%
    sample_frac(0.005) |> # sample 5% of the data for plot
    ggplot(aes(x = h, y = ph_variogram)) +
    # geom_point() +
    geom_line() +
    ggtitle("pH Variogram") +
    xlab("Distance (km)") +
    ylab("Semivariance") +
    theme_bw()

# plot the log SOC variogram (National)
log_SOC_semivariogram <- results %>%
    sample_frac(0.005) |> # sample 5% of the data for plot
    ggplot(aes(x = h, y = log_SOC_variogram)) +
    # geom_point() +
    geom_line() +
    ggtitle("log SOC Variogram") +
    xlab("Distance (km)") +
    ylab("Semivariance") +
    theme_bw()

# plot the pH variogram per district
pH_Dist_semivariogram <- results %>%
    filter(p1_District == p2_District) %>%
    ggplot(aes(x = h, y = ph_variogram)) +
    geom_line() +
    ggtitle("pH Variogram") +
    xlab("Distance (km)") +
    ylab("Semivariance") +
    theme_bw() +
    facet_wrap(~p1_District)

# plot the log SOC variogram per district
log_SOC_Dist_semivariogram <- results %>%
    filter(p1_District == p2_District) %>%
    ggplot(aes(x = h, y = log_SOC_variogram)) +
    geom_line() +
    ggtitle("log SOC Variogram") +
    xlab("Distance (km)") +
    ylab("Semivariance") +
    theme_bw() +
    facet_wrap(~p1_District)
