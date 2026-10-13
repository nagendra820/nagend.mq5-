
#include <Trade/Trade.mqh>

CTrade trade;

input double Lots = 0.01;
input int FastEMA = 9;
input int SlowEMA = 33;
input int StopLossPoints = 300;
input int TakeProfitPoints = 600;

int fastHandle, slowHandle;
datetime lastBar = 0;

int OnInit()
{
   fastHandle = iMA(_Symbol, PERIOD_M1, FastEMA,
                    0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M1, SlowEMA,
                    0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE ||
      slowHandle == INVALID_HANDLE)
      return INIT_FAILED;

   trade.SetExpertMagicNumber(1333333);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
}

void OnTick()
{
   datetime bar = iTime(_Symbol, PERIOD_M1, 0);
   if(bar == 0 || bar == lastBar)
      return;
   lastBar = bar;

   double fast[], slow[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);

   if(CopyBuffer(fastHandle, 0, 0, 3, fast) != 3 ||
      CopyBuffer(slowHandle, 0, 0, 3, slow) != 3)
      return;

   if(PositionSelect(_Symbol))
      return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(ask <= 0 || bid <= 0 || point <= 0)
      return;

   if(fast[2] <= slow[2] && fast[1] > slow[1])
   {
      trade.Buy(Lots, _Symbol, 0,
         NormalizeDouble(ask - StopLossPoints * point, digits),
         NormalizeDouble(ask + TakeProfitPoints * point, digits));
   }
   else if(fast[2] >= slow[2] && fast[1] < slow[1])
   {
      trade.Sell(Lots, _Symbol, 0,
         NormalizeDouble(bid + StopLossPoints * point, digits),
         NormalizeDouble(bid - TakeProfitPoints * point, digits));
   }
}
