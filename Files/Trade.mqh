//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
enum Action { OPEN_MARKET_ORDER,OPEN_LIMIT_ORDER,OPEN_SELLSTOP,
                 CLOSE_MARKET_ORDER,CLOSE_LIMIT_ORDER,CLOSE_SELLSTOP
                 
                 };
class Trade{
private: 

Action action;



public: void setAction(Action actions){
action=actions;

}
Action getAction(){
return action;
}
                     Trade();
                    ~Trade();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trade::Trade()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Trade::~Trade()
  {
  }
//+------------------------------------------------------------------+
