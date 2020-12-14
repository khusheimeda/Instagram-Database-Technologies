Use OpenCV to identify satellite images which have >50% greenery. 
Map it into tuples with less than and greater than threshold value. 
Reduce this to a counter of both. 
Use Hadoop to speed up the processing when there are many satellite images.

The input data is in the format <file_name,area_name,percentage_of_green cover>.
The mapper splits these three values and based on the percentage of green cover, outputs (G, 1) for green areas(>50%) and (C,1) otherwise.
The reducer adds up the G and C values separately and outputs the aggregate count of G and aggregate count of C.

 