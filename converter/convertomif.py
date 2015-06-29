from sys import argv
from binary import *

input_files = []

for i in range(1, len(argv)):
	input_files.append(open(argv[i], 'r'))

input_file_array = []

print "---------------------------"
print "  Creating mif file from:  "
for i in range(1, len(argv)):
	print "    " + argv[i]

for i in range(len(input_files)):
	input_file_array = input_file_array + (input_files[i].read().replace('\n', ',').replace('\r', '').split(','))

# sigle is IEEE 754 32 bit float format
context = single

output_array = []

print " "
print "  To binary..."
for i in range(len(input_file_array)):
	if (input_file_array[i] != ''):
		x = context(Decimal(input_file_array[i]))
		output_array.append(x)

output_file_name = "output.mif"
output_file = open(output_file_name, 'w')

# HEADER
content = "WIDTH=16;\nDEPTH=16384;\n\nADDRESS_RADIX=DEC;\nDATA_RADIX=BIN;\n\nCONTENT BEGIN\n"

for i in range(len(output_array)):
	content += "	" + str(i) + "  :  " + str(output_array[i]).replace(" ", "") + ";\n"

content += "END;"
output_file.write(content)

print "  Saving file..."
output_file.close()
print "  Done"
print "---------------------------"