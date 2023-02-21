# Load the required packages tidyverse and here
library(tidyverse)
library(here)
library(DT)

# Set the working directory
wd <- here::here()

# Read in the results from the variogram calculations
results_import <- read_csv(file.path(wd, "/data/variogram_outputs/mwi_sample_points_variogram.csv"))

# Clean results. Treat (p1_id,p2_id) == (p2_id,p1_id) as a duplicate row.
results <- results_import |>
    mutate(row_id_1 = pmax(p1_id, p2_id), row_id_2 = pmin(p1_id, p2_id)) |>
    distinct(row_id_1, row_id_2, .keep_all = TRUE)


## Overall summary statistics
national_summary <- results |>
    summarize(
        pairs_n = n(),
        points_n = n_distinct(p1_id),
        ph_variogram_mean = mean(ph_variogram),
        ph_vario_sd = sd(ph_variogram),
        log_SOC_variogram_mean = mean(log_SOC_variogram),
        log_SOC_vario_sd = sd(log_SOC_variogram)
    )



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
    )

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
    )





# plot the pH variogram (National)
pH_semivariogram <- results %>%
    sample_frac(0.05) |> # sample 5% of the data for plot
    ggplot(aes(x = h, y = ph_variogram)) +
    # geom_point() +
    geom_line() +
    ggtitle("pH Variogram") +
    xlab("Distance (km)") +
    ylab("Semivariance") +
    theme_bw()

# plot the log SOC variogram (National)
log_SOC_semivariogram <- results %>%
    sample_frac(0.05) |> # sample 5% of the data for plot
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
