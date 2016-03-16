import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Collections;
import java.util.Arrays;
//trie implementation

public class Trie { 
	private static int charToIndex(char c) {
		return (int)c - (int)'a';
	}
	class Node {
		Set<Word> words = new HashSet<Word>();
		Node[] children = new Node[26];
		Map<String, Integer> childBests = new HashMap<String, Integer>();

		
		private void updateChildBests(String pos, int freq) {
			if (this.childBests.get(pos) == null || this.childBests.get(pos) < freq) {
				this.childBests.put(pos, freq);
			}
		}

		private Node getChildNode(char c) {
			return this.children[charToIndex(c)];
		}
		private void add(Word w, int i) {
			if (i == w.text.length()) {
				//end of word -> add to words ending at this node
				this.words.add(w);
				this.updateChildBests(w.pos, w.frequency);
			} 
			else if (i < w.text.length()) {
				this.updateChildBests(w.pos, w.frequency);
				char c = w.text.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) {
					this.children[charToIndex(c)] = new Node();
					child = this.children[charToIndex(c)];
				}
				child.add(w, i+1);
			}


		}
		private boolean lookupFromNode(String word, int i) {
			if (i == word.length()) {
				return (! this.words.isEmpty());
			} else {
				char c = word.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) return false;
				else {
					return child.lookupFromNode(word, i+1);
				}
			}
		}
		private Map<String, Integer> traverseFindWords(String prefix, int i, int minWords, Map<String, Integer> wordsFound) {
			if (i == prefix.length() && wordsFound.size() < minWords) {
				if (this.words.size() > 0) {
					for (Word w : this.words) {
						wordsFound.put(w.text, 0);
					}
					if (wordsFound.size() >= minWords) return wordsFound;
				}
				for (int j = 0; j < 26; j++) {
					Node child = this.children[j];
					if (child == null) continue;
					else {
						wordsFound = child.traverseFindWords(prefix, i, minWords, wordsFound);
						if (wordsFound.size() >= minWords) return wordsFound;
					}
				}
				return wordsFound;
			} else {
				char c = prefix.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) return wordsFound;
				else return child.traverseFindWords(prefix, i+1, minWords, wordsFound);
			}
		}
		private Map<String, Integer> traverseFindWordsMostFreq(String prefix, int i, int minWords, Map<String, Integer> wordsFound) {
			int threshold = Trie.getCutoffLikelihood(minWords, wordsFound);

			if (i == prefix.length() ) {
				if (this.words.size() > 0) {
					int frequency = 0;
					String text = "ERROR";
					for (Word w : this.words) {
						frequency += w.frequency;
						text = w.text;
					}
					if (frequency > threshold) {
						wordsFound.put(text, frequency);
						threshold = getCutoffLikelihood(minWords, wordsFound);
						Trie.clearLowLikelihood(wordsFound, minWords, threshold);
						}		
				}
				for (int j = 0; j < 26; j++) {
					Node child = this.children[j];
					if (child == null) continue;
					else {
						if (! Trie.hasLikelyChildren(child, threshold)) {
						}

						if (Trie.hasLikelyChildren(child, threshold)) {
							wordsFound = child.traverseFindWordsMostFreq(prefix, i, minWords, wordsFound);

							Trie.clearLowLikelihood(wordsFound, minWords, threshold);
						}
					}
				}
				return wordsFound;

			} else {
				char c = prefix.charAt(i);
				Node child = this.getChildNode(c);
				if (child == null) return wordsFound;
				else {
					if (Trie.hasLikelyChildren(child, threshold)) {
							wordsFound = child.traverseFindWordsMostFreq(prefix, i+1, minWords, wordsFound);
							Trie.clearLowLikelihood(wordsFound, minWords, threshold);
					} else {

					}
					return wordsFound;
				}
			}
		}
	}
	private static int getCutoffLikelihood(int minWords, Map<String, Integer> wordsFound) {
		Integer[] values = wordsFound.values().toArray(new Integer[wordsFound.size()]);
		Arrays.sort(values, Collections.reverseOrder());
		if (minWords == values.length) 
			return values[minWords-1] - 1;
		else if (minWords < values.length)
			return values[minWords];
		else return 0;
	}
	private static void clearLowLikelihood(Map<String, Integer> wordsFound, int minWords, int threshold) {
		if (wordsFound.size() > minWords) {
			//clear out all words that aren't the minWords most likely
			Iterator it = wordsFound.entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry pair = (Map.Entry)it.next();
				if ((Integer)pair.getValue() <= threshold) 

					it.remove();
			}
		}
	}
	private static boolean hasLikelyChildren(Node node, int threshold) {
		if (threshold == 0) return true;
		Iterator it = node.childBests.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry pair = (Map.Entry)it.next();
			if ((Integer)pair.getValue() > threshold) {
				return true;
			}
		}
		return false;
	}
	
	Node root;
	public Trie() {
		root = new Node();
	}
	public void addList(Word[] words) {
		for (int i = 0; i < words.length; i++) {
			this.add(words[i]);

		}
	}
	public void add(Word w) {
		this.root.add(w, 0);
	}
	
	public boolean inTrie(String word) {
		return this.root.lookupFromNode(word, 0);
	}

	public Map<String, Integer> findWords(String prefix, int n) {
		Map<String,Integer> words = new HashMap<String,Integer>();

		Map<String, Integer> words1 = this.root.traverseFindWordsMostFreq(prefix, 0, n, words);
		
		return words1;
	}
}
	