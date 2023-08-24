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
labeledandunlabeled_profiles_df <- read.xlsx("LabeledAndUnlabeled_Profiles.xlsx", sheetIndex = 1)


#---- for small-text:
# create subset from xlsx with relevant columns an labeled examples
labeled_profiles_df <- labeledandunlabeled_profiles_df %>% 
  filter(row_number() < min(which(is.na(Label))))

# rename column "profile" to "example"
colnames(labeled_profiles_df)[3] <- "example"
# rename column "LabelMarius" to "twitter_handle"
colnames(labeled_profiles_df)[6] <- "label"

# Function to remove line breaks from a single string
remove_linebreaks <- function(s) {
  return(gsub("\n|\r", " ", s))
}

# Apply the function to remove line breaks from the entire dataframe
labeled_profiles_df <- data.frame(lapply(labeled_profiles_df, function(x) {
  if (is.character(x) || is.factor(x)) {
    return(remove_linebreaks(x))
  } else {
    return(x)
  }
}))

# modify dataframe for BERT
library(data.table)
labeled_profiles_df_bert <- labeled_profiles_df

# Add a new column with value 1 to the dataframe
labeled_profiles_df_bert$value <- 1

# Convert df to a data table
setDT(labeled_profiles_df_bert)

# Reshape data
labeled_profiles_df_bert_wide <- dcast(labeled_profiles_df_bert, ... ~ label, value.var = "value", fun.aggregate = sum, fill = 0)

# Now, remove the original 'label' column if it exists in df_wide
labeled_profiles_df_bert_wide[, label := NULL]

#export csv for BERT
write.table(labeled_profiles_df_bert_wide, 
            file = "initial_train_bert.csv",
            sep = ",",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes


# modify dataframe & export csv for small-text
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





