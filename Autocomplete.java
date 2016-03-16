import java.util.Arrays;
import java.util.Collections;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Set;
//import org.json.simple.JSONObject;

public class Autocomplete {
	
	Trie trie = new Trie();
	String[] currentOptions;
	int n;
	public Autocomplete(int n) {
		currentOptions = new String[n];
		this.n = n;
		for (int i = 0; i < n; i++) {
			currentOptions[i] = "";
		}

	}
	public void addWords(String[] words) {
		String[] parts;
		int rank;
		int frequency;
		String word;
		String pos;
		for (String line : words) {
			parts = line.split(" ");
			frequency = Integer.parseInt(parts[0]);
			word = parts[1].replaceAll("[^a-zA-Z ]", "").toLowerCase();
			pos = parts[2].replaceAll("[^a-zA-Z ]", "").toUpperCase();
        	this.trie.add(new Word(word, frequency, pos));
        		
		    }

	}

	public void getCompletions(String input) {

		if (this.n > 0) {			

			/* method returns list of possible continuations - all words with up to some 
			 * threshold probability based on parts of speech, word frequencies, etc
			 */
			Map<String, Integer> completionsMap = this.trie.findWords(input, this.n);
			
			String[] completions = completionsMap.keySet().toArray(new String[completionsMap.size()]);
			for (int i = 0; i < this.n; i++) {
				if (i < completions.length) {
					this.currentOptions[i] = completions[i];
				} else {	
					this.currentOptions[i] = "";
				}
			}
	
		}

		
	}	

	public String[] getBestCompletions(String input) {
		String[] completions = new String[100];
		for (int i = 0; i < input.length(); i++){
			completions[i] = input.substring(i, i+1);
		}
		return completions;
	}

}