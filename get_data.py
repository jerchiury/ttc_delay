#%% imports 
from __future__ import division
import os
from bs4 import BeautifulSoup as soup
import requests
import time
import re
import xlrd
import csv
import pandas as pd

os.chdir('C:\\Users\\Jerry\\Desktop\\Jerry\\projects\\ttc_delay')

#%% getting data
url='https://ckan0.cf.opendata.inter.prod-toronto.ca/tr/dataset/ttc-subway-delay-data'

req = requests.get(url, headers= {'User-Agent' : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/71.0'})
page_soup=soup(req.content,'html.parser')
req.close()
downlist=page_soup.findAll('a',{'class':"resource-url-analytics"})

for i in range(0, len(downlist)):
    link=downlist[i]['href']
    filename=re.sub('.+download/subway-srt-logs-','',link)
    filename=re.sub('.+download/ttc-subway-delay-','',filename)
    filename=re.sub('-','_',filename)
    req = requests.get(link, allow_redirects=True)
    open('data//'+filename, 'wb').write(req.content)

#%% Combining data into one csv file
filename=os.listdir('data')
codes=[n for n in filename if '20' not in n]
filename=[n for n in filename if '20' in n]

dataset=pd.DataFrame()
for i in range(0, len(filename)):
    print(i)
    temp=pd.read_excel('data//'+filename[i])
    dataset=dataset.append(temp , sort=True, ignore_index=True)

dataset.to_csv('data//ttc_delays.csv', index=False)

for i in (0,1):
    temp=pd.read_excel('data//'+codes[i])
    temp.to_csv(re.sub('.xlsx','.csv',codes[i]), index=False)