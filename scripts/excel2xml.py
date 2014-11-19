#!/usr/bin/env python
"""
* Requires xlrd.
$ python xl.py [filename].xsl
"""
import os
import sys
import xlrd
import time

from xlrd import open_workbook

if len(sys.argv) < 2:
	print "Error: You must supply a filename"
	sys.exit(1)

filename = sys.argv[-1]
if os.path.isfile(filename):
#	pathname=os.path.split(filename)[0]
	filebasename=os.path.split(filename)[1]
	xmlfilename=os.path.splitext(filebasename)[0]+".xml"
	with open(xmlfilename,"w") as xmlfile:
		print "####################################################################"
		print "Converting from:"+filename
		print "Converting to:  "+xmlfilename
		print "####################################################################"
		wb=open_workbook(filename)
		###########################################
		### Get the sheet names and loop over them
		###########################################
		names=wb.sheet_names()
		xmlfile.write("<!-- WorkBook Path: "+filename+" -->\n")
		xmlfile.write("<!-- Date: "+time.strftime("%c")+" -->\n")
		xmlfile.write("<Workbook>\n")
		###########################################
		### What sheet is the testplan on?
		###########################################
		for (i,name) in enumerate(names):
			s=wb.sheet_by_index(i)
			###########################################
			### Get the row that has the first data
			###########################################
			first_row=0
			row=0
			while row < s.nrows and first_row==0:
				values=s.row_values(row)
				for (i, item) in enumerate(values):
					if item<>'' and first_row==0:
						first_row=row
				row=row+1
			###########################################
			### Get the col that has the first data
			###########################################
			first_col=0
			col=0
			while col < s.ncols and first_col==0:
				values=s.col_values(col)
				for (i, item) in enumerate(values):
					if item<>'' and first_col==0:
						first_col=col
				col = col + 1
			###########################################
			### print out XML for the testplan, ignore
			### the other sheets
			###########################################
			if s.nrows-first_row-1>0 and s.ncols-1-first_col>0:
				print "Found Worksheet:",name
				xmlfile.write("  <Worksheet>  <!-- "+name+" -->\n")
				xmlfile.write("    <Table>\n")
				################################################
				### The first row has the headings, ignore them
				################################################
				for row in range(first_row+1,s.nrows):
					xmlfile.write( "      <Row>\n")
					for col in range(first_col,s.ncols):
						line="        <Cell>"+str(s.cell(row,col).value)+"</Cell> <!-- "+str(s.cell(first_row,col).value)+" -->\n"
						xmlfile.write(line)
					xmlfile.write( "      </Row>\n")
				xmlfile.write( "    </Table>\n")
				xmlfile.write( "  </Worksheet>\n")
		xmlfile.write( "</Workbook>\n")
		print "Done!"
else:
	sys.stderr.write("Error: "+filename+" doesn't exist!\n" )
	sys.stderr.write("Usage: excel2xml.py <excelfilename.xls/xlsx>\n" )
	sys.exit(2)
