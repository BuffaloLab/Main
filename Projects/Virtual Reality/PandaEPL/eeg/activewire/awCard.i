%module awCard

%{
#include "awCard.h"
%}

%typemap(python, in) unsigned char * {
$1 = (unsigned char *)PyString_AsString($input);
}

%include exception.i
%exception {
try {
    $function
}
catch(AWCException) {
SWIG_exception(SWIG_RuntimeError, "Uncaught exception from ActiveWire card interface!\nSee line beginning \"ActiveWire error\" above for details.");
}
}

%include "awCard.h"
