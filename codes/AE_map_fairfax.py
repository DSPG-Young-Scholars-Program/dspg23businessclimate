# import csv
# import requests
# from bs4 import BeautifulSoup
#
# # URL to scrape
# url = 'https://www.americanexpress.com/en-us/maps?country=US&near=Fairfax-County,VA&cat=Shop-Small&cl=38.74389439999' \
#       '999,-77.2405153&intlink=us-GABM-Map_Home'
#
# # Send a GET request to the URL
# response = requests.get(url)
# soup = BeautifulSoup(response.text, 'html.parser')
#
# # div_element = soup.find_all('div', {'class': 'views-row'})
#
# filename = 'ae_map_ffx_directory.csv'
#
# with open(filename, 'w', newline='', encoding='utf-8') as file:
#     writer = csv.writer(file)
#     writer.writerow(['Name', 'Address'])
#
#     div_elements = soup.find_all('div', {'class': 'col-lg-12 pad-0 height-full', 'data-merchant-list': 'merchantList'
#                                                                                                        'Container'})
#
#     for div_element in div_elements:
#         name_element = div_element.find('p', {'class': 'legal-2 dls-black word-wrap', 'data-merchant-list':
#             "merchantIndustryDetails"})
#
#         address_element_1 = div_element.find('p', {'class': "legal-1 dls-black text-capitalize text-truncate", 'data-'
#                                                                                 'merchant-list': "merchantAddress1"})
#
#         address_element_2 = div_element.find('p', {'class': "legal-1 dls-black text-capitalize text-truncate", 'data-'
#                                                                                 'merchant-list': "merchantAddress2"})
#
#         name = name_element.get_text(strip=True)
#         address1 = address_element_1.get_text(strip=True)
#         address2 = address_element_2.get_text(strip=True)
#         address = address1 + "," + address2
#
#         writer.writerow([name, address])
#
# print("Data written to", filename)

import csv
import requests
from bs4 import BeautifulSoup

url = 'https://www.americanexpress.com/en-us/maps?country=US&near=Fairfax-County,VA&cat=Shop-Small&cl=38.74389439999' \
      '999,-77.2405153&intlink=us-GABM-Map_Home'

response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

filename = 'ae_map_ffx_directory.csv'

with open(filename, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Name', 'Address'])

    div_elements = soup.find_all('div', {'class': 'col-lg-12 pad-0 height-full'})
    print(len(div_elements))
# print(div_elements.prettify())
    for div_element in div_elements:
        name_element = div_element.find('p', {'class': 'legal-2 dls-black word-wrap', 'data-merchant-list':
                                                                                            'merchantIndustryDetails'})
        address_element_1 = div_element.find('p', {'class': "legal-1 dls-black text-capitalize text-truncate",
                                                                            'data-merchant-list': "merchantAddress1"})
        address_element_2 = div_element.find('p', {'class': "legal-1 dls-black text-capitalize text-truncate",
                                                                            'data-merchant-list': "merchantAddress2"})

        name = name_element.get_text(strip=True)
        address1 = address_element_1.get_text(strip=True)
        address2 = address_element_2.get_text(strip=True)
        address = address1 + ", " + address2

        writer.writerow([name, address])

print("Data written to", filename)

