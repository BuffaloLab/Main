/*
Check for input from CORTEX, print to USB
 //0 for nothing yet, 1 for record, 2 for stop record
 */

// the setup routine runs once when you press reset:
int testPort = 7;//leave high if need a high input to test
// need these things to deal with the Matlab serial buffer
const int analogStartPin  = A0;
const int analogStopPin  = A5;
int readVals = 1;
int waitStart = 1;
int waitStop = 0;
int startLine;
int stopLine;
int baseline = 0;
int startNum = 1;
int stopNum = 1;

int startByte = 65;//A
int stopByte = 90;//Z

int inByte   = 0; 

void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  Serial.println(0);
  pinMode(analogStartPin, INPUT);	
  pinMode(analogStopPin, INPUT);
  digitalWrite(testPort, HIGH);
  digitalWrite(13, LOW);
  //analogWrite(analogStartPin, baseline);
  //analogWrite(analogStopPin, baseline);
}

// the loop routine runs over and over again forever:
void loop() {
  //  if (Serial.available()>0) {
  //    inByte = Serial.read();// get incoming byte, start byte is 'A'
  //  }
  //if (inByte==startByte){//start stimulation, need an else here for errors since this should always be the start Byte
  //readVals = 1;
  while ( readVals ){
    //Serial.println(waitStart);
    // read the input on analog pin 0:
    startLine = analogRead(analogStartPin);
    //Serial.println(startLine);
    stopLine = analogRead(analogStopPin);

    //resetLine = analogRead(analogResetPin);
    //  int endRecLine = analogRead(A5);

    // print out the value you read: 
    if ((startLine > 512) && (waitStart >0)){
      Serial.println(1);
      //Serial.println(startNum);
      //digitalWrite(13, HIGH);
      waitStart = 0;
      waitStop = 1;
      startNum = startNum + 1;
    }
    if ((stopLine > 512) && (waitStop>0)){
      Serial.println(2); 
      //Serial.println(stopNum);     
      //digitalWrite(13, LOW);
      waitStart = 1;
      waitStop =0;
      stopNum = stopNum + 1;

    }

    //      if (Serial.available()>0) {
    //        inByte = Serial.read();// get incoming byte, start byte is 'A'
    //      }
    //      if (inByte==stopByte){//start stimulation, need an else here for errors since this should always be the start Byte
    //        readVals = 0;  
    //      }
    // }
  }
}







