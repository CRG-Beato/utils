#!/usr/bin/python


#==================================================================================================
# Created on: 2016-04-21
# Usage: ./print_freeze_beato_metadata_metadata.py
# Author: Javier Quilez (GitHub: jaquol)
# Goal: makes dated freezes of the metadata database
#==================================================================================================


import os
import dataset
import time

# connect to database
ifile = '/users/mbeato/projects/data/beato_lab_metadata.db'
db = dataset.connect("sqlite:///%s" % ifile)

date = time.strftime("%Y-%m-%d")
ODIR = '/users/mbeato/projects/file_transfer/data/beato_lab_metadata_freezes/%s' % date
if not os.path.exists(ODIR):
    os.makedirs(ODIR)

# print tables
tables = db.tables
for t in tables:
	print 'making freeze for table %s' % t
	otab = '%s/%s.csv' % (ODIR, t)
	result = db[t].all()
	dataset.freeze(result, format = 'csv', filename = otab)