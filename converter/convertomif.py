from sys import argv
from binary import *


source, input_file_name = argv

print 'argumentos : ', argv[1]

print "Opening the file..."
input_file = open(input_file_name, 'r')

print "To array..."
input_file_array = input_file.read().replace('\n', ',').split(',')

# sigle is IEEE 754 32 bit float format
context = single

output_array = []

print "To binary..."
for i in range(len(input_file_array)):
	#x = context(Decimal("-0.9375"))
	if (input_file_array[i] != ''):
		x = context(Decimal(input_file_array[i]))
		#print x.replace(' ', '')
		output_array.append(x)

#print output_array

print "Adding to file..."
output_file_name = "output.mif"
output_file = open(output_file_name, 'w')

# HEADER
content = "WIDTH=16;\nDEPTH=16384;\n\nADDRESS_RADIX=DEC;\nDATA_RADIX=BIN;\n\nCONTENT BEGIN\n"

for i in range(len(output_array)):
	#print "array[" + str(i) + "] = " + str(input_file_array[i])
	#content += "array[" + str(i) + "] = " + str(input_file_array[i])
	content += "	" + str(i) + "  :  " + str(output_array[i]).replace(" ", "") + ";\n"

content += "END;"
output_file.write(content)

print "Saving file..."
output_file.close()
