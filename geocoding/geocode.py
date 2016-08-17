# -*- coding: utf-8 -*-
"""
Created on Fri Aug  5 10:15:43 2016

@author: wooyol
"""

import numpy as np
import pandas as pd
import geopy
from geopy.geocoders import GoogleV3

geolocator = GoogleV3(api_key = "AIzaSyDvwglFuj1Ha8Fu09jYoPnKO_442oXcgKA", timeout=None)

df = pd.read_csv('../refined.csv')

location = df['FARM_LOCPLC'].apply(lambda x: geolocator.geocode(x))

df['address'] = location

df['latitude'] = df['address'].map(lambda x: x.latitude, na_action='ignore')
df['longitude'] = df['address'].map(lambda x: x.longitude, na_action='ignore')

df.to_csv('geocoded.csv', encoding="utf-8")