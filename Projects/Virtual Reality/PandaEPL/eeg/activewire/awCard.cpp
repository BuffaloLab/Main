#include "awCard.h"

using std::cout;

awCard::awCard(bool debugmode, unsigned char *pinDirections, int mode):debug(debugmode), eventsmode(mode){
  try{
    if (aw_init()){
      throw AWCException("Unable to initialize driver. Exiting.");
    }
    else if (debug){
      cout << "Initialized driver." << endl;
    }

    number_of_boards = 0;

    if (aw_numberOfConnectedBoards(&number_of_boards)){
      throw AWCException("Unable to retrieve number of boards connected. Exiting.");
    }
    if (!number_of_boards){
      throw AWCException("No ActiveWire boards connected. Exiting.");
    }
	
    cout << static_cast<int>(number_of_boards) << " ActiveWire USB board connected." << endl;

    allOff_str = ALLOFF;
    allOn_str = ALLON;

    //set mode to output
    aw_binaryToDecimal(pinDirections, 2, decimal_array);
    if (aw_setDirectionsOfPinSets(0, decimal_array[0], decimal_array[1])){
      throw AWCException("Unable to set the IO pins' directions. Exiting.");
    }
    
    else if (debug){
      cout << "Set IO pins' directions." << endl;
    }

    if (aw_setEventDeliveryMethod(eventsmode, //defaults to AW_EVENT_DELIV_BUFFER
				  NULL, NULL, NULL, 0)){
      throw AWCException("Unable to set event delivery method. Exiting.");
    }

    allOff();
    
    if (eventsmode==AW_EVENT_DELIV_BUFFER){
      clearEvents();
    }

  }
  catch (AWCException &e){
    e.debug_print();
    throw;
  }
}

awCard::~awCard(){
  aw_close();
  cout << "Closed ActiveWire board(s)." << endl;
}

void awCard::write(unsigned char *s){
  try{
    aw_binaryToDecimal(s, 2, decimal_array);
    
    if (aw_writeData(0, decimal_array, 2)){
      throw AWCException("Unable to write data. Exiting.");
    }

  }
  catch (AWCException &e){
    e.debug_print();
    throw; //rethrow so the exception appears in python
  }
}

void awCard::allOn(){
  write(allOn_str);
}

void awCard::allOff(){
  write(allOff_str);
}

bool awCard::anyEvents(){
  if (eventsmode!=AW_EVENT_DELIV_BUFFER){
    throw AWCException("Wrong event delivery mode for anyEvents().");
  }
  AW_EVENT_LIST eventList = aw_getEvents();
  int numEvents = eventList->numberOfEvents;
  if (debug) {
    if (numEvents > 0){
      cout << "numEvents: " << numEvents << endl;
      for (int i=0; i<numEvents; i++){
	aw_decimalToBinary(eventList->events[i]->boardData, 1, binary_read_buffer);
	printf("Last event:\n	Board: %d\n	Type: %d\n	Time: (s: %d, ns: %d)\n	IO Pin 0: %d\n", 
	       eventList->events[i]->boardNumber,
	       eventList->events[i]->eventType,
	       (int)eventList->events[i]->timestamp.tv_sec,
	       (int)eventList->events[i]->timestamp.tv_nsec,
	       binary_read_buffer[0]);
      }
      cout << endl << "*******" << endl;
    }
  }
  aw_clearEvents();
  return (numEvents > 0);
}

bool awCard::anyBitVal(int bit, int val){
  if (eventsmode!=AW_EVENT_DELIV_BUFFER){
    throw AWCException("Wrong event delivery mode for anyEvents().");
  }

  // get the events
  AW_EVENT_LIST eventList = aw_getEvents();
  int numEvents = eventList->numberOfEvents;
  bool answer = false;

  // traverse the event list and look for val on pin # bit
  for (int i=0; i<numEvents; i++){
    aw_decimalToBinary(eventList->events[i]->boardData, 1, binary_read_buffer);
    if (static_cast<int>(binary_read_buffer[bit])==val){
      answer = true;
      break;
    }
  }    

  // clear the events
  aw_clearEvents();
  return answer;
}

bool awCard::anyLowEvents(){
  return anyBitVal(0, 0);
}

bool awCard::anyHighEvents(){
  return anyBitVal(0, 1);
}

void awCard::clearEvents(){
  if (eventsmode!=AW_EVENT_DELIV_BUFFER){
    throw AWCException("Wrong event delivery mode for anyEvents().");
  }
  aw_clearEvents();
}

int main(){
  awCard a(true);  
  while (true){
    if (a.anyLowEvents()){
      cout << "got a low signal." << endl;
    }
  }
}
