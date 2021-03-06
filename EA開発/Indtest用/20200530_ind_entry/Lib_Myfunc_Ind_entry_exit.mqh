//int Lots;

#ifndef EXPERT_MAGIC
#define EXPERT_MAGIC 123
#endif
            
#include <My_function_lib2.mqh>
#include "Lib_MyFunc_Trade.mqh"
#ifdef commentttt
Ind側
エントリー指示（売り買い、TPSL、現在価格、時間、依頼番号、手法番号）
Exit指示

EA側

　即時動的監視エントリー
	　指定したエントリーを、TPSL]の価格を動的に監視してクローズする。
	　エントリー時に、動的監視エントリーとして、TPSLを渡して、EA側でポーリングして制御する。エントリー名（番号、手法番号、通貨）とともに渡す。
　即時動的監視エントリーのTPSLの変更
　即時動的監視エントリーのトレーリング設定有無

　ある価格を超えたら、エントリーする。
	エントリー条件はＴpLSを指定する。または、動的に監視して実施する指定

即時動的監視エントリーの監視部分について
	監視対象のデータを保持：「動的エントリー」下記を持つ
		依頼番号、指定エントリー名（番号、手法、シンボル）の文字列
		tpSL
	監視はTickで監視する。
		動的エントリーデータで有効なものを順番に超えてないかを確認する。
			売りのエントリー
				Tp、SL　Askの価格を見る
			買いのエントリ
Tp.Sl　BIDの価格を見る




受信側ポーリング
	受信→登録、処理へ
		エントリー
		
Tick動作部分
	監視部分
		Exit監視
		トレイリング更新
#endif //commenttt
//初期化
void init_entry_exit_ctr_forEA(void){// (★EA)
	entry_exit_ctr_count = 0;
	entry_exit_ctr_start_idx=0;

    Ind_EntryNo=-1;
    Ind_hyoukaNo=-1;

    Ind_hyoukaSyuhouNo=-1;
    Ind_EntryPrice=-1;
    Ind_Tp_Price=-1;
    Ind_Sl_Price=-1;
   
	Ind_command=-1;
	Ind_EntryTime=-1;
	Ind_EntryDirect=-1;
	Ind_trailing_step_pips=-1;
	Ind_trailing_start_pips=-1;
	Ind_trailing_stop_pips=-1;
    
    
    Ind_EntryTime = 0;
    Ind_command = -1;
    
    IndReciveData();
    pre_Ind_EntryNo=Ind_EntryNo;	
}
//データ定義
int entry_exit_ctr_start_idx;

int  entry_exit_ctr_count;
struct struct_entry_exit_ctr{
	int status;//0;無効、１：監視中
	int	EntryNo;// entryno
	int	hyoukaNo;//
	int	hyoukaSyuhouNo;//hyoukaSyuhouNo
	int	command;// 動的監視有無: 0:なし、１：動的TPSLあり、２：動的TPSLありかつ　Trailing_stop
	int EntryDirect;//-1:sell, 1:buy
	string key;
	double Tp_Price;
	double Sl_Price;
	double EntryPrice;
	datetime EntryTime;
	
	//開始利益
	double trailing_step_pips;//利益出たら次のステップに移動させる幅
	//刻みh場
	double trailing_start_pips;//0はすぐにトレーリングする。
	//トータルの利益が最大どこでSTOPにするか？
	double trailing_stop_pips;//トレーリングでの離隔。
	double lots;
};
#define ENTRY_EXIT_CTR_OF_NUM 10000
struct_entry_exit_ctr	entry_exit_ctr[ENTRY_EXIT_CTR_OF_NUM];
void add_entry_exit_ctr(void){
	int i=entry_exit_ctr_count;
	
	entry_exit_ctr[i].EntryNo=Ind_EntryNo;//0;無効、１：監視中
	entry_exit_ctr[i].hyoukaNo=Ind_hyoukaNo;// entryno
	entry_exit_ctr[i].hyoukaSyuhouNo=Ind_hyoukaSyuhouNo;//hyoukaSyuhouNo
	entry_exit_ctr[i].command=Ind_command;// 動的監視有無: 0:即時Entry、１：動的TPSLあり、２：動的TPSLありかつ　Trailing_stop
	entry_exit_ctr[i].EntryDirect=Ind_EntryDirect;//-1:sell, 1:buy
	entry_exit_ctr[i].key=MakeKeyName_Comment((int)Ind_EntryNo,Ind_hyoukaNo,Ind_hyoukaSyuhouNo);
	entry_exit_ctr[i].Tp_Price=Ind_Tp_Price;
	entry_exit_ctr[i].Sl_Price=Ind_Sl_Price;
	entry_exit_ctr[i].EntryPrice=Ind_EntryPrice;
	entry_exit_ctr[i].EntryTime=Ind_EntryTime;
	//開始利益
	entry_exit_ctr[i].trailing_step_pips=Ind_trailing_step_pips;//利益出たら次のステップに移動させる幅
	//刻みh場
	entry_exit_ctr[i].trailing_start_pips=Ind_trailing_start_pips;//0はすぐにトレーリングする。
	//トータルの利益が最大どこでSTOPにするか？
	entry_exit_ctr[i].trailing_stop_pips=Ind_trailing_stop_pips;//トレーリングでの離隔。
	entry_exit_ctr[i].status = 1;//0;無効、１：監視中
}

//監視部分（★EA Tick部分へ)
void entry_exit_ctr_tick_exe(double now_price_ask,double now_price_bid){
	//受信処理
    IndReciveData();
	if(IndChkChgData()==true){
        //登録処理
        add_entry_exit_ctr();
	   
	}
	
	//監視処理
	int first_find_idx=0;
	for(int i=entry_exit_ctr_start_idx;i<entry_exit_ctr_count;i++){
		if(entry_exit_ctr[i].status == 1){//監視対象あり
			
			if(first_find_idx == 0){
				first_find_idx = i;
			}
				
			if(entry_exit_ctr[i].command == 0){//即時Entry
				OrderExecute_EntryNo(i);

			}else if(entry_exit_ctr[i].command == 1){//　監視　　動的TPSLあり
				bool flag_exit = false;
				//超えたか
				if(entry_exit_ctr[i].EntryDirect == 1){
					//buy
					if(now_price_bid >= entry_exit_ctr[i].Tp_Price){
						//exit処理
						flag_exit = true;
					}else if(now_price_bid <= entry_exit_ctr[i].Sl_Price){
						//exit処理
						flag_exit = true;
					}
				}else{
					//sell
					if(now_price_ask <= entry_exit_ctr[i].Tp_Price){
						//exit処理
						flag_exit = true;
					}else if(now_price_ask >= entry_exit_ctr[i].Sl_Price){
						//exit処理
						flag_exit = true;
					}
				}
				if(flag_exit == true){
					//exit処理 を実行
					exit_entry_exit_ctr(entry_exit_ctr[i].key);
					entry_exit_ctr[i].status= 0; //監視なしへ
				}
			}else if(entry_exit_ctr[i].command == 2){//　Trailing
				//Trailing
			}
		
		}
	}
	//読み取りのはじめのidxの更新
	if(first_find_idx > entry_exit_ctr_start_idx){
		entry_exit_ctr_start_idx = first_find_idx;
	}
	
}

void exit_entry_exit_ctr(string &key){// key  売り買い情報
	PositionSelect(Symbol());
	int total=PositionsTotal(); //　保有ポジション数	
	bool flagfinded = false;
	long  Position_ticket=0;

	double lots;//
	//double price,
	//nt slippage,
	//color arrow_color,///---
	
    for(int i=total-1; i>=0; i--)
	{
		string sret = PositionGetSymbol(i);
		if(sret !=""){
			Position_ticket=(long)PositionGetTicket(i);//ポジションの選択
			string comment = PositionGetString(POSITION_COMMENT);
			
			if(comment == key){
				flagfinded = true;
				lots=PositionGetDouble(POSITION_VOLUME);
				break;
			}
		}
	}
	if(flagfinded == true){
		bool bret = OrderClose_ticket((int)Position_ticket,key);
		if( bret == false){
			printf("error "+__FUNCTION__);
		}
	}
}

bool OrderClose_ticket(
int ticket,//
string str_comment
){
			   
			   // Selectしてあることが前提
			   
			   
			   
			   //--- 結果とリクエストの宣言
				 MqlTradeRequest request;
				 MqlTradeResult  result;
				 //int total=PositionsTotal(); //　保有ポジション数   
				 bool ret = true;
				double lots=PositionGetDouble(POSITION_VOLUME);
			   //--- 全ての保有ポジションの取捨
				// for(int i=total-1; i>=0; i--)
				   {
				   //--- 注文のパラメータ
				   // ulong  position_ticket=PositionGetTicket(i);									   // ポジションチケット
				   ulong  position_ticket = ticket; 									// ポジションチケット
				   string position_symbol=PositionGetString(POSITION_SYMBOL);						// シンボル 
				   int	  digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); 			// 小数点以下の桁数
				   ulong  magic=PositionGetInteger(POSITION_MAGIC); 								// ポジションのMagicNumber
				   //double volume=PositionGetDouble(POSITION_VOLUME);								   // ポジションボリューム
				   double volume=lots;								   // ポジションボリューム
				   ENUM_POSITION_TYPE type1=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);	 // ポジションタイプ
				   //--- ポジション情報の出力
				   PrintFormat("#%I64u %s  %s  %.2f  %s [%I64d]",
								position_ticket,
								position_symbol,
							   EnumToString(type1),
								volume,
							   DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
								magic);
				   //--- MagicNumberが一致している場合
				   if(magic==EXPERT_MAGIC)
					  {
						//string str_comment = GetStrSlowBandHigh();//★★★
					   //--- リクエストと結果の値のゼロ化
					   ZeroMemory(request);
					   ZeroMemory(result);
					   //--- 操作パラメータの設定
					   request.action	=TRADE_ACTION_DEAL; 	  // 取引操作タイプ
					   request.position =position_ticket;		  // ポジションチケット
					   request.symbol	=position_symbol;		  // シンボル 
					   request.comment = str_comment;
					   request.volume	=volume;				   // ポジションボリューム
					   request.deviation=5; 					  // 価格からの許容偏差
					   request.magic	=EXPERT_MAGIC;			   // ポジションのMagicNumber
					   //--- ポジションタイプによる注文タイプと価格の設定
					   if(type1==POSITION_TYPE_BUY)
						 {
						  request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
						  request.type =ORDER_TYPE_SELL;
						 }
					   else
						 {
						  request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
						  request.type =ORDER_TYPE_BUY;
						 }
					   //--- 決済情報の出力
					   PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type1));
					   //--- リクエストの送信
					   
					   if(!OrderSend(request,result))
						 PrintFormat("OrderSend error %d",GetLastError()); // リクエストの送信に失敗した場合、エラーコードを出力
					   //--- 操作情報  
					   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
					   //---
					   			 //flagNotTrade = false;

					  }
					  else{ ret =false;}
				   }
				   return(ret);
                }


///受信部分　EA部分
string Ind_paras[]={
"Ind_EntryNo",
"Ind_hyoukaNo",
"Ind_hyoukaSyuhouNo",
"Ind_EntryPrice",
"Ind_Tp_Price",
"Ind_Sl_Price"
"Ind_command",
"Ind_EntryTime",
"Ind_EntryDirect",
"Ind_trailing_step_pips",
"Ind_trailing_start_pips",
"Ind_trailing_stop_pips"
};

int Ind_EntryNo,pre_Ind_EntryNo;
int Ind_EntryDirect;
int Ind_hyoukaNo,pre_Ind_hyoukaNo;
int Ind_hyoukaSyuhouNo,pre_Ind_hyoukaSyuhouNo;
double Ind_EntryPrice,pre_Ind_EntryPrice;
double Ind_Tp_Price,pre_Ind_Tp_Price;
double Ind_Sl_Price,pre_Ind_Sl_Price;
int Ind_command;
datetime Ind_EntryTime;
double Ind_trailing_step_pips;
double Ind_trailing_start_pips;
double Ind_trailing_stop_pips;
double Ind_lots;

//void IndOninit(void){
//    Ind_EntryNo=-1;
//    Ind_hyoukaNo=-1;
//
//    Ind_hyoukaSyuhouNo=-1;
//    Ind_EntryPrice=-1;
//    Ind_Tp_Price=-1;
//    Ind_Sl_Price=-1;
//   
//	Ind_command=-1;
//	Ind_EntryTime=-1;
//	Ind_EntryDirect=-1;
//	Ind_trailing_step_pips=-1;
//	Ind_trailing_start_pips=-1;
//	Ind_trailing_stop_pips=-1;
//    
//    
//    Ind_EntryTime = 0;
//    Ind_command = -1;
//    
//    IndReciveData();
//    pre_Ind_EntryNo=Ind_EntryNo;
//    
//    //
//    ENUM_TIMEFRAMES period = Period();
//    int handle = iCustom(Symbol(),Period(),"MyMASignal\\パターン\\_20200509_current_レンジパターン\\TestZigzagPattern_current",period);
//    
//}
//void IndOnTick_Entry(void){
//    IndReciveData();
//	if(IndChkChgData()==true){
//        //Entry
//	    OrderExecute();
//	}
//}
bool IndChkChgData(void){
    return ( Ind_EntryNo!=-1 && Ind_EntryNo != pre_Ind_EntryNo);
}
void IndReciveData(void){
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


	ret = GlobalVariableGet("Ind_command",re);
	if(ret==true){
		Ind_command =(int)re;
	}
	ret = GlobalVariableGet("Ind_EntryTime",re);
	if(ret==true){
		Ind_EntryTime =(datetime)re;
	}
	ret = GlobalVariableGet("Ind_EntryDirect",re);
	if(ret==true){
		Ind_EntryDirect =(int)re;
	}
	ret = GlobalVariableGet("Ind_trailing_step_pips",re);
	if(ret==true){
		Ind_trailing_step_pips =re;
	}
	ret = GlobalVariableGet("Ind_trailing_start_pips",re);
	if(ret==true){
		Ind_trailing_start_pips =re;
	}
	ret = GlobalVariableGet("Ind_trailing_stop_pips",re);
	if(ret==true){
		Ind_trailing_stop_pips =re;
	}









//debug
//testtt2();
}

//Order実行
void OrderExecute_EntryNo(int i){
	double bid, ask;
	double sl,tp;
	bool ret=false;
	int flag_canNotTPSL = false;//小さすぎたら即時で実施
	//add 2019/08/03 時間フィルタを追加
	string str_comment = MakeKeyName_Comment(entry_exit_ctr[i].EntryNo,entry_exit_ctr[i].hyoukaNo,entry_exit_ctr[i].hyoukaSyuhouNo);
    RefreshPrice(bid, ask);
	double lots = entry_exit_ctr[i].lots;
//    sl = NormalizeDouble(Ind_Sl_Price,Digits());
//    tp = NormalizeDouble(Ind_Tp_Price,Digits());
    
    sl = MathAbs(entry_exit_ctr[i].EntryPrice-entry_exit_ctr[i].Sl_Price);
    int pp=55;
    if( sl < pp*Point()){
        sl=pp*Point();
        flag_canNotTPSL = true;
    }
    tp = MathAbs(entry_exit_ctr[i].Tp_Price-entry_exit_ctr[i].EntryPrice);
    if( tp < pp*Point()){
        tp=pp*Point();
        flag_canNotTPSL = true;
    }
    if(entry_exit_ctr[i].EntryDirect==-1){
        sl = NormalizeDouble(ask+sl,Digits());
        tp = NormalizeDouble(bid-tp,Digits());
        ret=OrderSend(Symbol(),  OP_SELL,lots,bid,3,sl,tp,str_comment,16384,0,Red); 
    }else if(Ind_EntryDirect==1){
        sl = NormalizeDouble(bid-sl,Digits());
        tp = NormalizeDouble(ask+tp,Digits());
        ret = OrderSend(Symbol(),  OP_BUY,lots,ask,3,sl,tp,str_comment,16384,0,Green); 
    }
    if(ret == false){
		printf("error entry __FUNCTION__");
	}


    if( flag_canNotTPSL == false){
		entry_exit_ctr[i].status = 0;// 即時としてEntry完了したので、監視しないようにする。
	}else{
		entry_exit_ctr[i].command = 1;//：動的TPSLあり　に変更し、監視対象とする。
	}
}

//void OrderExecute(double Lots,int Ind_EntryNo,int Ind_hyoukaNo,int Ind_hyoukaSyuhouNo){//string m_name,int hyoukaSyuhouNo,string c){
//	double bid, ask;
//	double sl,tp;
//	//add 2019/08/03 時間フィルタを追加
////	if(IsTimeFillter()==false){
////		return;
////	}
////string MakeKeyName_Comment(int no,int hyoukaSyuhouNo,int EntryDirect){
//	string str_comment = MakeKeyName_Comment((int)Ind_EntryNo,Ind_hyoukaNo,Ind_hyoukaSyuhouNo);
//    RefreshPrice(bid, ask);
//
////    sl = NormalizeDouble(Ind_Sl_Price,Digits());
////    tp = NormalizeDouble(Ind_Tp_Price,Digits());
//    
//    sl = MathAbs(Ind_EntryPrice-Ind_Sl_Price);
//    int pp=55;
//    if( sl < pp*Point()){
//        sl=pp*Point();
//    }
//    tp = MathAbs(Ind_Tp_Price-Ind_EntryPrice);
//    if( tp < pp*Point()){
//        tp=pp*Point();
//    }
//    
//    if(Ind_EntryDirect==-1){
//        sl = NormalizeDouble(ask+sl,Digits());
//        tp = NormalizeDouble(bid-tp,Digits());
//        OrderSend(Symbol(),  OP_SELL,Lots,bid,3,sl,tp,str_comment,16384,0,Red); 
//    }else if(Ind_EntryDirect==1){
//        sl = NormalizeDouble(bid-sl,Digits());
//        tp = NormalizeDouble(ask+tp,Digits());
//        OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl,tp,str_comment,16384,0,Green); 
//    }
//}
void testtt2(void){
    //sl tp
    printf("0.0001*10,0.001");
    test_order(0.0001*10,0.01);



    printf("0.0001,0.001");
    test_order(0.0001,0.001);

    printf("0.0003,0.001");
    test_order(0.0003,0.001);

    printf("0.0005,0.001");
    test_order(0.0005,0.001);

    printf("0.001,0.001");
    test_order(0.0005,0.001);

}

void test_order(double s,double t){
	double bid, ask;
	double sl,tp;
	//add 2019/08/03 時間フィルタを追加
	if(IsTimeFillter()==false){
		return;
	}
	string str_comment = MakeKeyName_Comment((int)Ind_EntryNo,Ind_hyoukaNo,Ind_hyoukaSyuhouNo);
    RefreshPrice(bid, ask);
    int ddd = Digits();

 //                       sl_sell = NormalizeDouble((ask+StopLoss*Point()),Digits());
//                        tp_sell = NormalizeDouble((bid-TakeProfit*Point()),Digits());

//     sl = NormalizeDouble(bid+s,Digits());
    s=50*Point();//5PIPS NG
    
    s=70*Point();//5PIPS OK
    s=60*Point();//9PIPS OK
    s=55*Point();//9PIPS OK
    s=52*Point();//9PIPS OK
    s=51*Point();//9PIPS NG
     sl = NormalizeDouble(ask+s,Digits());
    tp = NormalizeDouble(bid-t,Digits());
    
    
    OrderSend(Symbol(),  OP_SELL,0.1,bid,3,sl,tp,str_comment,16384,0,Red); 
}


string MakeKeyName_Comment(int no,int hyoukaSyuhouNo,int EntryDirect){
  string sep="#";               // 区切り文字 
  //ushort u_sep;                 // 区切り文字のコード 
  string result=sep+ IntegerToString( no)
  				+sep+ IntegerToString( hyoukaSyuhouNo)
  				+sep+ IntegerToString( EntryDirect)
  				;               // 文字列を受け取る配列 
  
  
  // debug 20200222
  //result = "123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#123456789#";
  //###       32byte分しかコメントには欠けない　　　123456789#123456789#123456789#1
  //Deal_Comment用リンク番号を先頭に付与
  return(result);   
}


//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// for Ind
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////


void init_entry_exit_ctr_forInd(void){//　for　Ind使用★　Initへ追加
	Ind_EntryNo = 0;
}

//各処理　　//　for　Ind使用★　Entry時に追加

//通常のTPSLの発注
void SetSendData_forEntry_tpsl(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots){
	int command = 0;
	Ind_EntryNo = Ind_EntryNo+1;
	int a = Ind_EntryNo;
	GlobalVariableSet("Ind_command",command);// 動的監視有無: 0:なし、１：動的TPSLあり、２：動的TPSLありかつ　Trailing_stop
	GlobalVariableSet("Ind_EntryNo",a);
	GlobalVariableSet("Ind_EntryDirect",EntryDirect);
	GlobalVariableSet("Ind_hyoukaNo",hyoukaNo);
	GlobalVariableSet("Ind_hyoukaSyuhouNo",hyoukaSyuhouNo);
	GlobalVariableSet("Ind_EntryPrice",EntryPrice);
	GlobalVariableSet("Ind_Tp_Price",Tp_Price);
	GlobalVariableSet("Ind_Sl_Price",Sl_Price);
	GlobalVariableSet("Ind_lots",lots);
	
}
 //動的監視でTPSLを実現
void SetSendData_forEntry_tpsl_direct_ctrl(int EntryDirect,int hyoukaNo,int hyoukaSyuhouNo,double EntryPrice,double Tp_Price,double Sl_Price,double lots){
	int command = 1;
	int a=Ind_EntryNo++;
	GlobalVariableSet("Ind_command",command);// 動的監視有無: 0:なし、１：動的TPSLあり、２：動的TPSLありかつ　Trailing_stop
	GlobalVariableSet("Ind_EntryNo",a);
	GlobalVariableSet("Ind_EntryDirect",EntryDirect);
	GlobalVariableSet("Ind_hyoukaNo",hyoukaNo);
	GlobalVariableSet("Ind_hyoukaSyuhouNo",hyoukaSyuhouNo);
	GlobalVariableSet("Ind_EntryPrice",EntryPrice);
	GlobalVariableSet("Ind_Tp_Price",Tp_Price);
	GlobalVariableSet("Ind_Sl_Price",Sl_Price);
	GlobalVariableSet("Ind_lots",lots);
} 