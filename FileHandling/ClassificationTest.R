library(openxlsx)

# read xlsx with 200 manually labeled descriptions
newlabeled_profiles_testdata <- read.xlsx("labeled_profiles_candm.xlsx")

# only choose first 200 rows, because these are labeled
newlabeled_profiles_testdata <- newlabeled_profiles_testdata[1:200,]

# Substitute values in 'label' with correct label names
newlabeled_profiles_testdata$label <- as.character(newlabeled_profiles_testdata$label)

# export with relevant columns for bert
newlabeled_profiles_testdata_bert <- newlabeled_profiles_testdata[c("X", "twitter_handle", "example", "user_id", "party", "label")]

write.table(newlabeled_profiles_testdata_bert, 
            file = "labeled_testdata_bert.csv",
            sep = ",",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes


#-- modify dataframe & export csv for small-text
newlabeled_profiles_testdata_smalltext <- newlabeled_profiles_testdata_bert[c("example", "label")]

write.table(newlabeled_profiles_testdata_smalltext, 
            file = "labeled_testdata_smalltext.csv",
            sep = "\t",          # Use tab as the delimiter
            eol = "\n",          # Set end of line character
            na = "",             # How to represent missing values
            row.names = FALSE,   # Do not write row names
            col.names = TRUE,    # Write column names
            quote = TRUE,        # Use quotes
            qmethod = "double")  # Double quotes for escaping quotes
