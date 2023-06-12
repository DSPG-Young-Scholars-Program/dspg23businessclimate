import csv
import requests
import json
import re

# URL of the webpage
url = "https://docu.team/mms.php?association=410#"

# Send a GET request to the URL
response = requests.get(url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Extract the JSON file URL using regex
    pattern = r'var jsonfile\s*=\s*\'([^"]+)\''
    match = re.search(pattern, response.text)

    if match:
        # Extracted JSON file URL
        json_url = match.group(1)

        # Send a GET request to the JSON file URL
        json_response = requests.get(json_url)

        # Check if the request was successful (status code 200)
        if json_response.status_code == 200:
            # Parse the JSON response
            json_data = json.loads(json_response.text)

            filename = 'hispanic_chamber_data.csv'
            with open(filename, 'w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(['Business Name', 'Owner Name', 'Phone', 'Email', 'Address'])

                for key, data in json_data.items():
                    # Extract relevant information from JSON
                    business_name = data.get('business_name', '')
                    first_name = data.get('first_name', '')
                    last_name = data.get('last_name', '')
                    phone = data.get('phone', '')
                    address_1 = data.get('address_1', '')
                    address_2 = data.get('address_2', '')
                    city = data.get('city', '')
                    state = data.get('state_province', '')
                    zip_code = data.get('zip_postal', '')
                    email = data.get('email', '')
                    address = f'{address_1} {address_2}, {city}, {state} {zip_code}'
                    full_name = f'{first_name} {last_name}'

                    writer.writerow([business_name, full_name, phone, email, address])

            print(f"Data successfully saved to {filename}")
        else:
            print("Error: Failed to retrieve the JSON file.")
    else:
        print("Error: JSON file URL not found.")
else:
    print("Error: Failed to retrieve the webpage.")
