import csv
import requests
from bs4 import BeautifulSoup


url = 'https://www.yelp.com/search?find_desc=Native+American+Owned+Businesses&find_loc=Fairfax%2C+VA'
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

div_elements = soup.find('ul', {'class': 'undefined list__09f24__ynIEd'})

filename = '../csv data/yelp_nativeamerican_data.csv'
with open(filename, 'a', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Business Name', 'URL'])
    name = ''
    url = ''

    for div_element in div_elements:
        name_element = div_element.find('span', {'class': 'css-1egxyvc'})
        url_element = div_element.find('a')

        if name_element is not None and url_element is not None:
            name = name_element.get_text(strip=True)
            url = url_element['href']

            writer.writerow([name, url])

print('Success!')