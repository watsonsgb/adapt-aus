library(terra)
library(tidyr)
library(stringr)
library(dplyr)

# Expected patterns: e.g. "f2022.c1991.p1991.t2022.nc" -> 2022

#full_rast <- rast("data/aba_res/f2022.c1991.p1991.t2022.nc")

profit <- rast("data/aba_res/f2022.c1991.p1991.t2022.nc")["FBP_fbp_hat_ha"]
profit_df <- as.data.frame(x = profit, xy = TRUE)

# 0) Point to your folder of .nc files
nc_dir <- "data/aba_res"

# 1) List + extract climate year with regex, then order by year
rx <- "^f(\\d{4})\\.c(\\d{4})\\.p(\\d{4})\\.t(\\d{4})\\.nc$"
files <- list.files(nc_dir, pattern = "\\.nc$", full.names = TRUE)

file_df <- tibble(file = files) |>
  mutate(fname = basename(file),
         farm_year   = str_match(fname, rx)[,2],
         climate_year= str_match(fname, rx)[,3],
         price_year  = str_match(fname, rx)[,4],
         tech_year   = str_match(fname, rx)[,5]) |>
  mutate(across(c(farm_year, climate_year, price_year, tech_year), as.integer)) |>
  arrange(climate_year)

# 2) Read the profit layer across all years as a single SpatRaster stack
#    NOTE: `subds` lets you pull the same layer by name from each file
profit_stack <- rast(file_df$file, subds = "FBP_fbp_hat_ha")

# 3) Name layers by their year for clarity
names(profit_stack) <- paste0("y", file_df$climate_year)

# 4) Grab a stable farm/cell ID and coordinates once (any file will do)
#    The dataset provides a `farmno` layer (grid id YYYXXX). :contentReference[oaicite:1]{index=1}
farmno_r <- rast(file_df$file[1], subds = "farmno")
xy_df    <- as.data.frame(farmno_r, xy = TRUE, na.rm = FALSE) |>
  rename(farmno = farmno)

# 5) Convert the profit stack to a wide data.frame aligned to `xy_df`
profit_wide <- as.data.frame(profit_stack, xy = FALSE, na.rm = FALSE)
stopifnot(nrow(profit_wide) == nrow(xy_df))

wide_df <- bind_cols(xy_df, profit_wide)  # columns: x, y, farmno, y1991, y1992, ...

# 6) Make it LONG: one row per farmno x year
profit_long <- wide_df |>
  pivot_longer(
    cols = starts_with("y"),
    names_to   = "year",
    names_pattern = "^y(\\d{4})$",
    values_to  = "profit_ha"
  ) |>
  mutate(year = as.integer(year)) |>
  arrange(farmno, year)

# Result: `profit_long` has columns: x, y, farmno, year, profit_ha
