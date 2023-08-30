# CERProject23MC
University project for the seminar "Computational Empirical Research" by
* Marius Behret
* Cuong Vo Ta
## Scrape data
* The original twitter dataset of [The German Federal Election 2021](https://blog.gesis.org/the-german-federal-election-2021-twitter-dataset/) is in `data/EPINetz_TwitterPoliticians_2021.csv`
* In the scraping directory is the python script `getTwitterData.py` which is using the [Rettiwt-API](https://github.com/Rishikant181/Rettiwt-API) to fetch profile description of twitter users
* The complete and cleaned dataset with 2048 twitter user and their profile description can be found in `data/username_with_description_cleaned.csv`

## Classification

## Small-Text

## BERT
* The Juypter Notebooks for finetuning the different BERT models are in the `jupyter-notebooks` directory
* `bert_1860.ipynb` is using the big dataset of 1860 profile descriptions
* `bert_420.ipynb` is using the small dataset of 420 profile descriptions
* With the variable `pretrained_LM` one can choose between the BERT models or other language models

Happy coding :)
