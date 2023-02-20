# Read in the results from the variogram calculations from the csv file in data\variogram_outputs\mwi_sample_points_variogram.csv
results <- read_csv(file.path(wd, "/data/variogram_outputs/mwi_sample_points_variogram.csv"))

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





# # Clean up the results data frame by removing rows with missing values
# results_clean <- results %>% drop_na()

# # Compute summary statistics for the variogram
# vario_summary <- tibble(District = character(), n = numeric(), vario_mean = numeric(), vario_sd = numeric())

# # Compute the summary statistics for the variogram for each district
# for (distr in unique(results_clean$p1_District)) {
#     # select the rows for the district
#     distr_summary <- results_clean %>%
#         filter(p1_District == distr & p2_District == distr) %>%
#         # compute the summary statistics
#         group_by(p1_District) %>%
#         summarize(
#             n = n(),
#             vario_mean = mean(vario),
#             vario_sd = sd(vario)
#         ) |>
#         # rename the District column from p1_District
#         rename(District = p1_District)
#     # append the summary statistics to the variogram summary dataframe
#     vario_summary <- rbind(vario_summary, distr_summary)
# }


# # Plot the variogram
# for (distr in unique(results_clean$p1_District)) {
#     # select the rows for the district
#     results_clean %>%
#         filter(p1_District == distr & p2_District == distr) %>%
#         # plot the variogram
#         ggplot(aes(x = h, y = vario)) +
#         geom_point() +
#         geom_line() +
#         # geom_errorbar(aes(ymin = vario_mean - vario_sd, ymax = vario_mean + vario_sd), width = 0.1) +
#         ggtitle("Experimental Variogram") +
#         xlab("Distance (km)") +
#         ylab("Semivariance") +
#         theme_bw()
# }


# # Plot the h on the horizontal axis and the variogram on the vertical axis
# results %>%
#     ggplot(aes(x = h, y = vario)) +
#     geom_point() +
#     geom_line() +
#     ggtitle("Experimental Variogram") +
#     xlab("Distance (km)") +
#     ylab("Semivariance") +
#     theme_bw()

# # filter points where p1_District == p2_Dristrict. Then Plot the h on the horizontal axis and the variogram on the vertical axis and group the points by district. Make a facet plots with a different plot for each district and also indicate the number of points in each plot.







# # filter points where p1_District == p2_Dristrict. Then Plot the h on the horizontal axis and the variogram on the vertical axis and group the points by district. Make a facet plots with a different plot for each district and also indicate the number of points in each plot.






# results %>%
#     filter(p1_District == p2_District) %>%
#     ggplot(aes(x = h, y = vario, color = p1_District)) +
#     geom_point() +
#     geom_line() +
#     ggtitle("Experimental Variogram") +
#     xlab("Distance (km)") +
#     ylab("Semivariance") +
#     theme_bw() +
#     facet_wrap(~p1_District)




# results %>%
#     ggplot(aes(x = h, y = vario, color = p1_District)) +
#     geom_point() +
#     geom_line() +
#     ggtitle("Experimental Variogram") +
#     xlab("Distance (km)") +
#     ylab("Semivariance") +
#     theme_bw() +
#     facet_wrap(~p1_District)



# results %>%
#     ggplot(aes(x = h, y = vario, color = p1_District)) +
#     geom_point() +
#     geom_line() +
#     ggtitle("Experimental Variogram") +
#     xlab("Distance (km)") +
#     ylab("Semivariance") +
#     theme_bw()
