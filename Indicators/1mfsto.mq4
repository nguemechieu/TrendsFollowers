#property copyright        "© OneMyForex Team"
#property link             "https://t.me/AlexanderDgreed"


#property indicator_separate_window
#property indicator_minimum -50
#property indicator_maximum  50
#property indicator_level1	 -30
#property indicator_level3	  0
#property indicator_level2	  30
#property indicator_levelcolor	Silver
#property indicator_levelwidth	0
#property indicator_levelstyle	2
#property indicator_buffers 8
#property indicator_color1 CLR_NONE
#property indicator_width1 4  
#property indicator_color2 CLR_NONE
#property indicator_width2 4  
#property indicator_color3 Red
#property indicator_style3 2
#property indicator_color4 Blue
#property indicator_style4 2
#property indicator_color5 Black
#property indicator_style5 2
#property indicator_color6 CLR_NONE
#property indicator_width6 4
#property indicator_color7 CLR_NONE
#property indicator_width7 4
#property indicator_color8 CLR_NONE
#property indicator_width8 2  
#property indicator_style8 0
//---- input parameters
extern int per1    =5;
extern int per2    =15;
extern int per3    =30;
int SignalLevel=0;
bool AlertON = false;
double SignalBuffer[];
double BUFFER_1[];
double BUFFER_2[];
double BUFFER_3[];
double GREEN[];
double RED[];
double up[];
double lo[];
string Name;
int TimeBar;
//+------------------------------------------------------------------+
int init()
  {
   TimeBar=Time[0];
//---- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,up);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,lo);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, BUFFER_1);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3, BUFFER_2);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4, BUFFER_3);
   SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(5, GREEN);
   SetIndexStyle(6,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(6, RED);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7, SignalBuffer);
//---- 
   per1 = next_period(per1);
   per2 = next_period(per2);
   per3 = next_period(per3);
   SetIndexLabel(2, "Stochastic "+TF(per1));
   SetIndexLabel(3, "Stochastic "+TF(per2));
   SetIndexLabel(4, "Stochastic "+TF(per3));
   SetIndexLabel(7, "Stochastic Average");
   Name = "Stochastic 3 ("+TF(per1)+""+TF(per2)+""+TF(per3)+")";
   IndicatorShortName(Name);
   int Win = WindowFind(Name);
   Name=StringConcatenate(Name,Win);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
{
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   int startLastBar = iBarShift(NULL,0,iTime(NULL,per3,0),false);
   if (limit<startLastBar) limit=startLastBar;
   for(int i=0; i<limit; i++)
   {
      BUFFER_1[i]  = iStochastic(NULL,per1,20,3,7,MODE_LWMA,1,MODE_MAIN,iBarShift(NULL,per1,Time[i],false))-50;
      BUFFER_2[i]  = iStochastic(NULL,per2,20,3,7,MODE_LWMA,1,MODE_MAIN,iBarShift(NULL,per2,Time[i],false))-50;
      BUFFER_3[i]  = iStochastic(NULL,per3,20,3,7,MODE_LWMA,1,MODE_MAIN,iBarShift(NULL,per3,Time[i],false))-50;
      SignalBuffer[i]  = (BUFFER_1[i]+BUFFER_2[i]+BUFFER_3[i])/3;
      if (SignalBuffer[i]> 0 ) up[i]=SignalBuffer[i]; else lo[i]=SignalBuffer[i];
      if (AlertON) 
      {
         if (SignalLevel==0)
         {
            if ((SignalBuffer[i]>0 && SignalBuffer[i+1]<0) || (SignalBuffer[i]<0 && SignalBuffer[i+1]>0)) 
            {
               if (TimeBar!=Time[0]) {if (i<2) Alert(Symbol()+" Stochastic 3 ÏÅÐÅÑÅ×ÅÍÈÅ 0");TimeBar=Time[0];}
            }
         }
         else
         {
            if (SignalBuffer[i]>-SignalLevel && SignalBuffer[i]< SignalLevel) 
            {
               GREEN[i]=SignalBuffer[i];
               if (i<2) Alert(Symbol()+" Stochastic 3 = "+DoubleToStr(SignalBuffer[i],2));
            }
         }
      }
      
   }
   return(0);
}
//+------------------------------------------------------------------+
int next_period(int per)
{
   if (per > 43200)  return(0); 
   if (per > 10080)  return(43200); 
   if (per > 1440)   return(10080); 
   if (per > 240)    return(1440); 
   if (per > 60)     return(240); 
   if (per > 30)     return(60);
   if (per > 15)     return(30); 
   if (per >  5)     return(15); 
   if (per >  1)     return(5);   
   if (per == 1)     return(1);   
   if (per == 0)     return(Period());   
return per;
}
//+------------------------------------------------------------------+
string TF(int per)
{
   if (per == 1)     return(" M1 ");
   if (per == 5)     return(" M5 ");
   if (per == 15)    return(" M15 ");
   if (per == 30)    return(" M30 ");
   if (per == 60)    return(" H1 ");
   if (per == 240)   return(" H4 ");
   if (per == 1440)  return(" D1 ");
   if (per == 10080) return(" W1 ");
   if (per == 43200) return(" MN1 ");
return("TF");
}
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete(Name);
   
   return 0;
}
//+------------------------------------------------------------------+


