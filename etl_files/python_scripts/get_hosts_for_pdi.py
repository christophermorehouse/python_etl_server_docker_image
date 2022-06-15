import json
import os
import requests
import sys

# these variables use pdi variables, ex. ${varname}, as their values.
# to run this script outside of pdi, change these to literals or use python .env
host = "${host}"
client_id = "${client_id}"
client_secret = "${client_secret}"

#create authentication token
def auth_token():
    url = 'https://' + host + '/api/v1/oauth/service/token'
    payload={
                'grant_type': 'client_credentials', 
                'client_id': client_id , 
                'client_secret': client_secret
            }
    token = requests.post( url, data=payload, verify=False).json()['access_token']
    return token

url = 'https://' + host
headers= {
    'authorization': 'Bearer ' + auth_token() +''
}

# make first call to api and get first page results
discover_api = requests.get(url + '/api/v1/hosts?page=1&pageSize=10', headers=headers, verify=False).json()
hosts = discover_api['data']

for page in range(2, discover_api['meta']['pagesCount'] + 1):
    discover_api = requests.get(url + '/api/v1/hosts?page=' + str(page) + '&pageSize=10', headers=headers, verify=False).json()
    # append each page's result to original hosts variable
    hosts.extend(discover_api['data'])

# only saving the raw data portion of the response, not the meta
#with open('listofhosts.json', 'w') as write_file:
#    json.dump(hosts, write_file)