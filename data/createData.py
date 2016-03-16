#make data
import os, string

words = dict()
out = "wordlist.txt"
for fname in os.listdir("brown"):
	if fname not in {".DS_Store", "cats.txt", "README", "CONTENTS"}:
		with open("brown/"+ fname) as f:
			for line in f.readlines():
				if not line.isspace():
					line = line.strip()
					for pair in line.split():
						wt = pair.split("/")
						if len(wt) >= 2 and wt[0]:
							word = wt[0].strip().lower()
							word = "".join([c if c.isalpha() else "" for c in word])
							if len(word) > 0:
								tag = wt[1].strip().upper()
								if tag[:2] in ["NN", "JJ", "VB", "DT", "PP", "WP", "RB","NP"]: tag = tag[:2]
								tag = tag.split("-")[0]
								if word not in words:
									words[word] = dict()
								if tag not in words[word]:
									words[word][tag] = 0
								words[word][tag] += 1

kwords = set()
with open("wordlist2.txt") as g:
	no = 0
	yes = 0
	for line in g.readlines():
		word = line.split()[0].strip().lower()
		kwords.add(word)
		if word not in words: 		
			no += 1
		else: yes += 1
print yes, no
print len(kwords)
print len(words)


"""
with open(out, "w") as g:
	for w in words:
		for t in words[w]:
			line = w + "/" + t + "/" + str(words[w][t] ) + "\n"
			g.write(line)
"""