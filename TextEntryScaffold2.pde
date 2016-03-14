import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Collections;
import android.graphics.Rect;
import android.graphics.Point;
import java.util.Comparator;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
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


Rect[] rects = new Rect[4];
Rect scroll = new Rect(margin, margin + tw*6, margin + tw*12, margin + tw*8);

Rect auto0 = new Rect(margin, margin + tw*8, margin + tw*6, margin + tw*10);
Rect auto1 = new Rect(margin + tw*6, margin + tw*8, margin + tw*12, margin +tw*10);
Rect auto2 = new Rect(margin, margin + tw*10, margin + tw * 6, margin + tw*12);
Rect auto3 = new Rect(margin + tw*6, margin + tw*10, margin + tw*6, margin + tw*12);

Point sMouse = new Point();
Point fMouse = new Point();
boolean inSwipe = false;


Letter[][] letters = new Letter[3][];

Rect qRect = new Rect(margin, margin + tw*2, margin + tw*12, margin + tw*12);
char[][] qwerty = {{'q','w','e','r','t','y','u','i','o','p'},
                   {'a','s','d','f','g','h','j','k','l'},
                   {'z','x','c','v','b','n','m'}};
int selectedScrollRectIndex = 0;
Rect[] scrollRects = new Rect[23]; // 23 is number of shifts required to go from abcd to wxyz

//You can modify anything in here. This is just a basic implementation.

//Lines for backspace and space
Point[] lines = new Point[4];
PriorityQueue <Letter> minHeap = new PriorityQueue<Letter>(4, new Comparator<Letter>() {
        public int compare(Letter x, Letter y) {
          return Float.compare(x.distance, y.distance);
        }
});

void setup()
{
  lines[0] = new Point(margin + tw*12, margin); lines[1] = new Point(margin + tw*12, margin + tw*12);
  lines[2] = new Point(margin , margin); lines[3] = new Point(margin, margin + tw*12);
  
  
  letters[0] = new Letter[10];
  letters[1] = new Letter[9];
  letters[2] = new Letter[7];
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      letters[i][j] = new Letter();
      letters[i][j].p = new Point(margin + 13 + (i*15) + (j*43), margin + tw*6 + (i*60));
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
  textSize(50);
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      if (letters[i][j].isActive) text("" + letters[i][j].l, letters[i][j].p.x, letters[i][j].p.y); 
    }
  }
}

void setQwertyActive(boolean b) {
  for (int i = 0; i < letters.length; i++) {
    for (int j = 0; j < letters[i].length; j++) {
      letters[i][j].isActive = b;
    }
  }
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

  // image(watch,-200,200);
  drawRect(input, #808080); //input area should be 2" by 2"
  textSize(30);
  

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
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
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    rect(800, 00, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 100); //draw next label


    //my draw code
    textAlign(CENTER);
  

    //Draw space and delete
    //drawRect(delete, #FFFFFF, "del");
    //drawRect(space, #FFFFFF, "_");

    drawQwerty();
    fill(255, 0, 0);
    //rect(200, 200, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    fill(0, 255, 0);
    //rect(200+sizeOfInputArea/2, 200, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void mousePressed()
{
  sMouse.set(mouseX, mouseY);
  inSwipe = true;
 
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

Letter[] top4 = new Letter[4];
boolean isFull = true;
void mouseReleased() {
  if (qRect.contains(mouseX, mouseY)) {
    if (isFull) {
      for (int i = 0; i < letters.length; i++) {
        for (int j = 0; j < letters[i].length; j++) {
          letters[i][j].distance = dist(letters[i][j].p.x, letters[i][j].p.y, mouseX, mouseY);
          minHeap.add(letters[i][j]);
        }
      }
      setQwertyActive(false);
      for (int i = 0; i < 4; i++) {
        top4[i] = minHeap.poll();
        top4[i].isActive = true;
      }
      minHeap.clear();
      isFull = false;
    } else {
      int index = 0;
      Letter l = null;
      float distance = Integer.MAX_VALUE;
      for (int i = 0; i < 4; i++) {
        if (dist(top4[i].p.x, top4[i].p.y, mouseX, mouseY) < distance) {
          distance = dist(top4[i].p.x, top4[i].p.y,mouseX,mouseY);
          index = i;
        }
      }
      currentTyped += ""+top4[index].l;
      setQwertyActive(true);
      isFull = true;
    }
  }
}


int counter = 0;

void mouseDragged() 
{
  if (inSwipe && (!input.contains(mouseX, mouseY)) && input.contains(sMouse.x, sMouse.y)){
    fMouse.set(mouseX, mouseY);
    //Space swipe
    if (linesIntersect(sMouse.x, sMouse.y, fMouse.x, fMouse.y, lines[0].x, lines[0].y, lines[1].x, lines[1].y)) {
        currentTyped+=" ";
    } else if (linesIntersect(sMouse.x, sMouse.y, fMouse.x, fMouse.y, lines[2].x, lines[2].y, lines[3].x, lines[3].y)) {
        currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    }
    inSwipe = false;
  }
}



void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

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