Using get_ALLdata() to extract eog and epp data from Cortex data file

To extract the eog and epp data from the Cortex data file into matrices, use the Matlab routine "get_ALLdata()", which was adapted from readcort.m by Greg Horwitz (and by Trina to add the epp stuff).  The usage of the function is as follows:

[times,events,eog_arr,epp_arr,header,trialcount] = get_ALLdata(path\file_name);

for example, you would type the following at a Matlab prompt:

[times,events,eog_arr,epp_arr,header,trialcount] = get_ALLdata('c:\matlabln\data\vout.1');

Once this command has been run, the data is now in the times array, the events array, the eog_arr array, the epp array, the header information array, and the trialcount.   (To see what is contained in any of these arrays, you can just type the name of the array at the matlab prompt.)
 
*******************

To plot the eog and epp data, you need to run other Matlab routines from the command line.  The syntax is:  

plot(name_of_array(starting_index:increment:stopping_index], number_of_trial)).

Since the eog  and epp data is stored in the order:  x1, y1, x2, y2, x3, y3,...., the x values should start at index#1, and increment by 2 to get every other index.  Similarly, the y values should start at index#2, and increment by 2 to get every other index.  
     Depending on the length of the trials, instead of using "end", may have to use a number like "500".  Otherwise, all the data is squished together in the plot, and it looks bad!  
     To print just one trial, give the number of the trial that you want to print.   Otherwise, to print all of the trials, use the symbol ":".    If the eog data was generated from a sine wave generator, then the plots should look like a sine wave.

% This command plots the X positions for trial 1
plot(eog_arr([1:2:end],1))

% This command plots the X positions for all trials
plot(eog_arr([1:2:end],:))

% This command plots the Y positions for trial 1
plot(eog_arr([2:2:end],1))

% This command plots the Y positions for all trials
plot(eog_arr([2:2:end],:))

(Similar commands are used to plot the epp data.  The epp array name, epp_arr, is just substituted into the commands above, instead of eog_arr.

******************

 Another fun thing to plot is the X values versus the Y values.  If the data was really a sine wave, then the resulting plot should display the dots in a circle or ellipse.  Here is the command to do that:

% This command plots the X positions against the Y positions
plot(eog_arr([1:2:end],:),eog_arr([2:2:end],:),'m.')

******************

To plot the average of all eog data of the Y traces for all of the trials on one plot:

plot(nanmean(eog_arr([2:2:500],:)'))

This should result in a sine wave as well.

******************
To keep the plot on the screen, and draw something else into the same plot, type:

hold on

Then, issue another plot command.  The new graph should be plotted into the same window.

******************
To get a new window for each plot, type:

figure

Then, issue another plot command.
