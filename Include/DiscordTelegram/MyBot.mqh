

 



#include <DiscordTelegram/Comment.mqh>

#include <DiscordTelegram/TradeExpert_Variables.mqh>

#include <DiscordTelegram/Telegram.mqh>
 
#include <DiscordTelegram/Trade.mqh>


#include <DiscordTelegram/Binance.mqh>
#include <DiscordTelegram/createObjects.mqh>
#include <Coinbase.mqh>

#include <DiscordTelegram/News.mqh>

#define  NL "\n"
//https://discord.com/api/v8'
//CLIENT_ID = '332269999912132097'
//CLIENT_SECRET = '937it3ow87i4ery69876wqire'



           CComment comments;

CNews mynews[100];
int NomNews=100; 
//--- Store trade data
TradeData tradeData;
//----------object Ctrade  to trade
CTrade trad;
bool exitchange=false;


//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define SEARCH_URL      "https://search.mql5.com"
//---
#define BUTTON_TOP      "\xF51D"
#define BUTTON_LEFT     "\x25C0"
#define BUTTON_RIGHT    "\x25B6"
//---
#define RADIO_SELECT    "\xF518"
#define RADIO_EMPTY     "\x26AA"
//---
#define CHECK_SELECT    "\xF533"
#define CHECK_EMPTY     "\x25FB"
//---
#define MENU_LANGUAGES  "Languages"
#define MENU_MODULES    "Modules"
//---
#define LANG_EN 0
#define LANG_RU 1
#define LANG_ZH 2
#define LANG_ES 3
#define LANG_DE 4
#define LANG_JA 5
//---
#define MODULE_PROFILES   0x001
#define MODULE_FORUM      0x002
#define MODULE_ARTICLES   0x004
#define MODULE_CODEBASE   0x008
#define MODULE_JOBS       0x010
#define MODULE_DOCS       0x020
#define MODULE_MARKET     0x040
#define MODULE_SIGNALS    0x080
#define MODULE_BLOGS      0x100

//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+


#include <DiscordTelegram/Telegram.mqh>

#include <DiscordTelegram/TradeExpert_Functions.mqh>

//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
{
private:
   ENUM_LANGUAGES    m_lang;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   string            m_template;
   CArrayString      m_templates;

public:
  

   //+------------------------------------------------------------------+
   int               Templates(const string _list)
   {
      m_templates.Clear();
      //--- parsing
      string text=StringTrim(_list);
      if(text=="")
         return(0);

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      amount=fmin(amount,5);

      for(int i=0; i<amount; i++)
      {
         array[i]=StringTrim(array[i]);
         if(array[i]!="")
            m_templates.Add(array[i]);
      }

      return(amount);
   }

   //+------------------------------------------------------------------+
   int               SendScreenShot(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
                                    const string _template=NULL)
   {
      int result=0;

      long chart_id=ChartOpen(_symbol,_period);
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=60;
      while(--wait>0)
      {
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
            break;
         Sleep(500);
      }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(500);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(100);

      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(100);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
         smartBot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=60;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(500);

         //---
         if(FileIsExist(filename))
         {
            string screen_id;
            result=smartBot.SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"???? ????????? '%s' ?? ??????.";
            PrintFormat(mask,filename);
         }
      }

      ChartClose(chart_id);
      return(result);
   }

   //+------------------------------------------------------------------+
   void              ProcessMessages(void)
   {

    for(int i=0; i<m_chats.Total(); i++)
      {
         CCustomChat *chat=new CCustomChat();
        
         chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;
                chat.m_new_one.Compare(chat,1);
            //--- start
            if(text=="/start" || text=="/help")
            {
               chat.m_state=0;
               string msg="The bot works with your trading account:\n";
               msg+="/info - get account information\n";
               msg+="/quotes - get quotes\n";
               msg+="/charts - get chart images\n";

               if(m_lang==LANGUAGE_RU)
               {
                  msg="??? ???????? ? ????? ???????? ??????:\n";
                  msg+="/info - ????????? ?????????? ?? ?????\n";
                  msg+="/quotes - ????????? ?????????\n";
                  msg+="/charts - ????????? ??????\n";
               }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_TOP)
            {
               chat.m_state=0;
               string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"???????? ????? ????";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_BACK)
            {
               if(chat.m_state==31)
               {
                  chat.m_state=3;
                  string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"??????? ???????? ???????????, ???????? 'EURUSD'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               else if(chat.m_state==32)
               {
                  chat.m_state=31;
                  string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"??????? ?????? ???????, ???????? 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  chat.m_state=0;
                  string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"???????? ????? ????";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               }
               continue;
            }

            //---
            if(text=="/info" || text=="Account Info" || text=="??????????")
            {
               chat.m_state=1;
               string currency=AccountInfoString(ACCOUNT_CURRENCY);
               string msg=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Balance":"??????",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Profit":"???????",AccountInfoDouble(ACCOUNT_PROFIT),currency);
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
            }

            //---
            if(text=="/quotes" || text=="Quotes" || text=="?????????")
            {
               chat.m_state=2;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"??????? ???????? ???????????, ???????? 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //---
            if(text=="/charts" || text=="Charts" || text=="???????")
            {
               chat.m_state=3;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"??????? ???????? ???????????, ???????? 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Quotes
            if(chat.m_state==2)
            {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"?????????? '%s' ?? ??????";
               string msg=StringFormat(mask,text);
               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  double open[1]= {0};

                  m_symbol=symbol;
                  //--- upload history
                  for(int k=0; k<3; k++)
                  {
#ifdef __MQL4__
                     double array[][6];
                     ArrayCopyRates(array,symbol,PERIOD_D1);
#endif

                     Sleep(2000);
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                  }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                  {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg=StringFormat("%s: %s %s (%s%%)",symbol,DoubleToString(bid,digits),sign,DoubleToString(percent,2));
                  }
                  else
                  {
                     msg=(m_lang==LANGUAGE_EN)?"No history for ":"??? ??????? ??? "+symbol;
                  }
               }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Charts
            if(chat.m_state==3)
            {

               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  m_symbol=symbol;

                  chat.m_state=31;
                  string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"??????? ?????? ???????, ???????? 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"?????????? '%s' ?? ??????";
                  string msg=StringFormat(mask,text);
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               continue;
            }

            //Charts->Periods
            if(chat.m_state==31)
            {
               bool found=false;
               int total=ArraySize(_periods);
               for(int k=0; k<total; k++)
               {
                  string str_tf=StringSubstr(EnumToString(_periods[k]),7);
                  if(StringCompare(str_tf,text,false)==0)
                  {
                     m_period=_periods[k];
                     found=true;
                     break;
                  }
               }

               if(found)
               {
                  //--- template
                  chat.m_state=32;
                  string str="[[\""+EMOJI_BACK+"\",\""+EMOJI_TOP+"\"]";
                  str+=",[\"None\"]";
                  for(int k=0; k<m_templates.Total(); k++)
                     str+=",[\""+m_templates.At(k)+"\"]";
                  str+="]";

                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"???????? ??????",ReplyKeyboardMarkup(str,false,false));
               }
               else
               {
                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"??????????? ????? ?????? ???????",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               continue;
            }
            //---
            if(chat.m_state==32)
            {
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=SendScreenShot(chat.m_id,m_symbol,m_period,m_template);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
            }
         }
      }
   }
 

//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|

string BotOrdersTotal(bool noPending=true)
{
   int count=0;
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( strBotInt("Total", count) );   
//--- Assert optimize function by checking noPending = false
   if( noPending==false ) return( strBotInt("Total", total) );
   
//--- Assert determine count of all trades that are opened
   for(int i=0;i<total;i++) {
      int go=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
   //--- Assert OrderType is either BUY or SELL
      if( OrderType() <= 1 ) count ++;
   }
   return( strBotInt( "Total", count ) );
}

string BotOrdersTrade(bool noPending=true)
{
   int ticket = -1;
   int count=0;

   const string strPartial="from #";
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( message );   

//--- Assert determine count of all trades that are opened
   for(int i=total-1;i>--total;i--) {
      ticket=OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );

   //--- Assert OrderType is either BUY or SELL if noPending=true
      if( noPending==true && OrderType() > 1 ) continue ;
      else count++;

      message = StringConcatenate(message, strBotInt( "Ticket",OrderTicket() ));
      message = StringConcatenate(message, strBotStr( "Symbol",OrderSymbol() ));
      message = StringConcatenate(message, strBotInt( "Type",OrderType() ));
      message = StringConcatenate(message, strBotDbl( "Lots",OrderLots(),2 ));
      message = StringConcatenate(message, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
      message = StringConcatenate(message, strBotDbl( "CurPrice",OrderClosePrice(),5 ));
      message= StringConcatenate(message, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
      message = StringConcatenate(message, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
      message= StringConcatenate(message, strBotTme( "OpenTime",OrderOpenTime() ));
      message = StringConcatenate(message, strBotTme( "CloseTime",OrderCloseTime() ));
      
   //--- Assert Partial Trade has comment="from #<historyTicket>"
      if( StringFind( OrderComment(), strPartial )>=0 )
         message = StringConcatenate(message, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
      else
         message= StringConcatenate(message, strBotStr( "PrevTicket", "0" ));
   }
//--- Assert msg isnt empty
   if( message=="" ) return( message );   
   
//--- Assert append count of trades
   message = StringConcatenate(strBotInt( "Count",count ), message);
   return( message);
}

string BotOrdersTicket(int tickets, bool noPending=true)
{string gh;

for(int a=OrdersHistoryTotal()-1;a>0;a--){

if(OrderSelect(a,SELECT_BY_POS,MODE_HISTORY)){
 gh=(string)"Ticket: "+(string)OrderTicket()+"  "+ "DATE"+(string) TimeCurrent();
}


};


   return( gh );
}

string BotHistoryTicket(int tickets, bool noPending=true)
{
  
   const string strPartial="from #";
   int total=OrdersHistoryTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( message );   

//--- Assert determine history by ticket
   if( OrderSelect( tickets, SELECT_BY_TICKET, MODE_HISTORY )==false ) return( message );
  
//--- Assert OrderType is either BUY or SELL if noPending=true
   if( noPending==true && OrderType() >=0 ) return( message);
      
//--- Assert OrderTicket is found

   message+= (string)StringConcatenate(message, strBotStr( "Date",(string)TimeCurrent() ));
   message +=  (string)StringConcatenate(message, strBotInt( "Ticket",OrderTicket() ));
   message +=  (string)StringConcatenate(message, strBotStr( "Symbol",OrderSymbol() ));
   message+=  (string)StringConcatenate(message, strBotInt( "Type",OrderType() ));
   message+=  (string)StringConcatenate(message, strBotDbl( "Lots",OrderLots(),2 ));
   message+=  (string)StringConcatenate(message, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
   message+=  (string)StringConcatenate(message, strBotDbl( "ClosePrice",OrderClosePrice(),5 ));
   message+=  (string)StringConcatenate(message, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
   message+= (string) StringConcatenate(message, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
   message+=  (string)StringConcatenate(message, strBotTme( "OpenTime",OrderOpenTime() ));
   message += (string) StringConcatenate(message, strBotTme( "CloseTime",OrderCloseTime() ));
   
//--- Assert Partial Trade has comment="from #<historyTicket>"
   if( StringFind( OrderComment(), strPartial )>=0 )
      message += StringConcatenate(message, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
   else
      message+= StringConcatenate(message, strBotStr( "PrevTicket", "0" ));
      
   return( message);
}

string BotOrdersHistoryTotal(bool noPending=true)
{
   return( strBotInt( "Total", OrdersHistoryTotal() ) );
}


string tradeReport(bool noPending=true){
string  report="None";
for(int j=OrdersHistoryTotal()-1;j>0;j--){
if(OrderSelect(j,SELECT_BY_TICKET,MODE_HISTORY )==false){
if(OrderProfit()>0){
report+="Total Profit : "+ (string)OrderProfit()+ "  "+(string)TimeCurrent() ;


};
if(OrderProfit()<0){
report+="Total Losses: "+ (string)OrderProfit()+"  "+(string)TimeCurrent();


};

};

}

return report;
}

//|-----------------------------------------------------------------------------------------|
//|                               A C C O U N T   S T A T U S                               |
//|-----------------------------------------------------------------------------------------|
string BotAccount(void) 
{


   message= StringConcatenate(message, strBotInt( "Number",AccountNumber() ));
   message = StringConcatenate(message, strBotStr( "Currency",AccountCurrency() ));
   message = StringConcatenate(message, strBotDbl( "Balance",AccountBalance(),2 ));
   message = StringConcatenate(message, strBotDbl( "Equity",AccountEquity(),2 ));
   message = StringConcatenate(message, strBotDbl( "Margin",AccountMargin(),2 ));
   message = StringConcatenate(message, strBotDbl( "FreeMargin",AccountFreeMargin(),2 ));
   message= StringConcatenate(message, strBotDbl( "Profit",AccountProfit(),2 ));
   
   return( message );
}

   //+------------------------------------------------------------------+
   int               SendScreenShot(
                                    const string _symbol,
                                    int _period,
                                    const string _template=NULL,bool SendScreenShots=false)
   {
             
      long chart_id=ChartOpen(_symbol,_period);
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=30;
      while(--wait>0)
      {
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
            break;
         Sleep(30);
      }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(500);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(100);
int result=0;
      if(ChartScreenShot(chart_id,filename,ChartWidth,ChartHigth,ALIGN_RIGHT))
      {
         
         Sleep(200);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
      SendChatAction(InpChatID,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=30;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(30);

         //---
         if(FileIsExist(filename)){
          string screen_id;
              if(InpToChannel==true)result=SendPhoto(screen_id,InpChannel,filename,_symbol+"_@SIGNAL \n"+"\nTimeFrame " +(string)_period);
              if( InpTochat==true) result= SendPhoto(InpChatID2,filename,_symbol+"_@ SIGNAL  \n"+"\nTimeFrame "+(string)_period);

         }
         else
         {
          string mask=m_lang==ENGLISH?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
         }
      }

      ChartClose(chart_id);
      
      
      return(result);
   }
 
      //+------------------------------------------------------------------+
   int               SendPhotoToChat( long   _chat_id,
                               const string _photo_id,
                               const string _caption=NULL)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      
      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%lld&photo=%s",_chat_id,_photo_id);
      if(_caption!=NULL)
         params+="&caption="+UrlEncode(_caption);
      string out="";
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res!=0)
      { CJAVal   item,js(NULL,out);
         //--- parse result
        
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         long err_code=js["error_code"].ToInt();
         string err_desc=js["description"].ToStr();
      }
      //--- done
      return(res);
   }
   
   
   
   
   
   
   

//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
string strBotInt(string key, int val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(NL,key,"=",NormalizeDouble(val,dgt)) );
}
string strBotTme(string key, datetime val)
{
   return( StringConcatenate(NL,key,"=",TimeToString(val)) );
}
string strBotStr(string key, string val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return StringConcatenate(NL,key,"=",valType) ;
}  


bool ChartColorSet()//set chart colors
  {
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,BearCandle);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,BullCandle);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,Bear_Outline);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,Bull_Outline);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,0);
   ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(ChartID(),CHART_MODE,1);
   ChartSetInteger(ChartID(),CHART_SHIFT,1);
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,1);
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,BackGround);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,ForeGround);
   return(true);
   }  
   
   
         void   Language(const ENUM_LANGUAGES _lang)
   {
      m_lang=_lang;
   }
   
  
        
 
   
   
};
    CMyBot smartBot;string message;
   
    
