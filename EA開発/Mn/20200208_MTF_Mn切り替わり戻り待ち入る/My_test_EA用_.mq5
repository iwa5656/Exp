//+------------------------------------------------------------------+
//|                                                 beard.mq5   base 売り買い11GMMA|
//|                            Copyright 2017, Alexander Masterskikh |
//|My_test_検索用_span_bollnger20190619_no1_markup_buy_s_bollinger4.mq5
//|base My_test_検索用_ボリンジャーバンド                                                                  |
//|base My_test_検索用_トレード両建て可能か確認2.mq5                                                             |
//|base My_test_検索用_トレード両建て可能か確認5_flactal                                                             |
//+------------------------------------------------------------------+
#property copyright   "2017, Alexander Masterskikh"
#property link        "https://www.mql5.com/en/users/a.masterskikh"


int testsq;//テストシーケンス番号
datetime testsq_time;
int testsq_small;
int testflag[1000];
bool flag_chg_ashi=false;//確定足出現：新しい脚ができたtrue ,それ以外false　　　
double local_min_price;//tmp　エントリーから最安値
double local_max_price;//tmp　エントリーから最高値
double TPwaruSL;
bool  flagbuy = false;
bool  flagsell = false;
double aaa[2][2];

input double inp_Tp=2000;// 利確point
input double inp_Sl=4000;// 損切point
double Tp,Sl;
////////////////////////////////
// option  機能のON/OFF
////////////////////////////////
//#define GMMA
//#define JYUUFUKU_NASHI	//ポジションあり、ポジションとったばかりのときはEntryしないようにガード

//#define USE_ONLY_CHG_ASHI //足が確定した時のみ処理をする、しないを制御

#define USE_No1 // No1を使用するとき
//#define USE_No2 // No2を使用するとき

//#define USE_method1
////////////////////////////////
// end option
////////////////////////////////

//
//  input
//
input double Hige_sinnkou=10;//Hige_sinnkouヒゲ幅　伸びている方向の幅[PIPS]　　10PIPS以上
input double Hige_gyakuhoukou=5;//Hige_gyakuhoukou髭幅　反対側の幅[PIPS]



double         ArrowABuffer[];




//+------------------------------------------------------------------+ 
//| 入力                                              | 
//+------------------------------------------------------------------+ 
input double EntrySigma = 0.0;// fillter EntrySigma未満だとエントリー
input double ExitSigma = -1.0;// Exit Sigma　以下でExit
input double RikakuSigma = 2.0;// rikaku Sigma　以上で利確


input double NumOfBeard_pips=20;//髭幅(PIPS)
input double NumOfBody_pips=10;//実態の幅(PIPS)

input double bandTouchWidth=5;//EMAタッチのバンド幅(PIPS)
input double DecisionBandWidth=10;//停滞、抜け判断のバンド幅(PIPS)
input int NumberOfBarAfterTouch=15; //タッチ後の本数（M5)(タッチ後の確認期間)

// 


//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
input int katamukiDays = 3; // katamuki days ave  傾きの何本前にするか


//----------------------------------------------------------------------------------------
//　確定足を判断するため
datetime kakuteihanndannTime; // 新しい脚ができたか確認するため

bool flagNotTrade; //未取引フラグ　		新しい脚出現　true　　		売り買いした場合　false

//----------------------------------------------------------------------------------------
input double higeWeigt = 0.05; // higeの長さの割合  open to closeの割合　１００％で１
input int XbarPassed=9;// n本経過後マイナス評価用
//----------------------------------------------------------------------------------------

int kol;

datetime Time_cur; 
   bool flagclose;
#define  MaxBars 6 	  // データの取得に必要な数　　コピー
//#define  MAX_DATA 1000
#define  MAX_DATA 30  // 前回値ほしいので　暫定
//#define  MAX_DATA 0
double High[MAX_DATA],Low[MAX_DATA],Open[MAX_DATA],Close[MAX_DATA];
datetime Time[MAX_DATA];// add iwa
               
               
         //      input double TakeProfit     = 600;   //take profit                                    
        //       input double StopLoss       = 300;   //stop loss                                 
//               input double TakeProfit     = 25000 	 ;   //take profit                                    
//               input double StopLoss       = 12500;   //stop loss                                 
               input double TakeProfit     = 8000 	 ;   //take profit                                    
               input double StopLoss       = 3000;   //stop loss                                 
//                double TakeProfit     = 8000 	 ;   //take profit                                    
//                double StopLoss       = 300;   //stop loss                                 
               input double Lots           = 0.1;     //number of lots
               input int Depo_first        = 100000; //initial client deposit in monetary terms
               input int Percent_risk_depo = 5;     //maximum allowed risk per deposit (in % to the client's initial deposit)
               input bool test             = true; //set: true - for test (default is false for trading)
               
               int testn=0;
#define  EXPERT_MAGIC 16384
               
               //#define OP_SELL ORDER_TYPE_SELL_STOP_LIMIT
               //#define OP_BUY ORDER_TYPE_BUY_STOP_LIMIT
               #define OP_SELL ORDER_TYPE_SELL_STOP_LIMIT
               #define OP_BUY ORDER_TYPE_BUY_STOP_LIMIT
               
               #include <Trade\SymbolInfo.mqh>
               #include <Trade\AccountInfo.mqh>
               
//-------------------------------------------------------------------------------------------------

// 読み込みLib
//#include "Lib_My_func_lib2.mqh"
#include <mn\My_function_lib2.mqh>
#include "Lib_MyFunc_Trade.mqh"

#include "Lib_MyFunc_Mn.mqh"

//#include "Lib_MyFunc_MA.mqh"

//#include "Lib_MyFunc_fractal.mqh"

//#include "Lib_MyFunc_Etc.mqh"
//#include "Lib_MyFunc_sn.mqh"


// 初期化関数:f0
int OnInit()
{
    Tp= inp_Tp;// 利確point
    Sl= inp_Sl;// 損切point

double pp = Point();
printf("POINT="+pp);


#ifdef Lib_MyFunc_Mn
	init_Lib_MyFunc_Mn();
#endif//Lib_MyFunc_Mn


#ifdef Lib_MyFunc_MA
	init_Lib_MyFunc_MA();
#endif//Lib_MyFunc_MA


#ifdef Lib_MyFunc_fractal
	init_Lib_MyFunc_fractal();
#endif//Lib_MyFunc_fractal

#ifdef Lib_MyFunc_sn
	init_Lib_MyFunc_sn();
#endif//Lib_MyFunc_sn
    int handle_zigzag = iCustom(Symbol(),Period(),"\\examples\\zigzag");


	
	flag_chg_ashi=false;//確定足出現：新しい脚ができたtrue ,それ以外false　　　

#ifdef USE_MyFunc_Etc
    init_MyFunc_Etc();
#endif //MyFunc_Etc
    
	//　確定足を判断するため
	OnInit_Time();


	//////////////////////////////////////////
	///// positiln deal
	/////////////////////////////////////////
	init_posision_data();
	init_deal_data();

    //add 2019/08/03 時間フィルタ追加
    OnInitCSignalITF();

    return(0);
}// end Oninit
// calc :f1
void OnTick(void)
{

//testtt();// debug用




      bool  flagbuy = false;
      bool  flagsell = false;
                   double bid;
                   double ask;
                   double sl_buy,tp_buy;
                   double sl_sell,tp_sell;
   //Variable values:
   //int numb;
   
	//すでに同じ足で取引があった場合は、取引しないようにする。
	OnTickTimekakuteihanndann();//       flagNotTrade      flag_chg_ashi

//	if(flagNotTrade == false){
//		return;
//	}   

//   ViewSignal();
//testDatetime();//test date debug

#ifdef USE_MyFunc_Etc
OnTick_MyFunc_Etc();
#endif //MyFunc_Etc
   
//   #ifdef aaa
   int m;
    for( m=0;m<MAX_DATA;m++){
        High[m] = iHigh(NULL,PERIOD_CURRENT,m); 
        Low[m]= iLow(NULL,PERIOD_CURRENT,m); 
        Open[m] = iOpen(NULL,PERIOD_CURRENT,m); 
        Close[m] = iClose(NULL,PERIOD_CURRENT,m); 
    
        Time[m] = iTime(NULL,PERIOD_CURRENT,m); 
    }   
    
    
    
    
	//-----------------------------------------------------------------------------------------//
	// 事前データの準備
	//-----------------------------------------------------------------------------------------//

	PositionSelect(    _Symbol     );
	kol = PositionsTotal();
	Time_cur = TimeCurrent();


	// position update
	check_ADD_position_data();
//	update_open_position(Open[0],(long)Time_cur);
	update_open_position(Close[0],(long)Time_cur);

	if( kol > 10 ){
	
	   testOrder();
	}
	RefreshPrice(bid, ask);
      //
	
#ifdef USE_HistoryDeal_test
	if(testsq == 0 ){
		testsq_time =  Close[1];
		testsq_small=0;
  		testsq++;
	}

	if(Time [1] != testsq_time){
		testsq_time = Time [1];
		
		if(testsq_small >10 ){
		   testsq_small =0;
   		
   		if(testsq > 5){
   		}else{
     		   testsq++;

   		}
   
      	if(testsq == 2){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 3){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 4){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 5){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 6){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 7){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 8){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 9){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      	if(testsq == 10){
      				testPositionInfoOut(testsq-1);
      				testHistoryInfoOut(testsq-1);
      	}
      }else{
         testsq_small++;
      }
	}	
#endif// USE_HistoryDeal_test
	//-----------------------------------------------------------------------------------------//
	//----sn entry-----------------------------------------------------------------------------//
	//-----------------------------------------------------------------------------------------//
#ifdef Lib_MyFunc_sn
    ontick_Lib_MyFunc_sn();//////////////////////////////////////
#endif//Lib_MyFunc_sn






	//確定足のみ処理する
	if(flag_chg_ashi ){
		// データの取得とデータ作成
#ifdef Lib_MyFunc_Mn		
		ontick_tick_Lib_MyFunc_Mn();
#endif // Lib_MyFunc_Mn



#ifdef Lib_MyFunc_MA		
		ontick_Lib_MyFunc_MA();
#endif // Lib_MyFunc_MA
#ifdef Lib_MyFunc_fractal		
		ontick__Lib_MyFunc_fractal();
        view_reg_sup();
#endif // Lib_MyFunc_fractal

        //売り買い判断　フラグを立てる
//        if(!buychek_hige_chk()){
            //sellchek_hige_chk();
        //}

	}
	//Tick処理
#ifdef Lib_MyFunc_Mn		
		ontick_kakuteiashi_Lib_MyFunc_Mn();
#endif // Lib_MyFunc_Mn


	//-----------------------------------------------------------------------------------------//
	//----span-------------------------------------------------------------------------------------//
	//-----------------------------------------------------------------------------------------//

#ifdef USE_MyFunc_Etc
	span_kakuteiashi_urikaihanndan();// spanモデルのエントリー　自転車
#endif //MyFunc_Etc
	
	
	
	

    
    
	//-----------------------------------------------------------------------------------------//
	// 売り買いなし　かつ　売り買い成立の足以外の場合処理する（flagNotTrade）
	//-----------------------------------------------------------------------------------------//
		
	// debug  ポジションもっていても売り買いEntryを確認する //if((kol < 1)  && flagNotTrade) //continue if there are no open orders

#ifdef JYUUFUKU_NASHI	
	if((kol < 1)  && flagNotTrade)   //ポジションあり、ポジションとったばかりのときはEntryしないようにガード
	{
#else	
	if(flagNotTrade) // debug        //同じ足のときでエントリーがあれば、エントリーチェックをガード
	{
#endif


	//-----------------------------------------------------------------------------------------//
	//  buy
	//-----------------------------------------------------------------------------------------//

      //　買い
      
      // LowerBuffer[0]を下抜ける
     //★
#ifdef aaaa
//		int numofmethod = GetMethodNum();
//		for(int method_no=0;method_no<numofmethod-1;method_no++){
//			
//			
//		}
#endif

		bool ret;
		ret = Buycheck_execute();// 買いチェックと成立時買い処理
		
		if(ret){
			flagNotTrade = false; // flag更新
		} 
#ifdef aaaa
//		if(flagbuy)
//		{
//			
//	        //if the Buy entry algorithm conditions specified above are met, generate the Buy entry order:
////	        sl_buy = NormalizeDouble((bid-StopLoss*Point()),Digits());
////	        tp_buy = NormalizeDouble((ask+TakeProfit*Point()),Digits());
//	        sl_buy = NormalizeDouble((bid-100*Point()),Digits());
//	        tp_buy = NormalizeDouble((ask+100*Point()),Digits());
//	        
//			setStrSlowBandHigh();
//	        string str_comment = GetStrSlowBandHigh();
////	        numb = OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl_buy,tp_buy,"Reduce_risks",16384,0,Green); 
//	        OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl_buy,tp_buy,str_comment,16384,0,Green); 
//	        flagNotTrade = false;
//
#ifdef aaaa
////	        if(numb > 0)
////	   
////	           {
////	   //          if(OrderSelect(numb,SELECT_BY_TICKET,MODE_TRADES))
////	            if(OrderSelect(numb,0,0))
////	            {
////	               Print("Buy entry : ",OrderOpenPrice());   
////	            }
////	           }
////	         else
////	            Print("Error when opening Buy order : ",GetLastError());
////	         //debug return;
#endif
//		}

#endif
   
	//-----------------------------------------------------------------------------------------//
	//  sell
	//-----------------------------------------------------------------------------------------//

      //　売り
     // bool flagsell=false;
     
     //売り条件の判定
     //★


		ret = Sellcheck_execute();// 売りチェックと成立時売り処理
		
		if(ret){
			flagNotTrade = false; // flag更新
		} 


   }  // kol
   //　クローズ条件確認
   
	int f;
	long ticket;
	bool ret;

	for(f=0; f < kol; f++)
    {
       //    if(!OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
           //      if(!OrderSelect(f,0,0))
       ticket = PositionGetTicket(f);
		if(!ticket)
			continue;
		if( //OrderType()<=OP_SELL &&   //check the order type 
			OrderSymbol()==Symbol())  //check the symbol
		{

		  // time test 
		         int after_bar_count=0; // オーダーからのバーの本数 
		         after_bar_count = 0; 
		         if(Time_cur > OrderOpenTime() && OrderOpenTime() > 0)                          //if the current time is farther than the entry Point()...
		         { after_bar_count = (int)NormalizeDouble( ((Time_cur - OrderOpenTime() ) /60), 0 ); }    //define the distance in tfM1 mybars up to the entry Point()


			// buy close check     POSITION_TYPE_BUY 買い。POSITION_TYPE_SELL 売り
	        if(OrderType()==POSITION_TYPE_BUY) //if the order is "Buy", move to closing Buy position:
	          {

		      
		      
		      
		      
		      
		      //// STC クローズチェック
		      /// #### 上書き
//		      flagclose =
//			      StochasticBuffer[1]>SignalBuffer[1]	&&					// main K がDをした抜き
//			      StochasticBuffer[0]<=SignalBuffer[0]						//
		      
		      ;
				// 手法によってクローズ確認とクローズ処理　チケット単位で実施
				ret = CloseBuycheck_execute();
                if(ret){
                    after_Close_Buy_execute();
                }

		   }
		   // sell close check
		   else if (OrderType()==POSITION_TYPE_SELL){
				// 手法によってクローズ確認とクローズ処理　チケット単位で実施
				ret = CloseSellcheck_execute();
                if(ret){
                    after_Close_Sell_execute();
                }

#ifdef aaaaaa
		   flagclose = flagclose ||
		      (after_bar_count> XbarPassed &&  Close[0]> OrderOpenPrice() );  //asdf   

		      //// STC クローズチェック
		      /// #### 上書き
//		      flagclose =
//			      StochasticBuffer[1]<SignalBuffer[1]	&&					// main K がDを上抜き
//			      StochasticBuffer[0]>=SignalBuffer[0]						//

		      ;

				flagclose = CloseSellcheck();

		      if(flagclose)
		                             {
		                       // TTTTTT
									if(testsq == 4 && testflag[4]==0){
			                        	if(!OrderClose(
				                        	3,
				                        	OrderLots(),
				                        	ask,3,Violet,"")) {    //if the closing algorithm is processed, form the order for closing the Buy position
				                            	 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
			                        	}


			                        	testflag[4]=1;
									}else if(testsq == 5&& testflag[5]==0){
			                        	if(!OrderClose(
				                        	2,
				                        	0.3,
				                        	ask,3,Violet,"")) {    //if the closing algorithm is processed, form the order for closing the Buy position
				                            	 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
			                        	}
			                        	testflag[5]=1;
									}else if(testsq == 6&& testflag[6]==0){
			                        	if(!OrderClose(
				                        	2,
				                        	0.7,
				                        	ask,3,Violet,"")) {    //if the closing algorithm is processed, form the order for closing the Buy position
				                            	 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
			                        	}
			                        	testflag[6]=1;
									}else if(testsq == 7&& testflag[7]==0){
			                        	if(!OrderClose(
				                        	4,
				                        	1.0,
				                        	ask,3,Violet,"")) {    //if the closing algorithm is processed, form the order for closing the Buy position
				                            	 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
			                        	}
									
			                        	testflag[7]=1;
									}else if(testsq == 8&& testflag[8]==0){
			                        	if(!OrderClose(
				                        	0,
				                        	1.0,
				                        	ask,3,Violet,"")) {    //if the closing algorithm is processed, form the order for closing the Buy position
				                            	 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
			                        	}
			                        	testflag[8]=1;
									}

#ifdef aaaa // debug		                        	

		                              if(!OrderClose((int)OrderTicket(),OrderLots(),ask,3,Violet))     //if the close algorithm is executed, generate the Sell position close order
		                                 Print("Error closing Sell position ",GetLastError());   //otherwise, print the Sell position closing error
#endif

		                              return;
		                             }        

#endif




		      
			}
		}
		  
		                     
		  
		  
	}// for position close check


               //---
                 }








///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//検索/////////////////////////////////////////////////////////////////////////////////////////




 


////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////Start　売り買いチェックメソッド/////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////
/// Closeチェック 共通
///////////////////////////////////////////////////////////////
bool CloseSellcheck_execute(){
	bool ret=false;
	if(CloseSellcheck_method1()){
		//メソッド名、メソッド番号、コメント
		CloseSellexecute("method1",0,"comment");
		ret = true;
	}
	if(CloseSellcheck_method2()){
		//メソッド名、メソッド番号、コメント
		CloseSellexecute("method1",0,"comment");
//		flag_buy_No2=false;
		ret = true;
	}
//	if(CloseBuycheck_method2()){
//		//メソッド名、メソッド番号、コメント
//		CloseSellexecute("method2",0,GetStrSlowBandHigh());
//		ret = true;
//	}

	return ret;

}

bool CloseBuycheck_execute(){
	bool ret=false;
	if(CloseBuycheck_method1()){
		//メソッド名、メソッド番号、コメント
		CloseBuyexecute("method1",0,"comment");
		ret = true;
		
//        flag_buy_No1=false;
	}
	if(CloseBuycheck_method2()){
		//メソッド名、メソッド番号、コメント
		CloseBuyexecute("",2,"comment");//GetEntryInfo());// ★★★
		ret = true;
		
//		flag_buy_No2=false;
	}
//	if(CloseBuycheck_method2()){
//		//メソッド名、メソッド番号、コメント
//		CloseBuyexecute("method2",0,GetStrSlowBandHigh());
//		ret = true;
//	}

	return ret;

}

///////////////////////////////////////////////////////////////
/// 売り買いチェック用　共通
///////////////////////////////////////////////////////////////

// 買いチェック・買い処理へ
bool	Buycheck_execute(){
	bool ret=false;
	if(Buycheck_method1()){
		//買いの実行
		//setStrSlowBandHigh(); // コメント作成
		//メソッド名、メソッド番号、コメント
//		Buyexecute(TPwaruSL,0,"");
		Buyexecute(TPwaruSL,trace_mn_idx,"");

		ret = true;
	}
	if(Buycheck_method2()){
		//買いの実行
		//メソッド名、エントリー理由、コメント
		Buyexecute("2",0,"");// ★★★
		ret = true;
	}
//	if(Buycheck_method1()){
//		Buyexecute("method1",0);
//	}
	if(ret){
		after_Buy_execute();
	}
	return ret;
}
//売りチェック・売り処理へ
bool	Sellcheck_execute(){
	bool ret=false;
	if(Sellcheck_method1()){
		//買いの実行
		//setStrSlowBandHigh(); // コメント作成
		//メソッド名、メソッド番号、コメント
//		Sellexecute(TPwaruSL,0,"");//GetStrSlowBandHigh());
		Sellexecute(TPwaruSL,trace_mn_idx,"");//GetStrSlowBandHigh());

		ret = true;
		
		
		
	}
//	if(Sellcheck_method1()){
//		Sellexecute("method1",0);
//	}

	if(ret){
		after_Sell_execute();
	}
   return ret;
}


///////////////////////////////////////////////////////////////
/// Close処理 共通
///////////////////////////////////////////////////////////////

//クローズ処理実行（買いポジションのクローズ処理）
bool CloseBuyexecute(string m_name,int method_no,string c){
	bool ret =false;
	double bid, ask;
   RefreshPrice(bid, ask);

	string str_comment = MakeMethodNo_Name_Comment(method_no,m_name,c);
	if(!OrderClose(

		(int)OrderTicket(),
		OrderLots(),
		bid,3,Violet,str_comment)) 
	{    //if the closing algorithm is processed, form the order for closing the Buy position
			 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
	}else { ret = true; }
	
	return ret;
}
//クローズ処理実行（売りポジションのクローズ処理）
bool CloseSellexecute(string m_name,int method_no,string c){
	bool ret =false;
	double bid, ask;
   RefreshPrice(bid, ask);

	string str_comment = MakeMethodNo_Name_Comment(method_no,m_name,c);
	if(!OrderClose(

		(int)OrderTicket(),
		OrderLots(),
		ask,3,Violet,str_comment)) 
	{    //if the closing algorithm is processed, form the order for closing the Buy position
			 Print("Error closing Sell position ",GetLastError());    //otherwise print Buy position closing error
	}else { ret = true; }
	
	return ret;
}

///////////////////////////////////////////////////////////////
/// 売り買い処理 共通
///////////////////////////////////////////////////////////////

//買い実行
void Buyexecute(string m_name,int method_no,string c){
	double bid, ask;
	double sl_buy,tp_buy;
	//add 2019/08/03 時間フィルタを追加
	if(IsTimeFillter()==false){
		return;
	}
	
	string str_comment = MakeMethodNo_Name_Comment(method_no,m_name,c);
    RefreshPrice(bid, ask);
//    sl_buy = NormalizeDouble((bid-StopLoss*Point()),Digits());
//    tp_buy = NormalizeDouble((ask+TakeProfit*Point()),Digits());
    sl_buy = NormalizeDouble((bid-Sl*Point()),Digits());
    tp_buy = NormalizeDouble((ask+Tp*Point()),Digits());

	        OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl_buy,tp_buy,str_comment,16384,0,Green); 
	        flagNotTrade = false;
return;
}
//売り実行
void Sellexecute(string m_name,int method_no,string c){
	double bid, ask;
	double sl_sell,tp_sell;
	//add 2019/08/03 時間フィルタを追加
	if(IsTimeFillter()==false){
		return;
	}
	string str_comment = MakeMethodNo_Name_Comment(method_no,m_name,c);
   RefreshPrice(bid, ask);

//    sl_sell = NormalizeDouble((ask+StopLoss*Point()),Digits());
//    tp_sell = NormalizeDouble((bid-TakeProfit*Point()),Digits());
    sl_sell = NormalizeDouble((ask+Sl*Point()),Digits());
    tp_sell = NormalizeDouble((bid-Tp*Point()),Digits());


    OrderSend(Symbol(),  OP_SELL,Lots,bid,3,sl_sell,tp_sell,str_comment,16384,0,Red); 
    flagNotTrade = false;
	
	return;
}

//メソッド
///////////////////////////////////////////////////////////////
/// 売り買いメソッド　個別　フレーム
///////////////////////////////////////////////////////////////

//買い判定
bool Buycheck_method1(){   // Span

#ifdef Lib_MyFunc_Mn
	return(buycheck_Lib_MyFunc_Mn());
#endif//Lib_MyFunc_Mn


#ifdef USE_method1
	return(buycheck_span_boll());
#endif// USE_method1
#ifdef Lib_MyFunc_MA
	return(buycheck_MA());
#endif//Lib_MyFunc_MA



}
bool Buycheck_method2(){
    return(false);
	//return(buycheck_span_boll_No2());
}
bool Buycheck_method3(){
    return(false);
//	return(Buycheck());
}
bool Buycheck_method4(){
    return(false);
//	return(Buycheck());
}

//売り判定
bool Sellcheck_method1(){  
#ifdef Lib_MyFunc_Mn
    return sellcheck_Lib_MyFunc_Mn();
#endif//Lib_MyFunc_Mn

#ifdef USE_method1
	return(sellcheck_span_boll());
#endif// USE_method1
#ifdef Lib_MyFunc_MA
    return sellcheck_MA();
#endif//Lib_MyFunc_MA
}
bool Sellcheck_method2(){
    return(false);
//	return(Sellcheck());
}
bool Sellcheck_method3(){
    return(false);
//	return(Sellcheck());
}
bool Sellcheck_method4(){
    return(false);
//	return(Sellcheck());
}


///////////////////////////////////////////////////////////////
/// 売り買いメソッド　個別　フレーム　詳細
///////////////////////////////////////////////////////////////

//クローズチェック　メソッド
//買いポジションのクローズチェック1
bool CloseBuycheck_method1(){
	bool ret;
	ret = false;
#ifdef Lib_MyFunc_Mn
	ret = CloseBuycheck_Lib_MyFunc_Mn();
#endif//Lib_MyFunc_Mn

	
    return(ret);
#ifdef USE_method1
	return exit_buycheck_span_boll();
#endif// USE_method1
	return false;

}
bool CloseBuycheck_method2(){
	bool ret=false;
    return(ret);
//	return exit_buycheck_span_boll_No2();
//	return exit_buycheck_span_boll_No2_bollnger();// ★★
}



//売りポジションのクローズチェック1
bool CloseSellcheck_method1(){
	bool ret;
	ret = false;
	
#ifdef Lib_MyFunc_Mn
	ret = CloseSellcheck_Lib_MyFunc_Mn();
#endif//Lib_MyFunc_Mn
	
    return(ret);
//	return exit_sellcheck_span_boll();
}
bool CloseSellcheck_method2(){
	bool ret=false;
    return(ret);

//	return exit_sellcheck_span_boll();
}

///////////////////////////////////////////////////////////////
/// 売り買いメソッド　個別　判断する関数
///////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////End　売り買いチェックメソッド///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////






int OnInit_Time()
{
   datetime t[1];
   CopyTime(_Symbol,_Period  ,0,1,t);
   kakuteihanndannTime = t[0];
   flagNotTrade=true;
   return(INIT_SUCCEEDED);
}

//void OnTick()
void OnTickTimekakuteihanndann()
{
   datetime t[1];
   CopyTime(_Symbol, _Period, 0, 1, t);
   if(t[0] != kakuteihanndannTime)
   {
      //Alert("newbar");
      kakuteihanndannTime = t[0];
      flagNotTrade=true;
      flag_chg_ashi=true;
   }else{
      flag_chg_ashi = false;
   }
}


bool buychek_hige(){
    bool ret = flagbuy;
    flagbuy = false;
    return(ret);
}

bool buychek_hige_chk(){
    bool ret;
    double x,y,z;
    x=Open[1]-Low[1];//下髭
    y=High[1]-Close[1];//上ヒゲ
    z=Close[1]-Open[1];//body

    double bid,ask,now_price;
    RefreshPrice(bid, ask);
  // request.stoplimit = NormalizeDouble(1.33626,digits); //debug       SELL_STOP_LIMITとBUY_STOP_LIMITのみ使用　　　　ここでは使用しない

//  request.price = price; //debug

	//買い？売り？ と現在価格からorderTypeを見直す　　SELL_STOP_LIMITとBUY_STOP_LIMITはこの関数では対象外
//	if(orderType == OP_BUY){
		//買い
			now_price = ask;
//	}else{
		//売り
//			now_price = bid;
//    }
    
    if( 
    (Close[1]-Open[1]>0&&    
    Close[2]-Open[2]>0&&        
    Close[3]-Open[3]>0)&&
    chgPrice2Pips(y)*10 > Hige_sinnkou*10  && // Hige_sinnkouヒゲ幅　伸びている方向の幅[PIPS]　　10PIPS以上
    chgPrice2Pips(x)*10 < Hige_gyakuhoukou*10//　Hige_gyakuhoukou髭幅　反対側の幅[PIPS]
    ){
        flagbuy = true;
        Tp=chgPrice2Pips(High[1]-now_price)*10;     //利確；髭先っぽまで
        Sl=chgPrice2Pips(now_price - Low[3] )*10;  // 損切；キーとなる足の2つ前の安値
        if( Sl !=0 ){
            TPwaruSL = Tp/Sl;
        }
    }else{
        flagbuy = false;
        Tp=0.0;
        Sl=0.0;
    }
    return flagbuy;
}
bool sellchek_hige(){
    bool ret = flagsell;
    flagsell = false;
    return(ret);
}

bool sellchek_hige_chk(){
    bool ret;
    double x,y,z,a;
    x=High[1]-Open[1];//下髭
    y=Close[1]-Low[1];//上ヒゲ
    z=Open[1]-Close[1];//body

    double bid,ask,now_price;
    RefreshPrice(bid, ask);
  // request.stoplimit = NormalizeDouble(1.33626,digits); //debug       SELL_STOP_LIMITとBUY_STOP_LIMITのみ使用　　　　ここでは使用しない

//  request.price = price; //debug

	//買い？売り？ と現在価格からorderTypeを見直す　　SELL_STOP_LIMITとBUY_STOP_LIMITはこの関数では対象外
//	if(orderType == OP_BUY){
		//買い
			now_price = ask;
//	}else{
		//売り
//			now_price = bid;
//    }
if( (
    Close[1]-Open[1]<0&&    
    Close[2]-Open[2]<0&&        
    Close[3]-Open[3]<0)&&
    chgPrice2Pips(y)*10 > Hige_sinnkou*10   // Hige_sinnkouヒゲ幅　伸びている方向の幅[PIPS]　　10PIPS以上
    ){
    Close[3]-Open[3]<0;
    
    }

    
    if( 
    (Close[1]-Open[1]<0&&    
    Close[2]-Open[2]<0&&        
    Close[3]-Open[3]<0)&&
    chgPrice2Pips(y)*10 > Hige_sinnkou*10  && // Hige_sinnkouヒゲ幅　伸びている方向の幅[PIPS]　　10PIPS以上
    chgPrice2Pips(x)*10 < Hige_gyakuhoukou*10//　Hige_gyakuhoukou髭幅　反対側の幅[PIPS]
    ){
        flagsell = true;
        Tp=chgPrice2Pips(now_price-Low[1])*10;     //利確；髭先っぽまで
        Sl=chgPrice2Pips(High[3]- now_price )*10;  // 損切；キーとなる足の2つ前の安値
        if( Sl !=0 ){
            TPwaruSL = Tp/Sl;
        }
    }else{
        Tp=0.0;
        Sl=0.0;
        flagsell = false;
    }
    return flagsell;
}


void after_Buy_execute(){
	
#ifdef Lib_MyFunc_Mn
flag_buy=false;
#endif//Lib_MyFunc_Mn
}

void after_Sell_execute(){

#ifdef Lib_MyFunc_Mn
flag_sell=false;
#endif//Lib_MyFunc_Mn
}

void after_Close_Buy_execute(){
#ifdef Lib_MyFunc_Mn
flag_close_buy=false;
#endif//Lib_MyFunc_Mn

}
void after_Close_Sell_execute(){
#ifdef Lib_MyFunc_Mn
flag_close_sell=false;
#endif//Lib_MyFunc_Mn
}
