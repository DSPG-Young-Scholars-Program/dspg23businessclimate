import csv
import requests
import matplotlib.pyplot as plt
import math
import requests
import json
import csv
import re
import os





MAIN_PATH = "./Business Climate/Yelp_API_Data/"
BLK_OWNED = MAIN_PATH + 'Black_Owned' 
BLK_CSV = "blk.csv"
ASN_OWNED = MAIN_PATH + 'Asian_Owned' 
ASN_CSV = "asn.csv"
LTN_OWNED = MAIN_PATH + 'Latinx_Owned' 
LTN_CSV = "ltn.csv"

file_list = os.listdir(LTN_OWNED)

xmin =  -77.53698 
ymin =  38.61768 
xmax = -77.04037 
ymax =  39.05779

zip_codes_ffx =[22030, 22003, 20171, 22015, 20170, 20120, 22079, 22033, 22309, 22042, 22031, 22306, 22153, 22032, 22310, 22101, 20191, 22315, 22041, 22152, 22312, 22150, 22102, 20121, 22182, 22180, 22043, 20151, 22311, 20190, 22046, 22124, 22039, 22151, 22066, 20124, 22303, 22181, 22044, 22308, 20194, 22307, 22060, 20193, 22092, 22047, 22120, 22027, 22184, 22185, 22035, 22009, 22037, 22036, 22067, 22081, 22082, 22095, 22096, 22103, 22107, 22106, 22109, 22108, 22118, 22116, 22119, 22122, 22121, 22158, 22156, 22160, 22159, 22183, 22199, 20122, 20153, 20172, 20192, 20195, 20196, 20511]






step = 0.05

crd_list = []

for x in range(int((xmax - xmin) / step) + 1 + 1):
    for y in range(int((ymax - ymin) / step) + 1 + 1):
        x_crd = xmin + x * step
        y_crd = ymin + y * step
        crd_list.append((x_crd, y_crd))



x = [xmin, xmax, xmax, xmin, xmin]
y = [ymin, ymin, ymax, ymax, ymin]

RADIUS = 24



plt.plot(x, y, color='red')

plt.xlabel('Longitude')
plt.ylabel('Latitude')


x_crds = list(map(lambda _i: _i[0] ,crd_list))
y_crds = list(map(lambda _i: _i[1] ,crd_list))

area = [math.pi *RADIUS**2] * len(x_crds)



print(x_crds)

print(y_crds)



plt.scatter(x_crds, y_crds, s=area, alpha = 0.5)


plt.show()

print(x_crds)
print(y_crds)




lats = y_crds
longs = x_crds
count = 0
radius = 3000


for lat, long in zip(lats, longs):
    if count >= 0:
        url = f"https://api.yelp.com/v3/businesses/search?latitude={lat}&longitude={long}&term=Latinx%20Owned&radius={radius}&sort_by=best_match&limit=50"
        headers = {
            "accept": "application/json",
            "Authorization": "Bearer tImvkH-wIxWdrlFL2BG6QGExAS9Y5CqEpKcmc0heyYrs3oUxLw1ng2QvtHO6_SySOr0QiF84vIyoBWC0IU00TKezTj14qogzF02QHXNivj0-QYlsn5l0OgqUObeUZHYx"
        }
        response = requests.get(url, headers=headers)
        file = open(f"./Business Climate/Yelp_API_Data/Latinx_Owned/{lat}_{long}.json", 'w')
        file.write(response.text)
        print(lat, long, response.status_code)
        file.close()
    count+=1


zip_codes_regex = "(22030|22003|20171|22015|20170|20120|22079|22033|22309|22042|22031|22306|22153|22032|22310|22101|20191|22315|22041|22152|22312|22150|22102|20121|22182|22180|22043|20151|22311|20190|22046|22124|22039|22151|22066|20124|22303|22181|22044|22308|20194|22307|22060|20193|22092|22047|22120|22027|22184|22185|22035|22009|22037|22036|22067|22081|22082|22095|22096|22103|22107|22106|22109|22108|22118|22116|22119|22122|22121|22158|22156|22160|22159|22183|22199|20122|20153|20172|20192|20195|20196|20511)"




total_scrapped = 0

w_data = [['name', 'city', 'zip_code']]

c = 0
c_1 = 0
dup_set = set()

for idx, file_name in enumerate(file_list):
    file_path = os.path.join(LTN_OWNED, file_name)
    #print(f"{idx}. {file_name}")    
    file_extension = os.path.splitext(file_path)[1]

    
    if os.path.isfile(file_path) and file_extension == '.json':
        with open(file_path, 'r') as file:
            raw_data = file.read()
            #print("RD", raw_data)
            rd_data = json.loads(raw_data)
            total_scrapped+=int(rd_data['total'])
            businesses = rd_data['businesses']
            for b in businesses:
                c_1+=1
                loc = b.get('location')
                if re.match(zip_codes_regex, loc.get('zip_code'), flags = re.M):
                    name = b.get('name')
                #print(name)
                    if not name in dup_set:
                        row = [name, loc.get('city'), loc.get('zip_code')]
                        dup_set.add(name)
                        w_data.append(row)
                    #else:
                        #pass
                        #c+=1
            #print(len(dup_set))

print("Total Data Analysed", c_1)

with open(MAIN_PATH+'/final'+ f'/{LTN_CSV}', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(w_data)

