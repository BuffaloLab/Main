#ifndef AWCARD_H
#define AWCARD_H

#include <iostream>
#include <string>
#include "aw_lib.h"

#define ALLON (unsigned char *)"1111111111111111"
#define ALLOFF (unsigned char *)"0000000000000000"

using std::cerr;
using std::endl;
using std::string;

class awCard{
  bool debug;
  int eventsmode;
  unsigned char number_of_boards;
  static const int binary_length = 8;
  unsigned char decimal_array[2], binary_array[binary_length];
  unsigned char decimal_read_buffer[2], binary_read_buffer[binary_length];
  unsigned char *allOn_str, *allOff_str;
 public:
  awCard(bool debug=false, unsigned char *pinDirections=ALLON, int mode=AW_EVENT_DELIV_BUFFER);
  ~awCard();
  void write(unsigned char *s);
  void allOn();
  void allOff();
  bool anyEvents();
  bool anyBitVal(int, int);
  bool anyLowEvents();
  bool anyHighEvents();
  void clearEvents();
};

class AWCException{
  string msg;
 public:
 AWCException(string s):msg(s){}
  void debug_print(){ cerr << "ActiveWire error: " << msg << endl; }
};

#endif
