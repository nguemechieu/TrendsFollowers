//+------------------------------------------------------------------+
//|                                              TrendsFollowers.mq4 |
//|                         Copyright 2022, nguemechieu noel martial |
//|                   https://github.com/nguemechieu/TrendsFollowers |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                   Strategy: TrendsFollowers1.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, nguemechieu noel martial"
#property link      "  https://github.com/nguemechieu/TrendsFollowers"
#property version   "1.00"

#property tester_library "Libraries"
#property stacksize 10000
#property  version "2.1" //EA VERSION 
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,                                                                                                                                                                                                                                                                                                                                                                                              
#include <stdlib.mqh>
#include <stderror.mqh>
#include <DiscordTelegram/MyBot.mqh>


input int TradeDurationMinutes = 30; //minimum trade duration




//------------------------------------------------------------------------------------------------------------
//--------------------------------------------- INTERNAL VARIABLE --------------------------------------------
//--- Vars and arrays



int myOrderSend(string symbol,int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   
   int err = 0;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed");
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders)
   || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders)
   )
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = Ask;
   else if(type == OP_SELL)
      price = Bid;
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   if(MaxSpread > 0 && Ask - Bid > MaxSpread * myPoint)
     {
      myAlert("order", "Order"+ordername_+" not sent, maximum spread "+DoubleToStr(MaxSpread * myPoint, Digits())+" exceeded");
      return(-1);
     }
   //adjust price for pending order if it is too close to the market price
   double MinDistance = PriceTooClose * myPoint;
   if(type == OP_BUYLIMIT && Ask - price < MinDistance)
      price = Ask - MinDistance;
   else if(type == OP_BUYSTOP && price - Ask < MinDistance)
      price = Ask + MinDistance;
   else if(type == OP_SELLLIMIT && price - Bid < MinDistance)
      price = Bid + MinDistance;
   else if(type == OP_SELLSTOP && Bid - price < MinDistance)
      price = Bid - MinDistance;
   while(ticket < 0 && retries < OrderRetry+1)
     {
      ticket = OrderSend(symbol, type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, 0, 0, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+IntegerToString(err)+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+IntegerToString(OrderRetry+1)+" times; error #"+IntegerToString(err)+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+IntegerToString(MagicNumber));
   return(ticket);
  }




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
  
int size=NumOfSymbols;
 ArrayResize( Symbols,size,0);
 
ArrayResize(indicatorsArrayList,NumOfSymbols,0);
    
       ArrayResize(lastSupport,size,0);
      ArrayResize(lastResistance,size,0);
      
      
     ArrayResize(indicatorTimeFrame,NumOfSymbols,0);
       
      //--- CheckConnection
      if(!TerminalInfoInteger(TERMINAL_CONNECTED))
         MessageBox("Warning: No Internet connection found!\nPlease check your network connection.",
                    MB_CAPTION+" | "+"#"+IntegerToString(123), MB_OK|MB_ICONWARNING);

      //--- CheckTradingIsAllowed
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))//Terminal
        {
         MessageBox("Warning: Check if automated trading is allowed in the terminal settings!",
                    MB_CAPTION+" | "+"#"+IntegerToString(123), MB_OK|MB_ICONWARNING);
        }
      else
        {
         if(!MQLInfoInteger(MQL_TRADE_ALLOWED))//CheckBox
           {
            MessageBox("Warning: Automated trading is forbidden in the program settings for "+__FILE__,
                       MB_CAPTION+" | "+"#"+IntegerToString(123), MB_OK|MB_ICONWARNING);
           }
        }

      //---
      if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))//Server
         MessageBox("Warning: Automated trading is forbidden for the account "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+" at the trade server side.",
                    MB_CAPTION+" | "+"#"+IntegerToString(123), MB_OK|MB_ICONWARNING);

      //---
      if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))//Investor
         MessageBox("Warning: Trading is forbidden for the account "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"."+
                    "\n\nPerhaps an investor password has been used to connect to the trading account."+
                    "\n\nCheck the terminal journal for the following entry:"+
                    "\n\'"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"\': trading has been disabled - investor mode.",
                    MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_DISABLED), MB_OK|MB_ICONWARNING);

      //---
      if(!SymbolInfoInteger(Symbol(), SYMBOL_TRADE_MODE))//Symbol
         MessageBox("Warning: Trading is disabled for the symbol "+_Symbol+" at the trade server side.",
                    MB_CAPTION+" | "+"#"+IntegerToString(ERR_TRADE_DISABLED), MB_OK|MB_ICONWARNING);

  

    

                          
  int x0=0,x1=0,x2=0,xf=0,xp=0;  Comment("EA_EXPIRATION:12,8,2022");
  
       if(!CheckDemoPeriod(12,8,2022))//ea expiration date control
         return INIT_FAILED;
   else  if(!LicenseControl())
     {
      MessageBox("Invalid LICENSE KEY!\nPlease contact support at nguemechieu@live.com for any assistance","License Control",MB_CANCELTRYCONTINUE);

      messages="Invalid LICENSE KEY!\nPlease contact support at nguemechieu@live.com for any assistance";

      smartBot.SendMessage(InpChatID,messages,smartBot.ReplyKeyboardMarkup(KEYB_MAIN,FALSE,FALSE),false,false);
  ExpertRemove();

      return INIT_FAILED;
     }
     
        switch(InpUpdateMode)
     {
      case UPDATE_FAST:
         timer_ms=500;
         break;
      case UPDATE_NORMAL:
         timer_ms=2000;
         break;
      case UPDATE_SLOW:
         timer_ms=3000;
         break;
      default:
         timer_ms=10;
         break;
         
         
     };

   //--- done
  smartBot.ChartColorSet();//set charcolor

     if(UseBot){
 
 init_error=smartBot.Token(InpTocken);

//--- set language
   smartBot.Language(InpLanguage);

//--- set token

//--- set filter
   smartBot.UserNameFilter(UserName);

//--- set templates
   smartBot.Templates(Template);
   smartBot.ReplyKeyboardMarkup(KEYB_MAIN,false,false);
//--- set timer
   timer_ms=3000;



}
    
 
   EventSetTimer(timer_ms);  
     
     if(EA_TIME_LOCK_ACTION)
     {
      mydate=TimeCurrent();
     
    
     }


     
//--- CheckData
   if(TerminalInfoInteger(TERMINAL_CONNECTED) && (LastReason == 0 || LastReason == REASON_PARAMETERS))
     {
      //---
      ResetLastError();
      NumOfIndicators=StringSplit(Indicators_list,';',indicatorsArrayList);
      
      
  NumOfSymbols=StringSplit(InpUsedSymbols,';',array_used_symbols);
    ArrayResize(Symbols,NumOfSymbols,0);
    
  datetime startTime=TimeCurrent();
   
//--- Disclaimer
   if(!GlobalVariableCheck(OBJPREFIX+"Disclaimer" ) || GlobalVariableGet(OBJPREFIX+"Disclaimer") != 1)
     {
       //---
   message = "Welcome to TradeExpert\nRisk Disclaimer:\n Please proceed with caution.\n";
      //---
      if(MessageBox(message, MB_CAPTION, MB_OKCANCEL|MB_ICONWARNING) == IDOK)
         GlobalVariableSet(OBJPREFIX+"Disclaimer", 1);

     }


//---
   if(LastReason == 0)
     {
      //--- OfflineChart
      if(ChartGetInteger(0, CHART_IS_OFFLINE))
        {
         MessageBox("The currenct chart is offline, make sure to uncheck \"Offline chart\" under Properties(F8)->Common.",
                    MB_CAPTION, MB_OK|MB_ICONERROR);

        }
    }
 

     
if(Indicators_list==""){MessageBox("Indicator list can't be empty","Error Indcator",1); ExpertRemove();return false;};
 if(StringFind(Indicators_list,",",0)>0){
 
 MessageBox("Make sure you enter Indicator follow by ';' example :RSI;CCI;OBV;...","Error IndcatoList Invalid",MB_OK);
 ExpertRemove();
 
 }   else  {
   NumOfIndicators=StringSplit(Indicators_list,';',indicatorsArrayList);
}
 ArrayResize(array_used_symbols,NumOfSymbols,0);
  ArrayResize( Symbols,size,0);
     
  
      //---
         // Load all symbols in to arrays
  for(int index=0;index<NumOfSymbols;index++){
  
  
  
   ArrayResize(tradesignals,NumOfSymbols,0);             
               
               
               
               
               
               
               
//initialize LotDigits
 int LotStep =(int) MarketInfo(Symbols[index], MODE_LOTSTEP);
   if(NormalizeDouble(LotStep, 3) == round(LotStep))
     {
      LotDigits = 0;
     }
   else
      if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
        {
         LotDigits = 1;
        }
      else
         if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep))
           {
            LotDigits = 2;
           }
         else
           {
            LotDigits = 3;
           }

 
   if(NormalizeDouble(LotStep, 3) == round(LotStep)){
      LotDigits = 0;}
   else if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
      LotDigits = 1;
   else if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep)){
      LotDigits = 2;}
   else {LotDigits = 3;
     }
     

               //---
  }}

   sendOnce=0;
  
     OnTimer();
//--- set panel corner
   
  
   ThisDayOfYear=DayOfYear();
//--- Calling the function displays the list of enumeration constants in the journal 
//--- (the list is set in the strings 22 and 25 of the DELib.mqh file) for checking the constants validity
 
   MaxSL = MaxSL * myPoint;
   MinSL = MinSL * myPoint;
   MaxTP = MaxTP * myPoint;
   MinTP = MinTP * myPoint;
   
 
   //initialize crossed

   return(INIT_SUCCEEDED);
  }
  
void myAlert(string type, string message1)
  {
   int handle;
   if(type == "print")
      Print(message1);
   else if(type == "error")
     {
      Print(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Audible_Alerts) Alert(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Send_Email) SendMail("TrendsFollowers1", type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      handle = FileOpen("TrendsFollowers1.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
     }
   else if(type == "order")
     {
      Print(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Audible_Alerts) Alert(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Send_Email) SendMail("TrendsFollowers1", type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      handle = FileOpen("TrendsFollowers1.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
     }
   else if(type == "modify")
     {
      Print(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Audible_Alerts) Alert(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      if(Send_Email) SendMail("TrendsFollowers1", type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
      handle = FileOpen("TrendsFollowers1.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | TrendsFollowers1 @ "+Symbol()+","+IntegerToString(Period())+" | "+message1);
     }
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  //--- Remove EA graphical objects by an object name prefix
   ObjectsDeleteAll(0,prefix);
    ObjectsDeleteAll(0,OBJ_VLINE);

   if(!IsTesting())
 
     {
      ObjectsDeleteAll(ChartID(),OBJPFX);

     }
   if(reason==REASON_CLOSE ||
      reason==REASON_PROGRAM ||
      reason==REASON_PARAMETERS ||
      reason==REASON_REMOVE ||
      reason==REASON_RECOMPILE ||
      reason==REASON_ACCOUNT ||
      reason==REASON_INITFAILED)
     {
      time_check=0;
      comments.Destroy();
     }


   ChartRedraw();
//--- destroy timer
   EventKillTimer();


//--- Remove EA graphical objects by an object name prefix

   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  smartBot.GetUpdates();
  smartBot.ForceReply();
  smartBot.ReplyKeyboardMarkup(KEYB_MAIN,0,0);
  //--- Initializing the last events
    int i,jkl;int digits=3;string symbol;
    
    i=MathRand()%NumOfSymbols;
  
    
if(i<NumOfSymbols)

  symbol=TradeScheduleSymbol(i,InpSelectPairs_By_Basket_Schedule);
  
digits=(int) MarketInfo(symbol,MODE_DIGITS);
   //initialize myPoint
   myPoint =(int) MarketInfo(symbol,MODE_POINT);
   if(digits == 5 || digits == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     }
   //initialize LotDigits
   double LotStep = MarketInfo(symbol, MODE_LOTSTEP);
   if(NormalizeDouble(LotStep, 3) == round(LotStep))
      LotDigits = 0;
   else if(NormalizeDouble(10*LotStep, 3) == round(10*LotStep))
      LotDigits = 1;
   else if(NormalizeDouble(100*LotStep, 3) == round(100*LotStep))
      LotDigits = 2;
   else LotDigits = 3;
   
    double test = iHigh(symbol, PERIOD_CURRENT, 0);
      
               double _High = iHigh(symbol, PERIOD_CURRENT, 0);
               double _Low = iLow(symbol, PERIOD_CURRENT, 0);
               double _Close = iClose(symbol, PERIOD_CURRENT, 0);
               //---
              double bid = tick.bid=SymbolInfoDouble(symbol, SYMBOL_BID);
               double ask =tick.ask= SymbolInfoDouble(symbol, SYMBOL_ASK);
               //---
      digits=(int)MarketInfo(symbol,MODE_DIGITS);
 
 
  
     double R3=0,S3=0,S2=0;
    //------ Pivot Points ------
      Rx = (yesterday_high - yesterday_low);
      Px = (yesterday_high + yesterday_low + yesterday_close)/3; //Pivot
     double R1x = Px + (Rx * 0.38);
     double R2x = Px + (Rx * 0.62);
     double R3x = Px + (Rx * 0.99);
    double  S1x = Px - (Rx * 0.38);
    double  S2x = Px - (Rx * 0.62);
     double S3x = Px - (Rx * 0.99);
     
  TradeReport(symbol,sendcontroltrade);
                       
    if(digits == 5 || digits == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     
     }
     ControlTrade(R2x,S2x,yesterday_high,symbol,controlTrade);
 int mainSignal = 0;
    
        tradeData.MagicNumber=MagicNumber;
        tradeData.date=TimeCurrent();
        tradeData.slippage=(int)InpSlippage;
        tradeData.volume=TradeSize(InpMoneyManagement);
        tradeData.stopLoss=InpStopLoss;
        tradeData.takeProfit=InpTakeProfit;

GetSetCoordinates();
     
          //--- stop working in tester
      double Free=AccountFreeMargin();
      double One_Lot=0;
    One_Lot=  MarketInfo( symbol,MODE_MARGINREQUIRED);

      if(One_Lot==NULL){
      
       printf("INSUFFISANT  MARGIN FOR ORDER "+  symbol ); 
       
        }
      else if( (floor(AccountBalance()/Free/(One_Lot*100)/100))<floor(Free/(One_Lot*100))/100)
           {
            Print("NOT ENOUGH MARGING FOR  THIS ORDER "+  symbol);    return;      
         
           }else
         if(TradeSize(InpMoneyManagement)==0){
             MessageBox("Invalid lot size can't be empty\nCheck MoneyManagement parameters!","MoneyManagement",1);
               return ;
       }
        
        
      double prs=0,prb=0;
    



  //News control
      if(CloseBeforNews)
        {
         NewsFilter = True;
        }
      else
        {
         NewsFilter = AvoidNews;
        }

      if(CurrencyOnly)
        {
         NewsSymb ="";
         if(StringLen(NewsSymb)>1)
            str1=NewsSymb;
        }
      else
        {
         str1 =symbol;
        }


      Vtunggal = NewsTunggal;
      Vhigh=NewsHard;
      Vmedium=NewsMedium;
      Vlow=NewsLight;

      MinBefore=BeforeNewsStop;
     MinAfter=AfterNewsStop;
string sf="";
  
      int v2 = (StringLen(symbol)-6);
      if(v2>0)
        {
        sf = StringSubstr(symbol,6,v2);
        }
      postfix=sf;
      TMN=0;
      e_d = expire_date;
      if(CloseBeforNews)
        {
         NewsFilter = True;
        }
      else
        {
         NewsFilter = AvoidNews;
        }

      if(CurrencyOnly)
        {
         NewsSymb ="";
         if(StringLen(NewsSymb)>1)
            str1=NewsSymb;
        }
      else
        {
         str1=symbol;
        }
      Vtunggal = NewsTunggal;
      Vhigh=NewsHard;
      Vmedium=NewsMedium;
      Vlow=NewsLight;

      MinBefore=BeforeNewsStop;
      MinAfter=AfterNewsStop;


      if(v2>0)
        {
         sf = StringSubstr(symbol,6,v2);
        }
         
        
      postfix=sf;
      e_d = expire_date;

      y_offset=offset;
      trade=newsTrade();
      if(trade==false){Comment("NO TRADING NEWS TIME!");}
 //--- Fast check of the account object

//--- Set the number of symbols in SymbolArraySize


smartBot.ChatsTotal();
      if(bid > R3x)
        {
         R3x = 0;
         S3x = R2x;
        }
      if(bid > R2x && bid < R3x)
        {
         R3x = 0;
         S3x = R1x;
        }
      if(bid > R1x && bid < R2x)
        {
         R3x = R3x;
         S3x = Px;
        }
      if(bid > Px && bid < R1x)
        {
         R3x = R2x;
         S3x = S1x;
        }
      if(bid > S1x && bid < Px)
        {
         R3x = R1x;
         S3x = S2x;
        }
      if(bid > S2x && bid < S1x)
        {
         R3x = Px;
         S3x = S3x;
        }
      if(bid > S3x && bid < S2x)
        {
         R3x = S1x;
         S3x = 0;
        }
      if(bid < S3x)
        {
         R3x = S2x;
         S3x = 0;
        }
        
        
        
        
        
        
        
        
   
   if(!IsTesting())
     {
      if(!ChartGetInteger(0,CHART_EVENT_MOUSE_MOVE))
         ChartEventMouseMoveSet(true);
     }
       


      // Calculer les floating profits pour le magic
      for(i=0; i<OrdersTotal(); i++)
        {
         int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
           {
            PB+=OrderProfit()+OrderCommission()+OrderSwap();
           }
         if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
           {
            PS+=OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
   double DailyProfit=P1+PB+PS;

      if(ProfitValue>0 && ((P1+PB+PS)/(AccountEquity()-(P1+PB+PS)))*100 >=ProfitValue && TimeCurrent()<
   (datetime) ( "D'"+(string)Year()+".01."+(string)(Day()+1) +"00:00'"))
        {
         Alert("Daily Target reached. Closed running trades");
         messages="Daily Target reached. Closing running trades.Bot will resume trade tomorow ;";

         smartBot.SendMessage(InpChannel,messages);
         smartBot.SendMessage(InpChatID2,messages);
         CloseAll();
         TargetReachedForDay=ThisDayOfYear;
         MessageBox(messages,"Money Management",MB_OK);
         return ;
    
        }
      else
        {
         for(i=0; i<OrdersTotal(); i++)
           {
            int xx=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(!xx)
               continue;
            if(OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber &&symbol==OrderSymbol())
              {
               TO++;
               TB++;
               PB+=OrderProfit()+OrderCommission()+OrderSwap();
               LTB+=OrderLots();

              
              ClosetradePairs(symbol);
              }
            if(OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
              {
               TO++;
               TS++;
               PS+=OrderProfit()+OrderCommission()+OrderSwap();
               LTS+=OrderLots();
              
              ClosetradePairs(symbol);
              }
           }
         }

   
   ThisDayOfYear=DayOfYear(); 
   
ObjectDelete(ChartID(),"");


 if(AccountBalance()>0)
{
         Persentase1=(P1/AccountBalance())*100;
}
  
  
 if(inpTradeMode==Signal_Only){ //Signal only mode here
     
  //  signalMessage(symbol,);//generate trade signal only
    //drawing news lines events

 }  else  if(inpTradeMode==Manual){//Manual trading  here 
 //Create Buttons pannels;
 

CreatePannel();
CreateClosePanel();
  tradeResponse(symbol);
 }
 
 else  if(inpTradeMode ==AutoTrade){ 
 
    
    if(!time1x){MessageBox("TRADING IS STOP BASE ON YOUR SCHEDULE.\nPLEASE WAIT FOR NEXT TRADE OPENING TIME!\nBOT Will RESUME  AT "+ (string)TOD_From_Hour +":"+ (string)TOD_From_Min,"Time Management",MB_CANCELTRYCONTINUE);comments.Show();
  return;
  
   }//end if time1
 int tickets=-1;
 
 //Auto trading mode here
 
      y_offset = 0;//--- GUI Debugging utils used in GetOpeningSignals,GetClosingSignals

     
 
 // Delete Pending Orders After  Bars
      if(DeletePendingOrder&&PendingOrderExpirationBars>0){DeleteByDuration(PendingOrderExpirationBars);}
        
        
     

  
       
        
   //DISPLAY INFOS
         //---Displayy menu
    
takeprofit=InpTakeProfit;

   if(UsePartialClose) {
      CheckPartialClose();
   }
   if(UseTrailingStop)
     {
      checkTrail();

     }
   if(UseBreakEven)
     {   _funcBE();
     }
     
    
  printf("TRADE STATUS "+(string)trade);

  SetPoint=pointx;
  string prev_symbol=symbol;
 
 
 int tradeNow=1;

 
           
   if( AccountBalance() <minbalance){
  Alert("Your account is below the minimum requierement ,please reload it and try it again\nCurrent minimum is set to "+(string)minbalance); 
   }

      if(CheckStochts261m30(symbol))
        {
         overboversellSymbol[0]=symbol;
        };//overbought and oversold signal
         timelockaction(symbol);
   string prevmessage="";   int count=0;
      if(LongTradingts261M30)
     {   smartBot.SendChatAction(InpChatID2,ACTION_TYPING);

         if(Minute()==30)
      message="\n_______Overbought______ \nSymbol: "+overboversellSymbol[0] +"Period:"+EnumToString(PERIOD_M30);
      count++;
      if(count>1)prevmessage=message;
      if(message==prevmessage) {}
       else
   smartBot.SendMessage(InpChannel,message);
     }
   else
      if(!LongTradingts261M30)
        {   smartBot.SendChatAction(InpChatID2,ACTION_TYPING);
   if(Minute()==30)

         message="\n_______OverSold______ \nsymbol:"+overboversellSymbol[0]  +"Period:"+EnumToString(PERIOD_M30);
      
       count++;
       if(count>1)prevmessage=message;
       if(message==prevmessage) {}
       else
   smartBot.SendMessage(InpChannel,message);
   
       } 
         
    CreateSymbolPanel(ShowTradedSymbols);
      
   TradeReport(symbol,sendcontroltrade);   
  HUD();
  HUD2();
  GUI();

 snr(i);
createFibo();//draw fibo
           
             
   //Close Long Positions, instant signal is tested first
   if( 1==(int)iCustom(symbol,PERIOD_CURRENT,"TrendExpert",0,1)) //Accelerator Oscillator crosses above Accelerator Oscillator
   
     {   
      if(IsTradeAllowed())
         myOrderClose(OP_BUY, 100, "");
      else //not autotrading => only send alert
         myAlert("order", "");
     }
   
   //Close Short Positions, instant signal is tested first
   if(-1==iCustom(symbol,PERIOD_CURRENT,"TrendExpert",1,1)   )
     {   
      if(IsTradeAllowed())
         myOrderClose(OP_SELL, 100, "");
      else //not autotrading => only send alert
         myAlert("order", "");
     }
             jkl=i;
             
            
         
           
            tradeData.Symbol=symbol;
            tradeData.bid=MarketInfo(symbol,MODE_BID); 
             
              tradeData.ask=MarketInfo(symbol,MODE_ASK);  
     
  if((AccountFreeMargin()/2)>0&&time1x&&trade&&(((NewBar()&&iTime(symbol,PERIOD_CURRENT,1) > sendOnce)|| !NewBar()) && TradesCount(OP_SELL)<MaxOpenTrades && ttlsell<MaxOpenTrades 
  &&(   //Open Sell Order

               
          TradeSignal2(i)==-1||-1==iCustom(symbol,PERIOD_CURRENT,"TrendExpert",1,1)
 )
   && TradesCount(OP_SELL)<MaxShortTrades && ((closetype == opposite ) || (closetype != opposite)) && (inpTradeStyle ==SHORT || inpTradeStyle ==BOTH)))
           {
             
             RefreshRates();//REFRESS DATA
               
             double tpx2=NormalizeDouble(MaxTP*SetPoint,(int)digits);
                          sendOnce=iTime(symbol,PERIOD_CURRENT,1); 
          
             
               if (PendingOrderDeletes) tradeData.expiration = TimeCurrent()+(PendingOrderExpirationBars*Period()*60);
               if (PendingOrderDeletes && Period() == 1) tradeData.expiration = TimeCurrent()+(MathMax(PendingOrderExpirationBars,12)*Period()*60);
             
             
               xlimit =NormalizeDouble(MarketInfo(symbol,MODE_ASK)+orderdistance*Point*10,(int)digits);
               xstop =NormalizeDouble(MarketInfo(symbol,MODE_ASK)-orderdistance*Point,(int)digits);
               slimit =NormalizeDouble(xlimit+MaxSL*myPoint,(int)digits);
               sls =NormalizeDouble(xstop+MaxSL*myPoint,(int)digits);
               tplimit =NormalizeDouble(xlimit-MaxTP*myPoint,(int)digits)-(tpx2*TS);
               tpx =NormalizeDouble(xstop+MaxTP*myPoint,(int)digits)+(tpx2*TS);
              if(UseFibo_TP==Yes){
               sls=iLow(symbol,PERIOD_15_MIN,1);
                tpx=iHigh(symbol,PERIOD_15_MIN,1);
                }else{
                
                
                sls=NormalizeDouble(yesterday_low,(int)digits);
                tpx=NormalizeDouble(yesterday_high,(int)digits);
                }
                
              if(TS>0){SubLots=TradeSize(InpMoneyManagement);}
              
            
            tradeData.Symbol=symbol;
              
          
             if(IsTradeAllowed()){
            tradeData.price=tick.bid;
                      tradeData.takeProfit=NormalizeDouble(tick.bid- (tick.bid/100),digits);
                      tradeData.stopLoss=NormalizeDouble(tick.bid+(tick.bid/100),digits);
             
                 switch(Order_Types)
                {
                       
                  case MARKET_ORDERS:
                     signalMessage(symbol,OP_SELL);
                      
                    tradeData.price=tick.bid;
                    tradeData.comment="MARKET SELL ORDER OPEN";
                    tradeData.clrName=clrRed;
                    tradeData.type=OP_SELL;
                        tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
          
                    
                             break;
                  case STOP_ORDERS:
                     
                      tradeData.price=xstop;
                    tradeData.comment="MARKET SELLSTOP ORDER OPEN";
                      signalMessage(symbol,OP_SELLSTOP);
                       tradeData.takeProfit=tpx;
                      tradeData.stopLoss=sls;
                    tradeData.clrName=clrBlue;
                    tradeData.type=OP_SELLSTOP;
                       tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
          
                      break;
                  case LIMIT_ORDERS:
                    
                          tradeData.price=xlimit;
                    tradeData.comment="MARKET SELLLIMIT ORDER OPEN";
                    tradeData.clrName=clrYellow;
                    tradeData.type=OP_SELLLIMIT;  signalMessage(symbol,OP_SELLLIMIT);
                       tradeData.takeProfit=tpx;
                      tradeData.stopLoss=sls;
                     tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
          
                    
                       break;
                  default:
                break;
                }
                
         
              if(tickets<=0)return;  
             }
             else 
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&symbol==OrderSymbol()){ myOrderModifyRel(OrderTicket(),sls,0);
          myOrderModifyRel(OrderTicket(),0,tpx);
 }
      }   
      
         
  
      CloseByDuration(MaxTradeDurationBars * PeriodSeconds());
  DeleteByDuration(PendingOrderExpirationBars * PeriodSeconds());
  DeleteByDistance(DeleteOrderAtDistance * myPoint);
  CloseTradesAtPL(CloseAtPL);
  TrailingStopBE(OP_BUY, Trail_Above * myPoint, 0); //Trailing Stop = go break even
  TrailingStopBE(OP_SELL, Trail_Above * myPoint, 0); //Trailing Stop = go break even
  
   
    
   if((AccountFreeMargin()/2)>0&&time1x&&trade&&(((NewBar()&&iTime(symbol,PERIOD_CURRENT,0) > sendOnce)|| !NewBar())&& TradesCount(OP_BUY)<MaxOpenTrades && TradesCount(OP_BUY)<MaxLongTrades &&(


                      TradeSignal2(i)==1||1==iCustom(symbol,PERIOD_CURRENT,"TrendExpert",1,1)&&TradesCount(OP_BUY) <MaxOpenTrades && ((closetype == opposite ) || (closetype != opposite)) && (inpTradeStyle == LONG || inpTradeStyle == BOTH))))
           { sendOnce = iTime(symbol,PERIOD_CURRENT,0);
      RefreshRates();
        
         
            double tpx2=NormalizeDouble(takeprofit*SetPoint,(int)digits);
         
             
               if (PendingOrderExpirationBars ) tradeData.expiration = TimeCurrent()+(PendingOrderExpirationBars*Period()*60);
               if (PendingOrderDeletes && Period() == 1) tradeData.expiration= TimeCurrent()+(MathMax(PendingOrderExpirationBars,12)*Period()*60);
               xlimit =NormalizeDouble(MarketInfo(symbol,MODE_BID)-orderdistance*SetPoint,(int)digits);
               xstop =NormalizeDouble(MarketInfo(symbol,MODE_BID)+orderdistance*SetPoint,(int)digits);
               slimit =NormalizeDouble(xlimit-MaxSL*SetPoint,(int)digits);
               slstop =NormalizeDouble(xstop-MaxSL*SetPoint,(int)digits);
               tplimit =NormalizeDouble(xlimit+MaxTP*SetPoint,(int)digits)+(tpx2*TB);
               tpstop =NormalizeDouble(xstop+MaxTP*SetPoint,(int)digits)+(tpx2*TB);
               if(UseFibo_TP==Yes ) sls=NormalizeDouble(S2,(int)digits);
               if(UseFibo_TP==Yes ) tpx=NormalizeDouble(R3,(int)digits);
               if(UseFibo_TP==Yes && S3 == 0 ) sls=NormalizeDouble(MarketInfo(symbol,MODE_ASK)-MaxSL*SetPoint,(int)digits);
               if(UseFibo_TP==Yes && R3== 0)  tpx=NormalizeDouble(MarketInfo(symbol,MODE_ASK)+MaxTP*SetPoint,(int)digits)+(tpx2*TB);
            if(TB>0){
            lot=SubLots=TradeSize(InpMoneyManagement);}
            tradesignal[jkl]=1;
           
        
           
                    
                      
                        sls=NormalizeDouble(yesterday_low,(int)digits);
                tpx=NormalizeDouble(yesterday_high,(int)digits);
                      
            tradeData.price=tick.ask;
                     tradeData.takeProfit=NormalizeDouble(tick.ask-(tick.ask/100),digits);
                      tradeData.stopLoss=NormalizeDouble(tick.ask+(tick.ask/100),digits);
           if(IsTradeAllowed()){
     
               switch(Order_Types)
                {
                 case MARKET_ORDERS:
                 
                     
                    tradeData.comment="MARKET BUY ORDER OPEN"; signalMessage(symbol,OP_BUY);
                    tradeData.clrName=clrGreen;
                    tradeData.type=OP_BUY;
                 tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
                  break;
                  case STOP_ORDERS:   
                  tradeData.takeProfit=tpx;
                      tradeData.stopLoss=sls;
                  
                  tradeData.price=xstop;
                    tradeData.comment="MARKET BUYSTOP ORDER OPEN"; signalMessage(symbol,OP_BUYSTOP);
                    tradeData.clrName=clrBrown;
                    tradeData.type=OP_BUYSTOP;
                        tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
          
                      break;
                  case LIMIT_ORDERS:
                     tradeData.takeProfit=tpx;
                      tradeData.stopLoss=sls;
                     
                         tradeData.price=xlimit;
                    tradeData.comment="MARKET BUYLIMIT ORDER OPEN";
                    tradeData.clrName=clrPurple;
                    tradeData.type=OP_BUYLIMIT; signalMessage(symbol,OP_BUYLIMIT);
                        tickets=  OrderSend(symbol,tradeData.type,tradeData.volume,tradeData.price,tradeData.slippage,tradeData.stopLoss,tradeData.takeProfit,tradeData.comment,tradeData.MagicNumber,tradeData.expiration,tradeData.clrName);
          
                  
                      default: 
              
                
        break;
          }
        
              if(tickets<=0)return;  
             }
             else 
      
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&symbol==OrderSymbol()){ myOrderModifyRel(OrderTicket(),sls,0);
          myOrderModifyRel(OrderTicket(),0,tpx);
          tradeResponse(symbol);
 }
       
   }
  
   
     

  
    }//autotrade
   

 }//jkl\
 
   void  signalMessage(string symbol1,int type) //signalmessage return only signal message for channels or chats
  {
  ArrayResize(indicatorsArrayList, NumOfSymbols,0);


string symbol=symbol1;
//avoid multiple messages within 10000 milsec
   bool check=true,trad1=true;
   if(type==OP_SELLLIMIT )
     {

      mytrade="tradePic";
      int count=0;



      tradeReason=StringFormat("\n MATCHED SELL LIMIT SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );

     }
   else
      if(type==OP_BUYLIMIT)
        {
         check=false;



         tradeReason=StringFormat("\nBUY LIMIT  SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );
         mytrade="tradePic";
         int count=0;

        }

      else
         if(type==OP_SELLSTOP)
           {
            check=false;
 


            tradeReason=StringFormat("\nSELL STOP SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );
            mytrade="tradePic";
            int count=0;




           }
         else
            if(type==OP_BUYSTOP)
              {
               check=false;
               mytrade="tradePic";
               int count=0;


               tradeReason=StringFormat("\nBUY STOP SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );
              }

            else
               if(
type==1)
                 {
                  mytrade="tradePic";
                  check=false;
                  int count=0;



 tradeReason=StringFormat("\nMATCHED BUY SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );
                 }
   if(type==-1)
     {
      mytrade="tradePic";
      check=false;
      int count=0;
                                
                                
                  tradeReason=StringFormat("\MATCHED SELL SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                )
                                       ;
                                
                                
                                
     }
   else
      if(check==true)
        {


         trad1=false;
         tradeReason=StringFormat("\nNO MATCHED SIGNALS: %s\n Date :%s \nSymbol:%s\n Stoploss %2.4f  \nTakeprofit %2.4f \n______Reasons_________\n%s\n,%s,\nTF1:%s ,\nShift1:%d,\nsignal1:%s, \n%s,\nTF2:%s,\nShift2:%d,\nsigna2:%s, \n%s,\nTF3:%s,\nShift3:%d ,\nsignal3:%s, \n%s,\nTF4:%s,\nShift4:%d,\n%s \n",
                                           "\xF4E3", (string)TimeCurrent(),symbol, iLow(symbol,PERIOD_CURRENT,0),iHigh(symbol,PERIOD_CURRENT,0),"__",
                                                           (string)indicatorsArrayList[inpInd0],EnumToString(inpTF0),inpShift0, (string)MasterSignal,
                                         (string)indicatorsArrayList[inpInd1],EnumToString(inpTF1),inpShift1,(string)Signal1,
                                (string)indicatorsArrayList[inpInd2],EnumToString(inpTF2),inpShift2,(string)Signal2
                               ,  (string)indicatorsArrayList[inpInd3],EnumToString(inpTF3),inpShift3,(string)Signal3,"-----------------"
                                
                                       );
  smartBot.SendMessage(InpChannel,tradeReason,false,false);


        };

 

  if(trad1==true) smartBot.SendMessage(InpChannel,tradeReason);

   if(trad1==true)smartBot.SendScreenShot(symbol,(ENUM_TIMEFRAMES)InpTimFrame,Template,SendScreenshot);

   
  }
  

  
  //+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
 
 

        smartBot.ProcessMessages();
 
   
smartBot.GetMe();

//-- EnableEventMouseMove
   string status2= "Bot :"+smartBot.Name()+  "Time:"+(string)TimeCurrent()+" Copyright©2022,www.tradeexperts.org";
   ObjectCreate("M5", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("M5",status2,10,"Arial",clrOrange);
   ObjectSet("M5", OBJPROP_CORNER, 2);
   ObjectSet("M5", OBJPROP_XDISTANCE, 500);
   ObjectSet("M5", OBJPROP_YDISTANCE, 0);
   CopyRightlogo();
  }

//+------------------------------------------------------------------+