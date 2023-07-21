import requests
import json
import csv
import pandas as pd

# Pass the four tokens in the headers while making any request made
# to the GraphQL server for fetching data.
auth_token = "798664791d0b058b963f687cb152c476d18e2adc"
ct0 = "0b17389975d2beaf8166bcc652979e92"
kdt = "aHOmtGjPBVw6PugbmxPh2alr9WpxC3aYCUOEsPKj"
twid = "1682092183455760384"

# mit den backslashes, wsl ist nur die Zahl die ID?
# "twid":"\\"u=1682092183455760384\\""

# Vom eigenen gehosteten GraphQL Server
url = "http://localhost:8001/graphql"

# Query for getting 4 tokens
body = """
{
    Login(email: "behrendmax8@gmail.com", userName: "csgohan123", password: "") {
            auth_token
            ct0
            kdt
            twid
    }
}
"""

def make_post_request(url, body):
    response = requests.post(url=url, json={"query": body})
    print("response status code:", response.status_code)
    if response.status_code == 200:
        print("response:", response.content)



def main():
    # Read the CSV file into a DataFrame
    df = pd.read_csv("./data/Bundestagswahl_2021_Kandidierenden.csv", encoding="utf-8", sep=';')

    # Keep only the last three columns
    df = df[['user_id1', 'user_id2']]

    # Updating user_id1 column with new user_ids from user_id2 column
    df['user_id1'] = df['user_id2'].combine_first(df['user_id1'])

    # Drop the second user_id column
    df = df[['user_id1']]

    # Remove empty rows
    df.dropna(inplace=True)
    print(df.size)

    # Change all numbers to numeric values
    df['user_id1'] = df['user_id1'].astype(float)
    print(df.head())
    print(df.size)

    df.to_csv("./data/user_ids.csv", sep=',', encoding='utf-8')
    # warum sind die Zahlen so scheisse


if __name__ == "__main__":
    main()
