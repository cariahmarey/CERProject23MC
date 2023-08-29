#-------- connect the profiles + profiledescriptions to their user-ids

# load necessary csvs
profiledescriptions_df <- read.csv("username_with_description_cleaned.csv")
allprofiles_df <- read.csv("EPINetz_TwitterPoliticians_2021.csv")

# rename column "user" to "twitter_handle"
colnames(profiledescriptions_df)[2] <- "twitter_handle"

# get userids and party from allprofiles_df
profiledescriptions_df$user_id <- allprofiles_df$user_id[match(profiledescriptions_df$twitter_handle, allprofiles_df$twitter_handle)]
profiledescriptions_df$party <- allprofiles_df$party[match(profiledescriptions_df$twitter_handle, allprofiles_df$twitter_handle)]

# export as csv
write.csv2(profiledescriptions_df, "profiledescriptions_withpartyanduserid.csv", sep = "\t", row.names = FALSE)


#-------- create the initial training CSV
library(xlsx)
library(dplyr)

# define function to remove line breaks from a single string
remove_linebreaks <- function(s) {
  return(gsub("\n|\r", " ", s))
}

# define function to replace multiple spaces with a single space
clean_spaces <- function(x) {
  trimmed <- gsub("^\\s+|\\s+$", "", x) # remove leading and trailing spaces
  gsub("\\s+", " ", trimmed) # replace multiple spaces with a single space
}


# import xlsx with labels
labeledandunlabeled_profiles_df <- read.xlsx("LabeledandUnlabeled_Profiles.xlsx", sheetIndex = 1)

# Apply the functions line breaks and space functions from above
labeledandunlabeled_profiles_df <- data.frame(lapply(labeledandunlabeled_profiles_df, function(x) {
  if (is.character(x) || is.factor(x)) {
    return(remove_linebreaks(x))
  } else {
    return(x)
  }
}))

labeledandunlabeled_profiles_df$example <- sapply(labeledandunlabeled_profiles_df$example, clean_spaces)



#---- for small-text:
# create subset from xlsx with relevant columns an labeled examples
labeled_profiles_df <- labeledandunlabeled_profiles_df %>% 
  filter(row_number() < min(which(is.na(Label))))

# rename column "profile" to "example"
colnames(labeled_profiles_df)[3] <- "example"
# rename column "LabelMarius" to "twitter_handle"
colnames(labeled_profiles_df)[6] <- "label"



#-- modify dataframe & export csv for small-text
labeled_profiles_df_smalltext <- labeled_profiles_df[c("example", "label")]

write.table(labeled_profiles_df_smalltext, 
            file = "initial_train_smalltext.csv",
            sep = "\t",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes



#-- modify dataframe for BERT
library(readxl)
library(dplyr)

# import xlsx file with the examples labeled in the small-text classification process
file_path <- "True Labels/CER_ClassificationProcess.xlsx"

# List all the sheets in the Excel file
sheet_names <- excel_sheets(file_path)

# Initialize an empty data frame
classified_examples_fromsmalltext <- data.frame()

# Loop through the sheet names, read each sheet, and append to the all_data dataframe
for (sheet in sheet_names) {
  sheet_data <- read_excel(file_path, sheet = sheet)
  classified_examples_fromsmalltext <- bind_rows(classified_examples_fromsmalltext, sheet_data)
}

# Apply the functions line breaks and space functions from above
classified_examples_fromsmalltext <- data.frame(lapply(classified_examples_fromsmalltext, function(x) {
  if (is.character(x) || is.factor(x)) {
    return(remove_linebreaks(x))
  } else {
    return(x)
  }
}))

classified_examples_fromsmalltext$text <- sapply(classified_examples_fromsmalltext$text, clean_spaces)

# replace every 4 with a 2
# Substitute every occurrence of a 4 with a 2 in 'target_column' because it got parsed wrong
classified_examples_fromsmalltext$text <- gsub("4", "2", classified_examples_fromsmalltext$text)

# rename column "text" to "example"
colnames(classified_examples_fromsmalltext)[1] <- "example"
# rename column "true label" to "label"
colnames(classified_examples_fromsmalltext)[3] <- "label"
# delete second column with predicted label
classified_examples_fromsmalltext[[2]] <- NULL

# rename column "text" to "example" from full dataset
colnames(labeledandunlabeled_profiles_df)[3] <- "example"
# rename column "true label" to "label" from full dataset
colnames(labeledandunlabeled_profiles_df)[6] <- "label"

# get X, twitter_handle, user_id and party from full dataset
classified_examples_fromsmalltext$X <- labeledandunlabeled_profiles_df$X[match(classified_examples_fromsmalltext$example, labeledandunlabeled_profiles_df$example)]
classified_examples_fromsmalltext$twitter_handle <- labeledandunlabeled_profiles_df$twitter_handle[match(classified_examples_fromsmalltext$example, labeledandunlabeled_profiles_df$example)]
classified_examples_fromsmalltext$user_id <- labeledandunlabeled_profiles_df$user_id[match(classified_examples_fromsmalltext$example, labeledandunlabeled_profiles_df$example)]
classified_examples_fromsmalltext$party <- labeledandunlabeled_profiles_df$party[match(classified_examples_fromsmalltext$example, labeledandunlabeled_profiles_df$example)]

labeled_profiles_df$label <- as.character(labeled_profiles_df$label)
classified_examples_fromsmalltext$label <- as.character(classified_examples_fromsmalltext$label)


labeled_profiles_df_bert <- bind_rows(labeled_profiles_df, classified_examples_fromsmalltext)

# Substitute values in 'label' with correct label names
labeled_profiles_df_bert <- labeled_profiles_df_bert %>%
  mutate(label = case_when(
    label == "0" ~ "0 Linke: ökonomisch links + libertär",
    label == "1" ~ "1 Grüne: ökonomisch neutral + libertär",
    label == "2" ~ "2 SPD: ökonomisch neutral + libertär/autoritär",
    label == "3" ~ "3 CDU/CSU: ökonomisch neutral + autoritär",
    label == "4" ~ "4 FDP: ökonomisch rechts + libertär/autoritär",
    label == "5" ~ "5 AfD: ökonomisch rechts + autoritär",
    label == "6" ~ "6 keine Kategorie",
    TRUE ~ label # If none of the above conditions are met, retain original value
  ))

#export csv for BERT
write.table(labeled_profiles_df_bert, 
            file = "initial_train_bert.csv",
            sep = ",",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes

#-------- create dataframe with only unlabeled rows
library(xlsx)
library(dplyr)

# import xlsx with pre-labeled sampled rows
labeled_profiles_df <- read.xlsx("Profiles_withPreLabeling.xlsx", sheetIndex = 1)
# only select the unlabeled rows
unlabeled_profiles_df <- labeled_profiles_df %>%
  filter(row_number() > min(which(is.na(LabelMarius))))
# only select column "profile" 
unlabeled_profiles_df <- unlabeled_profiles_df["profile"]
# rename column "profile" to "example"
colnames(unlabeled_profiles_df)[1] <- "example"

# write final csv
write.csv(unlabeled_profiles_df, file = "trainingdata_classifier_cer.csv", row.names = F)





