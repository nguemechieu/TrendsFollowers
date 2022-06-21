//+------------------------------------------------------------------+
//|                                   Indicator: TrendsFollowers.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 4
#property indicator_color1 0x59FF00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 4
#property indicator_color2 0x7300FF
#property indicator_label2 "Sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

extern int chatId = 805814430;
extern string InpToken = "";
extern string InpChannelName = "";
datetime time_alert; //used when sending alert
bool Send_Email = true;
bool Audible_Alerts = true;
bool Push_Notifications = true;
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      Print(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("TrendsFollowers", type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("TrendsFollowers.csv", FILE_CSV|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | TrendsFollowers @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

void DrawLine(string objname, double price, int count, int start_index) //creates or modifies existing object if necessary
  {
   if((price < 0) && ObjectFind(objname) >= 0)
     {
      ObjectDelete(objname);
     }
   else if(ObjectFind(objname) >= 0 && ObjectType(objname) == OBJ_TREND)
     {
      ObjectSet(objname, OBJPROP_TIME1, Time[start_index]);
      ObjectSet(objname, OBJPROP_PRICE1, price);
      ObjectSet(objname, OBJPROP_TIME2, Time[start_index+count-1]);
      ObjectSet(objname, OBJPROP_PRICE2, price);
     }
   else
     {
      ObjectCreate(objname, OBJ_TREND, 0, Time[start_index], price, Time[start_index+count-1], price);
      ObjectSet(objname, OBJPROP_RAY, false);
      ObjectSet(objname, OBJPROP_COLOR, C'0x00,0x00,0xFF');
      ObjectSet(objname, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objname, OBJPROP_WIDTH, 2);
     }
  }

double Support(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = Low[iLowest(NULL, 0, MODE_LOW, count, start_index)];
   if (draw) DrawLine("Support", ret, count, start_index);
   return(ret);
  }

double Resistance(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = High[iHighest(NULL, 0, MODE_HIGH, count, start_index)];
   if (draw) DrawLine("Resistance", ret, count, start_index);
   return(ret);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(2);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexArrow(0, 241);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexArrow(1, 242);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(iWPR(NULL, PERIOD_CURRENT, 20, i) > iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) < iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses above William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) > iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index > Average Directional Movement Index
      )
        {
         Buffer1[i] = Support(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Support
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Buy"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(iWPR(NULL, PERIOD_CURRENT, 20, i) < iWPR(NULL, PERIOD_CURRENT, 200, i)
      && iWPR(NULL, PERIOD_CURRENT, 20, i+1) > iWPR(NULL, PERIOD_CURRENT, 200, i+1) //William's Percent Range crosses below William's Percent Range
      && iADX(NULL, PERIOD_CURRENT, 20, PRICE_MEDIAN, MODE_MAIN, i) < iADX(NULL, PERIOD_CURRENT, 200, PRICE_LOW, MODE_MINUSDI, i) //Average Directional Movement Index < Average Directional Movement Index
      )
        {
         Buffer2[i] = Resistance(12 * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Resistance
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Sell"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+