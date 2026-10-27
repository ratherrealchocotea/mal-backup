#!/usr/bin/env python
# Because the old MAL script was less portable

import requests
import json
import sys

global saved
global data
global status
global current_entry

def download_list (username, client_id, filename):
    completed = []
    res = requests.get("https://api.myanimelist.net/v2/users/" + \
                        username +
                        "/animelist?fields=list_status&limit=1000",
                        headers={"X-MAL-CLIENT-ID": client_id})
    data = res.json()
    for entry in data["data"]:
        status = entry["list_status"]["status"]
        if status == "completed":
            title = entry["node"]["title"]
            completed.append(title)
            print(f"Adding {title} to the list")
    return sorted(completed)

if __name__ == "__main__":
    username, client_id, path = sys.argv[1:4]
    with open(path, "w") as f:
        for entry in download_list(username, client_id, f):
            f.write(entry + "\n")

    print("Done")
        
        
            
            
