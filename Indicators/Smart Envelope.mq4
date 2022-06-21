//+------------------------------------------------------------------+
//|                                               Smart Envelope.mq4 |
//|                                               Giovanni Riccobene |
//|                    https://www.mql5.com/en/users/zoster81/seller |
//+------------------------------------------------------------------+
#property copyright "Giovanni Riccobene"
#property link      "https://www.mql5.com/en/users/zoster81/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot Base
#property indicator_label1  "Base"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Up
#property indicator_label2  "Up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Dw
#property indicator_label3  "Dw"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot mom
#property indicator_label4  "mom"
#property indicator_type4   DRAW_NONE

//--- plot a
#property indicator_label5  "sa"
#property indicator_type5   DRAW_NONE

//--- plot b
#property indicator_label6  "sb"
#property indicator_type6   DRAW_NONE



#define src             getPrice(InputPrice, open, close, high, low, i)
#define nz              NonZero
#define max             MathMax
#define min             MathMin
#define abs             MathAbs

//--- input parameters
input int                        Periodo = 14;                 // Period
input double                     Factor = 1.0;                 // Factor
input ENUM_APPLIED_PRICE         InputPrice = PRICE_CLOSE;     // Input price
//--- indicator buffers
double         BaseBuffer[];
double         a[];
double         b[];
double         momBuffer[];
double         signa[], signb[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0, BaseBuffer);
   SetIndexBuffer(1, a);
   SetIndexBuffer(2, b);
   SetIndexBuffer(3, momBuffer);
   SetIndexBuffer(4, signa);
   SetIndexBuffer(5, signb);

   for(int i = 0; i <= 5; i++)
      SetIndexEmptyValue(i, 0.0);

   for(int i = 3; i <= 5; i++)
      SetIndexLabel(i, "");

//---
   return(INIT_SUCCEEDED);
}
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
                const int &spread[])
{
//---
   int limit = rates_total - 1 - Periodo;
   if(prev_calculated > 0)limit = rates_total - prev_calculated + 1;

   for(int i = limit; i >= 0; i--)
      {
         momBuffer[i] = MathAbs(getPrice(InputPrice, open, close, high, low, i) - getPrice(InputPrice, open, close, high, low, i+1));
         a[i] = max(src, nz(a[i + 1], src)) - min(abs(src - nz(a[i + 1], src)), momBuffer[i]) / Periodo * nz(signa[i + 1]);
         b[i] = min(src, nz(b[i + 1], src)) + min(abs(src - nz(b[i + 1], src)), momBuffer[i]) / Periodo * nz(signb[i + 1]);
         signa[i] = b[i] < b[i + 1] ? Factor * (-1) : Factor;
         signb[i] = a[i] > a[i + 1] ? Factor * (-1) : Factor;
         BaseBuffer[i] = (a[i] + b[i]) / 2;
      }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice, const double &open[], const double &close[], const double &high[], const double &low[], int i)
{
   if(i >= 0)
      switch(tprice)
         {
         case PRICE_CLOSE:
            return(close[i]);
         case PRICE_OPEN:
            return(open[i]);
         case PRICE_HIGH:
            return(high[i]);
         case PRICE_LOW:
            return(low[i]);
         case PRICE_MEDIAN:
            return((high[i] + low[i]) / 2.0);
         case PRICE_TYPICAL:
            return((high[i] + low[i] + close[i]) / 3.0);
         case PRICE_WEIGHTED:
            return((high[i] + low[i] + close[i] + close[i]) / 4.0);
         }
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NonZero(double _a, double _b = 0)
{
   if(_a == 0 || _a == EMPTY_VALUE)
      return _b;
   else return _a;
}
//+------------------------------------------------------------------+
