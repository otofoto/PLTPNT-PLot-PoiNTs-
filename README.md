# PLTPNT-PLot-PoiNTs-
PLTPNT (originally by Bill Steinbock) is an Microstation v8 MDL application which plots points at the location specified in an ASCII file.

PLTPNT is an MDL application which plots points at the location specified in an ASCII .txt or LIDAR .xyz file. Each point may have a cell, elevation, decriptor text, and a text label associated with it. The user activates the application by keying-in MDL L PLTPNT. A dialog box activates where all choices for placing point and associated text are selected. One recent addition is the settings for the number of decimal places for the elevation text. 

The users' data files must be formatted to comply with one of the space or comma delimited formats available. These formats are:
D,X,Y,Z,L \ D = Point Descriptor text
D,Y,X,Z,L \ X = X coordinate value (easting)
X,Y,Z,D,L / Comma Y = Y coordinate value (northing)
Y,X,Z,D,L / Z = Z coordinate value (elevation)
D X Y Z L \ L = Point Label text
D Y X Z L \
X Y Z D L / Space
Y X Z D L /

Note that text strings (D or L) to the right of the X Y and Z data are not required to be defined, but any descriptor text designated as left of the actual coordinates must be defined. For example, if you select the format D,X,Y,Z,L, the point descriptor text is required but the label may be left blank. Similarly, if the format is set to X,Y,Z,D,L the only required data are the X,Y, and Z values.
Sample design, cell library, and data files are include for software testing. The sample data files show the different input formats. 
File Input Format
------- ----------------------
test_1c D,X,Y,Z,L or D,Y,X,Z,L
test_2c D,X,Y,Z,L or D,Y,X,Z,L (L not used)
test_3c X,Y,Z,D,L or Y,X,Z,D,L (L not used)
test_4c X,Y,Z,D,L or Y,X,Z,D,L (D & L not used)
test_1s D X Y Z L or D Y X Z L
test_2s D X Y Z L or D Y X Z L (L not used)
test_3s X Y Z D L or Y X Z D L (L not used)
test_4s X Y Z D L or Y X Z D L (D & L not used)
