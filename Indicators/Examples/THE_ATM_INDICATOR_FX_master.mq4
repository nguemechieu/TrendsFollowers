//+------------------------------------------------------------------+
//|                               TrendExpert.mq4 |
//|                                       Noel Martial Nguemechieu |
//|                                                             |
//+------------------------------------------------------------------+
#property copyright "Noel Martial Nguemechieu"
#property link      "https://github.com/Bigbossmanger/TradeExpert"
#property version   "1.00"
#property description "This Indicator work with discord and telegram bot"

#include <stdlib.mqh>
#include <stderror.mqh>
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 25

#property indicator_type1 DRAW_ARROW
#property indicator_width1 4
#property indicator_color1 clrWhite
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 4
#property indicator_color2 clrWhite
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 1
#property indicator_color3 clrWhite
#property indicator_label3 "Buy"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 1
#property indicator_color4 clrWhite
#property indicator_label4 "Sell"

#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_color5 0x2B00FF
#property indicator_label5 ""

#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 2
#property indicator_color6 0xFF8000
#property indicator_label6 ""

#property indicator_type7 DRAW_NONE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_color7 0xFFAA00
#property indicator_label7 "Buy"

#property indicator_type8 DRAW_NONE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_color8 0xFFAA00
#property indicator_label8 "Buy"

#property indicator_type9 DRAW_HISTOGRAM
#property indicator_style9 STYLE_SOLID
#property indicator_width9 3
#property indicator_color9 0x00FF00
#property indicator_label9 "Bullish"

#property indicator_type10 DRAW_HISTOGRAM
#property indicator_style10 STYLE_SOLID
#property indicator_width10 3
#property indicator_color10 0x00FF00
#property indicator_label23 "Bullish"

#property indicator_type11 DRAW_HISTOGRAM
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_color11 0x00FF00
#property indicator_label32 "Bullish"

#property indicator_type12 DRAW_HISTOGRAM
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_color12 0x00FF00
#property indicator_label43 "Bullish"

#property indicator_type13 DRAW_HISTOGRAM
#property indicator_style13 STYLE_SOLID
#property indicator_width13 3
#property indicator_color13 0x008000
#property indicator_label52 "Bullish Weak"

#property indicator_type14 DRAW_HISTOGRAM
#property indicator_style14 STYLE_SOLID
#property indicator_width14 3
#property indicator_color14 0x008000
#property indicator_label62 "Bullish Weak"

#property indicator_type16 DRAW_HISTOGRAM
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_color16 0x008000
#property indicator_label74 "Bullish Weak"

#property indicator_type171 DRAW_HISTOGRAM
#property indicator_style17 STYLE_SOLID
#property indicator_width17 1
#property indicator_color17 0x008000
#property indicator_label85 "Bullish Weak"

#property indicator_type18 DRAW_HISTOGRAM
#property indicator_style18 STYLE_SOLID
#property indicator_width18 3
#property indicator_color18 0x4763FF
#property indicator_label90 "Bearish Weak"

#property indicator_type19 DRAW_HISTOGRAM
#property indicator_style19 STYLE_SOLID
#property indicator_width19 3
#property indicator_color19 0x4763FF
#property indicator_label164 "Bearish Weak"

#property indicator_type20 DRAW_HISTOGRAM
#property indicator_style20 STYLE_SOLID
#property indicator_width20 1
#property indicator_color20 0x4763FF
#property indicator_label11 "Bearish Weak"

#property indicator_type21 DRAW_HISTOGRAM
#property indicator_style21 STYLE_SOLID
#property indicator_width21 1
#property indicator_color21 0x4763FF
#property indicator_label12 "Bearish Weak"

#property indicator_type22 DRAW_HISTOGRAM
#property indicator_style22 STYLE_SOLID
#property indicator_width22 3
#property indicator_color22 0x0000FF
#property indicator_label13 "Bearish"

#property indicator_type23 DRAW_HISTOGRAM
#property indicator_style23 STYLE_SOLID
#property indicator_width23 3
#property indicator_color23 0x0000FF
#property indicator_label14 "Bearish"

#property indicator_type24 DRAW_HISTOGRAM
#property indicator_style24 STYLE_SOLID
#property indicator_width24 1
#property indicator_color24 0x0000FF
#property indicator_label15 "Bearish"

#property indicator_type25 DRAW_HISTOGRAM
#property indicator_style25 STYLE_SOLID
#property indicator_width25 1
#property indicator_color25 0x0000FF
#property indicator_label16 "Bearish"

#property strict
#property script_show_inputs
#property indicator_chart_window

#property description "RISK DISCLAIMER : Investing involves risks. Any decision to invest in either real estate or stock markets is a personal decision that should be made after thorough research, including an assessment of your personal risk tolerance and your personal financial condition and goals. Results are based on market conditions and on each personal and the action they take and the time and effort they put in"

#include <FxWeirdos\createObjects.mqh>    // Functions for creating objects
#include <FxWeirdos\pipValue.mqh>         // Functions for pip values
//--- Inputs
input color cRPTFontClr = C'255,166,36';  // Font color

//--- parameters
double dRPTAmtRisking;           // Used to calculate the overall risk
double dRPTAmtRewarding;         // Used to calculate the overall target      
int kRPT;                        // Used to loop all open orders to get the overall risk
string sRPTObjectName;           // To name all objects

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   //--- Hide the OneClick panel
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);
 OnnInit();
   return(INIT_SUCCEEDED);

}



//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];
double Buffer9[];
double Buffer10[];
double Buffer11[];
double Buffer12[];
double Buffer13[];
double Buffer14[];
double Buffer15[];
double Buffer16[];
double Buffer17[];
double Buffer18[];
double Buffer19[];
double Buffer20[];
double Buffer21[];
double Buffer22[];
double Buffer23[];
double Buffer24[];


extern int Period1 = 3;
extern int Period2 = 34;
extern int SR_LIMIT_BARS = 0;
datetime time_alert; //used when sending alert
extern bool Audible_Alerts = true;
extern bool Push_Notifications = true;
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | THE ATM INDICATOR FX @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      if(Audible_Alerts) Alert(type+" | THE ATM INDICATOR FX @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | THE ATM INDICATOR FX @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
    
      
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
void OnnInit()
  {   
   IndicatorBuffers(24);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexArrow(0, 233);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexArrow(1, 234);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexArrow(2, 233);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexArrow(3, 234);
   SetIndexBuffer(4, Buffer5);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexBuffer(5, Buffer6);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexBuffer(6, Buffer7);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexBuffer(7, Buffer8);
   SetIndexEmptyValue(7, EMPTY_VALUE);
   SetIndexBuffer(8, Buffer9);
   SetIndexEmptyValue(8, EMPTY_VALUE);
   SetIndexBuffer(9, Buffer10);
   SetIndexEmptyValue(9, EMPTY_VALUE);
   SetIndexBuffer(10, Buffer11);
   SetIndexEmptyValue(10, EMPTY_VALUE);
   SetIndexBuffer(11, Buffer12);
   SetIndexEmptyValue(11, EMPTY_VALUE);
   SetIndexBuffer(12, Buffer13);
   SetIndexEmptyValue(12, EMPTY_VALUE);
   SetIndexBuffer(13, Buffer14);
   SetIndexEmptyValue(13, EMPTY_VALUE);
   SetIndexBuffer(14, Buffer15);
   SetIndexEmptyValue(14, EMPTY_VALUE);
   SetIndexBuffer(15, Buffer16);
   SetIndexEmptyValue(15, EMPTY_VALUE);
   SetIndexBuffer(16, Buffer17);
   SetIndexEmptyValue(16, EMPTY_VALUE);
   SetIndexBuffer(17, Buffer18);
   SetIndexEmptyValue(17, EMPTY_VALUE);
   SetIndexBuffer(18, Buffer19);
   SetIndexEmptyValue(18, EMPTY_VALUE);
   SetIndexBuffer(19, Buffer20);
   SetIndexEmptyValue(19, EMPTY_VALUE);
   SetIndexBuffer(20, Buffer21);
   SetIndexEmptyValue(20, EMPTY_VALUE);
   SetIndexBuffer(21, Buffer22);
   SetIndexEmptyValue(21, EMPTY_VALUE);
   SetIndexBuffer(22, Buffer23);
   SetIndexEmptyValue(22, EMPTY_VALUE);
   SetIndexBuffer(23, Buffer24);
   SetIndexEmptyValue(23, EMPTY_VALUE);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
  
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
  
     //--- Delete these objects from chart 
   ObjectsDeleteAll(0);
   
   //--- Always reset these parameters at the beginning
  	dRPTAmtRisking=0.0;
  	dRPTAmtRewarding=0.0;
   sRPTObjectName="";

   //--- Loop all open orders in order to calculate the overall risk
	for (kRPT=0 ; kRPT<OrdersTotal() ; kRPT++) {
	   
      //--- Select the open order	   
		if (OrderSelect(kRPT,SELECT_BY_POS,MODE_TRADES)) {

         //--- Get the risks of Buys and Sells orders
   	   if (OrderGetInteger(ORDER_TYPE)==0 || OrderGetInteger(ORDER_TYPE)==1) {

            if (OrderSymbol()==Symbol()) {

               //--- Create SL object if it is not null               
               if(OrderStopLoss()!=0) {
               
                  //--- Name of the object SL Text
                  sRPTObjectName = ""; // This here is essential
                  sRPTObjectName = StringConcatenate(OrderTicket(),OrderStopLoss());
   
                  //--- Creation of the object SL Text
                  vSetText(0,sRPTObjectName,0,TimeCurrent(),OrderStopLoss(),8,cRPTFontClr,"SL: "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots())/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"% = "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots()),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
               
               }

               //--- Create TP object if it is not null               
               if (OrderTakeProfit()!=0) {
               
                  //--- Name of the object TP Text
                  sRPTObjectName = ""; // This here is essential
                  sRPTObjectName = StringConcatenate(OrderTicket(),OrderTakeProfit());
   
                  //--- Creation of the object TP Text
                  vSetText(0,sRPTObjectName,0,TimeCurrent(),OrderTakeProfit(),8,cRPTFontClr,"TP: "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots())/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"% = "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots()),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
               
               }
               
               //--- Add dRPTAmtRisking if SL is not null
               if(OrderStopLoss()!=0) {
               
      	         //--- Add the risk of this open order to the overall risk
         			dRPTAmtRisking =    dRPTAmtRisking +    dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots());
               }
               
               //--- Add dRPTAmtRewarding if TP is not null
               if (OrderTakeProfit()!=0) {
                                       			
      	         //--- Add the target of this open order to the overall target
         			dRPTAmtRewarding =  dRPTAmtRewarding +  dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots());
         			
      			}
            }
   		}
   	}
   }

   //--- Create the RPTBalance, RPTTotalPercentRisked & RPTTotalPercentTarget objects
   vSetLabel(0, "RPTBalance",0,25,20,8,cRPTFontClr,"Balance: "+ DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));         
   vSetLabel(0, "RPTAllSymbolPercentRisked",0,45,20,8,cRPTFontClr,"All "+Symbol()+"'s % Risked : "+ DoubleToString(dRPTAmtRisking/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");
   vSetLabel(0, "RPTAllSymbolPercentTarget",0,65,20,8,cRPTFontClr,"All "+Symbol()+"'s % Target : "+ DoubleToString(dRPTAmtRewarding/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");

  
  
  
  
  
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
   ArraySetAsSeries(Buffer7, true);
   ArraySetAsSeries(Buffer8, true);
   ArraySetAsSeries(Buffer9, true);
   ArraySetAsSeries(Buffer10, true);
   ArraySetAsSeries(Buffer11, true);
   ArraySetAsSeries(Buffer12, true);
   ArraySetAsSeries(Buffer13, true);
   ArraySetAsSeries(Buffer14, true);
   ArraySetAsSeries(Buffer15, true);
   ArraySetAsSeries(Buffer16, true);
   ArraySetAsSeries(Buffer17, true);
   ArraySetAsSeries(Buffer18, true);
   ArraySetAsSeries(Buffer19, true);
   ArraySetAsSeries(Buffer20, true);
   ArraySetAsSeries(Buffer21, true);
   ArraySetAsSeries(Buffer22, true);
   ArraySetAsSeries(Buffer23, true);
   ArraySetAsSeries(Buffer24, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
      ArrayInitialize(Buffer6, EMPTY_VALUE);
      ArrayInitialize(Buffer7, EMPTY_VALUE);
      ArrayInitialize(Buffer8, EMPTY_VALUE);
       ArrayInitialize(Buffer9, EMPTY_VALUE);
      ArrayInitialize(Buffer10, EMPTY_VALUE);
      ArrayInitialize(Buffer11, EMPTY_VALUE);
      ArrayInitialize(Buffer12, EMPTY_VALUE);
      ArrayInitialize(Buffer13, EMPTY_VALUE);
      ArrayInitialize(Buffer14, EMPTY_VALUE);
      ArrayInitialize(Buffer15, EMPTY_VALUE);
      ArrayInitialize(Buffer16, EMPTY_VALUE);
      ArrayInitialize(Buffer17, EMPTY_VALUE);
      ArrayInitialize(Buffer18, EMPTY_VALUE);
      ArrayInitialize(Buffer19, EMPTY_VALUE);
      ArrayInitialize(Buffer20, EMPTY_VALUE);
      ArrayInitialize(Buffer21, EMPTY_VALUE);
      ArrayInitialize(Buffer22, EMPTY_VALUE);
      ArrayInitialize(Buffer23, EMPTY_VALUE);
      ArrayInitialize(Buffer24, EMPTY_VALUE);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, 1+i) > iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, 1+i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, 2+i) < iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, 2+i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      
      )
        {
         Buffer1[i] = Low[2+i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         
         
         time_alert = Time[1];
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, 1+i) < iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, 1+i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, 2+i) > iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, 2+i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      
      )
        {
         Buffer2[i] = High[2+i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell"); //Alert on next bar open
         
         time_alert = Time[1];               
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i)
      && iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i+1) < iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i+1) //Moving Average crosses above Moving Average
      && iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, 2+i) //Moving Average < Moving Average
      && High[i] > iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, i) //Candlestick High > Moving Average
      
      )
        {
         Buffer3[i] = Low[2+i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         
         
         time_alert = Time[1];
     
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i)
      && iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_SMA, PRICE_CLOSE, i+1) > iMA(NULL, PERIOD_CURRENT, 12, 0, MODE_SMA, PRICE_CLOSE, i+1) //Moving Average crosses below Moving Average
      && iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 34, 0, MODE_SMA, PRICE_CLOSE, 2+i) //Moving Average > Moving Average
      && Low[i] < iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, i) //Candlestick Low < Moving Average
      
      )
        {
         Buffer4[i] = High[2+i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, i) == iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, i) //Moving Average is equal to Moving Average
      
      )
        {
         Buffer5[i] = iMA(NULL, PERIOD_CURRENT, 42, 0, MODE_SMA, PRICE_TYPICAL, i); //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", ""); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer5[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 6
      if(iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, i) == iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, i) //Moving Average is equal to Moving Average
      
      )
        {
         Buffer6[i] = iMA(NULL, PERIOD_CURRENT, 3, 0, MODE_SMMA, PRICE_MEDIAN, i); //Set indicator value at Moving Average
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", ""); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer6[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 7
      RefreshRates();
      if(Bid < Resistance(SR_LIMIT_BARS * PeriodSeconds(), false, 00, 00, true, i) //Price < Resistance
      )
        {
         Buffer7[i] = Resistance(SR_LIMIT_BARS * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Resistance
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer7[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 8
      RefreshRates();
      if(Bid > Support(SR_LIMIT_BARS * PeriodSeconds(), false, 00, 00, true, i) //Price > Support
      )
        {
         Buffer8[i] = Support(SR_LIMIT_BARS * PeriodSeconds(), false, 00, 00, true, i); //Set indicator value at Support
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer8[i] = EMPTY_VALUE;
        }
         if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer9[i] = Open[i]; //Set indicator value at Candlestick Open
        }
      else
        {
         Buffer9[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer10[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer10[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer11[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer11[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer12[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer12[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer13[i] = Open[i]; //Set indicator value at Candlestick Open
        }
      else
        {
         Buffer13[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 6
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer14[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer14[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 7
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      
      )
        {
         Buffer15[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer15[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 8
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer16[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer16[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 9
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer17[i] = Open[i]; //Set indicator value at Candlestick Open
        }
      else
        {
         Buffer17[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 10
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer18[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer18[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 11
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer19[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer19[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 12
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
        {
         Buffer20[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer20[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 13
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer21[i] = Open[i]; //Set indicator value at Candlestick Open
        }
      else
        {
         Buffer21[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 14
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer22[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer22[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 15
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer23[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer23[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 16
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
        {
         Buffer24[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer24[i] = EMPTY_VALUE;
        }
     
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+