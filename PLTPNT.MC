/*-------------------------------------------------------------------------+
|                                                                          |
|   pltpnt.mc  -- PLTPNT is an MDL application which plots points          |
|                 at the location specified in an ASCII file.              |
|                 Each point may have a cell, elevation, decriptor         |
|                 text, and a text label associated with it.               |
|                                                                          |
|              -------------------------------------------------           |
|                                                                          |
|                This is FREE software.  It may be used, copied,           |
|                and distributed as long as there is no charge for         |
|                the software.  This software was written by Bill          |
|                Steinbock, 6704 Hillside Drive, Pewee Valley KY           |
|                40056.                                                    |
|                geändert GRJ 16.10.96                                     |
|                geändert von COMPUSOL DES P.I. MITTERER-ZUBLASING DIETMAR |
|                             am 10.10.1997                                |
|                23.04.2005 an V8 angepasst + textJust                     |
|                30.11.2008 an V8 angepasst LevelID <- LevelCode           |
|                25.01.2011 Fehler bei Höhenbeschriftung korrigiert RJ     |
|                11.09.2013 Spaltenauswahl für .GPS Format eingefügt       |
|                           Ein-Aus mit Label Ein/Aus wäre noch zu         |
|							programmieren                                  |
|				 02.02.2018 updated for v8i [Oto]                          |
+-------------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|                                                                       |
|   Include Files                                                       |
|                                                                       |
+----------------------------------------------------------------------*/


#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>
#include    <mselems.h>
#include    <msdefs.h>
#include    <global.h>
#include    <scanner.h>
#include    <msinputq.h>
#include    <userfnc.h>
#include    <mdl.h>
#include    <cexpr.h>
#include    <rscdefs.h>
#include    <dlogitem.h>
#include    <dlogbox.h>
#include    <tcb.h>
#include    <cmdlist.h>
#include    <refernce.h>
#include    <mdlerrs.h>
#include    <math.h>

#include    <dlogman.fdf>
#include    <msrsrc.fdf>
#include    <mssystem.fdf>
#include    <msfile.fdf>
#include    <mselemen.fdf>
#include    <msstate.fdf>
#include    <mscexpr.fdf>
#include    <mscurrtr.fdf>
#include    <mselmdsc.fdf>
#include    <msscell.fdf>
#include    <mscell.fdf>
#include    <msoutput.fdf>
#include    <mstmatrx.fdf>
#include    <msparse.fdf>
#include    <msrmatrx.fdf>
#include    <msmisc.fdf>
#include    <mdllib.fdf>
#include    <mscnv.fdf>

#include    <leveltable.fdf>

#include    "pltpnt.h"
#include    ".\english\pltpntxt.h"

#pragma     Version     1:2:0
#define     MYPREFS     111L


#ifdef unix
   char sepchar = '/';
#else
   char sepchar = 92;
#endif

/*----------------------------------------------------------------------+
|									|
|   Local function declarations 					|
|									|
+----------------------------------------------------------------------*/

Public  pltpnt_Params       params;
Private MSElementDescr      *cellDescrP=NULL;


int flese(double *z,FILE *f);


/*----------------------------------------------------------------------+
|									|
| name          pltpnt_setCellSymbology                                 |
|									|
+----------------------------------------------------------------------*/
Private int     pltpnt_setCellSymbology
(
MSElement       *elP
)
    {
    unsigned int color;
    unsigned int weight;
    int style=0;

    color = params.cellColor;
    weight = params.cellWeight;

    mdlElement_setSymbology (elP, &color, &weight, &style);
    return (SUCCESS);
    }

/*----------------------------------------------------------------------+
|									|
|               pltpnt_placeSymbol                                      |
|                                                                       |
+----------------------------------------------------------------------*/
Private int     pltpnt_placeSymbol
(
Dpoint3d    *pntP
)
    {
    ULong           status, pos;
    Dpoint3d        cellScale, origin;
    RotMatrix       rMatrix;
    Transform       tMatrix;
    MSElementUnion  element;
    MSElementDescr  *cellDP;

    /* --- calculate rotation matrix --- */
    mdlRMatrix_fromView (&rMatrix, tcb->lstvw, FALSE);
    mdlRMatrix_invert (&rMatrix, &rMatrix);
    mdlRMatrix_rotate (&rMatrix, &rMatrix, 0.0, 0.0,
                       tcb->actangle*fc_piover180);

    /* --- get active scale --- */
    mdlParams_getActive (&cellScale,  ACTIVEPARAM_SCALE);

    /* --- copy terminator cell for placement --- */
    if (cellDescrP)
        {
        mdlElmdscr_duplicate (&cellDP, cellDescrP);

        /* --- rotate cell --- */
        mdlTMatrix_getIdentity (&tMatrix);
        mdlTMatrix_rotateByRMatrix (&tMatrix, &tMatrix, &rMatrix);
        mdlElmdscr_transform (cellDP, &tMatrix);

        /* --- scale cell --- */
        mdlTMatrix_getIdentity (&tMatrix);
        mdlTMatrix_scale (&tMatrix, &tMatrix, cellScale.x,
                          cellScale.y, cellScale.z);
        mdlElmdscr_transform (cellDP, &tMatrix);

        /* --- convert cell origin from MU's to UOR's and correct by GO --- */
        mdlCurrTrans_begin ();
        mdlCurrTrans_masterUnitsIdentity (TRUE);
        mdlCurrTrans_transformPointArray (&origin, pntP, 1);
        mdlCurrTrans_end ();

        /* --- adjust to correct position --- */
        mdlTMatrix_getIdentity (&tMatrix);
        mdlTMatrix_translate (&tMatrix, &tMatrix, origin.x, origin.y, origin.z);
        mdlElmdscr_transform (cellDP, &tMatrix);

        /* --- set level to specified level --- */
        mdlCell_fixLevels (cellDP, TRUE, params.cellLevel, NULL);

        /* --- set color weight and style to current --- */
        mdlElmdscr_operation (cellDP, pltpnt_setCellSymbology, NULL,
                              ELMD_ALL_ONCE);

        /* --- force update to cell level bit map --- */
        cellDescrP->h.isValid = FALSE;
        mdlElmdscr_validate (cellDP, MASTERFILE);
        status = mdlElmdscr_add (cellDP);

        if (status == 0L)
            {
            mdlOutput_printf (MSG_ERROR, TXT_CellNotPlaced,
                              params.cellName, status);
            mdlElmdscr_freeAll (&cellDP);
            return (ERROR);
            }

        mdlElmdscr_display (cellDP, MASTERFILE, NORMALDRAW);
        mdlElmdscr_freeAll (&cellDP);

        return (SUCCESS);
        }
    }

/*----------------------------------------------------------------------+
|									|
|               pltpnt_placePoint                                       |
|                                                                       |
+----------------------------------------------------------------------*/
Private int     pltpnt_placePoint
(
Dpoint3d    *pntP,
unsigned long         color,
unsigned long         weight,
int         level,
int         lock
)
    {
    int             status;
    int             style=0;
/*    int             lock=-1;   */
    unsigned long            levelid;
    long            levxx;
    long            statxx;
    MSElementUnion  element;
    Dpoint3d        pointArray[2];
    

    /* --- create a line of length 0 --- */

    pointArray[0] = *pntP;
    pointArray[1] = *pntP;
    
/*    xv = pointArray[0].x;
    mdlOutput_printf (MSG_ERROR,"X Wert %f",xv); */

    mdlCurrTrans_begin ();
    mdlCurrTrans_masterUnitsIdentity (TRUE);
    
    status = mdlLine_create (&element, NULL, pointArray);

    mdlCurrTrans_end ();

    if (status)
        return (ERROR);
 
    mdlLevel_getIdFromCode (&levelid,NULL,level);
        
    /* --- set style, weight, and color --- */
    mdlElement_setSymbology  (&element, &color, &weight, &style);
    mdlElement_setProperties (&element, &levelid, NULL, NULL, &lock,
                              NULL, NULL, NULL, NULL);

    mdlElement_add (&element);
    mdlElement_display (&element, NORMALDRAW);
/*    statxx = mdlLevel_getIdFromCode (&levxx,NULL,level);
    printf ("LEVEL %ld, %ld, %ld -\n\r",levxx,level,statxx);  */

/*    mdlElement_getProperties (&levxx, NULL, NULL, NULL,
                              NULL, NULL, NULL, NULL, &element);
    printf ("LEVEL %ld, %ld -\n\r",levxx,level);    */
   
    return SUCCESS;
    }


/*----------------------------------------------------------------------+
|									|
|               pltpnt_placeText                                        |
|                                                                       |
+----------------------------------------------------------------------*/
Private int     pltpnt_placeText
(
Dpoint3d    *pntP,
char        *txtString,
int         justification,
unsigned long color,
unsigned long weight,
unsigned long level
)
    {
    TextParam       txtParam;
    TextSizeParam   txtSize;
    MSElementUnion  element;
    RotMatrix       rMatrix;
    int             status;
    int             style=0;
    int             lock=0;
    unsigned long            levelid;
    Dpoint3d        pointArray[2];

    /* --- skip null and blank text strings --- */
    if (txtString == NULL)
        return (0);
    if (txtString[0] == 0)
        return (0);

    /* --- calculate rotation matrix --- */
    mdlRMatrix_fromView (&rMatrix, tcb->lstvw, FALSE);
    mdlRMatrix_invert (&rMatrix, &rMatrix);
    mdlRMatrix_rotate (&rMatrix, &rMatrix, 0.0, 0.0,
                       tcb->actangle*fc_piover180);

    txtParam.font            = 1;
    txtParam.just            = justification;
    txtParam.style           = -1;
    txtParam.viewIndependent = FALSE;

    txtSize.mode        = TXT_BY_TILE_SIZE;
    txtSize.size.height = params.TextHeight;
    txtSize.size.width  = params.TextHeight;

    mdlCurrTrans_begin ();
    mdlCurrTrans_masterUnitsIdentity (TRUE);

    status = mdlText_create (&element, NULL, txtString, pntP, &txtSize,
                             &rMatrix, &txtParam, NULL);
    mdlCurrTrans_end ();

    if (status)
        return (ERROR);

    mdlLevel_getIdFromCode (&levelid,NULL,level);
    
    /* --- set style, weight, and color --- */
    style = 0;
    mdlElement_setSymbology  (&element, &color, &weight, &style);
    mdlElement_setProperties (&element, &levelid, NULL, NULL, &lock,
                              &lock, NULL, NULL, NULL);
                              
  //  element.hdr.dhdr.props.b.s = 1;      /*  NOSNAPPABLE   */

    mdlElement_add (&element);
    mdlElement_display (&element, NORMALDRAW);
    return SUCCESS;
    }

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_textJust                                         |
|                                                                       |
+----------------------------------------------------------------------*/
Private int  pltpnt_textJust
(
double  Xoffset,
double  Yoffset
)
    {
    int  txtJust;

    if (Xoffset == 0) 
      txtJust = 6;
     else
      {
      if (Xoffset > 0)
        txtJust = 0;
       else
        txtJust = 12;
       } 
    if (Yoffset == 0) 
      txtJust = txtJust + 1;
     else
      {
      if (Yoffset > 0)
        txtJust = txtJust + 2;
       else
        txtJust = txtJust + 0;
       }
// test printf("\n1 TXTJUST: %d %lf %lf ",txtJust,Xoffset,Yoffset);  
    return txtJust;
    }
    

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_createGraphics                                   |
|                                                                       |
+----------------------------------------------------------------------*/
Private void    pltpnt_createGraphics
(
double  north,
double  east,
double  elev,
char    *descriptor,
char    *label
)
    {
    int         loc, i, decimalPlaces, len, textJust, txtJust, vLevel,vColor, lock;
    Dpoint3d    point;
    char        elevText[20], format[80];

    mdlParams_getActive (&textJust, ACTIVEPARAM_TEXTJUST);

    /* --- generate point descriptor text if toggle set --- */
    if (params.toggleMask & TOGGLEID_Descriptor)
        {
        point.x = east  + params.descrXoffset;
        point.y = north + params.descrYoffset;
        point.z = elev;
        txtJust = pltpnt_textJust (params.descrXoffset,params.descrYoffset);
        pltpnt_placeText (&point, descriptor, txtJust,
                          params.descrColor, params.descrWeight,
                          params.descrLevel);
        }

    /* --- generate point label text if toggle set --- */
    if (params.toggleMask & TOGGLEID_Label)
        {
        point.x = east  + params.labelXoffset;
        point.y = north + params.labelYoffset;
        point.z = elev;
        pltpnt_placeText (&point, label, textJust,
                          params.labelColor, params.labelWeight,
                          params.labelLevel);
        }

    /* --- generate point elevation text if toggle set --- */
    if (params.toggleMask & TOGGLEID_Elev)
        {
        if (params.elevXoffset == 0 && params.elevYoffset == 0)
            {
            point.x = east;
            point.y = north;
            point.z = elev;
    
            switch (tcb->ad1.format.adres2)
                {
                case 0:
                    decimalPlaces = 4;
                case 3:
                    decimalPlaces = 2;
                case 4:
                    decimalPlaces = 3;
                default:
                    decimalPlaces = 1;
                }
    
            /* --- create elevation text --- */
            sprintf (format, "%c-.0%dlf", '%', decimalPlaces);
    
            sprintf (elevText, format, point.z);
            len = strlen (elevText);
    
            /* --- find location of decimal --- */
            loc = strchr (elevText, '.') - elevText;
    
            /* --- pad with spaces to center justify --- */
            for (i=(loc*2+1)-len; i>0; i--)
                strcat (elevText, " ");
    
            pltpnt_placeText (&point, elevText, TXTJUST_CB,
                              params.elevColor, params.elevWeight,
                              params.elevLevel);
            }
        else 
            if (elev != 0.0)
            {
            sprintf (format, "%c-.0%dlf", '%', 3);
            sprintf (elevText, format, elev); 
            
            point.x = east  + params.elevXoffset;
            point.y = north + params.elevYoffset;
            point.z = elev;
            txtJust = pltpnt_textJust (params.elevXoffset,params.elevYoffset);
            
            pltpnt_placeText (&point, elevText, txtJust,
                              params.elevColor, params.elevWeight,
                              params.elevLevel);
            }
        }

    /* --- generate cell at point if toggle set --- */
    if (params.toggleMask & TOGGLEID_Cell) 
        {
        point.x = east;
        point.y = north;
        point.z = elev;
        vLevel  = params.cellLevel;
        vColor  = params.cellColor;
        if (params.inputFormat == LIDAR)
          vColor = atoi(label);
          if (vColor > 254) vColor = 254;
        /*   vLevel = atoi(label);
           if (vLevel == 0)
             vLevel = params.cellLevel; 
          else
           vLevel = params.cellLevel; */

        if (cellDescrP != NULL)
           pltpnt_placeSymbol (&point);
        else {
           if (params.toggleMask & TOGGLEID_Lock) lock = -1; else lock = NULL; 
            // TEST printf("\n1 Lock %d %d %d ",params.toggleMask,TOGGLEID_Lock,lock);  
           pltpnt_placePoint (&point, vColor, params.cellWeight,
                              vLevel,lock);
             }
        }
    }

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_assignValues                                     |
|                                                                       |
+----------------------------------------------------------------------*/
Private int     pltpnt_assignValues
(
char    *str1,
char    *str2,
char    *str3,
char    *str4,
char    *str5,
double  *east,
double  *north,
double  *elev,
char    *descriptor,
char    *label
)
    {
    if (sscanf (str1, "%lf", east) != 1)
        return (ERROR);
    if (sscanf (str2, "%lf", north) != 1)
        return (ERROR);
    if (sscanf (str3, "%lf", elev) != 1)
        return (ERROR);

    if (str4 != NULL)
        strcpy (descriptor, str4);
    else
        descriptor[0] = 0;

    if (str5 != NULL)
        strcpy (label, str5);
    else
        label[0] = 0;
    return (SUCCESS);
    }

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_plotPoints                                       |
|                                                                       |
+----------------------------------------------------------------------*/

Private void    pltpnt_plotPoints
(
void
)
    {
    char            *stringP, *cP, *token, buffer[132], parseString[2];
    int             numRead = 0, bufSize=132, status=SUCCESS, count=0,i,ret;
    long int	    ret1,ival1,ival2;
    long int        pclass,part;
    long int        height,v,e,m;
    double          hoehe,yval,xval;
    char            pnt_name[9];
    int             share=2;  /* use current setting */
    char            str1[132], str2[132], str3[132], str4[132], str5[132]; 
    char            descriptor[80], label[80], message[132],  strtmp[132];
MSWChar cell[18];
    Dpoint3d        scale, origin;
    double          north, east, elev;
    ULong           filePos=0L;
    MSElementUnion  cellInstance;
    FILE            *fp=NULL;
    RotMatrix       rotate;
  

    /* --- read cell for cell library --- */
    if (params.toggleMask & TOGGLEID_Cell)
        {
//compile error!
//        strcpy(cell, params.cellName);
//        strupr(cell);

        scale.x  = scale.y  =  scale.z = 1.0;
        origin.x = origin.y = origin.z = 0.0;

        if (cell[0]) 
            {
            share = tcb->ext_locks.sharedCells;
            
            status = mdlCell_getElmDscr (&cellDescrP, NULL, 
                     &origin, &scale, TRUE, NULL, NULL, tcb->cugraf, share, TRUE, cell, NULL);
    
            if (status == ERROR)
                {
                sprintf (message, TXT_CellNotFound, params.cellName);
                if (mdlDialog_openAlert (message) == ACTIONBUTTON_CANCEL)
                    return;
                else
                    cellDescrP = NULL;
                }
    
            if (cellDescrP)
                {
                /* --- if shared cell definition turn into cell instance --- */
                if (cellDescrP->el.ehdr.type == SHAREDCELL_DEF_ELM)
                    {
                    mdlRMatrix_getIdentity(&rotate);
                    mdlSharedCell_fromCellHeader (&cellInstance, &(cellDescrP->el),
                    &rotate,
                    TRUE, params.cellLevel,NULL);
    
                    /* --- create a cell instance descriptor --- */
                    mdlElmdscr_freeAll (&cellDescrP);
                    mdlElmdscr_new (&cellDescrP, NULL, &cellInstance);
                    }
                }
            }
        }
    


    if (params.inputFormat==BINAER)
    {
        fp=fopen(params.asciiFile, "rb");
	
        for (i=0;i<10;i++)                 //Filepointer 40 Byte weitersetzen 
            ret=fread (&ret1,4,1,fp);
    }
    else
	fp=fopen(params.asciiFile, "r");
    if (fp==NULL)
    {
	sprintf (buffer, TXT_FileNotOpened, params.asciiFile);
        mdlDialog_openAlert (buffer);
	return;
    }

    if (params.inputFormat >= DXYZLS)
        strcpy (parseString, " ");
    else
        strcpy (parseString, ",");

    while (TRUE)
        {
	if (params.inputFormat==BINAER)
        {
         for (i=0;i<=7;i++)
          ret=fread (&pnt_name[i],1,1,fp);
         pnt_name[8]='\0';
         ret=fread (&xval,8,1,fp);
         ret=fread (&yval,8,1,fp);
         ret=fread (&height,4,1,fp);
         ret=fread (&part,2,1,fp);
         ret=fread (&pclass,2,1,fp);
         ret=fread (&ival1,4,1,fp);
         ret=fread (&ival2,4,1,fp);
         part=part & 0x0000FFFF;
         pclass=pclass & 0x0000FFFF;
         v=(height & 0x80000000)>>31;
         e=(height & 0x7f800000)>>23;
         m=height & 0x007fffff;
         if (height==0)
            hoehe=0;
         else
         {
          hoehe=(1+(m/pow(2,23)))*pow(2,e-127);
          if (v==1)
              hoehe=hoehe*(-1);
         }
        }        
	else
         stringP = fgets (buffer, bufSize, fp);

        if ((stringP == NULL && params.inputFormat != BINAER) || (ret<=0 && params.inputFormat == BINAER))
        {
            mdlOutput_printf (MSG_MESSAGE, TXT_LinesProcessed, count);
            if (cellDescrP)
                mdlElmdscr_freeAll (&cellDescrP);
            fclose (fp);
            return;
         }

        count++;
        /* --- print processing message every 10 lines --- */
        if (!(count%10))
            mdlOutput_printf (MSG_MESSAGE, TXT_Processing, count);

       if (params.inputFormat != BINAER)
       {        
		/* --- remove LF, CR, and comments (;) --- */
        	if ( (cP = strchr (buffer, LINEFEED)) != NULL)
             *cP = '\0';
        	if ( (cP = strchr (buffer, CARRIAGERETURN)) != NULL)
             *cP = '\0';
        	if ( (cP = strchr (buffer, ';')) != NULL)
             *cP = '\0';

        	if (strchr (buffer, '$') != NULL)
            	continue;
		/* --- break into tokens --- */
        	token = strtok (buffer, parseString);
        	if (token == NULL)
            	continue;
        	strcpy (str1, token);

        	token = strtok (NULL, parseString);
        	if (token == NULL)
            	continue;
        	strcpy (str2, token);

        	token = strtok (NULL, parseString);
        	if (token == NULL)
            	continue;
        	strcpy (str3, token);

        	token = strtok (NULL, parseString);
        	if (token == NULL)
            	{
             	  if (params.inputFormat < XYZDLC)
                  continue;
             	  else
             	  {
                	str4[0] = 0;
                	str5[0] = 0;
             	  }
            	}
        	else
                {
             		strcpy (str4, token);

             		token = strtok (NULL, parseString);
               		str5[0]=0;
             		if (token != NULL)
             		    switch (params.labelRow) 
				 {
				 case 1:				/*  5  */
                		     strcpy (str5, token);
                                     break;
				 case 2:				/*  6  */
 	              		     token = strtok (NULL, parseString);
                		     strcpy (str5, token);
       		                     if(strcmp(str5, "-") == 0) str5[0]=0;
                                     break;
				 case 3:				/*  6-7  */
 	              		     token = strtok (NULL, parseString);   /* 6 */
 	              		     if (token != NULL)
 	              		     {
        		                 strcpy (str5, token);
        		                 if(strcmp(str5, "-") == 0) str5[0]=0;
				     }
	              		     token = strtok (NULL, parseString);   /* 7 */
 	              		     if (token != NULL)
 	              		     {
        		                 strcpy (strtmp, token);
                                         if (strlen(str5) != 0) { strcat(str5,"_"); }
                                         strcat(str5,strtmp);
                                     }
                                     break;
				 case 4:				/*  7  */
 	              		     token = strtok (NULL, parseString);
 	              		     token = strtok (NULL, parseString);
         		             if (token != NULL) strcpy (str5, token);
                                     break;
				 }   
               }
       }

 
        switch (params.inputFormat)
            {
            case DXYZLC:
            case DXYZLS:
                status = pltpnt_assignValues (str2, str3, str4, str1, str5,
                                     &east, &north, &elev, descriptor, label);
                break;

            case DYXZLC:
            case DYXZLS:
                status = pltpnt_assignValues (str3, str2, str4, str1, str5,
                                     &east, &north, &elev, descriptor, label);
                break;

            case XYZDLC:
            case XYZDLS:
                status = pltpnt_assignValues (str1, str2, str3, str4, str5,
                                     &east, &north, &elev, descriptor, label);
                break;

            case YXZDLS:
            case YXZDLC:
                status = pltpnt_assignValues (str2, str1, str3, str4, str5,
                                     &east, &north, &elev, descriptor, label);
                break;
           case LIDAR:
                status = pltpnt_assignValues (str1, str2, str3, str5, str4,
                                     &east, &north, &elev, descriptor, label);
                break;
            case BINAER:
                  east=xval; north=yval; elev=hoehe;
		 	strcpy(descriptor,pnt_name);
                  sprintf(label,"%li",part);
		 break;		
            }
	
        if (status == ERROR)
         continue;
        else
          {
            north = north + params.adjustY;
            east  = east  + params.adjustX;
            if (elev != 0.0) elev  = elev  + params.adjustZ;
            pltpnt_createGraphics (north, east, elev, descriptor, label);
          }
        }
    }



/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_setadjust                                        |
| 		Adjustment berechnen und vorschlagen                    |
+----------------------------------------------------------------------*/
Private int    pltpnt_setadjust
(
void
)
    {
    char            *stringP, *cP, *token, buffer[132], parseString[2];
    int             numRead = 0, bufSize=132, status=SUCCESS, count=0,i,ret;
    long int	  ret1,ival1,ival2;
    long int        pclas,part;
    long int        height,v,e,m;
    double          hoehe;
    double          yval,xval;
    char            pnt_name[9];
    int             share=2;  /* use current setting */
    char            str1[132], str2[132], str3[132], str4[132], str5[132];
    char            descriptor[80], label[80], message[132], cell[18];
    Dpoint3d        scale, origin;
    double          north, east, elev;
    ULong           filePos=0L;
    FILE            *fp=NULL;
    BoolInt         erst=TRUE;
    double          xmax,xmin,ymax,ymin,zmax,zmin;
    double          xv,yv,zv,UORs,max;
    double	    maxunits=4294967296.0;


   
    
    if (params.inputFormat==BINAER)
    {
        fp=fopen(params.asciiFile, "rb");
        for (i=0;i<10;i++)		      //Filepointer 40 Byte weitersetzen 
       	 ret=fread (&ret1,4,1,fp);


    }
    else
	fp=fopen(params.asciiFile, "r");
    if (fp==NULL)
    {
	sprintf (buffer, TXT_FileNotOpened, params.asciiFile);
        mdlDialog_openAlert (buffer);
	return ERROR;
    }

    if (params.inputFormat >= DXYZLS)
        strcpy (parseString, " ");
    else
        strcpy (parseString, ",");

    while (TRUE)
        {
	if (params.inputFormat==BINAER)
        {
         height=0;
         for (i=0;i<=7;i++)
          ret=fread (&pnt_name[i],1,1,fp);
         pnt_name[8]='\0';
         ret=fread (&xval,8,1,fp);
         ret=fread (&yval,8,1,fp);
         ret=fread (&height,4,1,fp);
         ret=fread (&part,2,1,fp);
         ret=fread (&pclas,2,1,fp);
         ret=fread (&ival1,4,1,fp);
         ret=fread (&ival2,4,1,fp);
         v=(height & 0x80000000)>>31;
         e=(height & 0x7f800000)>>23;
         m=height & 0x007fffff;
         part=part & 0x0000FFFF;
         pclas=pclas & 0x0000FFFF;

		if (height==0)
		 hoehe=0;
		else
		{
	 	 hoehe=(1+(m/pow(2,23)))*pow(2,e-127);
             if (v==1)
              hoehe=hoehe*(-1);
 		}
       }        
       else
           stringP = fgets (buffer, bufSize, fp);

        if ((stringP == NULL && params.inputFormat != BINAER) || (ret<=0 && params.inputFormat == BINAER))
        {
            mdlOutput_printf (MSG_MESSAGE, TXT_LinesProcessed, count);
            if (cellDescrP)
                mdlElmdscr_freeAll (&cellDescrP);
            fclose (fp);
            xv=-xmin;
            yv=-ymin;
	  	zv=-zmin;
            mdlCnv_masterToUOR(&UORs,1,MASTERFILE);
	      max=maxunits/UORs-1;
           
          if( ((xmax+xv)>=max)||((ymax+yv)>=max)||((zmax+zv)>=max))
	    {
		params.asciiFile[0] = '\0';
		mdlDialog_openAlert(TXT_bereich);
		return ERROR;
	    }
	    params.adjustX=xv;
	    params.adjustY=yv;
	    params.adjustZ=zv;
	    return SUCCESS;
         }

        count++;
        /* --- print processing message every 10 lines --- */
        if (!(count%10))
            mdlOutput_printf (MSG_MESSAGE, TXT_Processing, count);

       if (params.inputFormat != BINAER)
       {        
	/* --- remove LF, CR, and comments (;) --- */
        if ( (cP = strchr (buffer, LINEFEED)) != NULL)
            *cP = '\0';
        if ( (cP = strchr (buffer, CARRIAGERETURN)) != NULL)
            *cP = '\0';
        if ( (cP = strchr (buffer, ';')) != NULL)
            *cP = '\0';

        if (strchr (buffer, '$') != NULL)
            continue;
	/* --- break into tokens --- */
        token = strtok (buffer, parseString);
        if (token == NULL)
            continue;
        strcpy (str1, token);

        token = strtok (NULL, parseString);
        if (token == NULL)
            continue;
        strcpy (str2, token);

        token = strtok (NULL, parseString);
        if (token == NULL)
            continue;
        strcpy (str3, token);

        token = strtok (NULL, parseString);
        if (token == NULL)
            {
            if (params.inputFormat < XYZDLC)
                continue;
            else
                {
                str4[0] = 0;
                str5[0] = 0;
                }
            }
        else
            {
            strcpy (str4, token);

            token = strtok (NULL, parseString);
            if (token != NULL)
                strcpy (str5, token);
            else
                str5[0]=0;
            }
       }

 
        switch (params.inputFormat)
            {
            case DXYZLC:
            case DXYZLS:
                status = pltpnt_assignValues (str2, str3, str4, str1, str5,
                                     &east, &north, &elev, descriptor, label);
		
                break;

            case DYXZLC:
            case DYXZLS:
                status = pltpnt_assignValues (str3, str2, str4, str1, str5,
                                     &east, &north, &elev, descriptor, label);
                break;

            case XYZDLC:
            case XYZDLS:
                status = pltpnt_assignValues (str1, str2, str3, str4, str5,
                                     &east, &north, &elev, descriptor, label);
                break;

            case YXZDLS:
            case YXZDLC:
                status = pltpnt_assignValues (str2, str1, str3, str4, str5,
                                     &east, &north, &elev, descriptor, label);
                break;
           case LIDAR:
                status = pltpnt_assignValues (str1, str2, str3, str5, str4,
                                     &east, &north, &elev, descriptor, label);
                break;
            case BINAER:
                 east=xval; north=yval; elev=hoehe;
		     strcpy(descriptor,pnt_name);
                 sprintf(label,"%li",part);
		 break;		
            }
	
        if (status == ERROR)
         continue;
        else
          {
           if (erst)
	   	{
            xmin=xmax=east;
	    	ymin=ymax=north;
	    	zmax=zmin=elev;
	    	erst=FALSE;
	   	}
           if (east<xmin)
		xmin=east;
	   if (east>xmax)
		xmax=east;
	   if (north<ymin)
		ymin=north;
	   if (north>ymax)
		ymax=north;
	   if (elev<zmin)
		zmin=elev;
	   if (elev>zmax)
		zmax=elev;
     
          }
        }
    return SUCCESS;
    }


/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_enableItem                                       |
|                                                                       |
+----------------------------------------------------------------------*/
Private int     pltpnt_enableItem
(
DialogItemMessage   *dimP,
long                colorId,
long                weightId,
unsigned long                levelId,
long                xoffId,
long                yoffId,
int                 enabled
)
    {
    DialogItem  *diP;

    if (colorId)
        {
        if ((diP = mdlDialog_itemGetByTypeAndId (dimP->db, RTYPE_Text,
                                                 colorId, 0)))
        mdlDialog_itemSetEnabledState (dimP->db, diP->itemIndex, enabled,
                                       FALSE);
        }

    if (weightId)
        {
        if ((diP = mdlDialog_itemGetByTypeAndId (dimP->db, RTYPE_Text,
                                                 weightId, 0)))
            mdlDialog_itemSetEnabledState (dimP->db, diP->itemIndex,
                                           enabled, FALSE);
        }

    if (levelId)
        {
        if ((diP = mdlDialog_itemGetByTypeAndId (dimP->db, RTYPE_Text,
                                                 levelId, 0)))
        mdlDialog_itemSetEnabledState (dimP->db, diP->itemIndex, enabled,
                                       FALSE);
        }

    if (xoffId)
        {
        if ((diP = mdlDialog_itemGetByTypeAndId (dimP->db, RTYPE_Text,
                                                 xoffId, 0)))
        mdlDialog_itemSetEnabledState (dimP->db, diP->itemIndex, enabled,
                                       FALSE);
        }

    if (yoffId)
        {
         if ((diP = mdlDialog_itemGetByTypeAndId (dimP->db, RTYPE_Text,
                                                 yoffId, 0)))
        mdlDialog_itemSetEnabledState (dimP->db, diP->itemIndex, enabled,
                                       FALSE);
        }
 
    return SUCCESS;
    }

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_toggleButtonHook                                 |
|                                                                       |
+----------------------------------------------------------------------*/
Private void     pltpnt_toggleButtonHook
(
DialogItemMessage   *dimP
)
    {
    dimP->msgUnderstood = TRUE;

    switch (dimP->messageType)
	{
        case DITEM_MESSAGE_STATECHANGED:
        case DITEM_MESSAGE_INIT:
        case DITEM_MESSAGE_SYNCHRONIZE:
            {
            pltpnt_enableItem (dimP, TEXTID_DescrColor, TEXTID_DescrWeight,
                                TEXTID_DescrLevel, TEXTID_DescrXoff,
                                TEXTID_DescrYoff,
                                params.toggleMask & TOGGLEID_Descriptor);

            pltpnt_enableItem (dimP, TEXTID_LabelColor, TEXTID_LabelWeight,
                                TEXTID_LabelLevel, TEXTID_LabelXoff,
                                TEXTID_LabelYoff,
                                params.toggleMask & TOGGLEID_Label);

            pltpnt_enableItem (dimP, TEXTID_ElevColor, TEXTID_ElevWeight,
                                TEXTID_ElevLevel, TEXTID_ElevXoff,
                                TEXTID_ElevYoff,
                                params.toggleMask & TOGGLEID_Elev);

            pltpnt_enableItem (dimP, TEXTID_CellColor, TEXTID_CellWeight,
                                TEXTID_CellLevel, TEXTID_CellName,
                                0L,
                                params.toggleMask & TOGGLEID_Cell);
            break;
            }
        default:
	    dimP->msgUnderstood = FALSE;
	    break;
	}
  
//    return SUCCESS;
    }

/*----------------------------------------------------------------------+
|									|
| name          pltpnt_getFile                                          |
|									|
+----------------------------------------------------------------------*/
Private void    pltpnt_getFile
(
char *filename,
char *defaultExtension,
char *prompt
)   
    {
    int     status;
    int     stringLength;
    char    dir[MAXDIRLENGTH], localSpec[MAXFILELENGTH];

    /* --- get DGN Dir Path      --- */
    mdlFile_parseName (tcb->dgnfilenm, NULL, dir, NULL, NULL);
    stringLength        = strlen (dir);
    if (dir[stringLength-1] != sepchar)
        {
        dir[stringLength]   = sepchar;
        dir[stringLength+1] = 0;
        }

    /* --- use the built in dialog box to get the file name --- */
    if (mdlDialog_fileOpen (localSpec, NULL, 0, NULL, defaultExtension,
                            dir, prompt))
        return;
    else
        strcpy (filename, localSpec);
//    pltpnt_setadjust();
    }

/*----------------------------------------------------------------------+
|                                                                       |
| name          pltpnt_pushButtonHook                                   |
|                                                                       |
+----------------------------------------------------------------------*/
Private void     pltpnt_pushButtonHook
(
DialogItemMessage   *dimP
)
    {
    char        keyin[100];
    DialogItem  *diP;

    dimP->msgUnderstood = TRUE;

    switch (dimP->messageType)
	{
	case DITEM_MESSAGE_BUTTON:
            {
            switch (dimP->dialogItemP->rawItemP->itemHookArg)
                {
                case PUSHBUTTONID_Select:
                    {
                    pltpnt_getFile (params.asciiFile, "*.dat;*.gps;*.txt;*.csv", TXT_SelectFile);
                    mdlDialog_itemsSynch (dimP->db);
                    break;
                    }
                case PUSHBUTTONID_Run:
                    {
                    /* --- if no ASCII designated force user to select --- */
                    if (params.asciiFile[0] == 0)
                        {
                        pltpnt_getFile (params.asciiFile, "*.dat",
                                        TXT_SelectFile);
                        mdlDialog_itemsSynch (dimP->db);
                        }
                        pltpnt_plotPoints ();
                    break;
                    }
                case PUSHBUTTONID_Quit:
                    {
                    /* --- close dialog box forcing command to unload --- */
                    mdlDialog_closeCommandQueue (dimP->db);
                    break;
                    }
                }
            }
	default:
            {
	    dimP->msgUnderstood = FALSE;
	    break;
            }
	}
  
  //  return SUCCESS;
    }

/*----------------------------------------------------------------------+
|									|
| name          pltpnt_dialogBoxHook                                    |
|									|
+----------------------------------------------------------------------*/
Private void    pltpnt_dialogBoxHook
(
DialogMessage	*dmP	    /* => a ptr to a dialog message */
)
    {
    int status;

    dmP->msgUnderstood = TRUE;
    switch (dmP->messageType)
	{
	case DIALOG_MESSAGE_DESTROY:
            {
            /* --- unload this mdl task when the Dialog is closed --- */
	    mdlDialog_cmdNumberQueue (FALSE, CMD_MDL_UNLOAD,
				      mdlSystem_getCurrTaskID(), TRUE);
	    break;
            }
	default:
            {
	    dmP->msgUnderstood = FALSE;
	    break;
            }
        }
 //   return SUCCESS;
    }

/*----------------------------------------------------------------------+
|									|
| name          pltpnt_unloadFunction                                   |
|									|
+----------------------------------------------------------------------*/
Private int     pltpnt_unloadFunction
(
void
)       
    {
    RscFileHandle   userPrefsH;
    pltpnt_Params   *pltpntRscP;
    char            userPrefsFileName[MAXFILELENGTH];
    int             status;

    /* --- Check for an existing user preferences file --- */
    if ((status = mdlFile_find (userPrefsFileName, "myprefs.rsc",
                               "MS_DATA", "rsc")) == SUCCESS)
        {
        status = mdlResource_openFile (&userPrefsH, userPrefsFileName,
                                       RSC_READWRITE);
        }

    /* --- If existing userpref not found, create a new one. --- */
    if (status != SUCCESS)
	{
	/* --- Generate a user pref file name. --- */
        mdlFile_create (userPrefsFileName, userPrefsFileName, "MS_DATA", "rsc");

	/* --- Create the user pref file. --- */
        mdlResource_createFile (userPrefsFileName, "My Preferences", MYPREFS);

	/* --- Open the new user pref file. --- */
        mdlResource_openFile (&userPrefsH, userPrefsFileName, RSC_READWRITE);
        }

    /* --- if we can't open file exit function --- */
    if (userPrefsH == NULL)
        return FALSE;

    pltpntRscP = (pltpnt_Params *)mdlResource_load (userPrefsH,
                                                    RTYPE_Pltp, RSCID_Pltp);

    if (!pltpntRscP)
	{
        /* --- preferences do not exist, so add it --- */
        mdlResource_add (userPrefsH, RTYPE_Pltp, RSCID_Pltp,
                         &params, sizeof(pltpnt_Params),NULL);
        }
    else
	{
        /* --- Write out the updated resource --- */
        *pltpntRscP = params;
        mdlResource_write (pltpntRscP);
        mdlResource_free  (pltpntRscP);
	}

    /* --- Close user preference file ---- */
    mdlResource_closeFile (userPrefsH);
    mdlState_startDefaultCommand ();

    return  FALSE;
    }

/*----------------------------------------------------------------------+
|									|
| name          pltpnt_loadDefaults                                     |
|									|
+----------------------------------------------------------------------*/
Private int     pltpnt_loadDefaults
(  
void
)
    {
    char                    userPrefsFileName[MAXFILELENGTH];
    int                     status;
    double                  textHeight;
    RscFileHandle           rfHandle, userPrefsH;
    pltpnt_Params           *pltpntRscP=NULL;

    /* --- Check for an existing user preferences file --- */
    if ((status = mdlFile_find (userPrefsFileName, "myprefs.rsc",
                               "MS_DATA", "rsc")) == SUCCESS)
        {
        status = mdlResource_openFile (&userPrefsH, userPrefsFileName,
                                       RSC_READWRITE);
        }

    /* --- If userpref found try to read default values --- */
    if (status == SUCCESS)
	{
        pltpntRscP = mdlResource_load (userPrefsH, RTYPE_Pltp, RSCID_Pltp);

        if (pltpntRscP)
            {
            /* --- Copy from resource into structure --- */
            memcpy (&params, pltpntRscP, sizeof(pltpnt_Params));

            /* --- Free the memory used by the rsc --- */
            mdlResource_free (pltpntRscP);

            /* --- close the use preference file --- */
            mdlResource_closeFile (userPrefsH);
          
            return SUCCESS;
            }
        /* --- close the use preference file --- */
        mdlResource_closeFile (userPrefsH);
        }

    /* --- Set default values --- */
    /* --- get text size in master units --- */
    mdlCurrTrans_begin ();
    mdlCurrTrans_masterUnitsIdentity (FALSE);
    mdlParams_getActive (&textHeight, ACTIVEPARAM_TEXTHEIGHT);
    mdlCurrTrans_end ();

    params.TextHeight = textHeight;
    params.labelRow = 1;
    params.inputFormat=1;
    params.descrColor=4;
    params.descrWeight=1;
    params.descrLevel=4;
    params.labelColor=4;
    params.labelWeight=1;
    params.labelLevel=2;
    params.elevColor=2;
    params.elevWeight=1;
    params.elevLevel=3;
    params.cellColor=10;
    params.cellWeight=8;
    params.cellLevel=1;
    params.toggleMask=0x3;
    params.elevXoffset=0.0;
    params.elevYoffset=0.0;
    params.descrXoffset=0.0;
    params.descrYoffset=1.2*textHeight;
    params.labelXoffset=0.0;
    params.labelYoffset=-2.0*textHeight;
    strcpy (params.cellName, " ");
  
    return SUCCESS;
    }




/*----------------------------------------------------------------------+
|                                                                       |
|   Private Global variables                                            |
|                                                                       |
+----------------------------------------------------------------------*/


Private DialogHookInfo  uHooks[] =
    {
    {HOOKDIALOGID_DialogBox,    pltpnt_dialogBoxHook},
    {HOOKITEMID_ToggleButton,   pltpnt_toggleButtonHook},
    {HOOKITEMID_PushButton,     pltpnt_pushButtonHook},
    }; 



/*----------------------------------------------------------------------+
|									|
| name		main							|
|									|
+----------------------------------------------------------------------*/
int		main 
(
void
)	
    {
    RscFileHandle   rfHandle;
    SymbolSet            *setP;

    /* --- Publish the dialog item hooks --- */
    mdlDialog_hookPublish (sizeof(uHooks)/sizeof(DialogHookInfo), uHooks);

    /* --- Open our file for access to command table and dialog --- */
    mdlResource_openFile (&rfHandle, NULL, FALSE);
    
    /* ---  Publish locTextInfoP for access by the dialog manager --- */
    setP = mdlCExpression_initializeSet (VISIBILITY_DIALOG_BOX |
                                         VISIBILITY_DEBUGGER, 0, FALSE);
    

    mdlDialog_publishComplexVariable (setP, "pltpnt_params", "params", &params);

    /* --- set up current transform to deal with master units --- */
    mdlCurrTrans_begin ();
    mdlCurrTrans_identity ();

    /* --- load default from default user preference file --- */
    pltpnt_loadDefaults ();

    params.asciiFile[0] = 0;

    /* --- Set up function to get called at unload time --- */
    mdlSystem_setFunction (SYSTEM_UNLOAD_PROGRAM, pltpnt_unloadFunction);

    /* --- Open the dialog box --- */
    mdlDialog_open (NULL, DIALOGID_PlotPoints);
    
    return SUCCESS;
    }

// mdlCnv_masterToUOR(&UORsP,1,MASTERFILE);
// printf("\n1 Meter entspricht %lf UORs",UORsP);   
