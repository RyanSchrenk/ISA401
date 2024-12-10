#ISA401project!


# Getting the All Pro data into a dataframe ---------------------------------------

# Load required packages
library(rvest)
library(dplyr)

# Initialize an empty data frame to store the results
all_pro_bowl_data <- data.frame()

# Define the base URL
base_url <- "https://www.pro-football-reference.com/years/"

# Loop through the years 2005 to 2023
for (year in 2005:2023) {
  # Construct the full URL for the current year
  url <- paste0(base_url, year, "/allpro.htm")
  
  # Try to read and scrape the page, handle errors
  tryCatch({
    # Read the webpage
    webpage <- read_html(url)
    
    # Extract the Pro Bowl data using the selector #div_pro_bowl
    all_pro_bowl_table <- webpage %>%
      html_element("#div_all_pro") %>%
      html_table(fill = TRUE)
    
    # Ensure column names are unique
    colnames(all_pro_bowl_table) <- make.unique(colnames(all_pro_bowl_table))
    
    # Add a year column to the data
    all_pro_bowl_table <- all_pro_bowl_table %>%
      mutate(Year = year)
    
    # Append the current year's data to the combined data frame
    all_pro_bowl_data <- bind_rows(all_pro_bowl_data, all_pro_bowl_table)
    
    # Print a message indicating success for this year
    message("Successfully scraped data for year: ", year)
    
  }, error = function(e) {
    # Print a message indicating an error for this year
    message("Skipping year ", year, " due to error: ", e$message)
  })
  # to prevent too many requests to the system
  Sys.sleep(7)
}

# View the first few rows of the combined data
head(all_pro_bowl_data)



# Cleaning the Data -------------------------------------------------------

# create a copy of the data to manipulate
all_pro_bowl_data2 = all_pro_bowl_data

# add columns to designate AP all pro status
all_pro_bowl_data2$has_AP <- ifelse(grepl("AP: 1st Tm|AP: 2nd Tm", all_pro_bowl_data2$`All-pro teams`), "Yes", "No")
all_pro_bowl_data2$AP_status <- ifelse(
  grepl("AP: 1st Tm", all_pro_bowl_data2$`All-pro teams`), "AP: 1st Tm",
  ifelse(grepl("AP: 2nd Tm", all_pro_bowl_data2$`All-pro teams`), "AP: 2nd Tm", "Not all pro"))

# Save the data
write.csv(all_pro_bowl_data2, file = "All_Pro_Data.csv", row.names = FALSE)
