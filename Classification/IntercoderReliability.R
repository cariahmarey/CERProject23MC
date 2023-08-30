install.packages(c("irr", "dplyr"))
library(irr)
library(dplyr)
library(openxlsx)

# read xlsx with 200 manually labeled descriptions
newlabeled_profiles_testdata <- read.xlsx("labeled_profiles_candm.xlsx")
# only choose first 200 rows
newlabeled_profiles_testdata <- newlabeled_profiles_testdata[1:200,]

# calculate percentage agreement
percentage_agreement <- newlabeled_profiles_testdata %>%
  mutate(agreement = ifelse(label_r1 == label_r2, 1, 0)) %>%
  summarise(percentage = mean(agreement, na.rm = TRUE) * 100) %>%
  pull(percentage)

print(paste0("Percentage Agreement: ", percentage_agreement, "%"))

# calculate Cohen's Kappa
kappa_result <- kappa2(newlabeled_profiles_testdata[, c("label_r1", "label_r2")])
print(kappa_result)

# calculate Krippendorf's Alpha
# Assuming newlabeled_profiles_testdata is your data frame
data_matrix <- as.matrix(newlabeled_profiles_testdata[, c("label_r1", "label_r2")])

# Transpose the matrix
transposed_matrix <- t(data_matrix)

# Calculate Krippendorff's Alpha
alpha_result <- kripp.alpha(transposed_matrix)
print(alpha_result)



