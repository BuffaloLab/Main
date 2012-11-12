As they are, the files give you the very first training step, with these initial values for key variables:
* The ITI is set to 150ms.
* The grey square is displayed for a variable time of 150 to 300ms.
* The yellow square / max response time allowed is set to 1500ms.
* The squares have a 6 degree height and width.

Once the animal has mastered these settings, change each variable gradually, waiting with each change for the animal has mastered it, until finally the monkey can successfully do these final settings:
* ITI = 1000ms
* Grey = 500-150ms
* Yellow / Response Time = 500ms
* Square = .3 height and width

The ITI, grey square time, and yellow-square/response-time can be edited at the top of the .TIM file:

    /* Set min and max time for duration of grey square on screen in milliseconds */
    #define mintim 150
    #define maxtim 300
    
    /* Set ITI duration in milliseconds */
    #define ititim 150
    
    /* Set duration of yellow square on screen / time animal has to respond in milliseconds */
    #define maxrsptim 1500

The square size, however, must be edited in the .ITM file by changing the height and width of items #1-3 from 6.0 to whatever size is desired.