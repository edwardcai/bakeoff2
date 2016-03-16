import java.util.Arrays;
import java.util.Map;
import java.util.Collections;
import java.util.LinkedList;
import android.graphics.Rect;
import android.graphics.Point;
import java.util.Comparator;
import android.text.TextUtils;

Autocomplete autocomplete;
String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 424; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
final int tw = sizeOfInputArea/12; //Used because fractions confuse me
final int margin = 200;
int numAutocompleteOptions = 4;
final int ellipseRad = tw*6;
final int ellipseVert = tw*5;

int scrollLoc = 0;
Rect input = new Rect(margin, margin, margin + tw*12, margin + tw*12);
Rect delete = new Rect(margin, margin, margin + tw*6, margin + tw * 2);
Rect space = new Rect(margin + tw * 6, margin, margin + tw * 12, margin + tw * 2);

public class Letter{
  Point p;
  char l;
  float distance;
  boolean isActive;
  
}

//So that the ellipse doesn't go off screen. silly processing
Rect black1 = new Rect(0, 0, 1080, margin);
Rect black2 = new Rect(0, 0, margin, 1920);
Rect black3 = new Rect(margin + tw*12, 0, 1080, 1920);
Rect black4 = new Rect(0, margin + tw*12, 1080, 1920);



Rect[] rects = new Rect[4];
Rect scroll = new Rect(margin, margin + tw*6, margin + tw*12, margin + tw*8);
Rect[] auto = new Rect[4];


Point sMouse = new Point();
Point fMouse = new Point();
boolean inSwipe = false;


Letter[][] letters = new Letter[3][];

Rect qRect = new Rect(margin, margin + tw*6, margin + tw*12, margin + tw*12);
char[][] qwerty = {{'q','w','e','r','t','y','u','i','o','p'},
                   {'a','s','d','f','g','h','j','k','l'},
                   {'z','x','c','v','b','n','m'}};
int selectedScrollRectIndex = 0;
Rect[] scrollRects = new Rect[23]; // 23 is number of shifts required to go from abcd to wxyz

//You can modify anything in here. This is just a basic implementation.

//Lines for backspace and space
Point[] lines = new Point[4];

Map<String, float[]> commonLetters = new HashMap<String, float[]>();

void setup()
{
  autocomplete = new Autocomplete(4);
  autocomplete.addWords(loadStrings("worddata.txt"));
  auto[0] = new Rect(margin, margin, margin + tw*6, margin + tw*2 + tw/2);
  auto[1] = new Rect(margin + tw*6, margin, margin + tw*12, margin +tw*2 + tw/2);
  auto[2] = new Rect(margin, margin + tw*2 + tw/2, margin + tw * 6, margin + tw*5);
  auto[3] = new Rect(margin + tw*6, margin + tw*2 + tw/2, margin + tw*12, margin + tw*5 ); 
   // can't map char as key, so need to cast when checking previous letter
 commonLetters.put(" ", new float[] { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});
 commonLetters.put("a", new float[] {  0.09,2.54,5.41,4.07,0.16,0.78,3.19,0.3,3.59,0.1,1.1,11.6,3.84,18.6,0.07,2.4,0.14,12.4,7.25,14.6,1.53,2.13,0.57,0.33,2.96,0.29});
 commonLetters.put("b", new float[] {  11.78,0.87,0.45,0.18,22.74,0.04,0.05,0.09,7.52,1.12,0.02,12.32,0.78,0.25,12.5,0.15,0.02,6.68,3.35,0.53,10.07,0.1,0.09,0.02,8.24,0.03});
 commonLetters.put("c", new float[] {  13.5,0.06,1.95,0.37,14.5,0.05,0.05,13.03,5.67,0.01,5.38,4.48,0.12,0.13,19.13,0.11,0.08,3.76,1.27,11.06,3.64,0.06,0.02,0.01,1.5,0.03});
 commonLetters.put("d", new float[] {  11.24,0.59,0.48,2.96,30.57,0.29,1.17,0.24,19.52,0.26,0.05,1.26,0.81,0.47,9.04,0.18,0.03,3.76,5.99,0.32,6.37,2.04,0.6,0.02,1.73,0.01});
 commonLetters.put("e", new float[] {  6.87,1.0,4.87,8.77,3.75,1.17,1.39,0.22,1.08,0.03,0.27,5.58,3.77,12.25,0.77,1.69,0.51,19.04,14.32,4.52,0.36,2.23,2.22,2.18,1.09,0.07});
 commonLetters.put("f", new float[] {  8.21,0.05,0.14,0.09,11.65,7.47,0.11,0.06,17.13,0.01,0.02,3.55,0.12,0.05,28.11,0.09,0.01,12.39,0.43,4.43,5.21,0.01,0.07,0.04,0.57,0.0});
 commonLetters.put("g", new float[] {  10.44,0.27,0.13,0.3,26.84,0.11,1.35,10.62,9.81,0.01,0.04,3.21,0.56,4.09,8.53,0.23,0.0,11.03,3.83,1.11,5.39,0.02,0.1,0.01,1.96,0.03});
 commonLetters.put("h", new float[] {  16.37,0.14,0.09,0.16,44.41,0.05,0.02,0.03,14.21,0.01,0.02,0.38,0.28,1.0,14.25,0.18,0.02,1.86,0.44,3.21,1.6,0.03,0.17,0.01,1.04,0.04});
 commonLetters.put("i", new float[] {  3.52,1.04,8.59,3.24,4.78,1.96,3.0,0.02,0.18,0.04,0.5,5.66,2.76,25.38,8.91,1.54,0.13,3.13,10.36,11.19,0.18,2.92,0.02,0.27,0.01,0.66});
 commonLetters.put("j", new float[] {  22.76,0.17,0.35,0.25,21.67,0.09,0.04,0.1,2.61,0.12,0.14,0.09,0.2,0.1,26.63,0.55,0.01,0.33,0.34,0.09,23.05,0.2,0.08,0.02,0.03,0.01});
 commonLetters.put("k", new float[] {  5.61,1.11,0.17,0.3,37.4,0.56,0.66,0.51,20.96,0.25,0.31,2.39,0.74,5.53,2.64,0.45,0.01,0.93,15.16,0.9,1.1,0.09,0.44,0.02,1.74,0.03});
 commonLetters.put("l", new float[] {  12.58,0.37,0.47,4.26,20.35,0.78,0.19,0.04,16.93,0.01,0.49,13.63,0.54,0.12,10.4,1.01,0.0,0.24,4.08,3.06,3.24,0.57,0.18,0.01,6.42,0.02});
 commonLetters.put("m", new float[] {  21.59,3.93,0.4,0.18,28.82,0.17,0.1,0.06,10.47,0.01,0.02,0.39,4.17,0.28,11.59,7.62,0.0,0.16,3.88,0.22,3.64,0.04,0.08,0.03,2.13,0.01});
 commonLetters.put("n", new float[] {  6.22,0.13,5.31,16.47,11.81,1.52,14.33,0.17,5.51,0.16,1.34,1.32,0.46,1.56,6.2,0.11,0.06,0.15,7.29,15.68,1.64,0.76,0.1,0.03,1.57,0.09});
 commonLetters.put("o", new float[] {  1.07,1.21,2.2,2.59,0.43,7.93,1.68,0.29,0.92,0.2,1.19,4.51,6.92,19.95,3.24,3.4,0.01,16.69,3.37,5.27,10.08,2.23,3.73,0.33,0.5,0.06});
 commonLetters.put("p", new float[] {  14.11,0.11,0.45,0.67,14.63,0.12,0.21,4.27,5.38,0.01,0.06,9.88,1.69,0.1,13.47,5.38,0.01,18.14,2.51,3.48,4.12,0.04,0.04,0.02,1.1,0.02});
 commonLetters.put("q", new float[] {  0.61,0.11,0.2,0.07,0.08,0.14,0.03,0.04,0.69,0.02,0.01,1.88,0.12,0.06,0.13,0.07,0.09,0.16,0.99,0.81,93.45,0.09,0.11,0.02,0.01,0.01});
 commonLetters.put("r", new float[] {  10.64,0.43,2.71,3.16,26.91,0.5,1.42,0.15,11.62,0.01,1.82,1.27,2.73,2.62,11.02,0.62,0.02,1.64,6.64,6.26,2.0,1.6,0.24,0.01,3.9,0.03});
 commonLetters.put("s", new float[] {  4.7,0.37,3.64,0.36,18.73,0.3,0.11,6.18,11.56,0.01,1.09,1.14,1.04,0.32,7.37,3.97,0.18,0.24,8.23,22.63,5.77,0.09,0.71,0.01,1.27,0.01});
 commonLetters.put("t", new float[] {  7.33,0.13,0.58,0.12,16.68,0.12,0.09,25.55,15.92,0.01,0.03,0.96,0.49,0.21,12.41,0.14,0.0,5.25,5.08,1.93,2.99,0.12,0.89,0.04,2.88,0.06});
 commonLetters.put("u", new float[] {  3.76,3.29,4.94,2.99,4.19,0.6,2.75,0.04,3.42,0.04,0.48,7.68,4.78,11.38,0.4,4.52,0.02,17.55,14.88,10.88,0.04,0.12,0.03,0.28,0.8,0.14});
 commonLetters.put("v", new float[] {  12.15,0.11,0.17,1.02,51.71,0.03,0.14,0.12,28.71,0.0,0.0,0.08,0.07,0.05,4.37,0.1,0.01,0.16,0.38,0.1,0.16,0.02,0.02,0.03,0.28,0.0});
 commonLetters.put("w", new float[] {  16.94,0.2,0.13,0.19,20.15,0.12,0.04,12.69,22.15,0.12,0.12,0.79,0.14,4.77,12.03,0.13,0.0,1.87,6.18,0.43,0.06,0.04,0.31,0.04,0.35,0.0});
 commonLetters.put("x", new float[] {  9.54,0.88,9.14,0.2,9.89,0.7,0.1,1.62,11.71,0.03,0.03,0.6,1.5,0.19,1.57,21.59,0.08,0.26,0.44,22.55,2.36,0.3,0.15,2.64,1.89,0.03});
 commonLetters.put("y", new float[] {  3.69,1.23,2.0,1.16,13.89,0.14,0.32,0.18,3.24,0.01,0.09,3.2,3.96,2.42,36.1,4.39,0.0,3.87,15.34,2.45,0.48,0.1,1.37,0.04,0.08,0.26});
 commonLetters.put("z", new float[] {  18.18,0.43,0.13,0.72,37.4,0.07,0.17,0.82,16.46,0.16,0.19,1.41,0.31,0.24,11.06,0.1,0.03,0.59,0.55,0.29,3.1,0.12,0.26,0.05,2.33,4.82});

  
  lines[0] = new Point(margin + tw*12, margin); lines[1] = new Point(margin + tw*12, margin + tw*12);
  lines[2] = new Point(margin , margin); lines[3] = new Point(margin, margin + tw*12);
  
  
  letters[0] = new Letter[10];
  letters[1] = new Letter[9];
  letters[2] = new Letter[7];
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      letters[i][j] = new Letter();
      //magic numbers fight me kosbie
      letters[i][j].p = new Point(margin + 21 + (i*15) + (j*41), margin + tw*7 + (tw/2) + (i*60));
      letters[i][j].l = qwerty[i][j];
      letters[i][j].isActive = true;
    }
  }
  
  for (int i = 0; i < 4; i++) {
    rects[i] = new Rect(margin + (tw*3)*i, margin + (tw*2), margin + ((tw*3) * (i+1)), margin + tw*6);
  }
    

  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1080, 1920); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
}

void drawRect(Rect r, int hex) {
  fill(hex);
  stroke(0);
  rect((float)r.left, (float)r.top, (float)r.width(), (float)r.height());
}

// I don't feel like changing every instance of drawRect so I'm just making another one
void drawRectNoStroke(Rect r, int val) {
  fill(val);
  noStroke();
  rect((float)r.left, (float)r.top, (float)r.width(), (float)r.height());
}

void drawRect(Rect r, int hex, String input) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY()+15); //
}


void drawQwerty() {
  fill(0);
  textSize(50);
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      if (letters[i][j].isActive) text("" + letters[i][j].l, letters[i][j].p.x, letters[i][j].p.y); 
    }
  }
}
void drawRect(Rect r, int hex, String input, int marginTop) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY() + marginTop); //
}

void drawEllipse() {
  fill(200);
  ellipse(mouseX, mouseY - ellipseVert, ellipseRad, ellipseRad);
  fill(255);
  ellipse(mouseX, mouseY - ellipseVert, ellipseRad/3, ellipseRad/3);
  fill(50);
  textSize(60);
  for (Letter n : neighbors) {
    if (n != closest) text("" + n.l, (n.p.x), 0 - ellipseVert + (n.p.y));  
  }
  fill(255,0,0);
  textSize(80);
  text("" + closest.l, closest.p.x , closest.p.y - ellipseVert);
}

void setQwertyActive(boolean b) {
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      letters[i][j].isActive = b;
    }
  }
}
int counter = 0;
//You can modify anything in here. This is just a basic implementation.
void draw()
{
  counter++;
  background(0); //clear background
  // image(watch,-200,200);
  drawRect(input, #d3d3d3); //input area should be 2" by 2"
  textSize(30);
  

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    text("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f),margin + tw, margin + tw * 20);
    text("Total time taken: " + (finishTime - startTime) ,margin + tw, margin + tw * 20 + 40);
    text("Total errors entered: " + errorsTotal ,margin + tw, margin + tw * 20 + 80);
    text("Total time taken: " + (finishTime - startTime) ,margin + tw, margin + tw * 20 + 120);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //my draw code
    textAlign(CENTER,CENTER);
    textSize(40);
    for (int i = 0; i < 4; i++) {
      drawRect(auto[i], #FFFFFF,   autocomplete.currentOptions[i], tw/5 );
    }
    drawQwerty();
    if (qRect.contains(mouseX, mouseY) && inSwipe) drawEllipse();
    drawRect(black1,0);drawRect(black2,0);drawRect(black3,0);drawRect(black4,0);
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textSize(30);
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    if (counter < 15) {
      text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far
    } else {
      text("Entered:  " + currentTyped + "|", 70, 140);
      counter = 0;
      if (counter == 70) counter = 0;
    }
    fill(255, 0, 0);
    rect(800, 00, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 100); //draw next label


   
  }
  
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void mousePressed()
{
  for (int i = 0 ; i < numAutocompleteOptions; i++ ) {
    if (auto[i].contains(mouseX, mouseY)) addRestOfWord(i);
  }
  sMouse.set(mouseX, mouseY);
  inSwipe = true;
  if (qRect.contains(mouseX, mouseY)) {
      neighbors.clear();
      float distance = Integer.MAX_VALUE;
      for (int i = 0; i < letters.length; i++) {
        for (int j = 0; j < letters[i].length; j++) {
          float distOff = 0;
   
          letters[i][j].distance = dist(letters[i][j].p.x, letters[i][j].p.y, mouseX, mouseY);
          //Find letters within range 
          if (letters[i][j].distance < ellipseRad/3){
            if (currentTyped.length() > 0) {
              float prob = commonLetters.get("" + currentTyped.charAt(currentTyped.length()-1))[(int)letters[i][j].l - (int)'a']; 
              distOff += prob/44 * (ellipseRad/6);
            letters[i][j].distance -= distOff;
            }
            neighbors.add(letters[i][j]);
          }
          //Find closest letter
          if (letters[i][j].distance < distance) {
            closest = letters[i][j];
            distance = letters[i][j].distance;
          }
        }
      }
  }
}

boolean started = false;
void mouseReleased() {
  inSwipe = false;
  if (!started) {
    started = true;
    return;
  }
  if (qRect.contains(mouseX, mouseY)) {
    currentTyped += ""+closest.l;  
    callAutocorrect();
  }
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


LinkedList<Letter> neighbors = new LinkedList<Letter>();
Letter closest = null;

void mouseDragged() 
{
  if (inSwipe && (!input.contains(mouseX, mouseY)) && input.contains(sMouse.x, sMouse.y)){
    fMouse.set(mouseX, mouseY);
    //Space swipe
    if (linesIntersect(sMouse.x, sMouse.y, fMouse.x, fMouse.y, lines[0].x, lines[0].y, lines[1].x, lines[1].y)) {
        currentTyped+=" ";
    } else if (linesIntersect(sMouse.x, sMouse.y, fMouse.x, fMouse.y, lines[2].x, lines[2].y, lines[3].x, lines[3].y)) {
        if (currentTyped.length() > 0) currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    }
    inSwipe = false;
    if (currentTyped.length() > 0) callAutocorrect();
  }
  if (qRect.contains(mouseX, mouseY)) {
      neighbors.clear();
      float distance = Integer.MAX_VALUE;
      for (int i = 0; i < letters.length; i++) {
        for (int j = 0; j < letters[i].length; j++) {
          float distOff = 0;
   
          letters[i][j].distance = dist(letters[i][j].p.x, letters[i][j].p.y, mouseX, mouseY);
          //Find letters within range 
          if (letters[i][j].distance < ellipseRad/3){
            if (currentTyped.length() > 0) {
              float prob = commonLetters.get("" + currentTyped.charAt(currentTyped.length()-1))[(int)letters[i][j].l - (int)'a']; 
              distOff += prob/44 * (ellipseRad/6);
            letters[i][j].distance -= distOff;
            }
            neighbors.add(letters[i][j]);
          }
          //Find closest letter
          if (letters[i][j].distance < distance) {
            closest = letters[i][j];
            distance = letters[i][j].distance;
          }
        }
      }
  }
}

String currentWord(String typed) {
  if (typed.charAt(typed.length()-1) == ' ') return "";
  String[] words = typed.split(" ");
  System.out.println(words[words.length-1]);
  return words[words.length - 1];
}
void addRestOfWord(int i) {
  String[] words = currentTyped.split(" ");
  if (autocomplete.currentOptions[i] == "") return;
  words[words.length-1] = autocomplete.currentOptions[i];
  currentTyped = TextUtils.join(" ", words);
  callAutocorrect();
}

void callAutocorrect() {
  String word = currentWord(currentTyped);
  if (word != "") {
    autocomplete.getCompletions(word);
  } else {
    for (int i = 0; i < numAutocompleteOptions; i++) {
      autocomplete.currentOptions[i] = "";
    }
  }
}

void restart() {
  totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
  currTrialNum = 0; // the current trial number (indexes into trials array above)
  startTime = 0; // time starts when the first letter is entered
  finishTime = 0; // records the time of when the final trial ends
  lastTime = 0; //the timestamp of when the last trial was completed
  lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
  lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
  errorsTotal = 0; //a running total of the number of errors (when hitting next)
  currentPhrase = ""; //the current target phrase
  currentTyped = ""; //what the user has typed so far
  started = false;
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
}



void nextTrial()
{
  if (currTrialNum >= totalTrialNum) { //check to see if experiment is done
    restart();
    return; 
  }

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//Test for intersection
public static boolean linesIntersect(final int X1, final int Y1, final int X2, final int Y2,
      final int X3, final int Y3, final int X4, final int Y4) {
    return ((relativeCCW(X1, Y1, X2, Y2, X3, Y3)
        * relativeCCW(X1, Y1, X2, Y2, X4, Y4) <= 0) && (relativeCCW(X3,
            Y3, X4, Y4, X1, Y1)
            * relativeCCW(X3, Y3, X4, Y4, X2, Y2) <= 0));
}

  private static int relativeCCW(final int X1, final int Y1, int X2, int Y2, int PX,
      int PY) {
    X2 -= X1;
    Y2 -= Y1;
    PX -= X1;
    PY -= Y1;
    int ccw = PX * Y2 - PY * X2;
    if (ccw == 0) {
      ccw = PX * X2 + PY * Y2;
      if (ccw > 0) {
        PX -= X2;
        PY -= Y2;
        ccw = PX * X2 + PY * Y2;
        if (ccw < 0) {
          ccw = 0;
        }
      }
    }
    return (ccw < 0) ? -1 : ((ccw > 0) ? 1 : 0);
  }




//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}