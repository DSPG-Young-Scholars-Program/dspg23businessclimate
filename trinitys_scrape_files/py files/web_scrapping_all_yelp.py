import csv
import requests
from bs4 import BeautifulSoup

global url

i = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230]
filename = '../csv data/yelp_all_data.csv'
with open(filename, 'a', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    run = 0
    with open(filename, 'r') as file:
        csvreader = csv.reader(file)
        for row in csvreader:
            if "Business Name" in row:
                run = 1
    if run == 0:
        writer.writerow(['Business Name', 'URL'])

        for page in i:
            url = 'https://www.yelp.com/search?find_desc=businesses&find_loc=Fairfax%2C+VA&start=' + str(page)

            response = requests.get(url)
            soup = BeautifulSoup(response.text, 'html.parser')

            div_elements = soup.find('ul', {'class': 'undefined list__09f24__ynIEd'})

            for div_element in div_elements:
                name_element = div_element.find('span', {'class': 'css-1egxyvc'})
                url_element = div_element.find('a')

                if name_element is not None and url_element is not None:
                    name = name_element.get_text(strip=True)
                    for char in name:
                        if not char.isalpha():
                            name = name.replace(char, "")

                    url = url_element['href']

                    writer.writerow([name, url])

    print('Success!')