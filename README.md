# CERProject23MC
University project for the seminar "Computational Empirical Research" by
* Marius Behret
* Cuong Vo Ta
## Data Collection
* The original twitter dataset of [The German Federal Election 2021](https://blog.gesis.org/the-german-federal-election-2021-twitter-dataset/) is in `Data Collection/EPINetz_TwitterPoliticians_2021.csv`
* In the scraping folder is the python script `getTwitterData.py` which is using the [Rettiwt-API](https://github.com/Rishikant181/Rettiwt-API) to fetch profile description of twitter users
* The complete and cleaned dataset with 2048 twitter user and their profile description can be found in `Data Collection/username_with_description_cleaned.csv`

## FileHandling & Classification
* Used to prepare and handle the different files with labeled and unlabeled data
* `FileHandling & Classification/Predicted Labels` contains the CSVs with the 350 predicted labels from the active learning process from small-text
* `FileHandling & Classification/True Labels` contains an XLSX with the 350 predicted and the manually coded labels 
* `FileHandling & Classification/initial_train_bert.csv` & `FileHandling & Classification/initial_train_bert.csv` are the training files for the different machine-learning-methods
* In `FileHandling & Classification/labeled_profiles_candm.xlsx` there are the 200 manually labeled examples from both coders and in `FileHandling & Classification/labeled_testdata_bert.csv` & `FileHandling & Classification/labeled_testdata_smalltext.csv` are the according datasets for the test run
* `FileHandling & Classification/LabeledandUnlabeled_Profiles.xlsx` contains the 70 prelabeled texts + all other unlabeled texts
* A simple list of the categories can be found in `FileHandling & Classification/Labels.txt`
* In  `FileHandling & Classification/profiledescriptions_withpartyanduserid.csv` there are all profiles that have a profile description, with their twitter_handle, user_id and party
* The file `FileHandling & Classification/trainingdata_classifier_cer.csv` holds the training data for the small-text active classification process

## small-text
* `small-text/FirstPrediction_Classifier_CER.ipynb` is for the first prediction, `small-text/Classifier_Main_CER.ipynb` for the following and `small-text/ClassificationTest_CER.ipynb` for the evaluation test
* `small-text/class_balancer` is from the small-text library

## BERT
* The Juypter Notebooks for finetuning the different BERT models are in the `jupyter-notebooks` directory
* `bert_1860.ipynb` is using the big dataset of 1860 profile descriptions
* `bert_420.ipynb` is using the small dataset of 420 profile descriptions
* With the variable `pretrained_LM` one can choose between the BERT models or other language models
