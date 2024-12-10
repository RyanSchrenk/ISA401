library(rvest)
library(dplyr)
library(writexl)

# Initialize an empty data frame
standings_data <- data.frame()

# Define the base URL
base_url <- "https://www.pro-football-reference.com/years/"

# Loop through the years 2005 to 2023
for (year in 2005:2023) {
  # Construct the full URL for the current year
  url <- paste0(base_url, year, "/")
  
  tryCatch({
    # Read the webpage
    webpage <- read_html(url)
    
    # Extract AFC standings table
    afc_table <- webpage %>%
      html_element("#AFC") %>%
      html_table(fill = TRUE) %>%
      mutate(Conference = "AFC", Year = year)
    
    # Extract NFC standings table
    nfc_table <- webpage %>%
      html_element("#NFC") %>%
      html_table(fill = TRUE) %>%
      mutate(Conference = "NFC", Year = year)
    
    # Combine both tables
    standings <- bind_rows(afc_table, nfc_table)
    
    # Append the year's data to the overall standings
    standings_data <- bind_rows(standings_data, standings)
    
    message("Successfully scraped standings data for year: ", year)
    
  }, error = function(e) {
    message("Skipping year ", year, ": ", e$message)
  })
  
  # Pause to comply with rate limits
  Sys.sleep(6)
}

# Export the combined data to an Excel file
write_xlsx(standings_data, "standings_data_2005_2023.xlsx")
message("Data successfully saved as 'standings_data_2005_2023.xlsx'")