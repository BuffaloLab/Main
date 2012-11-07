These files only display single-color squares (not complicated pictures) and, as they are, give you the very first training step with these variables at the top of the .TIM file:

    /* Set timdelay to the desired delay between images in milliseconds */
    #define timdelay 150
    
    /* Set nonmatches to max # of nonmatching stimuli */
    #define nonmatches 0
    
    /* Set nonmatchtim to the amount of time the distractors should display for */
    #define nonmatchtim 150

Once the animal has mastered the task with those variables, start increasing _timdelay_ gradually, making sure the animal does each step successfully, until finally arriving at a 500ms delay.

Next, start introducing nonmatching stimuli by changing _nonmatches_ to 1.  Once the monkey can do that, _nonmatchtim_ should be increased until it reaches 500.

Finally, increase _nonmatches_ to 2.