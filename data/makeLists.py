import os, string
out = ""
count = 0
with open("written.num.o5") as f:
	for line in f.readlines():
		if count > 25000: break
		data = line.split(" ")
		freq = int(data[0].strip())
		word = data[1].strip().lower()
		pos = data[2].strip().upper()
		if word.isalpha():
			out += "%d %s %s\n"%(freq, word, pos)
			count += 1
with open("worddata.txt", 'w') as g:
	g.write(out)





	"""
	with open("phrases2.txt") as g:
		words = set()

		for phrase in g.readlines():
			phrase = phrase.split()
			for word in phrase:
				words.add(word.strip().lower())
		found = set()
		total = 0
		for line in f.readlines():
			word = line.split(" ")[1].strip().lower()
			if word in words and word not in found:
				found.add(word)
			total += 1
			if (total % 1000 == 0) :
				print "found %d out of %d  words in top %d, percent: %0.2f"%(len(found), len(words), total, len(found)*100.0/len(words))
		for word in words:
			if word not in found:
				print word

"""