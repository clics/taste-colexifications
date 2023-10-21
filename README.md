# Retrieving and Analyzing Taste Colexifications from Lexibank

Data and Code accompanying the study.

# Installation

```
$ git clone https://github.com/lexibank/lexibank-analysed
$ cd lexibank-analysed
$ git checkout -v1.0
$ cd ..
$ pip install pycldf
$ cldf createdb lexibank-analysed/cldf/wordlist-metadata.json ../lexibank.sqlite3
$ cd ..
$ pip install csvkit
```
