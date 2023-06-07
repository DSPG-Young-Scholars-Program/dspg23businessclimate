import csv
import requests
from bs4 import BeautifulSoup


# URL to scrape
yelp_url = 'https://www.yelp.com/search?find_desc=Asian+Owned+Businesses&find_loc=Fairfax'
# Send a GET request to the URL
response = requests.get(yelp_url)
page = BeautifulSoup(response.text, 'html.parser')

allresults_div = page.find_all('ul', {'class': ' undefined list__09f24__ynIEd'})

#set up csv file
f = open("scrapped_yelp.txt", "w")
f.write(response.text)
f.close()

file_name = '2021_yelp_data.csv'

with open(file_name, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
#column titles in csv
    writer.writerow(['Business Name'])
#extract information from each card
    name = ''
    for element in allresults_div:
        name1 = element.find('li', {'class': 'border-color--default__09f24__NPAKY'})
        name2 = name1.find(
            'div', {'class': 'container__09f24__mpR8_ hoverable__09f24__wQ_on margin-t3__09f24__riq4X margin-b3__09f24__l9v5d  border--top__09f24__exYYb border--right__09f24__X7Tln border--bottom__09f24___mg5X border--left__09f24__DMOkM border-color--default__09f24__NPAKY'})
        name3 = name2.find('div', {'class': '  toggle__09f24__aaito css-1ty9ct  padding-t3__09f24__TMrIW padding-r3__09f24__eaF7p padding-b3__09f24__S8R2d padding-l3__09f24__IOjKY border-color--default__09f24__NPAKY'})
#still finsihing code to get list of names only since we know that all the businesses in the url are based in fairfax
        name4 = name3.find()
        writer.writerow([name])


print("SUCCESS!")