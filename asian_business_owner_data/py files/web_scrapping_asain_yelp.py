import csv
import requests
from bs4 import BeautifulSoup

global yelp_url

i = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230]####HELP
#make a csv:
filename = 'yelp_asian_data.csv'
with open(filename, 'a', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['Business Name', 'URL'])


    for page in i:
      # URL to scrape
      yelp_url = 'https://www.yelp.com/search?find_desc=Asian+Owned+Businesses&find_loc=Fairfax%2C+VA' + str(page)
      # Send a GET request to the URL
      response = requests.get(yelp_url)
      page = BeautifulSoup(response.text, 'html.parser')

      allresults_div = page.find_all('ul', {'class': ' undefined list__09f24__ynIEd'})
      for element in allresults_div:
          name_element = element.find('span', {'class': 'css-1egxyvc'})
          url_element = element.find('a')

          if name_element is not None and url_element is not None:
              name = name_element.get_text(strip=True)
              url = url_element['href']

              writer.writerow([name, url])





#extract information from each card
#    name = ''
#     for element in allresults_div:
#         name1 = element.find('li', {'class': 'border-color--default__09f24__NPAKY'})
#         name2 = name1.find(
#             'div', {'class': 'container__09f24__mpR8_ hoverable__09f24__wQ_on margin-t3__09f24__riq4X margin-b3__09f24__l9v5d  border--top__09f24__exYYb border--right__09f24__X7Tln border--bottom__09f24___mg5X border--left__09f24__DMOkM border-color--default__09f24__NPAKY'})
#         name3 = name2.find('div', {'class': '  toggle__09f24__aaito css-1ty9ct  padding-t3__09f24__TMrIW padding-r3__09f24__eaF7p padding-b3__09f24__S8R2d padding-l3__09f24__IOjKY border-color--default__09f24__NPAKY'})
# #still finsihing code to get list of names only since we know that all the businesses in the url are based in fairfax
#         name4 = name3.find()
#         writer.writerow([name])


print("SUCCESS!")