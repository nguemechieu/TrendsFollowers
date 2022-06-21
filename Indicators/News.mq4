//+------------------------------------------------------------------+
//|                                                         News.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property  copyright "Ѕулагин јндрей"
#property  link      "andre9@ya.ru"
#property indicator_chart_window 
#property indicator_buffers 0 

//----
#import "wininet.dll"
int InternetAttemptConnect (int x);
  int InternetOpenW(string sAgent, int lAccessType, 
                    string sProxyName = "", string sProxyBypass = "", 
                    int lFlags = 0);
  int InternetOpenUrlW(int hInternetSession, string sUrl, 
                       string sHeaders = "", int lHeadersLength = 0,
                       int lFlags = 0, int lContext = 0);
  int InternetReadFile(int hFile, int& sBuffer[], int lNumBytesToRead, 
                       int& lNumberOfBytesRead[]);
  int InternetCloseHandle(int hInet);
#import

extern bool lines    = true;        // показывать вертикальные линии в моменты выхода новостей
extern bool texts    = true;        // показывать текстовые надписи с описани€ми новостей
extern bool comments = true;        // показывать список ближайших будущих и прошедших новостей
extern int total_in_list = 10;      // количество новостей в списке

extern bool high     = true;        // показывать важные новости
extern bool medium   = true;        // показывать новости средней важности
extern bool low      = true;        // показывать новости малой важности

extern int update = 15;             // обновл€ть список новостей каждые 15 минут

extern bool auto = true;            // авто-выбор новостей, подход€щих дл€ валютной пары графика
extern bool eur = true;             // показывать новости дл€ определенных валют
extern bool usd = true;
extern bool jpy = true;
extern bool gbp = true;
extern bool chf = true;
extern bool cad = true;
extern bool aud = true;
extern bool nzd = true;

extern color high_color    = Maroon;         // цвет важных новостей
extern color medium_color  = Sienna;         // цвет обычных новостей
extern color low_color     = DarkSlateGray;  // цвет незначительных новостей

extern bool russian = true;         // использовать файл перевода дл€ руссификации новостей

extern int server_timezone = 2;     // часовой по€с сервера (Alpary - GMT+2)
extern int show_timezone   = 4;     // показывать врем€ дл€ часового по€са (ћосква - GMT+4)

extern bool alerts = true;          // предупреждать о выходе новостей звуковыми сигналами
extern int  alert_before = 5;       // предупреждать за 5 минут до выхода новостей
extern int  alert_every  = 30;      // звуковые сигналы каждые 30 секунд

// -----------------------------------------------------------------------------------------------------------------------------
int TotalNews = 0;
string News[1000][10];
datetime LastUpdate = 0;
int NextNewsLine = 0;
int LastAlert = 0;
string Translate[1000][2];
int TotalTranslate = 0;

// -----------------------------------------------------------------------------------------------------------------------------
int init() 
{ 
   if(auto) // авто-выбор новостей, подход€щих дл€ текущей валютной пары
   {
      string sym = Symbol();
      if(StringFind(sym, "EUR") != -1) eur = true; else eur = false;
      if(StringFind(sym, "USD") != -1) usd = true; else usd = false;
      if(StringFind(sym, "JPY") != -1) jpy = true; else jpy = false;
      if(StringFind(sym, "GBP") != -1) gbp = true; else gbp = false;
      if(StringFind(sym, "CHF") != -1) chf = true; else chf = false;
      if(StringFind(sym, "CAD") != -1) cad = true; else cad = false;
      if(StringFind(sym, "AUD") != -1) aud = true; else aud = false;
      if(StringFind(sym, "NZD") != -1) nzd = true; else nzd = false;
   }
      
   if(russian) // подготовка шаблонов перевода новостей
   {
      int fhandle = FileOpen("translate.txt", FILE_READ);
      if(fhandle>0)
      {
         int i = 0;
         while(!FileIsEnding(fhandle))
         {
            string str = FileReadString(fhandle);
            if(str == "") break;
            Translate[i][0] = str;
            Translate[i][1] = FileReadString(fhandle);
            if(Translate[i][1] == "") Translate[i][1] = Translate[i][0];
            i++;
         }
         TotalTranslate = i;
         FileClose(fhandle);
      }
   }
   
   return(0); 
} 

// -----------------------------------------------------------------------------------------------------------------------------
int deinit() 
{ 
   for(int i=0; i<TotalNews; i++)
   {
      ObjectDelete("News Line "+i);
      ObjectDelete("News Text "+i);
   }   
   
   return(0); 
} 

// -----------------------------------------------------------------------------------------------------------------------------
int start()
{
   string Filter1 = "";
   if(!eur) Filter1 = Filter1 + "EUR|";
   if(!usd) Filter1 = Filter1 + "USD|";
   if(!jpy) Filter1 = Filter1 + "JPY|";
   if(!gbp) Filter1 = Filter1 + "GBP|";
   if(!chf) Filter1 = Filter1 + "CHF|";
   if(!cad) Filter1 = Filter1 + "CAD|";
   if(!aud) Filter1 = Filter1 + "AUD|";
   if(!nzd) Filter1 = Filter1 + "NZD|";
   
   string Filter2 = "";
   if(!high)   Filter2 = Filter2 + "High|";
   if(!medium) Filter2 = Filter2 + "Medium|";
   if(!low)    Filter2 = Filter2 + "Low|";
   
   datetime time = TimeCurrent();
   if(time >= LastUpdate+update*60)    // обновление списка новостей
   {
      for(int i=0; i<TotalNews; i++)
      {
         ObjectDelete("News Line "+i);
         ObjectDelete("News Text "+i);
      }   
      
      LastUpdate = time;
      string str = ReadWebPage("http://www.dailyfx.com/calendar/Dailyfx_Global_Economic_Calendar.csv?direction=none&collector=allInFolderDateDesc&view=week&timezone=GMT&currencyFilter="+Filter1+"&importanceFilter="+Filter2+"&time="+time);

      if(str == "") return(0);
      int pos = StringFind(str,"\r\n\r\n\r\n");
      str = StringTrimRight(StringTrimLeft(StringSubstr(str,pos+6)));
      
      
      string arr[1000];
      TotalNews = Explode(str, "\r\n\r\n\r\n", arr);
      for( i=0; i<TotalNews; i++)
      {      
         string arr1[10];
         Explode(arr[i], ",", arr1);
         for( int j=0; j<10; j++ )
            News[i][j] = arr1[j];
         string tmp[3], tmp1[2];    
         Explode(News[i][0], " ", tmp);
         int mon = 0;
         if(tmp[1]=="Jan") mon=1; else 
         if(tmp[1]=="Feb") mon=2; else 
         if(tmp[1]=="Mar") mon=3; else 
         if(tmp[1]=="Apr") mon=4; else 
         if(tmp[1]=="May") mon=5; else 
         if(tmp[1]=="Jun") mon=6; else 
         if(tmp[1]=="Jul") mon=7; else
         if(tmp[1]=="Aug") mon=8; else
         if(tmp[1]=="Sep") mon=9; else
         if(tmp[1]=="Oct") mon=10; else
         if(tmp[1]=="Nov") mon=11; else
         if(tmp[1]=="Dec") mon=12;
         News[i][0] = Year()+"."+mon+"."+tmp[2];
         
         Explode(News[i][1], " ", tmp);
         bool pm = tmp[1]=="PM";
         Explode(tmp[0], ":", tmp1);
         tmp1[0] = StrToInteger(tmp1[0])%12;
         if(pm) tmp1[0] = StrToInteger(tmp1[0])+12;
         News[i][1] = tmp1[0]+":"+tmp1[1];
         
         datetime dt = StrToTime(News[i][0]+" "+News[i][1]);
         News[i][0] = TimeToStr(dt + server_timezone*60*60, TIME_DATE);
         News[i][1] = TimeToStr(dt + server_timezone*60*60, TIME_MINUTES);
         News[i][9] = TimeToStr(dt + show_timezone*60*60, TIME_MINUTES);
         
         if(russian)
         {
            for(j=0; j<TotalTranslate; j++)
            {
               pos = StringFind(News[i][4], Translate[j][0]);
               if(pos != -1) News[i][4] = StringSubstr(News[i][4], 0, pos) + Translate[j][1] + StringSubstr(News[i][4], pos+StringLen(Translate[j][0]));
            }
         }
         
      }

      datetime current = 0;
      for( i=0; i<TotalNews; i++) // создание линий и надписей новостей на графике
      {      
         if(StrToTime(News[i][0]+" "+News[i][1]) == current) continue;
         current = StrToTime(News[i][0]+" "+News[i][1]);
         color clr;
         if(News[i][5] == "Low")    clr = low_color;     else
         if(News[i][5] == "Medium") clr = medium_color;  else
         if(News[i][5] == "High")   clr = high_color;
         
         string text = "";
         if(News[i][8] != "" || News[i][7] != "") text = "[" + News[i][8] + ", " + News[i][7] + "]";
         if(News[i][6] != "") text = text + " " + News[i][6];
         
         if(lines)
         {
            ObjectCreate("News Line "+i, OBJ_VLINE, 0, current, 0);
            ObjectSet("News Line "+i, OBJPROP_COLOR, clr);
            ObjectSet("News Line "+i, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            ObjectSet("News Line "+i, OBJPROP_BACK, true);          
            ObjectSetText("News Line "+i, News[i][9] + " " + News[i][4] + " " + text, 8);         
         }
         
         if (texts)
         {
            ObjectCreate("News Text "+i, OBJ_TEXT, 0, current, WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())*0.8 );
            ObjectSet("News Text "+i, OBJPROP_COLOR, clr);
            ObjectSet("News Text "+i, OBJPROP_ANGLE, 90);
            ObjectSetText("News Text "+i, News[i][9] + " " + News[i][4] + " " + text, 8);
         }
         
         
      }                
      
      for(i=0; i<TotalNews; i++)
         if(StrToTime(News[i][0]+" "+News[i][1]) > time) break;
      NextNewsLine = i;
      LastAlert = 0;

      if(comments) // создание списка новостей на графике
      {
         int start = 0;
         if(NextNewsLine >= 5) start = NextNewsLine - 5;
         string com = "";
         for(i=start; i<start+total_in_list && i<TotalNews; i++)
         {
            text = "";
            if(News[i][8] != "" || News[i][7] != "") text = "[" + News[i][8] + ", " + News[i][7] + "]";
            if(News[i][6] != "") text = text + " " + News[i][6];
            com = com + News[i][9] + " " + StringSubstr(News[i][5], 0, 1) + " " + News[i][4] + " " + text + "\n";
         }
         Comment(com);   
      }   
   } // конец обновлени€ списка новостей
   
   datetime next_time = StrToTime(News[NextNewsLine][0]+" "+News[NextNewsLine][1]);
   if(time >= next_time) // вышла следующа€ новость
   {
      LastUpdate = time - update*60 + 60;  // обновить список новостей через минуту после выхода очередной новости
      for(i=0; i<TotalNews; i++)
         if(StrToTime(News[i][0]+" "+News[i][1]) > time) break;
      NextNewsLine = i;

      LastAlert = 0;
      if(comments)
      {
         start = 0;
         if(NextNewsLine >= 5) start = NextNewsLine - 5;
         com = "";
         for(i=start; i<start+10 && i<TotalNews; i++)
         {
            text = "";
            if(News[i][8] != "" || News[i][7] != "") text = "[" + News[i][8] + ", " + News[i][7] + "]";
            if(News[i][6] != "") text = text + " " + News[i][6];
            com = com + News[i][9] + " " + StringSubstr(News[i][5], 0, 1) + " " + News[i][4] + " " + text + "\n";
         }
         Comment(com);   
      }   
   }

   next_time = StrToTime(News[NextNewsLine][0]+" "+News[NextNewsLine][1]);
   if(time >= next_time - alert_before*60) // скоро выйдет следующа€ новость
   {
      if(time >= LastAlert + alert_every)
      {
         if(alerts) PlaySound("alert.wav");
         Print("—ледующа€ новость выйдет через " + (((next_time-time)-(next_time-time)%60)/60) + " минут(ы) " + ((next_time-time)%60) + " секунд(ы).");
         LastAlert = time;
      }
   }

   
   return(0);
}

// -----------------------------------------------------------------------------------------------------------------------------
int Explode(string str, string delimiter, string& arr[])
{
   int i = 0;
   int pos = StringFind(str, delimiter);
   while(pos != -1)
   {
      if(pos == 0) arr[i] = ""; else arr[i] = StringSubstr(str, 0, pos);
      i++;
      str = StringSubstr(str, pos+StringLen(delimiter));
      pos = StringFind(str, delimiter);
      if(pos == -1 || str == "") break;
   }
   arr[i] = str;

   return(i+1);
}

// -----------------------------------------------------------------------------------------------------------------------------
string ReadWebPage(string url)
{
   if(!IsDllsAllowed())
   {
      Alert("Ќеобходимо в настройках разрешить использование DLL");
      return("");
   }
   int rv = InternetAttemptConnect(0);
   if(rv != 0)
   {
      Alert("ќшибка при вызове InternetAttemptConnect()");
      return("");
   }
   int hInternetSession = InternetOpenW("Microsoft Internet Explorer", 
                                        0, "", "", 0);
   if(hInternetSession <= 0)
     {
       Alert("ќшибка при вызове InternetOpenW()");
       return("");         
     }
   int hURL = InternetOpenUrlW(hInternetSession, 
              url, "", 0, 0, 0);
   if(hURL <= 0)
     {
       Alert("ќшибка при вызове InternetOpenUrlW()");
       InternetCloseHandle(hInternetSession);
       return(0);         
     }      
   int cBuffer[256];
   int dwBytesRead[1]; 
   string TXT = "";
   while(!IsStopped())
   {
      for(int i = 0; i<256; i++) cBuffer[i] = 0;
      bool bResult = InternetReadFile(hURL, cBuffer, 1024, dwBytesRead);
      if(dwBytesRead[0] == 0) break;
      string text = "";   
      for(i = 0; i < 256; i++)
      {
         text = text + CharToStr(cBuffer[i] & 0x000000FF);
         if(StringLen(text) == dwBytesRead[0]) break;
         text = text + CharToStr(cBuffer[i] >> 8 & 0x000000FF);
         if(StringLen(text) == dwBytesRead[0]) break;
         text = text + CharToStr(cBuffer[i] >> 16 & 0x000000FF);
         if(StringLen(text) == dwBytesRead[0]) break;
         text = text + CharToStr(cBuffer[i] >> 24 & 0x000000FF);
      }
      TXT = TXT + text;
      Sleep(1);
   }
   if(TXT == "") Alert("Ќет считанных данных");
   InternetCloseHandle(hInternetSession);
   
   return(TXT);
}

// -----------------------------------------------------------------------------------------------------------------------------

