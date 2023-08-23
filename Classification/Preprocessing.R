#-------- connect the profiles + profiledescriptions to their user-ids

# load necessary csvs
profiledescriptions_df <- read.csv("username_with_description_cleaned.csv")
allprofiles_df <- read.csv("EPINetz_TwitterPoliticians_2021.csv")

# rename column "user" to "twitter_handle"
colnames(profiledescriptions_df)[2] <- "twitter_handle"

# get userids from allprofiles_df
profiledescriptions_df$user_id <- allprofiles_df$user_id[match(profiledescriptions_df$twitter_handle, allprofiles_df$twitter_handle)]
profiledescriptions_df$party <- allprofiles_df$party[match(profiledescriptions_df$twitter_handle, allprofiles_df$twitter_handle)]

# export as csv
write.csv2(profiledescriptions_df, "profiledescriptions_withpartyanduserid.csv", sep = "\t", row.names = FALSE)


#-------- create the initial training CSV
library(xlsx)
library(dplyr)

# import xlsx with labels
labeled_profiles_df <- read.xlsx("Labeled_Profiles_Marius.xlsx", sheetIndex = 1)

# create subset from xlsx with relevant columns an labeled examples
labeled_profiles_df <- labeled_profiles_df[c("profile", "user_id", "Label.Marius")]
labeled_profiles_df_subset <- labeled_profiles_df %>% 
  filter(row_number() < min(which(is.na(Label.Marius))))

# Function to remove line breaks from a single string
remove_linebreaks <- function(s) {
  return(gsub("\n|\r", " ", s))
}

# Apply the function to remove line breaks from the entire dataframe
labeled_profiles_df_subset <- data.frame(lapply(labeled_profiles_df_subset, function(x) {
  if (is.character(x) || is.factor(x)) {
    return(remove_linebreaks(x))
  } else {
    return(x)
  }
}))

# export csv
write.table(labeled_profiles_df_subset, 
            file = "initial_train.csv",
            sep = "\t",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes


#-------- create folds for cross-validation
library(caret)
library(xlsx)
library(dplyr)

# import xlsx with pre-labeled sampled rows
labeled_profiles_df <- read.xlsx("Profiles_withoutPreLabeling.xlsx", sheetIndex = 1)
# only select the unlabeled rows
unlabeled_profiles_df <- labeled_profiles_df %>%
  filter(row_number() > min(which(is.na(Label.Marius))))
unlabeled_profiles_df <- 

set.seed(123) # Set a seed for reproducibility
folds <- createFolds(unlabeled_profiles_df$Label.Marius, k = 5)

install.packages("installr")
library(installr)
updateR()


