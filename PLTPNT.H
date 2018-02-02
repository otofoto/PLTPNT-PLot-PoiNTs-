/*----------------------------------------------------------------------+
|                                                                       |
|   pltpnt.h                                                            |
|                                                                       |
+----------------------------------------------------------------------*/
#ifndef __pltpntH__
#define __pltpntH__

#include    <msdefs.h>

#define	    LINEFEED		0x0a
#define	    CARRIAGERETURN	0x0d

#define     DXYZLC              1
#define     DYXZLC              2
#define     XYZDLC              3
#define     YXZDLC              4
#define     DXYZLS              5
#define     DYXZLS              6
#define     XYZDLS              7
#define     YXZDLS              8
#define     BINAER              9
#define     LIDAR              10

#define     ROW5              1
#define     ROW6              2
#define     ROW67             3
#define     ROW7              4

#define DIALOGID_PlotPoints                 1

#define HOOKDIALOGID_DialogBox              1
#define HOOKITEMID_ToggleButton             2
#define HOOKITEMID_PushButton               3

#define TOGGLEID_Descriptor                 1
#define TOGGLEID_Label                      2
#define TOGGLEID_Elev                       4
#define TOGGLEID_Cell                       8
#define TOGGLEID_Lock                      16

#define OPTIONBUTTONID_Format               1
#define OPTIONBUTTONID_Row                  2

#define PUSHBUTTONID_Select                 1
#define PUSHBUTTONID_Run                    2
#define PUSHBUTTONID_Quit                   3

#define TEXTID_DescrColor                   1
#define TEXTID_DescrWeight                  2
#define TEXTID_DescrLevel                   3
#define TEXTID_DescrXoff                    4
#define TEXTID_DescrYoff                    5
#define TEXTID_LabelColor                   6
#define TEXTID_LabelWeight                  7
#define TEXTID_LabelLevel                   8
#define TEXTID_LabelXoff                    9
#define TEXTID_LabelYoff                   10
#define TEXTID_ElevColor                   11
#define TEXTID_ElevWeight                  12
#define TEXTID_ElevLevel                   13
#define TEXTID_ElevXoff                    14
#define TEXTID_ElevYoff                    15
#define TEXTID_CellColor                   16
#define TEXTID_CellWeight                  17
#define TEXTID_CellLevel                   18
#define TEXTID_CellName                    19
#define TEXTID_AsciiFile                   20
#define TEXTID_AdjustX                     21
#define TEXTID_AdjustY                     22
#define TEXTID_AdjustZ                     23
#define TEXTID_TextHeight1                 24

/*----------------------------------------------------------------------+
                                                                      |
|   Resource Type and ID for UserPrefs                                  |
|									|
+----------------------------------------------------------------------*/
#define RTYPE_Pltp                     'Pltp'
#define RSCID_Pltp                      1

/*----------------------------------------------------------------------+
|									|
|   pltpntParams                                                        |
|									|
+----------------------------------------------------------------------*/
typedef struct pltpnt_params
    {
      int     inputFormat;
      int     descrColor;
      int     descrWeight;
      int     descrLevel;
      int     labelColor;
      int     labelWeight;
      int     labelLevel;
      int     elevColor;
      int     elevWeight;
      int     elevLevel;
      int     cellColor;
      int     cellWeight;
      int     cellLevel;
      int     toggleMask;
      int     labelRow;
      double  elevXoffset;
      double  elevYoffset;
      double  descrXoffset;
      double  descrYoffset;
      double  labelXoffset;
      double  labelYoffset;
      double  adjustX;
      double  adjustY;
      double  adjustZ;
      double  TextHeight;
      char    cellName[16];
      char    asciiFile[255];
      } pltpnt_Params;

#endif    
