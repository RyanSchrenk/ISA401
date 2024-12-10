# Load required packages
library(rvest)
library(dplyr)
library(writexl)  # For exporting to Excel

# Initialize an empty data frame to store the results
all_pro_bowl_data <- data.frame()

# Define the base URL
base_url <- "https://www.pro-football-reference.com/years/"

# Loop through the years 2000 to 2023
for (year in 2005:2023) {
  # Construct the full URL for the current year
  url <- paste0(base_url, year, "/probowl.htm")
  
  # Try to read and scrape the page, handle errors
  tryCatch({
    # Read the webpage
    webpage <- read_html(url)
    
    # Extract the Pro Bowl data using the selector #div_pro_bowl
    pro_bowl_table <- webpage %>%
      html_element("#div_pro_bowl") %>%
      html_table(fill = TRUE)
    
    # Ensure column names are unique
    colnames(pro_bowl_table) <- make.unique(colnames(pro_bowl_table))
    
    # Add a year column to the data
    pro_bowl_table <- pro_bowl_table %>%
      mutate(Year = year)
    
    # Append the current year's data to the combined data frame
    all_pro_bowl_data <- bind_rows(all_pro_bowl_data, pro_bowl_table)
    
    # Print a message indicating success for this year
    message("Successfully scraped data for year: ", year)
    
  }, error = function(e) {
    # Print a message indicating an error for this year
    message("Skipping year ", year, " due to error: ", e$message)
  })
  
  # Pause to comply with rate limits
  Sys.sleep(6)  # Pause for 6 seconds to ensure no more than 10 requests per minute
}

# Remove unwanted columns
columns_to_remove <- c("G", "GS", "Cmp", "Att", "Yds", "TD", "Int",
                       "Att.1", "Yds.1", "TD.1", "Rec", "Yds.2", "TD.2",
                       "Solo", "Sk", "Int.1", "All-pro teams")

all_pro_bowl_data <- all_pro_bowl_data %>%
  select(-all_of(columns_to_remove))

# Export the combined data frame to an Excel file
write_xlsx(all_pro_bowl_data, "pro_bowl_data_2000_2023.xlsx")

message("Data successfully saved as 'pro_bowl_data_2000_2023.xlsx'")