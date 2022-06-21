//+------------------------------------------------------------------+
//|                                TradeExpert_Indicator_V3_2021.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Noel Martial Nguemechieu ."
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 5

#property indicator_color1 clrGold		// buy sig.
#property indicator_color2 clrRed// sell sig.
#property indicator_color3 clrBlue		// buy exit sig.
#property indicator_color4 clrYellow// sell exit sig.
#property indicator_color5 clrViolet	// SL values
#property description "RISK DISCLAIMER : Investing involves risks. Any decision to invest in either real estate or stock markets is a personal decision that should be made after thorough research, including an assessment of your personal risk tolerance and your personal financial condition and goals. Results are based on market conditions and on each personal and the action they take and the time and effort they put in"

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <DoEasy/LicenseControl/License.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


// EXTERN variables

// MA

extern const string  s="";//_______________________Properties_______________________;
extern string License="Noelm307#";//License";



input string Username=" Enter your username";//Username

input string Password=" Enter your password";//Password




extern int MAFastBars 	= 10;// MAFastBars 
extern int MAFastType 	= MODE_EMA;//MAFastType
extern int MAFastPrice 	= PRICE_WEIGHTED;// MAFastPrice
extern int MASlowBars 	= 30;// MASlowBars 
extern int MASlowType 	= MODE_SMMA;//MASlowType
extern int MASlowPrice 	= PRICE_WEIGHTED;		//MASlowPrice 

// SL (Chandelier)

extern int ChandBars 		= 7;				
extern double ChandATRFact = 2.0;	

extern double RiskPercent 	= 2.0;	//Risk_Percentage for lot calculation according to the SL (for manual trading info)
extern int Offset				= 10;		// offset for arrows in pips
extern int BarsBack 			= 2000;//SetBarsBack 
extern color InfoColor		= Snow;//SetInfoColor

extern string AlertSound = "alert.wav";//Select Alert Sound

extern bool UseSoundAlert = true;//SetSoundAlert
extern bool UsePopupAlert = true;//SetPopupAlert
extern bool WriteToLog = false;//SetWriteToLog


// CONSTs

#define	TRADE_BUY					1
#define	TRADE_SELL					-1
#define	TRADE_NO_SIGNAL			0
#define	TRADE_EXIT_BUY				5
#define	TRADE_EXIT_SELL			-5

// BUFFERs

double dBufBuy[], dBufSell[], dBufExitBuy[], dBufExitSell[], dBufSL[];

// GLOBALNE variables

string	IndName = "TradeExpert2021";
string	ObjPref = "TradeExpertInd_1";					// prefix for this indicator's objects

bool	BuyActive = false, SellActive = false;
double StartPrice, StartSpread;
datetime StartTime;								
bool FirstDisplay = false;

double MinSLDistance = 0.0;

// utils

int LogHandle;
double dblPoint;
int iDigits;
double offset=0;

bool EABlocked=false;

datetime allowed_until = D'2023.10.07 00:00';    

const datetime initDate=D'2021.10.03 00:00';     
datetime endDate =allowed_until ;

string generatedLicense[100]={"Trial Mode","Noel307#","3456noel","845677654"};

string licenseState(){

string answer="";
if(initDate<endDate && License==generatedLicense[0]){
  answer="Trial Mode";
}else if(License==generatedLicense[1] && initDate <endDate){
  answer="Limited";
}else if(License==generatedLicense[2] ){
answer="Unlimited";
}else if(endDate==TimeCurrent() &&( License==generatedLicense[1] ||License==generatedLicense[0])){
answer= "Expired";
}else{answer="Invalid";
}

return answer;
}



bool  ExpertStatus(){ 
 if((licenseState()=="Actif" ||  licenseState()=="Trial Mode"  || licenseState()=="Limited") && initDate<endDate){return true;}
 
  return false;
 };
//-----------------------------------------------------------------------------
// INIT
//-----------------------------------------------------------------------------

int init()
{//Unlock EA
 Comment("Time :"+(string)TimeDay(TimeCurrent()));
 
  CLicense *mylicense;
 mylicense.m_Write(AccountInfoString(ACCOUNT_NAME),AccountServer());
 mylicense.m_Count=6;
 

 
   if( ExpertStatus()==true){
   Comment("\n@TradeExpert :"+"Init dateTime :" + (string)initDate + "\nLicenseState :" + licenseState()+"\nExpiration date:"+(string)endDate);
//acc number
	SetIndexBuffer    (0, dBufBuy);
	SetIndexEmptyValue(0, 0.0);
	SetIndexStyle     (0, DRAW_ARROW);
	SetIndexArrow     (0, 233);					// full arrow up	
	SetIndexLabel		(0, " BUY");
	
	SetIndexBuffer    (1, dBufSell);
	SetIndexEmptyValue(1, 0.0);
	SetIndexStyle     (1, DRAW_ARROW);
	SetIndexArrow     (1, 234);					// full arrow down	
	SetIndexLabel		(1, " SELL");
 
	SetIndexBuffer    (2, dBufExitBuy);
	SetIndexEmptyValue(2, 0.0);
	SetIndexStyle     (2, DRAW_ARROW);
	SetIndexArrow     (2, 251);					// cross	
	SetIndexLabel		(2, " BUY EXIT");

	SetIndexBuffer    (3, dBufExitSell);
	SetIndexEmptyValue(3, 0.0);
	SetIndexStyle     (3, DRAW_ARROW);
	SetIndexArrow     (3, 251);					// cross	
	SetIndexLabel		(3, "SELL EXIT");
	
	SetIndexBuffer    (4, dBufSL);
	SetIndexEmptyValue(4, 0.0);
	SetIndexStyle     (4, DRAW_LINE, STYLE_DASH);
	SetIndexLabel		(4, "SL");
	 
	IndicatorShortName(IndName);
 
	RemoveObjects(ObjPref);	
	WindowRedraw();

	LogOpen();
	LogWrite(0, "Log for: " + IndName);
	LogWrite(0, "Pair: " + Symbol()+", period: "+(string)Period());
	LogWrite(0, "\n");	
	
	GetPoint();	
	
	Offset*=(int)dblPoint;

	if (MarketInfo(NULL, MODE_STOPLEVEL) > 0)
	{
		MinSLDistance = MarketInfo(NULL, MODE_STOPLEVEL);	// min. SL distance
		MinSLDistance /= dblPoint/Point;							// in pips

		LogWrite(0, "Min. SL distance (in pips): " + (string)MinSLDistance);
	}
   //--- Hide the OneClick panel
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);
   
   }else {
   
   Comment("_____________No TRADING SIGNAL____________\nLICENSE STATE:  "+licenseState()+"\nInvalid license !\nNo Trade signal can be generated by this bot now.\nPlease contact support  at email: nnoelmartial@yahoo.fr to get a new license.Thanks you!");
   }
	return(0);
}


//-----------------------------------------------------------------------------
// DEINIT
//-----------------------------------------------------------------------------

int deinit()
{
	RemoveObjects(ObjPref);	
	WindowRedraw();

	LogWrite(0, "END log");
	LogClose();

	return(0);
}


//-----------------------------------------------------------------------------
// DisplayInfo
//-----------------------------------------------------------------------------

void DisplayInfo(int BNum)
{
	int StartY, StartX, Distance, FSize, Row;
	string FName;
	color FColor;
	double Pips, Lots, LotsRisk;
	int StartBar;
	bool TradeActive = false;
	string Printout="";

	StartY = 100; Distance = 20;
	FSize = 10;
	StartX = 1300; 
	DrawFixedLbl(ObjPref + "Title", "TradeExpert Signal", 1, StartX, StartY,
				 		FSize, FName, clrAliceBlue, false);
				 		

	

	
		StartX = 1300; StartY =60;
	FName = "Arial"; FColor = clrCoral; FSize = 11;
	


	TradeActive = BuyActive || SellActive;
	Row=0;


	// trade type
	if (BuyActive) Printout = "Buy";
	else if (SellActive) Printout = "Sell";
	else Printout = "---";
	Row=5;
	DrawFixedLbl(ObjPref + "L_Trade", "Trade: " + Printout, 1, StartX, StartY + Row*Distance,
				 		FSize, FName, FColor, false);
	
	Row++;
	
	// start price
	if (TradeActive)
		Printout = DoubleToStr(StartPrice, iDigits);
	else
		Printout = "---";	
	DrawFixedLbl(ObjPref + "StartP", "Entry Price: " + Printout, 1, StartX, StartY + Row*Distance,
				 		FSize, FName, clrGreen, false);
	Row++;	
	
	// current SL
	if (TradeActive)
		Printout = DoubleToStr(dBufSL[BNum], iDigits);
	else
		Printout = "---";	
	DrawFixedLbl(ObjPref + "SL", "Current SL: " + Printout, 1, StartX, StartY + Row*Distance,
				 		FSize, FName, clrRed, false);
	Row++;	

	// current spread
	Printout = DoubleToStr((Ask-Bid)/dblPoint, 1);
	DrawFixedLbl(ObjPref + "Spread", "Current spread: " + Printout, 1, StartX, StartY + Row*Distance,
				 		FSize, FName, clrAliceBlue, false);
	Row++;	
	
	// lots according to risk
	if (TradeActive)
	{Row=0;Pips=0;
		StartBar = iBarShift(NULL, 0, StartTime);

		Lots = (dblPoint / MarketInfo(Symbol(), MODE_TICKSIZE)) * MarketInfo(Symbol(), MODE_TICKVALUE);
		if (BuyActive)
			Pips = (Open[StartBar] - dBufSL[StartBar])/dblPoint + StartSpread/dblPoint;	// buy SL is at Bid, so we have to add spread
		else if (SellActive)
			Pips = (dBufSL[StartBar] - Open[StartBar])/dblPoint;									// sell SL is at Ask, so spread is included here

		LotsRisk = (AccountFreeMargin() * (RiskPercent/100.0)) / Lots / Pips;
		Printout = DoubleToStr(LotsRisk, 1);
	}
	else
		Printout = "---";
		
	DrawFixedLbl(ObjPref + "L_Lots", DoubleToStr(RiskPercent, 1) + " %Risk Per SL in lots  : " + Printout, 1, StartX, StartY + Row*Distance,
				 		FSize, FName, FColor, false);
				 	
				 	


}


//-----------------------------------------------------------------------------
// TradeSignal
// checks conditions for the trade
//-----------------------------------------------------------------------------

int TradeSignal(int BarNum)
{
	int FResult = TRADE_NO_SIGNAL;
	double MAF0, MAF1, MAS0, MAS1;
	double MA2M;
//	double ATRVal;
//double BarLength0;


	LogWrite(BarNum, "--- TradeSignal");	
		 
	MAF0 = iMA(NULL, 0, MAFastBars, 0, MAFastType, MAFastPrice, BarNum);
	MAF1 = iMA(NULL, 0, MAFastBars, 0, MAFastType, MAFastPrice, BarNum+1);
	MAS0 = iMA(NULL, 0, MASlowBars, 0, MASlowType, MASlowPrice, BarNum);
	MAS1 = iMA(NULL, 0, MASlowBars, 0, MASlowType, MASlowPrice, BarNum+1);

	MA2M = iMA(NULL, 0, 2, 0, MODE_EMA, PRICE_TYPICAL, BarNum);
	
	// conditions for BUY	(EMA2 is above fast EMA and slow SMMA, fast EMA is below slow SMMA 
	//								 and they are coming together or fast EMA is above slow SMMA and they are separating; last two bars should not be bearish)
	
	if ( 
			!(Close[BarNum] < Open[BarNum] && Close[BarNum+1] <= Open[BarNum+1])
		&& MA2M > MAF0
		&& MA2M > MAS0
		&& (	(MAF0 > MAS0 && MathAbs(MAF0 - MAS0) > MathAbs(MAF1 - MAS1))
			|| (MAF0 < MAS0 && MathAbs(MAF0 - MAS0) < MathAbs(MAF1 - MAS1)) )		
		)
	{
		LogWrite(BarNum, "BUY Conditions");
		FResult = TRADE_BUY;
	}
	
	// conditions for SELL	(EMA2 is below fast EMA and slow SMMA, fast EMA is above slow SMMA 
	//								 and they are coming together or fast EMA is below slow SMMA and they are separating; last two bars should not be bullish)
	
	if (
			!(Close[BarNum] > Open[BarNum] && Close[BarNum+1] >= Open[BarNum+1])	
		&&	MA2M < MAF0
		&& MA2M < MAS0
		&& (	(MAF0 < MAS0 && MathAbs(MAF0 - MAS0) > MathAbs(MAF1 - MAS1))
			|| (MAF0 > MAS0 && MathAbs(MAF0 - MAS0) < MathAbs(MAF1 - MAS1)) )
		)
	{
		LogWrite(BarNum, "SELL Conditions");		
		FResult = TRADE_SELL;
	}	
	
	return(FResult);
}


//-----------------------------------------------------------------------------

// simulates hitting a SL
//-----------------------------------------------------------------------------

void SimSLHit(int BarNum)
{
	bool CrossedSL = false;
	double CorrectedSL=0;

	
	if (!(BuyActive || SellActive))
		return;

	LogWrite(BarNum, "-----  SimSLHit");

	// if trade is buy, SL is hit at Bid price; if it's sell, SL is hit at Ask price
	if (BuyActive)
		CorrectedSL = dBufSL[BarNum];
	else if (SellActive)
		CorrectedSL = dBufSL[BarNum] - StartSpread;

	// has price hit SL at this candle?
	CrossedSL = (  (High[BarNum] >= CorrectedSL
					 && Low[BarNum] <= CorrectedSL)
					 || (BuyActive && High[BarNum] <= CorrectedSL)			// when price jumps below SL
					 || (SellActive && Low[BarNum] >= CorrectedSL) );		// when price jumps above SL

	dBufExitBuy[BarNum] = 0.0;
	dBufExitSell[BarNum] = 0.0;

	if (!CrossedSL)
		return;

	// if SL was hit
	if (BuyActive)
	{
		BuyActive = false;
		dBufExitBuy[BarNum] = dBufSL[BarNum];		// for buys mark exit at Bid price (at visual SL and as in backtester)
	
		// alert if current bar
		if (BarNum == 0)
			ProcessAlert("Exit from buy");
	}
	else if (SellActive)
	{
		SellActive = false;
		dBufExitSell[BarNum] = dBufSL[BarNum];		// for sells mark exit at Ask price (at visual SL and as in backtester)
		
		// alert if current bar
		if (BarNum == 0)
			ProcessAlert("Exit from sell");
	}			

	LogWrite(BarNum, "Hit SL at: " + (string)dBufSL[BarNum]);
	
	
 
}





















//-----------------------------------------------------------------------------
// ExitManagement
// checks exit conditions
//-----------------------------------------------------------------------------

void ExitManagement(int BarNum)
{
	int ExitSig = TRADE_NO_SIGNAL,
		 TradeSig = TRADE_NO_SIGNAL;
	double MAF0, MAF1, MAS0, MAS1, MA2M;
	
	
	if ( !(BuyActive || SellActive) || BarNum == 0 )	// for complete bars only
		return;
	
	LogWrite(BarNum, "-----  ExitManagement");

	// new trade conditions?
	TradeSig = TradeSignal(BarNum);
	LogWrite(BarNum, "Trade signal: " + (string)TradeSig);

	MAF0 = iMA(NULL, 0, MAFastBars, 0, MAFastType, MAFastPrice, BarNum);
	MAF1 = iMA(NULL, 0, MAFastBars, 0, MAFastType, MAFastPrice, BarNum+1);
	MAS0 = iMA(NULL, 0, MASlowBars, 0, MASlowType, MASlowPrice, BarNum);
	MAS1 = iMA(NULL, 0, MASlowBars, 0, MASlowType, MASlowPrice, BarNum+1);	
	MA2M = iMA(NULL, 0, 2, 0, MODE_EMA, PRICE_TYPICAL, BarNum);


	dBufExitBuy[BarNum] = 0.0;
	dBufExitSell[BarNum] = 0.0;

	// exit from BUY
	if (	BuyActive
			&& (	TradeSig == TRADE_SELL			// new sell signal
				|| MA2M < MAS0 ) 						// or EMA2 crossed slow SMMA down
		)
	{		
		BuyActive = false;
		dBufExitBuy[BarNum] = Close[BarNum];	// for buys mark exit at Bid (visual) price
		
		if (TradeSig == TRADE_SELL)
			LogWrite(BarNum, "Exit because of sell signal: " + (string)dBufExitBuy[BarNum]);
		else
			LogWrite(BarNum, "Exit because of EMA2 crossed slow SMMA down: " + (string)dBufExitBuy[BarNum]);
	}		
	// exit from SELL
	else if (	SellActive 
				&& (	TradeSig == TRADE_BUY		// new buy signal
					|| MA2M > MAS0 ) 					// or EMA2 crossed slow SMMA up
				)
	{
		SellActive = false;
		dBufExitSell[BarNum] = Close[BarNum]+StartSpread;	// for sells mark exit at Ask price
		
		if (TradeSig == TRADE_BUY)
			LogWrite(BarNum, "Exit because of buy signal: " + (string)dBufExitSell[BarNum]);
		else
			LogWrite(BarNum, "Exit because EMA2 crossed slow SMMA up: " + (string)dBufExitSell[BarNum]);
	}
}


//-----------------------------------------------------------------------------
// NewTradeManagement
//-----------------------------------------------------------------------------

void NewTradeManagement(int BarNum)
{
	int TradeSig = TRADE_NO_SIGNAL;

	if (SellActive || BuyActive)
		return;

	LogWrite(BarNum, "-----  New Trade Management");
	
	TradeSig = TradeSignal(BarNum);

	dBufBuy[BarNum] = 0.0;
	dBufSell[BarNum] = 0.0;
					
	// if signal for SELL
	if (TradeSig == TRADE_SELL)
	{
		dBufSell[BarNum] = High[BarNum] + offset;
		LogWrite(BarNum, "SELL arrow");
		
		// for history bars
		if (BarNum > 0)
		{		
		   SellActive = true;
			StartSpread = (Ask-Bid);			// current spread
			StartPrice = Open[BarNum-1];		// sells are open at Bid price
			StartTime = Time[BarNum-1];
			LogWrite(BarNum, "Sell Active: true, Start Price: " + (string)StartPrice + ", Start Time: " + TimeToStr(StartTime, TIME_DATE | TIME_SECONDS) +
								", Start Spread: " + (string)StartSpread);
		}	
	}
	
	// if signal for BUY
	else if (TradeSig == TRADE_BUY)
	{
		dBufBuy[BarNum] = Low[BarNum] - offset;
		LogWrite(BarNum, "BUY arrow");

		// for history bars		
		if (BarNum > 0)
		{								
		   BuyActive = true;
			StartSpread = (Ask-Bid);							// current spread
			StartPrice = Open[BarNum-1]+StartSpread;		// buys are open at Ask price
			StartTime = Time[BarNum-1];
			LogWrite(BarNum, "BuyActive: true, StartPrice: " + (string)StartPrice + ", StartTime: " + TimeToStr(StartTime, TIME_DATE | TIME_SECONDS) +
								", StartSpread: " + (string)StartSpread);
		}
	}
}


//-----------------------------------------------------------------------------
// SetSL
// calculates SL for each bar
//-----------------------------------------------------------------------------

void SetSL(int BarNum)
{	
	double ATRVal, SLVal;
	//double FractUp, FractDown;
	//int PosUp, PosDown;


   if ( !(BuyActive || SellActive) )
   	return;
   
   LogWrite(BarNum, "-----  SetSL");
   
   // if SL is already set for this bar
   if (dBufSL[BarNum] > 0.0)
   {
   	LogWrite(BarNum, "SL already set: " + (string)dBufSL[BarNum]);
   	return;  
   }
   
   dBufSL[BarNum] = 0.0;
     
   ATRVal = iATR(NULL, 0, 200, BarNum+1);			// ATR for 200 bars gives pretty stable bar range value for a certain pair and time period
	LogWrite(BarNum, "ATRVal: " + (string)ATRVal);
		
	// SL for BUY
		
	if (BuyActive)
	{   	
  		SLVal = High[Highest(NULL, 0, MODE_HIGH, ChandBars, BarNum+1)] + StartSpread - ATRVal*ChandATRFact;	// calculate according to Ask price
  		
  		// if SL is too close
  		if (SLVal > Open[BarNum] + StartSpread - ATRVal)			
  			SLVal = Open[BarNum] + StartSpread - ATRVal;
  		
   	SLVal = NormalizeDouble(SLVal, Digits);   	
   	LogWrite(BarNum, "Buy, suggested SLVal: " + (string)SLVal);
   	
   	// SL goes only in one direction (up for buys)

		// if prev. trade ended at prev. bar or new trade just started	
   	if (	(dBufExitBuy[BarNum+1] > 0.0 || dBufExitSell[BarNum+1] > 0.0) 	
   		|| dBufSL[BarNum+1] == 0.0 )										
   	{
   		LogWrite(BarNum, "New SL: " + (string)SLVal);
   		dBufSL[BarNum] = SLVal;
   	}
   	else if ( (SLVal - dBufSL[BarNum+1] >= 0.5*dblPoint)						// if new SL is higher (at least for 0.5 pip) than previous one
   		 		 && (Open[BarNum] - SLVal > MinSLDistance*dblPoint) )			// and far enough from current price (which is open price at the beginning of the bar)
   	{
   		LogWrite(BarNum, "Old SL: " + (string)dBufSL[BarNum+1] + ", new SL: " + (string)SLVal);   		
   		dBufSL[BarNum] = SLVal;
   	}
   	else																						// otherwise SL doesn't change
   	{
   		dBufSL[BarNum] = dBufSL[BarNum+1];
   		LogWrite(BarNum, "SL stays same: " + (string)dBufSL[BarNum+1]);   		
   	}   		
	}
	
	// SL for SELL
	
	if (SellActive)
	{
		SLVal = Low[Lowest(NULL, 0, MODE_LOW, ChandBars, BarNum+1)] + ATRVal*ChandATRFact;						// calculate according to Bid price
		
  		// if SL is too close
  		if (SLVal < Open[BarNum] + ATRVal)	
  			SLVal = Open[BarNum] + ATRVal;

   	SLVal = NormalizeDouble(SLVal, Digits);   	
			
   	LogWrite(BarNum, "Sell, suggested SLVal: " + (string)SLVal);
		
   	// SL goes only in one direction (down for sells)
   	
		// if prev. trade ended at prev. bar or new trade just started	
		if (	(dBufExitBuy[BarNum+1] > 0.0 || dBufExitSell[BarNum+1] > 0.0)
			|| dBufSL[BarNum+1] == 0.0)		
		{
   		LogWrite(BarNum, "New SL: " + (string)SLVal);
			dBufSL[BarNum] = SLVal;		
		}
		else if ( (dBufSL[BarNum+1] - SLVal >= 0.5*dblPoint)						// if new SL is lower (at least for 0.5 pip) than previous one
			 		 && (SLVal - Open[BarNum] > MinSLDistance*dblPoint) )			// and far enough from current price (which is open price at the beginning of the bar)
		{
   		LogWrite(BarNum, "Old SL: " + (string)dBufSL[BarNum] + ", new SL: " + (string)SLVal);
	  		dBufSL[BarNum] = SLVal;
	  	}
   	else																						// otherwise SL doesn't change
   	{
   		dBufSL[BarNum] = dBufSL[BarNum+1];
   		LogWrite(BarNum, "SL stays same: " + (string)dBufSL[BarNum+1]);   		   		
   	}   		
	}
}


//-----------------------------------------------------------------------------
// ProcessAlert
//-----------------------------------------------------------------------------

void ProcessAlert(string AlertStr)
{
	if (UseSoundAlert)	 	
		PlaySound(AlertSound);
	
	if (UsePopupAlert)
		Alert(IndName, ": ", Symbol(), " M", Period(), ": ", AlertStr);
		   	
   LogWrite(0, AlertStr);	
}


//=============================================================================
// START
//=============================================================================

int start()
{




	int counted_bars = IndicatorCounted();
	int MinBars;
	
   int i = 0;
	static datetime PrevTime = 0;
	

	// --- common proc.
	
	// just for 1st init.
	if (PrevTime == 0)
		PrevTime = Time[0];	
		
	MinBars = 200;
	
   i = Bars-MinBars-1;
   if (i < 0)
   	return(-1);
   	
	if (counted_bars < 0)
		return(-1);  	
  
   if ( counted_bars > MinBars )
   	i = Bars - counted_bars - 1;

	if ( i > BarsBack-1 )
		i = BarsBack-1;


	// ====================    bar processing history + current
	
	if (PrevTime == Time[0])	
	{
		for (; i>=0; i--)
		{					
			LogWrite(i, "\n\nBar: " + (string)i);
			
			SetSL(i);					// if in trade, does SL need to be changed?
			SimSLHit(i);				// if in trade, has SL been hit?
			ExitManagement(i);		// if in trade, are exit conditions met?
			NewTradeManagement(i);	// if not in trade, are entry conditions met?
		}	

		if (!FirstDisplay)
		{
			DisplayInfo(0);
			FirstDisplay = true;
		}		
	}
	
	else		// ==================   after each new bar
	{
		PrevTime = Time[0];

		LogWrite(0, "\n\nNew current bar");

		// for the just finished bar we have to recheck conditions and set flags

		ExitManagement(1);			// look for exit conditions at the just finished bar
		NewTradeManagement(1);		// look for entry conditions at the just completed bar
		SetSL(0);						// if in trade, set SL for the new bar
		DisplayInfo(0);				// if in trade, display info for trading

		// alerts			
		if ( dBufExitBuy[1] > 0.0 )	
			ProcessAlert("Exit now from buy");
	
		if ( dBufExitSell[1] > 0.0 )	
			ProcessAlert("Exit now from sell");
			
		if ( dBufBuy[1] > 0.0 )			
			ProcessAlert("Buy now");
	
		if ( dBufSell[1] > 0.0 )		
			ProcessAlert("Sell");
	}	
	
	return(0);
}	// end START



//--------------------------------------------------------------------------------------
// GetPoint
//--------------------------------------------------------------------------------------

void GetPoint()
{
	if (Digits == 3 || Digits == 5)   
		dblPoint = Point * 10;
	else
		dblPoint = Point;
      
	if (Digits == 3 || Digits == 2)
		iDigits = 2;
	else
		iDigits = 4;
}


//--------------------------------------------------------------------------------------
// RemoveObjects
//--------------------------------------------------------------------------------------

void RemoveObjects(string Pref)
{   
   int i;
   string OName = "";

   for (i = ObjectsTotal(); i >= 0; i--) 
   {
      OName = ObjectName(i);
      if (StringFind(OName, Pref, 0) > -1)
        	ObjectDelete(OName);
   }
}


//--------------------------------------------------------------------------------------
// DrawFixedLbl
//--------------------------------------------------------------------------------------

void DrawFixedLbl(string OName, string Capt, int Corner, int DX, int DY, int FSize, string Font, color FColor, bool BG)
{
   if (ObjectFind(OName) < 0)
   	ObjectCreate(OName, OBJ_LABEL, 0, 0, 0);
   
   ObjectSet(OName, OBJPROP_CORNER, Corner);
   ObjectSet(OName, OBJPROP_XDISTANCE, DX);
   ObjectSet(OName, OBJPROP_YDISTANCE, DY);
   ObjectSet(OName,OBJPROP_BACK, BG);      
   
   if (Capt == "" || Capt == "Label") Capt = " ";

   ObjectSetText(OName, Capt, FSize, Font, FColor);
}


// *************************************************************************************
//
//	LOG routines
//
// *************************************************************************************


//--------------------------------------------------------------------------------------
// LogOpen
//--------------------------------------------------------------------------------------

void LogOpen()
{
	if (!WriteToLog)
		return;
	
	string FName = StringFormat(  "Name:%s, Symbol: %s,M :%s,.log%s", IndName , Symbol() , "_M" ,Period() , ".log");
		
	LogHandle = FileOpen(FName, FILE_WRITE);
	
	if (LogHandle < 1)
	{
		Print("Cannot open LOG file ", FName + "; Error: ", GetLastError(), " : ", ErrorDescription( GetLastError() ) );
		return;
	}	

	FileSeek(LogHandle, 0, SEEK_END);
}


//--------------------------------------------------------------------------------------
// LogClose
//--------------------------------------------------------------------------------------

void LogClose()
{
	if ( (!WriteToLog) || (LogHandle < 1) )
		return;

	FileClose(LogHandle); 
}


//--------------------------------------------------------------------------------------
// LogWrite
//--------------------------------------------------------------------------------------

void LogWrite(int i, string sText) 
{
	if ( (!WriteToLog) || (LogHandle < 1) )
		return;

	if (i == 0)
		FileWrite(LogHandle, TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + ": " + sText);
	else
		FileWrite(LogHandle, TimeToStr(Time[i], TIME_DATE | TIME_SECONDS) + ": " + sText);  

	FileFlush(LogHandle);
	
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
