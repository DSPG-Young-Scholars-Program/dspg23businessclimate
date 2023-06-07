# import csv
# import requests as requests
# from bs4 import BeautifulSoup
#
# # URL to scrape
# url = 'https://docu.team/mms.php?association=410#'
# #Send a GET request to the URL
# response = requests.get(url)
# soup = BeautifulSoup(response.text, 'html.parser')
# directory_div = soup.find('div', {'id': 'results', 'class': 'memlist row'})
# f = open("scrapped.txt", "w")
# f.write(response.text)
# f.close()
# filename = 'hispanic_chamber_data.csv'
# with open(filename, 'w', newline='', encoding='utf-8') as file:
#     writer = csv.writer(file)
#     writer.writerow(['Name', 'Phone', 'Address'])
#     nested_divs = directory_div.find_all(
#     'div', {'class': 'card text-center h-100'})
#     #print(len(nested_divs))
#     for div_element in nested_divs:
#         name_element = div_element.find(
#         'h3', {'class': 'mb-3 text-accent' }) # potentially dont need to add the mb-3, if errors check here
#         name = name_element.get_text(strip=True)
#         email = ''
#         phone = ''
#
#         phone_element = div_element.find(
#             'a', {'class': 'phone'}).get_text(strip = True)
# # phone = phone_element.find(
# #     'span', { 'itemprop': 'telephone'}).get_text(strip = True)
# # email_element = div_element.find(
# #     'li', {'class': 'gz-card-email'})
# # email = email_element.find(
# #     'span', {'itemprop': 'email'}).get_text(strip = True)
#
# # Find the <address> tag
#         address_tag = soup.find('address')
#         if address_tag:
#             # Extract the address and remove unnecessary parts
#             address_tag = address_tag.get_text(strip=True).replace('== $0', '').replace('"', '').strip()
#
# # address_element = div_address.find(
# #     'address', {'class': 'gz-card-email'})
# # address = address_element.find(
# #     'span', {'itemprop': 'email'}).get_text(strip = True)
#         writer.writerow([name, phone_element, address_tag])
# print("SUCCESS!")

# import csv
# import requests
# from bs4 import BeautifulSoup
#
# # URL to scrape
# url = 'https://www.fcrevite.org/made-fairfax/directory'
#
# # Send a GET request to the URL
# response = requests.get(url)
# soup = BeautifulSoup(response.text, 'html.parser')
# directory_section = soup.find('section',
#                               {'class': 'views-element-container block block-views block-views-blockbusiness-'
#                    import csv
# import requests
# from bs4 import BeautifulSoup
#
# # URL to scrape
# url = 'https://www.fcrevite.org/made-fairfax/directory'
#
# # Send a GET request to the URL
# response = requests.get(url)
# soup = BeautifulSoup(response.text, 'html.parser')
# # directory_section = soup.find('section',
# #                               {'class': 'views-element-container block block-views block-views-blockbusiness-'
# #                                         'directory-block-1 clearfix', 'id': 'block-views-block-business-'
# #                                                                             'directory-block-1'})
#
# directory_div = soup.find('div', {'class': 'view-content'})
# # print(directory_div.prettify())
# filename = 'made_in_ffx_directory.csv'
# with open(filename, 'w', newline='', encoding='utf-8') as file:
#     writer = csv.writer(file)
#     writer.writerow(['Name', 'URL'])
#
#     # nested_divs = directory_div.find(id="col-lg-4 pb-4 mem")
#     nested_divs = directory_div.find_all('div', {'class': 'views-row'})
#     # print(len(nested_divs))
#     for div_element in nested_divs:
#         url_element = div_element.find('a', {'href':})
#         name_element = div_element.find('h3', {'class': 'mb-3 text-accent'})
#         name = name_element.get_text(strip=True)
#         phone_element = div_element.find('a', {'class': 'phone'}).get_text(strip=True)
#         address_tag = div_element.find('address')
#         if address_tag:
#             address = address_tag.get_text(strip=True).replace('== $0', '').replace('"', '').strip()
#         else:
#             address = ''
#         writer.writerow([name, phone_element, address])
#
# print("SUCCESS!")                     'directory-block-1 clearfix', 'id': 'block-views-block-business-'
#                                                                             'directory-block-1'})

# directory_div = soup.find('div', {'class': 'view-content'})
# # print(directory_div.prettify())
# filename = 'made_in_ffx_directory.csv'
# with open(filename, 'w', newline='', encoding='utf-8') as file:
#     writer = csv.writer(file)
#     writer.writerow(['Name', 'URL'])
#
#     # nested_divs = directory_div.find(id="col-lg-4 pb-4 mem")
#     nested_divs = directory_div.find_all('div', {'class': 'views-row'})
#     # print(len(nested_divs))
#     for div_element in nested_divs:
#         url_element = div_element.find('a', {'href':})
#         name_element = div_element.find('h3', {'class': 'mb-3 text-accent'})
#         name = name_element.get_text(strip=True)
#         phone_element = div_element.find('a', {'class': 'phone'}).get_text(strip=True)
#         address_tag = div_element.find('address')
#         if address_tag:
#             address = address_tag.get_text(strip=True).replace('== $0', '').replace('"', '').strip()
#         else:
#             address = ''
#         writer.writerow([name, phone_element, address])
#
# print("SUCCESS!")

import csv
import requests
from bs4 import BeautifulSoup

# URL to scrape
url = 'https://www.fcrevite.org/made-fairfax/directory'

# Send a GET request to the URL
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

# div_element = soup.find_all('div', {'class': 'views-row'})

filename = 'made_in_ffx_directory.csv'

with open(filename, 'w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Name', 'URL'])

    div_elements = soup.find_all('div', {'class': 'views-row'})

    for div_element in div_elements:
        name_element = div_element.find('strong')
        url_element = div_element.find('a')

        name = name_element.get_text(strip=True)
        url = url_element['href']

        writer.writerow([name, url])

print("Data written to", filename)