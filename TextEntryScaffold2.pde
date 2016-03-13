import java.util.Arrays;
import java.util.Collections;
import android.graphics.Rect;
import android.graphics.Point;

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
final int DPIofYourDeviceScreen = 480; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
final int tw = sizeOfInputArea/12; //Used because fractions confuse me
final int margin = 200;

int scrollLoc = 0;

Rect input = new Rect(margin, margin, margin + tw*12, margin + tw*12);
Rect delete = new Rect(margin+tw, margin+tw, margin + tw*6, margin + tw * 3);
Rect space = new Rect(margin + tw * 6, margin+tw, margin + tw * 11, margin + tw * 3);

Rect[] rects = new Rect[2];
Rect scroll = new Rect(margin, margin + tw*6, margin + tw*12, margin + tw*8);

Rect auto0 = new Rect(margin, margin + tw*8, margin + tw*6, margin + tw*10);
Rect auto1 = new Rect(margin + tw*6, margin + tw*8, margin + tw*12, margin +tw*10);
Rect auto2 = new Rect(margin, margin + tw*10, margin + tw * 6, margin + tw*12);
Rect auto3 = new Rect(margin + tw*6, margin + tw*10, margin + tw*6, margin + tw*12);

Point[] points = new Point[48];

Point sMouse = new Point();
Point fMouse = new Point();
boolean inSwipe = false;

char[][] baseLetters = { 
                        {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x'},
                        {'y','z','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'}
                       };
char[] letters = baseLetters[0];
//You can modify anything in here. This is just a basic implementation.
void setup()
{
  for (int i = 0; i < 2; i++) {
    rects[i] = new Rect(margin + tw + (tw*5)*(i%2), margin + tw + (tw*2)*(1+(i/2)), margin + tw + (tw*5)*(1 + (i%2)), margin + tw + (tw*2)*(2+(i/2)));
  }
  
  points[0] = new Point(margin+tw*0, margin+tw*0); points[1] = new Point(margin+tw*2, margin+tw*0);
  points[2] = new Point(margin+tw*2, margin+tw*0); points[3] = new Point(margin+tw*4, margin+tw*0);
  points[4] = new Point(margin+tw*4, margin+tw*0); points[5] = new Point(margin+tw*6, margin+tw*0);
  points[6] = new Point(margin+tw*6, margin+tw*0); points[7] = new Point(margin+tw*8, margin+tw*0);
  points[8] = new Point(margin+tw*8, margin+tw*0); points[9] = new Point(margin+tw*10, margin+tw*0);
  points[10] = new Point(margin+tw*10, margin+tw*0); points[11] = new Point(margin+tw*12, margin+tw*0);
  
  points[12] = new Point(margin+tw*12, margin+tw*0); points[13]  = new Point(margin+tw*12, margin+tw*2);
  points[14] = new Point(margin+tw*12, margin+tw*2); points[15] = new Point(margin+tw*12, margin+tw*4);
  points[16] = new Point(margin+tw*12, margin+tw*4); points[17] = new Point(margin+tw*12, margin+tw*6);
  points[18] = new Point(margin+tw*12, margin+tw*6); points[19] = new Point(margin+tw*12, margin+tw*8);
  points[20] = new Point(margin+tw*12, margin+tw*8); points[21] = new Point(margin+tw*12, margin+tw*10);
  points[22] = new Point(margin+tw*12, margin+tw*10); points[23] = new Point(margin+tw*12, margin+tw*12);
  
  points[24] = new Point(margin+tw*12, margin+tw*12); points[25] = new Point(margin+tw*10, margin+tw*12);
  points[26] = new Point(margin+tw*10, margin+tw*12); points[27] = new Point(margin+tw*8, margin+tw*12);
  points[28] = new Point(margin+tw*8, margin+tw*12); points[29] = new Point(margin+tw*6, margin+tw*12);
  points[30] = new Point(margin+tw*6, margin+tw*12); points[31] = new Point(margin+tw*4, margin+tw*12);
  points[32] = new Point(margin+tw*4, margin+tw*12); points[33] = new Point(margin+tw*2, margin+tw*12);
  points[34] = new Point(margin+tw*2, margin+tw*12); points[35] = new Point(margin+tw*0, margin+tw*12);
  
  points[36] = new Point(margin+tw*0, margin+tw*12); points[37] = new Point(margin+tw*0, margin+tw*10);
  points[38] = new Point(margin+tw*0, margin+tw*10); points[39] = new Point(margin+tw*0, margin+tw*8);
  points[40] = new Point(margin+tw*0, margin+tw*8); points[41] = new Point(margin+tw*0, margin+tw*6);
  points[42] = new Point(margin+tw*0, margin+tw*6); points[43] = new Point(margin+tw*0, margin+tw*4);
  points[44] = new Point(margin+tw*0, margin+tw*4); points[45] = new Point(margin+tw*0, margin+tw*2);
  points[46] = new Point(margin+tw*0, margin+tw*2); points[47] = new Point(margin+tw*0, margin+tw*0);


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

void drawRect(Rect r, int hex, String input) {
  drawRect(r, hex);
  fill(0);
  text(input, (float)r.centerX(), (float)r.centerY()+15); 
}

void drawScroll(Rect r, int hex) {
  drawRect(r, hex);
  for (int i = 0; i < 7; i++) {
    fill(#808080);
    if (i == scrollLoc) fill(#FF0000); 
    ellipse((float)r.left+(tw*12/7) * i + 40, (float)r.centerY(), 20, 20);
  }
}

Point midpoint (Point a, Point b) {
  return new Point((a.x + b.x)/2, (a.y + b.y)/2);
}

void drawLetters(char[] letters) {
   for (int i = 0; i < 48; i+=2){
      Point mid = midpoint(points[i], points[i+1]);
      int offsetY = 0;
      int offsetX = 0;
      if ((i/12) == 0) offsetY = 30;
      if ((i/12) == 1) offsetX = -15;
      if ((i/12) == 2) offsetY = -10;
      if ((i/12) == 3) offsetX = 15;
      text(""+letters[i/2], mid.x+offsetX, mid.y+offsetY);
   }
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

  // image(watch,-200,200);
  drawRect(input, #808080); //input area should be 2" by 2"

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

    textSize(50);
    textAlign(CENTER);
    //Draw letters
    for (int i = 0; i < 1; i++) {
      drawRect(rects[i], #FFFFFF, baseLetters[i][0] + "-" + baseLetters[i][23]);
    }
    drawRect(rects[1], #FFFFFF, baseLetters[1][0] + "-" + baseLetters[1][1]);
   
   
    //Draw space and delete
    
    drawRect(space, #FFFFFF, "_"); 
    drawRect(delete, #FFFFFF, "del"); 
    drawLetters(letters);
    textSize(30);
    //Draw scroll bar
    //drawScroll(scroll, #FFFFFF);
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

  

  /*
  if (letter1=="_") //if underscore, consider that a space bar
   
   else if (letter1=='`' & currentTyped.length()>0) //if `, treat that as a delete command
   //currentTyped = currentTyped.substring(0, currentTyped.length()-1);
   else if (letter1!='`') //if not any of the above cases, add the current letter to the typed string
   currentTyped+=letter1;*/

  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

int counter = 0;

void mouseReleased() {
  inSwipe = false; 
    if (space.contains(mouseX, mouseY)) {
    currentTyped+=" ";
  }
  if (delete.contains(mouseX, mouseY)) {
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  }
  for (int i = 0; i < 2; i++) {
    if (rects[i].contains(mouseX, mouseY)) {
      letters = baseLetters[i];
    }
  }
}

void mouseDragged() 
{
  if (inSwipe && (!input.contains(mouseX, mouseY)) && input.contains(sMouse.x, sMouse.y)){
    fMouse.set(mouseX, mouseY);
    for (int i = 0; i < 48; i+=2) {
      if (linesIntersect(sMouse.x, sMouse.y, fMouse.x, fMouse.y, points[i].x, points[i].y, points[i+1].x, points[i+1].y)) {
        currentTyped += letters[i/2];
      }
    }
    inSwipe = false;
  }
  /*
  if (input.contains(mouseX, mouseY)) //check if click occured in letter area
  {
    counter++;
    if (counter == 7) {
      counter = 0;
      if (mouseX > pmouseX) //check if click in left button
      {
        for (int i = 0; i < 4; i++) {
          letters[i] = (char((((int)letters[i] + 1 - 97) % 26) + 97));
        }
      }

      if (mouseX < pmouseX) //check if click in right button
      {
        for (int i = 0; i < 4; i++) {
          letters[i] = (char((((int)letters[i] - 1 - 97 + 26) % 26) + 97));
        }
      }
    }
  }
  scrollLoc = (((int)letters[0] - 97) % 26) / 4;
  */
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