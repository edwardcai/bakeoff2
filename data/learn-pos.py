import os, string, re, json


tagmap = {
	"ABL" : "DT",
	"ABN" : "DT",
	"ABX" : "DT",
	"AP" : "DT",
	"AT" : "AT",
	"BE" : "VB",
	"BED" : "VB",
	"BEDZ" : "VB",
	"BEG" : "VB",
	"BEM" : "VB",
	"BEN" : "VB",
	"BER" : "VB",
	"BEZ" : "VB",
	"CC" : "CJ",
	"CD" : "CRD",
	"CS" : "CJ",
	"DO" : "VD",
	"DOD" : "VD",
	"DOZ" : "VD",
	"DT" : "DT",
	"DTI" : "DT",
	"DTS" : "DT",
	"DTX" : "DT",
	"EX" : "EX0",
	"FW" : "UNC",
	"HV" : "VH",
	"HVD" : "VH",
	"HVG" : "VH",
	"HVN" : "VH",
	"HVZ" : "VH",
	"IN" : "PRP",
	"JJ" : "AJ",
	"JJR" : "AJ",
	"JJS" : "AJ",
	"JJT" : "AJ",
	"MD" : "VM0",
	"NIL" : "UNC",
	"NN" : "NN",
	"NNS" : "NN",
	"NP" : "NP",
	"NPS" : "NP",
	"NR" : "NN",
	"NRS" : "NN",
	"OD" : "ORD",
	"PN" : "NN",
	"PP" : "PN",
	"PPL" : "PN",
	"PPLS" : "PN",
	"PPO" : "PN",
	"PPS" : "PN",
	"PPSS" : "PN",
	"QL" : "AV",
	"QLP" : "AV",
	"RB" : "AV",
	"RBR" : "AV",
	"RBT" : "AV",
	"RN" : "NN",
	"RP" : "AV",
	"TO" : "TO0",
	"UH" : "ITJ",
	"VB" : "VV",
	"VBD" : "VV",
	"VBG" : "VV",
	"VBN" : "VV",
	"VBZ" : "VV",
	"WDT" : "DT",
	"WP" : "PN",
	"WPO" : "PN",
	"WPS" : "PN",
	"WQL" : "AV",
	"WRB" : "AV"
}
"""
AJ adjective
AT article
AV adverb
CJ conjunction
CRD cardinal number
DT determiner
EX0 existential there
ITJ interjection
NN common noun
NP proper noun
ORD ordinal number
PN pronoun
PRP preposition
TO0 infinitival to 
UNC unclassivied
VB be verb
VD do verb
VH have verb
VV lexical verb
VM0 modal
"""

ngram = 3
words = dict()
out = "wordlist.txt"
# dict: string -> (dict: string -> int)
ngrams = dict()
for fname in os.listdir("brown"):
	if fname not in {".DS_Store", "cats.txt", "README", "CONTENTS"}:
		with open("brown/"+ fname) as f:
			for line in f.readlines():
				if not line.isspace():
					tags = ["#"]
					line = line.strip()
					for pair in line.split():
						wt = pair.split("/")
						if len(wt) >= 2 and wt[0]:
							word = wt[0].strip().lower()
							word = "".join([c if c.isalpha() else "" for c in word])
							if len(word) > 0:
								tag = wt[1].strip().upper()
								tag = re.split('\+|-', tag)[0]
								tag = re.sub(r'[^A-Z]+', '', tag)
								if tag != "" and tag in tagmap:
									tags += [tagmap[tag]]

					for k in xrange(2, ngram+1):
						for i in xrange(k-1, len(tags)):
							previous = " ".join(tags[i-k+1:i])
							tag = tags[i]
							if previous not in ngrams:
								ngrams[previous] = dict()
							if tag not in ngrams[previous]:
								ngrams[previous][tag] = 0
							ngrams[previous][tag] += 1

with open("pos-ngrams.txt", "w") as outfile:
	json.dump(ngrams, outfile)




									


