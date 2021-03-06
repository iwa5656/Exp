#define Lib_MyFunc_Mn 1


#include <exchng.mqh>
#include <mn\sn_mn_receve.mqh>	// 各インジの受信データ・fumc
#include <mn\My_function_lib2.mqh>


//--- input parameters
input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
input int      calcnum=1000; //計算範囲：足の数
input int      flag_all_view_sn = 0; //0all snview,1chg

bool flag_buy;
bool flag_sell;
//data
int trace_at_mn_count;
//option 
#define USE_close_next_mn

void init_Lib_MyFunc_Mn(){
	//data ini
    flag_buy=false;
    flag_sell=false;	
	//
	string symbols = _Symbol;//"GBPUSD";
	int periods[4];
	periods[0]=PERIOD_M1;
	periods[1]=PERIOD_M5;
	periods[2]=PERIOD_M15;
	periods[3]=PERIOD_M30;



	//init_sn_mn_data_recive();// debug 20200101
		init_struct_sn_mn_data_receve(recive_data[0],"sn_mn"+symbols+IntegerToString(periods[0]),symbols,periods[0]);
		init_View_flag(0,1,1,1,1,1); //##1参照
		init_struct_sn_mn_data_receve(recive_data[1],"sn_mn"+symbols+IntegerToString(periods[1]),symbols,periods[1]);
		init_View_flag(1,1,1,1,1,1); //##1参照
		init_struct_sn_mn_data_receve(recive_data[2],"sn_mn"+symbols+IntegerToString(periods[2]),symbols,periods[2]);
		init_View_flag(2,1,1,1,1,1); //##1参照
		init_struct_sn_mn_data_receve(recive_data[3],"sn_mn"+symbols+IntegerToString(periods[3]),symbols,periods[3]);
		init_View_flag(3,1,1,1,1,1); //##1参照
		
		init_recive_data();// 受信データの初期化
	
	/// インジを複数作成する
		//icustom  indBs
			int handle_tmp;
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[0],"201907_Sn\\v1.4Sn_Mn\\Sn_mn_Bfordebug_Not_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
#ifdef NOTUSE_123
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[1],"201907_Sn\\v1.4Sn_Mn\\Sn_mn_Bfordebug_Not_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[2],"201907_Sn\\v1.4Sn_Mn\\Sn_mn_Bfordebug_Not_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[3],"201907_Sn\\v1.4Sn_Mn\\Sn_mn_Bfordebug_Not_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
#endif// NOTUSE_123
}

void OnDeinit_Lib_MyFunc_Mn(){
	printf("ondeinit_Lib_MyFunc_Mn");
	//--- 作業終了後にタイマーを破壊する 
	EventKillTimer();

}
struct_pattearn pre_pt[NUM_OF_USE_INDICATE];
struct_pattearn now_pt[NUM_OF_USE_INDICATE];
void set_pattern(struct_pattearn &a[]){
	
	for(int i = 0; i<NUM_OF_USE_INDICATE;i++){
	    int count = recive_data[i].recive_data_mn_count-1;
		if(count >12){
		    for(int k = 0; k< NUM_OF_USE_INDICATE ;k++){
			    a[i].pt[k]=recive_data[i].MnPt[count-1-1].pt[k];
			}
		}
	}
}
int pre_oder_mn_count;
int tmp;
void ontick_Lib_MyFunc_Mn(){
	
	set_pattern(pre_pt);
	
	on_tick_recive_data_kakuninn();//受信処理 sn mn    

	set_pattern(now_pt);


	//判断
	//受信前後で変化があったとき且つ指定のパターンになったとき
	int mn_count =recive_data[0].recive_data_mn_count;
	if(
		pre_pt[0].pt[0]!=now_pt[0].pt[0] ||
		pre_pt[0].pt[1]!=now_pt[0].pt[1] ||
		pre_pt[0].pt[2]!=now_pt[0].pt[2] ||
		pre_pt[0].pt[3]!=now_pt[0].pt[3] 
	){
	    if (pre_oder_mn_count +1 ==(int)mn_count){
	        tmp=1;
	    }
	    if (pre_oder_mn_count +2 ==(int)mn_count){
	        tmp=2;
	    }
	    if (pre_oder_mn_count +3 == (int)mn_count){
	        tmp=3;
	    }
	
	
		//指定のパターン
		struct_pattearn trade_pt[1];
		//3222->222
		trade_pt[0].pt[0]=2;
		trade_pt[0].pt[1]=2;
		trade_pt[0].pt[2]=2;
		trade_pt[0].pt[3]=0;

		if(
			trade_pt[0].pt[0]==now_pt[0].pt[0] &&
			trade_pt[0].pt[1]==now_pt[0].pt[1] &&
			trade_pt[0].pt[2]==now_pt[0].pt[2] 
		){
			//成立
			int MnDirection = (int)//最後が形成したときのNMより前のものを使用する。
			    recive_data[0].MnDirection[mn_count-1-1];
			if( MnDirection == -1){
				flag_buy = true;
			}else{  
				flag_sell = true;
			} 
			set_tp_sl();
			double pf = Tp/Sl;
			if(pf < 0 ){
			    flag_buy = false;
			    flag_sell = false;
			}
			if(Tp < 0 || Sl < 0){
			    flag_buy = false;
			    flag_sell = false;
			}
			if(pf < 1 ){
			//    flag_buy = false;
			//    flag_sell = false;
			}
			//現在の
			pre_oder_mn_count = mn_count;
		}
	

	}


	//データコピー
}


bool buycheck_Lib_MyFunc_Mn(){
	bool ret=false;
	ret = flag_buy;
	return ret;
}
bool sellcheck_Lib_MyFunc_Mn(){
	bool ret=false;
	ret = flag_sell;
	return ret;
}

bool CloseSellcheck_Lib_MyFunc_Mn(){
    bool ret=false;
    if(trace_at_mn_count +1 == recive_data[0].recive_data_mn_count){
        ret = true;
    }
    return(ret);
//    return(GetAfter_bar_candle()>60);
}

bool CloseBuycheck_Lib_MyFunc_Mn(){
    bool ret=false;
    if(trace_at_mn_count +1 == recive_data[0].recive_data_mn_count){
        ret = true;
    }
    return(ret);
//    return(GetAfter_bar_candle()>60);
}

void set_tp_sl(){

    double bid,ask,now_price;
    RefreshPrice(bid, ask);
    
    int mn_count =recive_data[0].recive_data_mn_count;
    double start_value = recive_data[0].MnStartValue[mn_count-2];//基準の始まり
    double end_value = recive_data[0].MnEndValue[mn_count-2];//基準の終わり

    double direct = recive_data[0].MnDirection[mn_count-2];
    //Bid（ビッド）　→　買いたい人が提示する希望価格
    //Ask（アスク） →　売りたい人が提示する希望価格
    //自分が買いたい時 →　売りたい人の提示している価格を見る　→ Askを見る
    //自分が売りたい時　→ 買いたい人の提示している価格を見る　→ Bidを見る
    string s="";    
    if(direct == -1){
        //buy
        now_price = ask;
        Tp = chgPrice2Pips((start_value - now_price))*10;
        Sl = chgPrice2Pips((now_price - end_value))*10;
        s="buy";
    }else{
        //sell
        now_price = bid;
        Tp = chgPrice2Pips((now_price - start_value))*10;
        Sl = chgPrice2Pips((end_value - now_price))*10;
        s="sel";
    }
    int idx = mn_count-2;
    double t=ask-bid;
    double d=chgPrice2Pips(MathAbs(start_value - end_value))*10;//point  /10でPIPS
    double pf = Tp/Sl;
    printf(s+"Mnidx="+idx+"Tp:"+Tp+"  Sl:"+Sl+"D:"+d+"pf:"+pf);
    double aaa = 0;
#ifdef USE_close_next_mn
    trace_at_mn_count = mn_count;
    Tp = 20000;
#endif //USE_close_next_mn    
}