/*----------------------------------------------------------------------+
|                                                                       |
|   ppdlg.r
|                                                                       |
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|                                                                       |
|   Include Files                                                       |
|                                                                       |
+----------------------------------------------------------------------*/
#include <rscdefs.h>
#include <cmdclass.h>
#include <dlogbox.h>
#include <dlogids.h>
#include <msdefs.h>

#include "pltpnt.h"
#include "pltpntxt.h"

/*----------------------------------------------------------------------+
|                                                                       |
|   Dialog Box                                                          |
|                                                                       |
+----------------------------------------------------------------------*/
DialogBoxRsc DIALOGID_PlotPoints =
    {
    DIALOGATTR_NORIGHTICONS |
    DIALOGATTR_DEFAULT,
    56*XC+5, 26*YC+9,
    NOHELP,    MHELP,
    HOOKDIALOGID_DialogBox,
    NOPARENTID,
    TXT_DialogTitle,
{
{{ 9*XC+5, 1*YC+8, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelTxtHeight, ""},
{{36*XC, 1*YC+8, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelinRow, ""},
{{46*XC, 1*YC+8, 5*XC, 0}, OptionButton, OPTIONBUTTONID_Row, ON, 0, TXT_LabelRow, ""},

{{15*XC+1, 3*YC, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelColor, ""},
{{22*XC+5, 3*YC, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelWeight, ""},
{{29*XC+4, 3*YC, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelLevel, ""},
{{36*XC+2, 3*YC, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelXoffset, ""},
{{46*XC+1, 3*YC, 8*XC, 0}, Label, 0, ON, 0, TXT_LabelYoffset, ""},

{{3, 9,       55*XC+2, 8*YC+10}, GroupBox, 0, ON, 0, TXT_Text, ""},
{{3, 10*YC+6, 55*XC+2, 2*YC+15}, GroupBox, 0, ON, 0, TXT_Symbol, ""},
{{3, 14*YC+7, 55*XC+2, 4*YC+8}, GroupBox, 0, ON, 0, TXT_File, ""},
{{3, 20*YC+7, 55*XC+2, 2*YC+8}, GroupBox, 0, ON, 0, TXT_LabelAdjust, ""},

{{45*XC, 15*YC+8, 8*XC, 0},    PushButton, PUSHBUTTONID_Select, ON, 0, TXT_pBtn_Select, ""},

{{15*XC+4, 23*YC+10, 8*XC, 0}, PushButton, PUSHBUTTONID_Run, ON, 0, TXT_pBtn_Run, ""},
{{33*XC+5, 23*YC+10, 8*XC, 0}, PushButton, PUSHBUTTONID_Quit, ON, 0, TXT_pBtn_Cancel, ""},

{{ 2*XC+4, 1*YC+9, 7*XC, 0},        Text, TEXTID_TextHeight1, ON, 0, "", ""},
{{15*XC+5, 4*YC+3, 5*XC+2, 1*YC+3}, Text, TEXTID_DescrColor, ON, 0, "", ""},
{{22*XC+3, 4*YC+3, 5*XC+2, 1*YC+3}, Text, TEXTID_DescrWeight, ON, 0, "", ""},
{{29*XC+3, 4*YC+3, 5*XC+2, 1*YC+3}, Text, TEXTID_DescrLevel, ON, 0, "", ""},
{{36*XC+3, 4*YC+3, 8*XC, 0},        Text, TEXTID_DescrXoff, ON, 0, "", ""},
{{46*XC+3, 4*YC+3, 8*XC, 0},        Text, TEXTID_DescrYoff, ON, 0, "", ""},

{{15*XC+5, 5*YC+10, 5*XC+2, 0},  Text, TEXTID_LabelColor, ON, 0, "", ""},
{{22*XC+3, 5*YC+10, 5*XC+2, 0}, Text, TEXTID_LabelWeight, ON, 0, "", ""},
{{29*XC+3, 5*YC+10, 5*XC+2, 0}, Text, TEXTID_LabelLevel, ON, 0, "", ""},
{{36*XC+3, 5*YC+10, 8*XC, 0},   Text, TEXTID_LabelXoff, ON, 0, "", ""},
{{46*XC+3, 5*YC+10, 8*XC, 0},   Text, TEXTID_LabelYoff, ON, 0, "", ""},

{{15*XC+5, 7*YC+5, 5*XC+2, 0}, Text, TEXTID_ElevColor, ON, 0, "", ""},
{{22*XC+3, 7*YC+5, 5*XC+2, 0}, Text, TEXTID_ElevWeight, ON, 0, "", ""},
{{29*XC+3, 7*YC+5, 5*XC+2, 0}, Text, TEXTID_ElevLevel, ON, 0, "", ""},
{{36*XC+3, 7*YC+5, 8*XC, 0},   Text, TEXTID_ElevXoff, ON, 0, "", ""},
{{46*XC+3, 7*YC+5, 8*XC, 0},   Text, TEXTID_ElevYoff, ON, 0, "", ""},

{{15*XC+5, 11*YC+6, 5*XC+2, 0},       Text, TEXTID_CellColor, ON, 0, "", ""},
{{22*XC+3, 11*YC+6, 5*XC+2, 0},       Text, TEXTID_CellWeight, ON, 0, "", ""},
{{29*XC+3, 11*YC+6, 5*XC+2, 0},       Text, TEXTID_CellLevel, ON, 0, "", ""},
{{42*XC+3, 11*YC+6, 12*XC+2, 1*YC+3}, Text, TEXTID_CellName, ON, 0, TXT_CellName, ""},
{{ 5*XC+3, 15*YC+9, 38*XC+1, 1*YC+3}, Text, TEXTID_AsciiFile, ON, 0, TXT_AsciiFile, ""},

{{12*XC+3, 21*YC+5, 12*XC, 0},   Text, TEXTID_AdjustX, ON, 0, "X", ""},
{{27*XC+3, 21*YC+5, 12*XC, 0},   Text, TEXTID_AdjustY, ON, 0, "Y", ""},
{{42*XC+3, 21*YC+5, 12*XC, 0},   Text, TEXTID_AdjustZ, ON, 0, "Z", ""},

{{25*XC+4, 17*YC+7, 10*XC, 0}, OptionButton, OPTIONBUTTONID_Format, ON, 0, TXT_InputFormat, ""},

{{2*XC+1, 4*YC+4, 0, 0},  ToggleButton, TOGGLEID_Descriptor, ON, 0, TXT_toggle_Descriptor, ""},
{{2*XC+1, 5*YC+10, 0, 0}, ToggleButton, TOGGLEID_Label, ON, 0, TXT_toggle_Label, ""},
{{2*XC+1, 7*YC+7, 0, 0},  ToggleButton, TOGGLEID_Elev, ON, 0, TXT_toggle_Elev, ""},
{{2*XC+1,11*YC+3, 0, 0},  ToggleButton, TOGGLEID_Cell, ON, 0, TXT_toggle_Cell, ""},
{{2*XC+1,12*YC+5, 0, 0},  ToggleButton, TOGGLEID_Lock, ON, 0, TXT_toggle_Lock, ""},
}
    };
/* --- toggle buttons must go last to insure that the
        enable function works correctly  ------ */

/*----------------------------------------------------------------------+
|                                                                       |
|   Item Instances                                                      |
|                                                                       |
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|                                                                       |
|   Option Button Item Resource                                         |
|                                                                       |
+----------------------------------------------------------------------*/
DItem_OptionButtonRsc OPTIONBUTTONID_Format =
    {
    NOSYNONYM, NOHELP, LHELPCMD, NOHOOK,
    NOARG, TXT_InputFormat,
    "params.inputFormat",
    {
    {NOTYPE, NOICON, NOCMD, MCMD, DXYZLC, NOMASK, ON, TXT_0_DXYZL},
    {NOTYPE, NOICON, NOCMD, MCMD, DYXZLC, NOMASK, ON, TXT_1_DYXZL},
    {NOTYPE, NOICON, NOCMD, MCMD, XYZDLC, NOMASK, ON, TXT_2_XYZDL},
    {NOTYPE, NOICON, NOCMD, MCMD, YXZDLC, NOMASK, ON, TXT_3_YXZDL},
    {NOTYPE, NOICON, NOCMD, MCMD, DXYZLS, NOMASK, ON, TXT_4_DXYZL},
    {NOTYPE, NOICON, NOCMD, MCMD, DYXZLS, NOMASK, ON, TXT_5_DYXZL},
    {NOTYPE, NOICON, NOCMD, MCMD, XYZDLS, NOMASK, ON, TXT_6_XYZDL},
    {NOTYPE, NOICON, NOCMD, MCMD, YXZDLS, NOMASK, ON, TXT_7_YXZDL},
    {NOTYPE, NOICON, NOCMD, MCMD, BINAER, NOMASK, ON, TXT_8_BINAER},
    {NOTYPE, NOICON, NOCMD, MCMD, LIDAR,  NOMASK, ON, TXT_9_LIDAR}
    }
    };
DItem_OptionButtonRsc OPTIONBUTTONID_Row =
    {
    NOSYNONYM, NOHELP, LHELPCMD, NOHOOK,
    NOARG, TXT_LabelRow,
    "params.labelRow",
    {
    {NOTYPE, NOICON, NOCMD, MCMD, ROW5, NOMASK, ON, TXT_0_ROW},
    {NOTYPE, NOICON, NOCMD, MCMD, ROW6, NOMASK, ON, TXT_1_ROW},
    {NOTYPE, NOICON, NOCMD, MCMD, ROW67, NOMASK, ON, TXT_2_ROW},
    {NOTYPE, NOICON, NOCMD, MCMD, ROW7, NOMASK, ON, TXT_3_ROW}
    }
    };

/*----------------------------------------------------------------------+
|                                                                       |
|   PushButton Item Resource                                            |
|                                                                       |
+----------------------------------------------------------------------*/
DItem_PushButtonRsc PUSHBUTTONID_Select =
    {
    NOT_DEFAULT_BUTTON, NOHELP, LHELPCMD,
    HOOKITEMID_PushButton, PUSHBUTTONID_Select, NOCMD, LCMD, "",
    TXT_pBtn_Select
    };

DItem_PushButtonRsc PUSHBUTTONID_Run =
    {
    NOT_DEFAULT_BUTTON, NOHELP, LHELPCMD,
    HOOKITEMID_PushButton, PUSHBUTTONID_Run, NOCMD, LCMD, "",
    TXT_pBtn_Run
    };

DItem_PushButtonRsc PUSHBUTTONID_Quit =
    {
    NOT_DEFAULT_BUTTON, NOHELP, LHELP,
    HOOKITEMID_PushButton, PUSHBUTTONID_Quit, NOCMD, MCMD, "",
    TXT_pBtn_Cancel
    };

/*----------------------------------------------------------------------+
|                                                                       |
|   Text Item Resource                                                  |
|                                                                       |
+----------------------------------------------------------------------*/
DItem_TextRsc TEXTID_TextHeight1 =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 8, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.TextHeight"
    };


DItem_TextRsc TEXTID_DescrColor =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "255",
    NOMASK, TEXT_NOCONCAT, "",
    "params.descrColor"
    };

DItem_TextRsc TEXTID_DescrWeight =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "31",
    NOMASK, TEXT_NOCONCAT, "",
    "params.descrWeight"
    };

DItem_TextRsc TEXTID_DescrLevel =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "4294967295",
    NOMASK, TEXT_NOCONCAT, "",
    "params.descrLevel"
    };

DItem_TextRsc TEXTID_DescrXoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.descrXoffset"
    };

DItem_TextRsc TEXTID_DescrYoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.descrYoffset"
    };

DItem_TextRsc TEXTID_LabelColor =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "255",
    NOMASK, TEXT_NOCONCAT, "",
    "params.labelColor"
    };

DItem_TextRsc TEXTID_LabelWeight =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "31",
    NOMASK, TEXT_NOCONCAT, "",
    "params.labelWeight"
    };

DItem_TextRsc TEXTID_LabelLevel =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "4294967295",
    NOMASK, TEXT_NOCONCAT, "",
    "params.labelLevel"
    };

DItem_TextRsc TEXTID_LabelXoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.labelXoffset"
    };

DItem_TextRsc TEXTID_LabelYoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.labelYoffset"
    };

DItem_TextRsc TEXTID_ElevColor =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "255",
    NOMASK, TEXT_NOCONCAT, "",
    "params.elevColor"
    };

DItem_TextRsc TEXTID_ElevWeight =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "31",
    NOMASK, TEXT_NOCONCAT, "",
    "params.elevWeight"
    };

DItem_TextRsc TEXTID_ElevLevel =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "1", "63",
    NOMASK, TEXT_NOCONCAT, "",
    "params.elevLevel"
    };

DItem_TextRsc TEXTID_ElevXoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.elevXoffset"
    };

DItem_TextRsc TEXTID_ElevYoff =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.elevYoffset"
    };

DItem_TextRsc TEXTID_AdjustX =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.adjustX"
    };

DItem_TextRsc TEXTID_AdjustY =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.adjustY"
    };

DItem_TextRsc TEXTID_AdjustZ =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%.3f", "%f", "", "",
    NOMASK, TEXT_NOCONCAT, "",
    "params.adjustZ"
    };

DItem_TextRsc TEXTID_CellColor =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "255",
    NOMASK, TEXT_NOCONCAT, "",
    "params.cellColor"
    };

DItem_TextRsc TEXTID_CellWeight =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-1", "31",
    NOMASK, TEXT_NOCONCAT, "",
    "params.cellWeight"
    };

DItem_TextRsc TEXTID_CellLevel =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 20, "%d", "%d", "-2", "4294967295",
    NOMASK, TEXT_NOCONCAT, "",
    "params.cellLevel"
    };

DItem_TextRsc TEXTID_CellName =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 6, "%s", "%s", "", "",
    NOMASK, TEXT_NOCONCAT, TXT_CellName,
    "params.cellName"
    };

DItem_TextRsc TEXTID_AsciiFile =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    NOHOOK, NOARG, 132, "%s", "%s", "",  "",
    NOMASK, TEXT_NOCONCAT, TXT_AsciiFile,
    "params.asciiFile"
    };

/*----------------------------------------------------------------------+
|                                                                       |
|   Toggle Button Item Resource                                         |
|                                                                       |
+----------------------------------------------------------------------*/
DItem_ToggleButtonRsc TOGGLEID_Descriptor =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    HOOKITEMID_ToggleButton, NOARG, TOGGLEID_Descriptor, NOINVERT, TXT_toggle_Descriptor,
    "params.toggleMask"
    };

DItem_ToggleButtonRsc TOGGLEID_Label =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    HOOKITEMID_ToggleButton, NOARG, TOGGLEID_Label, NOINVERT, TXT_toggle_Label,
    "params.toggleMask"
    };

DItem_ToggleButtonRsc TOGGLEID_Elev =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    HOOKITEMID_ToggleButton, NOARG, TOGGLEID_Elev, NOINVERT, TXT_toggle_Elev,
    "params.toggleMask"
    };

DItem_ToggleButtonRsc TOGGLEID_Cell =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    HOOKITEMID_ToggleButton, NOARG, TOGGLEID_Cell, NOINVERT, TXT_toggle_Cell,
    "params.toggleMask"
    };
DItem_ToggleButtonRsc TOGGLEID_Lock =
    {
    NOCMD, LCMD, NOSYNONYM, NOHELP, LHELPCMD,
    HOOKITEMID_ToggleButton, NOARG, TOGGLEID_Lock, NOINVERT, TXT_toggle_Lock,
    "params.toggleMask"
    };
