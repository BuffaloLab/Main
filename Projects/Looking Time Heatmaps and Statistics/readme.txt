Please run and examine demo.m and example_usage.m for usage examples.
It is very easy to use this code.

Example:
For one set of eye data, xy1 = [x data;y data]
[values maps options] = heat_stats_xy(xy1);values
figure;imagescnan(maps.xb,maps.yb,maps.t1)

For two sets of eye data,
[values maps options] = heat_stats_xy(xy1,xy2);values
figure;
subplot 121;imagescnan(maps.xb,maps.yb,maps.t1)
subplot 122;imagescnan(maps.xb,maps.yb,maps.t2)

values = heat_stats(map1,map2) can be used if you already have the heat maps

The function [values maps options] = heat_stats_xy(xy1,xy2,options) 
computes looking time heat maps from calibrated eye data and will also 
compute 4 useful values for comparing two conditions (i.e. novel vs repeat viewings). 
All values (except KLD, which is unbounded) range from 0 for no difference to 1 for completely different:

1. values.sum_product_norm: 1 minus the sum of the product of the two maps normalized to the maximum value
2. values.local_novelty_preference: the name says it
3. values.diff: 1-Normalized Mutual Information
4. values.kld: Kullback-Leibler Divergence

More detailed description of the above:

I came up with some measures that give similar results in terms of the divergence of novel vs repeat looking patterns.
1. 1 minus (the integral of the product of the novel and repeat heat maps / maximum value of integral of  novel^2)
2. The local novelty preference = amount of time in repeat outside of the novel heat map / amount of time in repeat heat map
3. 1 minus the normalized mutual information
4. Kullback-leibler divergence between novel and repeat looking distributions
-These values are returned in a structure by heat_stats(). 
-Number 3 is my favorite and takes into account more features of the data. However the others are useful to look at as well because they may be easier to intuit.