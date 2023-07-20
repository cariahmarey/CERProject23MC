import requests
import json
#import pandas as pd

# Vom eigenen gehosteten GraphQL Server
url = "http://localhost:8001/graphql"

# Pass the four tokens in the headers while making any request made
# to the GraphQL server for fetching data.
auth_token = "798664791d0b058b963f687cb152c476d18e2adc"
ct0 = "0b17389975d2beaf8166bcc652979e92"
kdt = "aHOmtGjPBVw6PugbmxPh2alr9WpxC3aYCUOEsPKj"
twid = "1682092183455760384"

# mit den backslashes, wsl ist nur die Zahl die ID?
# "twid":"\\"u=1682092183455760384\\""

# Query for getting 4 tokens
query = """
{
    Login(email: "behrendmax8@gmail.com", userName: "csgohan123", password: "") {
            auth_token
            ct0
            kdt
            twid
    }
}
"""

response = requests.post(url=url, json={"query": query})
print("response status code: ", response.status_code)
if response.status_code == 200:
    print("response : ", response.content)
