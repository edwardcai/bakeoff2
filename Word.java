// word class - keeps data on POS, frequency, etc
public class Word {
	public String text;
	public int frequency;
	public String pos;
	public Word(String word, int frequency, String pos) {
		this.text = word;
		this.frequency = frequency;
		this.pos = pos;

	}	
	public String text() {
		return this.text;
	}
	
}