library(jsonlite)

json <- fromJSON('disease_20160803.json')
df_raw <- json$data
df_all <- unique(df_raw)
df_all$OCCRRNC_DE <- as.Date(df_all$OCCRRNC_DE, "%Y%m%d")
df <- df_all[c(2, 3, 5, 11, 12, 13)]

write.csv(df, file = 'refined.csv', row.names = FALSE)