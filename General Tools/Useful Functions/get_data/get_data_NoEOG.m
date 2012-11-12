function [time_arr,event_arr,eog_arr,epp_arr, header,trialcount]  = get_data_NoEOG(name)

% function to read the cortex datafile 
% and put the timecodes, eventcodes, trialheaders
% in an array of arrays, and the nr of trials in a scalar.
% - - -
% USAGE: [times,events,eog_arr,epp_arr, header,trialcount] = get_data(path\file_name)
% - - - 
% adapted from readcort.m
%
% GDLH modified this 5/16/00 -- no need to preallocate the sizes of the arrays
% Matlab 5.2 will automatically pad with zeros when necessary.  How convenient!
% (But preallocating does seem to speed things up a bit.)
%
% GDLH modified this 4/2/01 -- Now returning the eog_arr as well.
%
% GDLH modified this 4/28/01 -- if we hit an error in the datafile, just
% return what we can.

MAXNUMTRIALS = 1000;
trialcount = 0;
fid = fopen(name, 'rb');
if (fid == -1)
   error(['Cannot open file: ',name]);
end
time_arr  = [];	% array of time_code arrays
event_arr = zeros(1, MAXNUMTRIALS);	% array of event_code arrays
eog_arr = [];	% array of eog_code arrays
eog_lengths = [];
epp_arr = [];	% array of epp_code arrays
epp_lengths = [];
header    = zeros(13, MAXNUMTRIALS);	% array of trial headers
hd=zeros(1,13);					% a single header (read every trial)
while (~feof (fid))
   length = fread(fid, 1, 'ushort');
   if (isempty(length)~=1)
      hd(1,1:8)= (fread(fid, 8, 'ushort'))'; 
      hd(1,9:10) = (fread(fid, 2, 'uchar'))'; 
      hd(1,11:13)= (fread(fid, 3, 'ushort'))';
      hd(1,5)=hd(1,5)/4;	% reduce the size of the time_code array 
      hd(1,6)=hd(1,6)/2;	% idem for event_code array
      hd(1,7)=hd(1,7)/2;  	% and eogs
      hd(1,8)=hd(1,8)/2;	% and epp (not used)
      % read the time codes, event_codes, eogs and epps (if any) for this trial
      try
        (fread (fid,(hd(1,5)) , 'ulong'));   
         event_arr(1:(hd(1,6)),trialcount+1) = (fread (fid,(hd(1,6)), 'ushort'));
         
         % epp array is stored in the data file before the eog array
         fread (fid,(hd(1,8)), 'short');
            
            
                      
                    

         
         (fread (fid,(hd(1,7)), 'short'));
                  
         % put this trial's header in the header_array
         header(1:13,trialcount+1)=hd(1,1:13)';
         trialcount = trialcount+1;
      catch
         break;
      end;
   end; 
end;

fclose(fid);
event_arr(:,[trialcount+1:end]) = []; 
header(:,[trialcount+1:end]) = []; 
