ClusterFix TM
=======================

ClusterFix[ation] is an automated algorithm employing kmeans clustering to detect fixations and saccades.

ClusterFixation_Final and ClusterFixation are the same algorithm. However; ClusterFixation_Final 
assumes you have already pre-proccessed your data into a cell array containg [x;y] eye positions 
with each cell being a different condition or trial. Pre-processing entails extracting raw data, 
calibrating such raw data, and filtering the data appropriately to remove noise. We also remove 
x,y data that are more than 50 pixels (~2 dva) outside of the image. ClusterFixation does all the
pre-processing for you except the way ClusterFixation is setup is to mostly deal with 
SCM (scene manipulation) data. Thus ClusterFixation_Final is best for non-SCM data. Details of 
the default pre-processing can be found in getEyeData and the beginging sections of ClusterFixation.

Please feel free to use this algorithm as you see fit. Please do not share the code with others
outside of the Buffalo lab without the explicit permission of Seth Koenig and/or Dr. Elizabeth
Buffalo since this algorithm is being evaluated by Emory for intelectual property rights. This 
collection of code is protected under copyright law. 

I, Seth, don't want to sound pretensious but as far as I know this is the most advanced, accurate, 
and non-arbitrary fixation detection algorithm on the planet and perhaps the universe!!!! 
