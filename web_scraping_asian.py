import csv
import requests
from bs4 import BeautifulSoup


# URL to scrape
aacc_url = 'https://business.asian-americanchamber.org/list/searchalpha/a?o=&'
# Send a GET request to the URL
response = requests.get(aacc_url)
page = BeautifulSoup(response.text, 'html.parser')

allresults_div = page.find_all('div', {'class': 'card gz-results-card gz-web-participation-10 gz-no-logo gz-nonsponsor'})

#set up csv file
f = open("scrapped.txt", "w")
f.write(response.text)
f.close()

file_name = '2021_aacc_data.csv'

with open(file_name, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
#column titles in csv
    writer.writerow(['Business Name', 'Address', 'phone'])
#extract information from each card
    name = ''
    address = ''
    phone = ''
    for element in allresults_div:
        name_element = element.find('div', {'class': 'card-header'})
        name = name_element.find('span', {'class': 'gz-img-placeholder'}).get_text(strip=True)

        #bottom of card extraction
        tele_addy = element.find('div', {'class': 'card-body gz-results-card-body'})
        tel_add = tele_addy.find('ul', {'class': 'list-group list-group-flush'})
        address_card = tel_add.find('li',{'class': 'list-group-item gz-card-address'})
        address_element = address_card.find('a', {'class': 'card-link'})
        street = address_element.find('span', {'itemprop': 'streetAddress'}).get_text(strip=True)
        csz_card = address_element.find('div', {'itemprop': 'citystatezip'})
        children = csz_card.findChildren()
        childrenlist = []
        print(children)
        for child in children:
            child = (list)
            childrenlist.append(child)
            print (child)
            print (str(childrenlist))

        c = csz_card.find('span', {'class':'gz-address-city'}).get_text(strip=True)
        sz = csz_card.find('span',{""}).get_text(strip=True)
        csz = c + str(sz)

        address = street + ", " + str(csz) #+ str(sz)

        phone_card = tel_add.find('li', {'class': 'list-group-item gz-card-phone'})
        phone_element = phone_card.find('a', {'class': 'card-link'})
        phone = phone_element.find('span', {}).get_text(strip=True)

        writer.writerow([name, address, phone])

    # prints the dataset to console
    print("Business Name: " + name + "\n")
    print("Address: " + address + "\n")
    print(" " + phone + "\n")


print("SUCCESS!")











