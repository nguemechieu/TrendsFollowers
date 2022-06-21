//+------------------------------------------------------------------+
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//| account_info_horizontal 4.01                                     |
//| File45: https://www.mql5.com/en/users/file45/publications        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, file45."
#property link      "https://www.mql5.com"
#property version   "4.01"
#property description "Places account information on the chart in horizontal sequence." 
#property description " "
#property description  "Hide account info: Click anywhere on account text."
#property description  "Show account info: Click on text - 'Account Info'."
#property description " "
#property description  "Show Profit only option."
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window
enum spacing_x
  {
   a=8, // 1
   b=9, // 2
   c=10,// 3
  };
//+------------------------------------------------------------------+
input bool Show_only_Profit= false; // Show Profit only
input ENUM_BASE_CORNER Ch   = 3;    // Corner
int    Left_Right_H_S;
input int    Up_Down        = 2;    // Up <-> Down
input int    Left_Right_P   = 15;   // Left <-> Right 
input spacing_x Spacing=b; // Acount Header spacing
input color  Font_Color     = SlateGray; // Info Color
input color  Color_Profit   = LimeGreen; // Profit Color
input color  Color_Loss     = Red;       // Loss Color
input int    Font_Size_h=8;   // Font Size
input bool   Font_Bold=false;     // Font Bold

color  Color_PnL_Closed=Font_Color;
bool switchh=false;
color PnL_Color;
string Acc_F,TM,Hide_Show_h,ML_Perc;
int PC,Up_Down_h,Font_Size;
double Spacing_h;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   switch(Font_Bold)
     {
      case 1: Acc_F = "Arial Bold"; break;
      case 0: Acc_F = "Arial";      break;
     }

   Hide_Show_h=" ";

   if(Font_Size_h<6)
     {
      Font_Size=6;
     }
   else
     {
      Font_Size=Font_Size_h;
     }

   if(Show_only_Profit==false)
     {
      ObjectCreate(0,"Acc_ML_h",OBJ_LABEL,0,0,0);
      ObjectCreate(0,"Acc_M_h",OBJ_LABEL,0,0,0);
      ObjectCreate(0,"Acc_FM_h",OBJ_LABEL,0,0,0);
      ObjectCreate(0,"Acc_E_h",OBJ_LABEL,0,0,0);
      ObjectCreate(0,"Acc_B_h",OBJ_LABEL,0,0,0);
     }
   ObjectCreate(0,"Acc_P_h",OBJ_LABEL,0,0,0);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("Acc_H_S_h");
   ObjectDelete("Acc_ML_h");
   ObjectDelete("Acc_M_h");
   ObjectDelete("Acc_FM_h");
   ObjectDelete("Acc_E_h");
   ObjectDelete("Acc_B_h");
   ObjectDelete("Acc_P_h");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
  {
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

 
   return(rates_total);

}