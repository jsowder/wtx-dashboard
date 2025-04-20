library(wtx)
library(mapgl)

# Read Data
parcels <-
  wtx_parcel |>
  mutate(
    `Appraised Value Per Acre` = if_else(acreage > .05, market_val/acreage, 0),
    height = `Appraised Value Per Acre` / 20000
  )

# Return Map
maplibre(
  style = carto_style("dark-matter"),
  center = c(-97.1384, 31.5525),  # Downtown Waco
  zoom = 12,
  pitch = 60,
  bearing = 20
) |>
  add_fill_extrusion_layer(
    "value",
    source = parcels,
    fill_extrusion_height = get_column("height"),
    fill_extrusion_color = interpolate(
      column = "height",
      values = c(0, 250, 500, 1000, 3000),
      stops = c("#008000", "#FFFF00", "#FFA500", "#FF0000", "#800080")
    )
  )
