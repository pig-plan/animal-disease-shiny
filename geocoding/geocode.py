# -*- coding: utf-8 -*-
"""
Created on Fri Aug  5 10:15:43 2016

@author: wooyol
"""

import pandas as pd
from geopy.geocoders import GoogleV3

geolocator = GoogleV3(api_key = "AIzaSyDvwglFuj1Ha8Fu09jYoPnKO_442oXcgKA")

df = pd.read_csv('../refined.csv')

location = df['FARM_LOCPLC'].apply(lambda x: geolocator.geocode(x))