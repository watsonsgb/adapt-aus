library(terra)

# Expected patterns: e.g. "f2022.c1991.p1991.t2022.nc" -> 2022


#full_rast <- rast("data/aba_res/f2022.c1991.p1991.t2022.nc")

profit <- rast("data/aba_res/f2022.c1991.p1991.t2022.nc")["FBP_fbp_hat_ha"]

profit_df <- as.data.frame(x = profit, xy = TRUE)

names(profit_df) <- c("lon","lat",paste0("y",1990:2022))

profit_long <- profit_df |>
  pivot_longer(starts_with("y"), names_to="year", values_to="profit_ha") |>
  mutate(year = as.integer(sub("y","",year)))

time(profit)

data_path <- ""
