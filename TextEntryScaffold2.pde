import java.util.Arrays;
import java.util.PriorityQueue;
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
final int DPIofYourDeviceScreen = 424; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
final int tw = sizeOfInputArea/12; //Used because fractions confuse me
final int margin = 200;

int scrollLoc = 0;
Rect input = new Rect(margin, margin, margin + tw*12, margin + tw*12);
Rect delete = new Rect(margin, margin, margin + tw*6, margin + tw * 2);
Rect space = new Rect(margin + tw * 6, margin, margin + tw * 12, margin + tw * 2);


Rect[] rects = new Rect[4];
Rect scroll = new Rect(margin, margin + tw*6, margin + tw*12, margin + tw*8);

Rect auto0 = new Rect(margin, margin + tw*8, margin + tw*6, margin + tw*10);
Rect auto1 = new Rect(margin + tw*6, margin + tw*8, margin + tw*12, margin +tw*10);
Rect auto2 = new Rect(margin, margin + tw*10, margin + tw * 6, margin + tw*12);
Rect auto3 = new Rect(margin + tw*6, margin + tw*10, margin + tw*6, margin + tw*12);


Point[][] point = new Point[3][];

Rect qRect = new Rect(margin, margin + tw*2, margin + tw*12, margin + tw*12);
char[][] qwerty = {{'q','w','e','r','t','y','u','i','o','p'},
                   {'a','s','d','f','g','h','j','k','l'},
                   {'z','x','c','v','b','n','m'}};
char[] lettersFull = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
int selectedScrollRectIndex = 0;
Rect[] scrollRects = new Rect[23]; // 23 is number of shifts required to go from abcd to wxyz
int letterScrollWidth = scroll.width() / (scrollRects.length + 2); // +2 instead of -1 to allow double width for 'a' and 'z'
char[] letters = {'a', 'b', 'c', 'd'};
//You can modify anything in here. This is just a basic implementation.

PriorityQueue<Integer> queue = new PriorityQueue<>(10, Collections.reverseOrder());


void setup()
{
  point[0] = new Point[10];
  point[1] = new Point[9];
  point[2] = new Point[7];
  for (int i = 0; i < point.length; i++) {
    for (int j = 0; j < point[i].length; j++) {
      point[i][j] = new Point(margin + 13 + (i*15) + (j*43), margin + tw*6 + (i*60)); 
    }
  }
  
  for (int i = 0; i < 4; i++) {
    rects[i] = new Rect(margin + (tw*3)*i, margin + (tw*2), margin + ((tw*3) * (i+1)), margin + tw*6);
  }
    
  for (int i = 0; i < scrollRects.length; i++) {
    if (i == 0) {
      scrollRects[i] = new Rect(margin, margin + tw*6, margin + letterScrollWidth*2, margin + tw*8);
    } else if (i == scrollRects.length -1) {
      // scroll.width() - (int-->float conversion of letterScrollWidth) = 5, which is where that magic number comes from
      scrollRects[i] = new Rect(margin + letterScrollWidth*(i+1), margin + tw*6, margin + letterScrollWidth*(i+3)+5, margin + tw*8);
    } else {
      scrollRects[i] = new Rect(margin + letterScrollWidth*(i+1), margin + tw*6, margin + letterScrollWidth*(i+2), margin + tw*8);
    }
    
   //scrollRects[i] = new Rect(margin + letterScrollWidth*i, margin + tw*6, margin + letterScrollWidth*(i+1), margin + tw*8);
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

void drawScroll(Rect r, int hex) {
  float xPos = scrollLoc;
  drawRect(r, hex);
  
  // Note: we don't actually need to show this; just for debugging purposes at the moment (although it may be cool to highlight a bar instead of the circle)
  for (int i = 0; i < scrollRects.length; i++) {
    if (i == selectedScrollRectIndex) {
      drawRectNoStroke(scrollRects[i], #FF0000);
    } else {
      drawRectNoStroke(scrollRects[i], 255-10*i);
    }
  }
  // keep ellipse within bounds of box
  //if (scrollLoc > scroll.left + 20 && scrollLoc < scroll.right - 20) xPos = scrollLoc;
  //if (scrollLoc <= scroll.left) xPos = scroll.left + 20;
  //else if (scrollLoc >= scroll.right) xPos = scroll.right - 20;
  //fill(#FF0000);
  //ellipse((float)xPos, (float)r.centerY(), 40, 40);
  //for (int i = 0; i < 7; i++) {
  //  fill(#808080);
  //  if (i == scrollLoc) fill(#FF0000); 
  //  ellipse((float)r.left+(tw*12/7) * i + 40, (float)r.centerY(), 20, 20);
  //}
}

void drawQwerty() {
  textSize(50);
  for (int i = 0; i < qwerty.length; i++) {
    for (int j = 0; j < qwerty[i].length; j++) {
      text("" + qwerty[i][j], point[i][j].x, point[i][j].y); 
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
    drawRect(delete, #FFFFFF, "del");
    drawRect(space, #FFFFFF, "_");

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

void scrollPositionChanged()
{
  for (int i = 0; i < scrollRects.length; i++)
  {
    if (scrollRects[i].contains(mouseX, mouseY))
    {
      for (int j = 0; j < 4; j++) {
        letters[j] = lettersFull[i+j];
      }
      selectedScrollRectIndex = i;
      break;
    }
  }
}

void mousePressed()
{
  if (space.contains(mouseX, mouseY)) {
    currentTyped+=" ";
  }
  if (delete.contains(mouseX, mouseY)) {
    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  }
  
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

void mouseReleased() {  
  int indexI = 0;
  int indexJ = 0;
  if (qRect.contains(mouseX, mouseY)) {
    float distance = Integer.MAX_VALUE;
    for (int i = 0; i < point.length; i++) {
      for (int j = 0; j < point[i].length; j++) {
        if (dist(point[i][j].x, point[i][j].y, mouseX, mouseY) < distance) {
          distance = dist(point[i][j].x, point[i][j].y,mouseX,mouseY);
          indexI = i;
          indexJ = j;
        }
      }
    }
    currentTyped += ""+qwerty[indexI][indexJ];
  }
}


int counter = 0;

void mouseDragged() 
{
  if (input.contains(mouseX, mouseY))
  {
    
    scrollPositionChanged();
    
    //counter++;
    //// indicator that user is moving in a particular direction
    //// pmouseX = previous mouse x
    //if (counter == 7) {
    //  counter = 0;
      
      
      
    //  if (mouseX > pmouseX) //check if click in left button
    //  {
    //    for (int i = 0; i < 4; i++) {
    //      letters[i] = (char((((int)letters[i] + 1 - 97) % 26) + 97));
    //    }
    //  }

    //  if (mouseX < pmouseX) //check if click in right button
    //  {
    //    for (int i = 0; i < 4; i++) {
    //      letters[i] = (char((((int)letters[i] - 1 - 97 + 26) % 26) + 97));
    //    }
    //  }
    //}
  }
  //scrollLoc = (((int)letters[0] - 97) % 26) / 4;
  scrollLoc = mouseX;
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