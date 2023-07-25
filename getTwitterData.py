import requests
import json
import csv
import time
import pandas as pd

# Pass the four tokens in the headers while making any request made
# to the GraphQL server for fetching data.
auth_token = "8f030fb87a4a924247012345726f4f75c0d154b0"
ct0 = "3fb26907c0f7f5332fe249009601881e"
kdt = "9d363BDQ7RGv2DW1bOgEtFjmGtUQH3VJBjzH4sEU"
twid = "1682092183455760384"

# mit den backslashes, wsl ist nur die Zahl die ID?
# "twid":"\\"u=1682092183455760384\\""

# Vom eigenen gehosteten GraphQL Server
graphql_url = "http://localhost:8001/graphql"

# Headers
headers = {
    'auth_token': 'cf36515525102adb4024e3adb0f6c79f5828c762',
    'ct0': 'c4ddc89ea3f1739bd775e34ce9a3ddc0',
    'kdt': 'JykXCq572htOlUWV29fh08giuu4kHwjMXCwVXXRw',
    'twid': '1682092183455760384'
}

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
    response = requests.post(url=graphql_url, json={"query": body})
    print("response status code:", response.status_code)
    if response.status_code == 200:
        print("response:", response.content)


def get_userid_from_dataset(data):
    # Read the CSV file into a DataFrame
    df = pd.read_csv(data, encoding="utf-8", sep=';')

    # Keep only the userid columns
    df = df[['user_id1', 'user_id2']]

    # Updating user_id1 column with new user_ids from user_id2 column
    df['user_id1'] = df['user_id2'].combine_first(df['user_id1'])

    # Drop the second user_id column
    df = df[['user_id1']]

    # Remove empty rows
    df.dropna(inplace=True)
    df.reset_index(drop=True, inplace=True)

    # Change all numbers to numeric values
    df['user_id1'] = df['user_id1'].astype(float)

    df.to_csv("./data/user_ids.csv", sep=',', encoding='utf-8')
    # TODO: userid nummern sind noch komisch formatiert


def get_username_from_dataset(data):
    df = pd.read_csv(data, encoding="utf-8", sep=',')
    # Keep only the username columns
    #df = df[['screen_name1']]
    df = df[['twitter_handle']]
    # Remove empty rows
    df.dropna(inplace=True)
    # Reset index of rows
    df.reset_index(drop=True, inplace=True)
    df.rename(columns={'twitter_handle': 'user'}, inplace=True)
    df.to_csv("./data/username.csv", sep=',', encoding='utf-8')


def get_user_description(username):
    graphql_query = """
    query {
        User(id: $id) {
            description
        }
    }
    """

    # Necessary for dynamic querying of the passed parameter 'username'
    query_variables = {'id': username}
    formatted_query = graphql_query.replace('$id', f'"{username}"')

    response = requests.post(graphql_url, json={'query': formatted_query, 'variables': query_variables}, headers=headers)


    if response.status_code == 200:
        data = response.json()
        # Check if 'data' and 'user' exist in the JSON response
        if 'data' in data and 'User' in data['data'] and data['data']['User'] is not None:
            user_description = data['data']['User']['description']
            print(user_description)
            return user_description
        else:
            print(f"Error: User data not found for {username}")
            return None
    else:
        print(f"Error: Unable to retrieve user description for {username}")
        return None


def get_all_user_descriptions(usernames_csv):
    usernames_df = pd.read_csv(usernames_csv, encoding="utf-8", sep=',')
    # Initialize a counter for the number of queries and a limit for the sleep interval
    query_count = 0
    query_limit = 95

    for username in usernames_df['user']:
        # Call the get_user_description function for each username
        user_description = get_user_description(username)
        usernames_df.at[usernames_df.index[query_count], 'profile'] = user_description

        # Increment the query counter
        query_count += 1

        # Check if the counter reaches the query limit, then sleep for 15 minutes
        if query_count % query_limit == 0:
            usernames_df.to_csv("./data/username_with_description.csv", sep=',', encoding='utf-8')
            print(f"Reached query limit of {query_limit}. Waiting for 15 minutes...")
            time.sleep(900)  # Sleep for 15 minutes (15 minutes * 60 seconds)

    usernames_df.to_csv("./data/username_with_description.csv", sep=',', encoding='utf-8')

    # # Loop over the DataFrame to retrieve usernames and their descriptions
    # usernames_df['profile'] = usernames_df['user'].apply(get_user_description)
    # usernames_df.to_csv("./data/username_with_description.csv", sep=',', encoding='utf-8')



def main():
    #get_userid_from_dataset("./data/Bundestagswahl_2021_Kandidierenden.csv")
    #get_username_from_dataset("./data/EPINetz_TwitterPoliticians_2021.csv")
    #make_post_request(graphql_url, body)
    get_all_user_descriptions("./data/username.csv")
    #get_user_description("gerdlippold")



if __name__ == "__main__":
    main()
