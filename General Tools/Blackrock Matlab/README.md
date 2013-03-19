BLACKROCK DATA LOADING INTO MATLAB - FIELDTRIP STYLE.
======================================================
some notes on Blackrock:
Blackrock files are not supported by fieldtrip 
spike data can be read and sorted by offline sorter and loaded into neuroexplorer
it appears theoretically possible to load analog data from the .ns5 files into neuroexplorer
if using the neuroshare .dll. However, I have not had any success with this -perhaps with short files?
It is easy and quick to load the data into Matlab with some help from the NPMK toolbox and other code,
most of which should be included in the main folder, with modified files in the NKBR folder

the following is working well for me so far: 
the .ns5 file and the .nev file must have the same name and be in the same folder
there are some fieldtrip dependencies and other dependencies, not all may be included in this folder
email njkillian@gmail.com if there are problems

1. if you specify cfg.channel = {'sig001a';'AD01';'X';...};
and cfg.trl = fieldtrip style trial matrix in terms of downsampled rate
and cfg.dsfs = downsampled frequency, 1000 by default
then do: data = brload(cfg) 
which is equivalent to 
data = ft_preprocessing(cfg)
note that preproc. filtering is not directly implemented here, but
for each trial, line noise can be removed with rmline(), e.g. data.trial{k} = rmline(data.trial{k},dsfs)

2. the 'mrk' structure used in our trial functions can be obtained with
mrk = getBRmrk(string_to_.nev_file)

3. eye data can be obtained with
[eog pupil] = getBReye(string_to_.nev_file)

4. color change calibration is easily adapted using the mrk and eog variables as obtained above
see EDscale() which returns calibrated eye data based on VPCgetclrchg2_Iterative()

5. todo: a next step would be to throw the code in brload() and subfunctions directly into the fieldtrip read functions
