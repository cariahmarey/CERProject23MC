install.packages(c("irr", "dplyr"))
library(irr)
library(dplyr)
library(openxlsx)

# read xlsx with 200 manually labeled descriptions
newlabeled_profiles_testdata <- read.xlsx()

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
alpha_result <- kripp.alpha(as.matrix(newlabeled_profiles_testdata[, c("label_r1", "label_r2")]))
print(alpha_result)


