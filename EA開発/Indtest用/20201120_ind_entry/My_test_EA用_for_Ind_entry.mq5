#property tester_indicator "MyMASignal\\パターン\\_20201016_current_zigzagoutput_chg_entry動的\\ooooo.ex5"
//+------------------------------------------------------------------+
//|                                                 beard
//|                            Copyright 2017, Alexander Masterskikh |
//|
//|
//|
//|
//+------------------------------------------------------------------+
#property copyright   "2017, Alexander Masterskikh"
#property link        "https://www.mql5.com/en/users/a.masterskikh"


double Tp,Sl;
////////////////////////////////
// option  機能のON/OFF
////////////////////////////////
#define USE_position_data
////////////////////////////////
// end option
////////////////////////////////

//
//  input
//
input double Inp_nobiritu =1.0;// tp d12率 EA
input double Inp_songiriritu= 1.15;//　sl d12率 EA
input double Inp_tp_per_sl_hiritu=1.0;// tp/sl率以上でエントリー可とする
input bool Inp_VjiUse=false;// \Vjiつかうｔ、使わないF
input double Inp_para_double1 =0.1;//double para1
input double Inp_para_double2 =1.0;//double para2
input double Inp_para_double3 =0.2;//double para3
input double Inp_para_double4 =2.0;//double para4
input double Inp_para_int1 =0;//int para1
input double Inp_para_int2 =0;//int para2
input double Inp_para_int3 =0;//int para2

#ifdef aaasdfasf
input double Inp_nobiritu =1.6;// tp d12率 EA
input double Inp_songiriritu= 1.15;//　sl d12率 EA
input double Inp_tp_per_sl_hiritu=1.0;// tp/sl率以上でエントリー可とする
input bool Inp_VjiUse=false;// \Vjiつかうｔ、使わないF
input double Inp_para_double1 =0.1;//double para1
input double Inp_para_double2 =1.0;//double para2
input double Inp_para_double3 =0.2;//double para3
input double Inp_para_double4 =2.0;//double para4
input double Inp_para_int1 =0;//int para1
input double Inp_para_int2 =0;//int para2
input double Inp_para_int3 =0;//int para2
#endif



input bool Inp_OPTIMUM_tester = false;//最適化時T、単体動作時はF　グローバル変数最適化時使えないため
//input bool Inp_OPTIMUM_tester = true;//最適化時T、単体動作時はF　グローバル変数最適化時使えないため


//+------------------------------------------------------------------+ 
//| 入力                                              | 
//+------------------------------------------------------------------+ 
               input double Lots           = 0.1;     //number of lots

// 


//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
//　確定足を判断するため
datetime kakuteihanndannTime; // 新しい脚ができたか確認するため
bool flagNotTrade; //未取引フラグ　		新しい脚出現　true　　		売り買いした場合　false
bool flag_chg_ashi=false;//確定足出現：新しい脚ができたtrue ,それ以外false　　　

int handle_c;//カスタム指標のハンドル
double para[];//カスタム指標の受信パラメータ

//double local_min_price;//tmp　エントリーから最安値
//double local_max_price;//tmp　エントリーから最高値

double TPwaruSL;

//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
#define  MAX_DATA 30  // 前回値ほしいので　暫定
//#define  MAX_DATA 0
double High[MAX_DATA],Low[MAX_DATA],Open[MAX_DATA],Close[MAX_DATA];
datetime Time[MAX_DATA];// add iwa

datetime Time_cur; 
//----------------------------------------------------------------------------------------

int kol;

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
#include <_inc\\My_function_lib2.mqh>
//#include "Lib_MyFunc_Trade.mqh"
#include <_inc\\動的エントリー監視LIB\\Lib_Myfunc_Ind_entry_exit.mqh> //SetSendData_forEntry_tpsl_direct_ctrl(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots)
//#include "Lib_MyFunc_Mn.mqh"

//#include "Lib_MyFunc_MA.mqh"

//#include "Lib_MyFunc_fractal.mqh"

//#include "Lib_MyFunc_Etc.mqh"
//#include "Lib_MyFunc_sn.mqh"


// 初期化関数:f0
int OnInit()
{
   init_ema_bolinger();//debug
    init_entry_exit_ctr_forEA();//// (★EA)
//    int handle_zigzag = iCustom(Symbol(),Period(),"\\examples\\zigzag");
	//　確定足を判断するため
	OnInit_Time();


#ifdef USE_position_data
	//////////////////////////////////////////
	///// positiln deal
	/////////////////////////////////////////
	init_posision_data();
	init_deal_data();
#endif//USE_position_data

    //add 2019/08/03 時間フィルタ追加
    OnInitCSignalITF();
    
    IndOninit();
    return(0);
}// end Oninit
// calc :f1
void OnTick(void)
{
//debug IndToEA
    if(Inp_OPTIMUM_tester == true){
        get_Ind_para();
    }
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

    ///
    //IndOnTick_Entry();


#ifdef USE_position_data
	// position update
	check_ADD_position_data();
//	update_open_position(Open[0],(long)Time_cur);
	update_open_position(Close[0],(long)Time_cur);
#endif//USE_position_data

	if( kol > 10 ){
	
//	   testOrder();
	}
	RefreshPrice(bid, ask);
      //
	entry_exit_ctr_tick_exe(ask,bid);
	#ifdef debug20201230//debug20201230
 	MqlTick tick;
 	SymbolInfoTick(_Symbol, tick);
    printf("EA Tick        :"+TimeToString(tick.time)+"  now time;"+TimeToString(tick.time));//debug20201230
   tick=tick;
	#endif// debug20201230//debug20201230

#ifdef USE_HistoryDeal_test
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
		ontick_Lib_MyFunc_Mn();
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


//
//
//
//
//

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


		   }
		   // sell close check
		   else if (OrderType()==POSITION_TYPE_SELL){
				// 手法によってクローズ確認とクローズ処理　チケット単位で実施
				ret = CloseSellcheck_execute();

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
		Buyexecute(TPwaruSL,0,"");
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
		Sellexecute(TPwaruSL,0,"");//GetStrSlowBandHigh());
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

    return(false);

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
    return(false);

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
	ret = CloseSellcheck_Lib_MyFunc_Mn();
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

#property tester_indicator "TestZigzagPattern.ex5"
//

#ifdef aaaaaaaaa
int Ind_EntryNo,pre_Ind_EntryNo;
int Ind_EntryDirect;
int Ind_hyoukaNo,pre_Ind_hyoukaNo;
int Ind_hyoukaSyuhouNo,pre_Ind_hyoukaSyuhouNo;
double Ind_EntryPrice,pre_Ind_EntryPrice;
double Ind_Tp_Price,pre_Ind_Tp_Price;
double Ind_Sl_Price,pre_Ind_Sl_Price;
#endif

void IndOninit(void){
    Ind_EntryNo=-1;
    Ind_hyoukaNo=-1;
    Ind_EntryDirect=-1;
    Ind_hyoukaSyuhouNo=-1;
    Ind_EntryPrice=-1;
    Ind_Tp_Price=-1;
    Ind_Sl_Price=-1;
    
    IndReciveData();
    pre_Ind_EntryNo=Ind_EntryNo;
    
    //
    ENUM_TIMEFRAMES period = Period();
//    int handle = iCustom(Symbol(),Period(),"MyMASignal\\パターン\\_20200509_current_レンジパターン_chg_entry動的\\TestZigzagPattern_current",period);
    handle_c = iCustom(Symbol(),Period(),
    "_Ind\\ind1\\ooooo",Inp_nobiritu,Inp_songiriritu,Inp_tp_per_sl_hiritu,Inp_VjiUse,
	Inp_para_double1,Inp_para_double2,Inp_para_double3,Inp_para_double4, //add double4 20210820 線が引かれない不具合対応
	Inp_para_int1,Inp_para_int2,Inp_para_int3
	);
//    "_Ind\\ind1\\ooooo",Inp_nobiritu,Inp_songiriritu,Inp_tp_per_sl_hiritu,Inp_VjiUse);
//    "MyMASignal\\パターン\\_20201016_current_zigzagoutput_chg_entry動的\\ooooo",Inp_nobiritu,Inp_songiriritu,Inp_tp_per_sl_hiritu);
//    "MyMASignal\\パターン\\_20201016_current_zigzagoutput_chg_entry動的\\ooooo",\Inp_nobiritu,Inp_songiriritu,);
    
}
void IndOnTick_Entry(void){
    IndReciveData();
	if(IndChkChgData()==true){
	    //Entry
	    OrderExecute();
	}
}
//bool IndChkChgData(void){
//    return ( Ind_EntryNo!=-1 && Ind_EntryNo != pre_Ind_EntryNo);
//}

#ifdef dellll
//void IndReciveData(void){
    pre_Ind_EntryNo=Ind_EntryNo;
    
    double re;
    bool ret;
	ret = GlobalVariableGet("Ind_EntryNo",re);
	if(ret==true){
		Ind_EntryNo = (int)re;
	}

	ret = GlobalVariableGet("Ind_EntryDirect",re);
	if(ret==true){
		 Ind_EntryDirect= (int)re;
	}

	ret = GlobalVariableGet("Ind_hyoukaNo",re);
	if(ret==true){
		 Ind_hyoukaNo= (int)re;
	}
	ret = GlobalVariableGet("Ind_hyoukaSyuhouNo",re);
	if(ret==true){
		 Ind_hyoukaSyuhouNo= (int)re;
	}
	ret = GlobalVariableGet("Ind_EntryPrice",re);
	if(ret==true){
		Ind_EntryPrice = re;
	}
	ret = GlobalVariableGet("Ind_Tp_Price",re);
	if(ret==true){
		Ind_Tp_Price = re;
	}
	ret = GlobalVariableGet("Ind_Sl_Price",re);
	if(ret==true){
		Ind_Sl_Price =re;
	}

//debug
//testtt2();
//}
#endif //dellll
//Order実行
void OrderExecute(){//string m_name,int method_no,string c){
	double bid, ask;
	double sl,tp;
	//add 2019/08/03 時間フィルタを追加
	if(IsTimeFillter()==false){
		return;
	}
	string str_comment = MakeMethodNo_Name_Comment((int)Ind_EntryNo,IntegerToString(Ind_hyoukaNo),IntegerToString(Ind_hyoukaSyuhouNo));
    RefreshPrice(bid, ask);

//    sl = NormalizeDouble(Ind_Sl_Price,Digits());
//    tp = NormalizeDouble(Ind_Tp_Price,Digits());
    
    sl = MathAbs(Ind_EntryPrice-Ind_Sl_Price);
    int pp=55;
    if( sl < pp*Point()){
        sl=pp*Point();
    }
    tp = MathAbs(Ind_Tp_Price-Ind_EntryPrice);
    if( tp < pp*Point()){
        tp=pp*Point();
    }
    
    if(Ind_EntryDirect==-1){
        sl = NormalizeDouble(ask+sl,Digits());
        tp = NormalizeDouble(bid-tp,Digits());
        OrderSend(Symbol(),  OP_SELL,Lots,bid,3,sl,tp,str_comment,16384,0,Red); 
    }else if(Ind_EntryDirect==1){
        sl = NormalizeDouble(bid-sl,Digits());
        tp = NormalizeDouble(ask+tp,Digits());
        OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl,tp,str_comment,16384,0,Green); 
    }
}

//debug IndToEA  パラメータ
void get_Ind_para(void){
    int ret;
//    ret = CopyBuffer(handle_c,2,0,5,para);
//    ret = CopyBuffer(handle_c,7,0,5,para);
    ret = CopyBuffer(handle_c,5,0,15,para);//正解　SetIndexBuffer　の引数
#ifdef commmmm    
    int  CopyBuffer( 
   int      indicator_handle,    // 指標ハンドル 
  int      buffer_num,          // 指標バッファ番号 
  int      start_pos,            // 開始位置 
  int      count,                // 複製する量 
  double    buffer[]              // 受け取り側の配列 
  );
#endif//commmmm
}

int handle_ema;
int handle_bolinger2;
int handle_bolinger1;
void init_ema_bolinger(void){
   handle_ema = iMA(_Symbol,PERIOD_CURRENT,10,0,MODE_EMA,PRICE_CLOSE);
   handle_bolinger2=iBands(_Symbol,PERIOD_CURRENT,20,0,2.0,PRICE_CLOSE);
   handle_bolinger1=iBands(_Symbol,PERIOD_CURRENT,20,0,1.0,PRICE_CLOSE);
#ifdef commmment
   int  iBands(
  string              symbol,            // 銘柄名
  ENUM_TIMEFRAMES    period,            // 期間
  int                bands_period,     // 平均線の計算の期間
  int                bands_shift,      // 指標の水平シフト
  double              deviation,        // 標準偏差の数
  ENUM_APPLIED_PRICE  applied_price      // 価格の種類かハンドル
  );
#endif//commmmment
  
}