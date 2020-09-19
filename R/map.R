


library(ggmap)
atms = readxl::read_excel(here::here("data", "techcombank_atms_with_gps_coordinates.xlsx"))

## sanity check of GPS values
quantile(atms$lon[atms$province == "Hà Nội"], na.rm = T)
quantile(atms$lat[atms$province == "Hà Nội"], na.rm = T)

quantile(atms$lat[atms$province == "Hồ Chí Minh"], na.rm = T)
quantile(atms$lon[atms$province == "Hồ Chí Minh"], na.rm = T)

## quick map
hn = qmplot(lon, lat, data = atms[atms$province == "Hà Nội" & atms$lon < 106, ], maptype = "toner-lite", color = I("brown"))
ggsave(plot = hn, filename = here::here("figures", "hn.png"), type = "cairo-png")

hcm = qmplot(lon, lat, data = atms[atms$province == "Hồ Chí Minh", ], maptype = "toner-lite", color = I("brown"))
ggsave(plot = hcm, filename = here::here("figures", "hcm.png"), type = "cairo-png")
