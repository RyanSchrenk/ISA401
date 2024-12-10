all_pro_df = read.csv("All_Pro_Data.csv")


# eliminate unecessary columns
all_pro_df <- all_pro_df[, -c(4:21)]

# change has AP status to binary
all_pro_df$has_AP <- ifelse(all_pro_df$has_AP == "Yes", 1, 0)


# read in new data
pro_bowl_df = read.csv("pro_bowl_data_2005_2023.csv")







# combine the two dataframes

# Create a new column in allpro_df initialized to 0
all_pro_df$Pro_Bowl <- 0

# Loop through each row in probowl_df
for(i in 1:nrow(pro_bowl_df)) {
  # Get the current player and year from probowl_df
  player <- gsub("[^a-zA-Z ]", "", pro_bowl_df$Player[i])
  year <- pro_bowl_df$Year[i]
  pos <- pro_bowl_df$Pos[i]
  tm <- pro_bowl_df$Tm[i]
  
  
  # Check if the player and year combination exists in allpro_df
  match_idx <- which(all_pro_df$Player == player & all_pro_df$Year == year)
  
  if(length(match_idx) > 0) {
    # If a match is found, add 1 to the NewColumn for that row in allpro_df
    all_pro_df$Pro_Bowl[match_idx] <- 1
  } else {
    # If no match is found, add a new row to allpro_df with the player, year, and NewColumn = 1
    all_pro_df <- rbind(all_pro_df, data.frame(Pos = pos, Tm = tm, All.pro.teams = "n/a", Player = player, Year = year, has_AP = 0, AP_status = "n/a", Pro_Bowl = 1))
  }
}

# save the dataframe to a csv
write.csv(all_pro_df, "data_combined_401project2.csv", row.names = FALSE)

