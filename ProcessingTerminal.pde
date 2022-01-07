/* Serial terminal
 Johan terryn
 */
import processing.serial.*;
import java.text.*;
import java.util.*;
import controlP5.*;
// https://www.sojamo.de/libraries/controlP5/reference/index.html
ControlP5 cp5;
ScrollableList list;
int listX = 1250;
int listY = 50;
int listWidth = 200;
int listHeight = 200;
int barHeight = 25;

Boolean toFile = false;
Serial myPort;  // The serial port
String fileName;
PrintWriter output;
DateFormat fnameFormat = new SimpleDateFormat("MMdd_HHmmss");
DateFormat timeFormat = new SimpleDateFormat("hh:mm:ss:SSS");
int cols = 1500;
int rows = 900;
int col = 0;
int row = 10;
PImage rec, start;
String command = "";

void setup() {
  size(1500, 1000);
  cp5 = new ControlP5(this);
  List l = Arrays.asList("9600", "19200", "38400", "57600", "115200", "250000", "500000", "1000000");
  list = cp5.addScrollableList("Baud rate")
    .setPosition(listX, listY)
    .setSize(listWidth, listHeight)
    .setBarHeight(barHeight)
    .setItemHeight(20)
    .addItems(l)
    .setType(ScrollableList.DROPDOWN);
  //CColor c = new CColor();
  //c.setBackground(color(125,0,0));
  //list.getItem(4).put("color", c);
  myPort = new Serial(this, Serial.list()[0], 115200);  //set data speed required -> equal to sender!!!
  rec = loadImage("record-icon.png");
  start = loadImage("start-icon.png");
  textFont(createFont("Go-Medium.ttf", 10));
  textSize(10);
  background(0);
  while (myPort.available() > 0) { //clean up of com port data
    myPort.readChar();
  }
}

void draw() {
  if (toFile) {
    image(rec, 1280, 900);
  } else {
    image(start, 1280, 900);
  }
  push(); //command line area
  fill(255);
  rect(190, 940, 1000, 25, 25);
  fill(0);
  if (command.length() > 0) {
    textSize(16);
    text(command, 200, 957);
  }
  pop(); //command line area
  while (myPort.available() > 0) {
    char inByte = myPort.readChar();
    //print(inByte);  //to console
    if (toFile) {
      output.print(inByte);
    }
    // to screen
    text(inByte, col+=11, row);
    if ((inByte == '\n') || (col > cols)) { // end of line
      col  = 0;
      row += 11;
    }
    if (row > rows) { //end of page
      col = 0;
      row = 10;
      background(0);
    }
  }
}

void keyPressed() {
  if (focused) {
    switch (key) {
    case ESC:
      if (output != null) {
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file
      }
      exit(); // Stops the program
    case BACKSPACE:
      if (command.length() > 0) {
        command = command.substring(0, command.length()-1); //remove last character
      }
      break;
    case ENTER: //send command
      if (command.length() > 0) {
        myPort.write(command);
        println(command);
        command = ""; //empty command
        break;
      }
    default:  //add valid ascii characters to the command
      if (key >= 32 && key <= 127) {
        command += key;
      }
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    int x = mouseX;
    int y = mouseY;
    if ( x > 1280 && x < 1352 && y > 900 && y < 972) { // inside record / stop button
      toFile = !toFile;
      if (toFile)
      {
        Date now = new Date();
        fileName = fnameFormat.format(now);
        output = createWriter(fileName + ".txt"); // save the file in the sketch folder}
      } else {
        output.flush(); // Writes the remaining data to the file
        output.close(); // Finishes the file
      }
    }
  }
}

void controlEvent(ControlEvent theEvent) { //when something in the list is selected
  int baudRates[] = {9600, 19200, 38400, 57600, 115200, 250000, 500000, 1000000};
  myPort.clear(); //delete the port
  myPort.stop(); //stop the port
  if (theEvent.isController() &&list.isMouseOver()) {
    myPort = new Serial(this, Serial.list()[0], baudRates[(int)theEvent.getController().getValue()]); //set Baudrate
    println("Serial index set to: " + baudRates[(int)theEvent.getController().getValue()]);
    push();
    fill(0);
    rect (listX, listY,listWidth,listHeight);
    pop();
  }
}
