//+------------------------------------------------------------------+
//|                                          TradeExpert_Library.mq4 |
//|                         Copyright 2022, nguemechieu noel martial |
//|                       https://github.com/nguemechieu/TradeExpert |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "https://github.com/nguemechieu/TradeExpert"
#property version   "1.00"
#property strict
input bool InpAlign=true;

 //+------------------------------------------------------------------+
//|                                                     stderror.mqh |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                       stdlib.mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#import "stdlib.ex4"

string ErrorDescription(int error_code);
int    RGB(int red_value,int green_value,int blue_value);
bool   CompareDoubles(double number1,double number2);
string DoubleToStrMorePrecision(double number,int precision);
string IntegerToHexString(int integer_number);

#import




#define  EXPERT_NAME "TradeExpert"
//--- define the maximum number of used indicators in the EA

#include <DiscordTelegram/Common.mqh>//start settings all include file orders matters
#include <DiscordTelegram/PanelDialog.mqh>

#include <DiscordTelegram/Autheticator.mqh>


struct TOOLS{

MqlTick tick;
int Pip(){ return(int) _Point; 

};
double Ask(){return tick.ask;

};
double Digits(){return _Digits;
};
double Bid(){return tick.bid;}
;
};
  
  //+------------------------------------------------------------------+
  //|                       CREATE OBJECTS                                           |
  //+------------------------------------------------------------------+
  
void vSetRectangle(string name, int sub_window, int xx, int yy, int width, int height, color bg_color, color border_clr, int border_width) export{

   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);

}


void vSetBackground(string sName,int sub_window, int xx, int yy, int width, int height, color BacgroundColor)export {

   ObjectCreate(0,sName,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,sName,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,sName,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,sName,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,sName,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,sName,OBJPROP_BGCOLOR,BacgroundColor);
   ObjectSetInteger(0,sName,OBJPROP_SELECTABLE,false);
   
}











void vSetHLine(long lChartid, string sName,int sub_window, double dPrice, color cFontColor, int iFontSize,string Textx) export{
   ObjectCreate(lChartid,sName,OBJ_HLINE,sub_window,0,0,dPrice);

   ObjectSetInteger(lChartid,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(lChartid,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(lChartid,sName,OBJPROP_TEXT, 0,Textx);
}

void vSetHLine (string sName,int sub_window, double dPrice, color cFontColor)export {
   ObjectCreate(0,sName,OBJ_HLINE,sub_window,0,0);
   ObjectSetInteger(0,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetDouble(0,sName, OBJPROP_PRICE, dPrice);
}

  
  
//+------------------------------------------------------------------+ 
//| Create cycle lines                                               | 
//+------------------------------------------------------------------+ 
bool CyclesCreate(const long            chart_ID=0,        // chart's ID 
                  const string          name="Cycles",     // object name 
                  const int             sub_window=0,      // subwindow index 
                  datetime              time1=0,           // first point time 
                  double                price1=0,          // first point price 
                  datetime              time2=0,           // second point time 
                  double                price2=0,          // second point price 
                  const color           clr=clrRed,        // color of cycle lines 
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // style of cycle lines 
                  const int             width=1,           // width of cycle lines 
                  const bool            back=false,        // in the background 
                  const bool            selection=true,    // highlight to move 
                  const bool            hidden=true,       // hidden in the object list 
                  const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   ChangeCyclesEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create cycle lines by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_CYCLES,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create cycle lines! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set color of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set display style of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the lines by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Move the anchor point                                            | 
//+------------------------------------------------------------------+ 
bool CyclesPointChange(const long   chart_ID=0,    // chart's ID 
                       const string name="Cycles", // object name 
                       const int    point_index=0, // anchor point index 
                       datetime     time=0,        // anchor point time coordinate 
                       double       pricex=0)       // anchor point price coordinate 
  { 
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time) 
      time=TimeCurrent(); 
   if(!pricex) 
      pricex=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,pricex)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move the anchor point! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Delete the cycle lines                                           | 
//+------------------------------------------------------------------+ 
bool CyclesDelete(const long   chart_ID=0,    // chart's ID 
                  const string name="Cycles") // object name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete cycle lines 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete cycle lines! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+-----------------------------------------------------------------------+ 
//| Check the values of cycle lines' anchor points and set default values | 
//| values for empty ones                                                 | 
//+-----------------------------------------------------------------------+ 
void ChangeCyclesEmptyPoints(datetime &time1,double &price1, 
                             datetime &time2,double &price2) 
  { 
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1) 
      time1=TimeCurrent(); 
//--- if the first point's price is not set, it will have Bid value 
   if(!price1) 
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2) 
     { 
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10]; 
      CopyTime(Symbol(),Period(),time1,10,temp); 
      //--- set the second point 9 bars left from the first one 
      time2=temp[0]; 
     } 
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2) 
      price2=price1; 
  } 
//+------------------------------------------------------------------+
//| My functions                                                    |
//+------------------------------------------------------------------+
int MyCalculator(int value,int value2) export
   {
    return(value+value2);
  }
  
  double add(double sum1,double sum2)export{//calculate sum
  double sum=sum1+sum2;
  return sum;
  };
  
    double substract(double sum1,double sum2)export{//calculate substract
  double sum=sum1-sum2;
  return sum;
  };
  
    double divide(double sum1,double sum2)export{//calculate divide
    
    if(sum2==0){ printf ("sum2 can't be null");return 0;}
  double sum=sum1/sum2;
  
  return sum;
  };
    double multiply(double sum1,double sum2)export{//calculate sum
  double sum=sum1*sum2;
  return sum;
  };
  
  
  