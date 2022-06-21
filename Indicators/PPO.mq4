//+------------------------------------------------------------------+
//|                                                          PPO.mq4 |
//|                                       Copyright © 2007 Tom Balfe |
//|                                                                  |
//| Percentage Price Oscillator                                      |
//| This is a momentum indicator.                                    |
//| Signal line is EMA of PPO.                                       |
//|                                                                  |
//| Follows formula: (FastEMA-SlowEMA)/SlowEMA                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 Tom Balfe"
#property link      "redcarsarasota@yahoo.com"
//----
#property indicator_separate_window
#property indicator_buffers 4
//----
#property indicator_color1 SkyBlue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_width1 2
#property indicator_width2 1
#property indicator_style2 2
//---- user changeable stuff
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalEMA=9;
extern bool sound= true;
//---- two buffers
double     PPOBuffer[];
double     SignalBuffer[];
double     ExtMapBuffer3[];
double     ExtMapBuffer4[];
static int prevtime = 0 ;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SignalEMA);
   IndicatorDigits(Digits+1);
   SetIndexBuffer(0,PPOBuffer);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexStyle(2,DRAW_ARROW,Red);
   SetIndexArrow(2,236);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0); 
   SetIndexStyle(3,DRAW_ARROW,Blue);
   SetIndexArrow(3,238);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);     
//----
   IndicatorShortName("PPO ("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   SetIndexLabel(0,"PPO");
   SetIndexLabel(1,"Signal");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+2;
//---- (FastEMA-SlowEMA)/SlowEMA
//---- PPO counted in the 1st buffer
   for(int i=0; i<limit; i++)
      {      
      PPOBuffer[i]=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i))/
      iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
      }
   for(i=0; i<limit; i++)
      {      
      SignalBuffer[i]=iMAOnArray(PPOBuffer,Bars,SignalEMA,0,MODE_EMA,i);
      if (Time[0]!=prevtime)
         {
         if ((PPOBuffer[i+2]>SignalBuffer[i+2])&&(PPOBuffer[i+1]<SignalBuffer[i+1]))
            {
            ExtMapBuffer4[i]=SignalBuffer[i];
            if (sound == true){ PlaySound("alert.wav"); }
            }
         if ((PPOBuffer[i+2]<SignalBuffer[i+2])&&(PPOBuffer[i+1]>SignalBuffer[i+1])) 
            {
            ExtMapBuffer3[i]=SignalBuffer[i];
            if (sound == true){ PlaySound("alert2.wav"); }
            }         
         prevtime=Time[0];
         }      
      }


 
           
   return(0);
  }
//+--------------------------------------------------------------