import json
import sys


with open('results.json') as data_file:
	data = json.load(data_file)
	for i in xrange(26):
		sum = 0.0;
		probList = []
		for j in xrange(26):
			sum += data[chr(i + 97)][j][1];
		for j in xrange(26):
			probList += [(data[chr(i + 97)][j][0], round(data[chr(i + 97)][j][1]/sum * 100, 2))]
		sortedList = (sorted(probList, key=lambda x: x[0]))
		for s in sortedList:
			sys.stdout.write(str(s[1]))
			sys.stdout.write(",")
		print("")