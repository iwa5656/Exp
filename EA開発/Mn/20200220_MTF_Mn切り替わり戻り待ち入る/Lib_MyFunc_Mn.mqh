//20200208_MTF_Mn切り替わり戻り待ち入る
#ifdef housinnn
	H1の目線切り替わり後、押し目がサポートされたときに入る
	①上位足H1の目線転換した
		上位足目線転換した状態：待ち状態ON
		どの方向に向かうかを記憶（期待して伸びる方向）
		
		待ち状態キャンセルは、切り上げした基点よりも逆に行き過ぎたときこの状態をキャンセル（②に行かない）
	②下位足で押し目を作ることを確認し、
		待ち状態ONの時かつ以下
		言い換えると、期待して伸びる方向へMnが切り替わったタイミング
	③その反転でEntry
	Exitは
		１HのMnの反転確認まで
			H1長期のMnが、期待して伸びる方向で無くなった時点でExit
		(M5のMnラインｓが続伸が終わるまで)
	
	必要なロジック
		各時間軸での切り替わりのタイミングと、切り替わり後の伸びる方向をTickで調べる
		

#endif


#define Lib_MyFunc_Mn 1


#include <exchng.mqh>
#include <mn\sn_mn_receve.mqh>	// 各インジの受信データ・fumc
#include <mn\My_function_lib2.mqh>

//#define USE_Tp_sl	//Tp_slを使用するかどうか？


//--- input parameters
input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
input int      calcnum=1000; //計算範囲：足の数
input int      flag_all_view_sn = 0; //0all snview,1chg

bool flag_buy;
bool flag_sell;
bool flag_close_buy;
bool flag_close_sell;
//data
int trace_at_mn_count;
int trace_mn_idx;
int trace_mn_mesen_changed_id[4];//目線切り替え判断完了したid。初期値は-1．
int MnMesen[4];//0:未決定、1上方向、-1下方向
int pre_MnMesen[4];//0:未決定、1上方向、-1下方向
int trade_condition_state;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
int condition_direction;//前提条件成立時の伸び（Entry）を期待する方向  0初期値、１上、-1下方向期待
int condition_entry_direction;//entryした方向を記憶
double condition_Mn_endvalue[4];
double condition_Mn_startvalue[4];
double condition_Mn_endChgvalue[4];
double condition_Mn_startChgvalue[4];
double 	now_Mn_endChgvalue[4];
double	now_Mn_startChgvalue[4] ;
   
double	now_Mn_startvalue[4] ;
double	now_Mn_endvalue[4];

//option 
#define USE_close_next_mn

void init_Lib_MyFunc_Mn(){
	//data ini
    flag_buy=false;
    flag_sell=false;
    flag_close_buy=false;
    flag_close_sell=false;
//    trace_mn_mesen_changed_id =-1;	
	for(int i = 0 ; i < 2;i++){
		trace_mn_mesen_changed_id[i] =-1;
		MnMesen[i]=0;//0:未決定、1上方向、-1下方向
		pre_MnMesen[i]=0;//0:未決定、1上方向、-1下方向
	}
	condition_direction = 0;
	condition_entry_direction = 0;
	//
	string symbols = _Symbol;//"GBPUSD";
	int periods[4];
	periods[0]=PERIOD_M1;
	periods[1]=PERIOD_H1;
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
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[0],"201907_Sn\\v1.5Sn_Mn\\Sn_mn_Bfordebug_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[1],"201907_Sn\\v1.5Sn_Mn\\Sn_mn_Bfordebug_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
#ifdef NOTUSE_123
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[2],"201907_Sn\\v1.5Sn_Mn\\Sn_mn_Bfordebug_All_view",
				Input_use_easy_calc,///input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
				calcnum,///input int      calcnum=1000; //計算範囲：足の数
				flag_all_view_sn///input int      flag_all_view_sn = 0; //0all snview,1chg
				);
			handle_tmp = iCustom(symbols,(ENUM_TIMEFRAMES)periods[3],"201907_Sn\\v1.5Sn_Mn\\Sn_mn_Bfordebug_All_view",
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


void	mesen_kirikawari_hantei(int i){// MnMesen,pre_MnMesen,trace_mn_mesen_changed_id[i]
	int mn_count =recive_data[i].recive_data_mn_count;
	if(mn_count < 1){
	    return;
	}
	if(trace_mn_mesen_changed_id[i] == -1 ){//現在の足が確定したことにする
	    trace_mn_mesen_changed_id[i] = mn_count-1;
	    MnMesen[i] = recive_data[i].MnDirection[trace_mn_mesen_changed_id[i]];
	    pre_MnMesen[i]=MnMesen[i];
	}
#define debug_mesen	
#ifdef debug_mesen   
   //mesen検証
   int tt = (int)recive_data[i].MnDirection[mn_count-1];
   if( MnMesen[i] !=  tt){
      int k;k=1;
         }
#endif // debug_mesen 
	
    if(trace_mn_mesen_changed_id[i] >= mn_count){
        return;// まだ、次のMnできてないならまつ
    }else{
					condition_Mn_endChgvalue[i] = recive_data[i].MnEndChgBaseValue[trace_mn_mesen_changed_id[i]-1];;
					condition_Mn_startChgvalue[i] = recive_data[i].MnStartChgBaseValue[trace_mn_mesen_changed_id[i]-1];;
               
					condition_Mn_startvalue[i] = recive_data[i].MnStartValue[trace_mn_mesen_changed_id[i]-1];;
					condition_Mn_endvalue[i] = recive_data[i].MnEndValue[trace_mn_mesen_changed_id[i]-1];;

    
    }


    bool flag_Mn_chg = false;//Mn切り替わりありなし

   pre_MnMesen[i]=MnMesen[i];
   int tmp = (int)recive_data[i].MnDirection[mn_count-1];
   MnMesen[i]=tmp;
   if(pre_MnMesen[i]!=MnMesen[i]){
      flag_Mn_chg = true;
   }
   
   
   
   
    int MnDirection = (int)recive_data[i].MnDirection[trace_mn_mesen_changed_id[i]];
    double MnEndChgBaseValue = recive_data[i].MnEndChgBaseValue[trace_mn_mesen_changed_id[i]];
    datetime MnEndChgBaseTime= recive_data[i].MnEndChgBaseTime[trace_mn_mesen_changed_id[i]];
#ifdef del
   if(mn_count -1 == trace_mn_mesen_changed_id[i]){
			   i=i;
   }else{
			   i=i;   
   }
  
    if(MnDirection == -1){
        //今の足下向きで超えたら
        if( MnEndChgBaseValue < Close[0]){
            flag_Mn_chg = true;
			MnMesen[i]=1;
			//pre_MnMesen[i]=-1;
			if(i==0){
			   i=i;
			}else{
			   i=i;
			}
        }
    
    }else if ( MnDirection == 1){
        //今の足上向きで超えたら
        if( MnEndChgBaseValue > Close[0]){
            flag_Mn_chg = true;
			MnMesen[i]=-1;
			//pre_MnMesen[i]=1;
			if(i==0){
			   i=i;
			}else{
			   i=i;
			}
        }
    }
#endif // del
    if(flag_Mn_chg == true){
		//現在の
		//pre_oder_mn_count = mn_count;
		//トレードしたMnのidxの記憶
		//trace_mn_idx = mn_count-1;

//		trade_condition_state=1;//エントリー前提条件成立状態
					//エントリーキャンセルの閾値値（上の方向きたいなら、Mnの下の末端（EndValue)）
					condition_Mn_endChgvalue[i] = recive_data[i].MnEndChgBaseValue[trace_mn_mesen_changed_id[i]];;
					condition_Mn_startChgvalue[i] = recive_data[i].MnStartChgBaseValue[trace_mn_mesen_changed_id[i]];;
               
					condition_Mn_startvalue[i] = recive_data[i].MnStartValue[trace_mn_mesen_changed_id[i]];;
					condition_Mn_endvalue[i] = recive_data[i].MnEndValue[trace_mn_mesen_changed_id[i]];;


		//set_tp_sl_kirikawari();
		trace_mn_mesen_changed_id[i] = trace_mn_mesen_changed_id[i]+1;//次のMnIdxが対象
	}else{ // ｃｈｇのMn情報を更新
					condition_Mn_endChgvalue[i] = recive_data[i].MnEndChgBaseValue[trace_mn_mesen_changed_id[i]-1];;
					condition_Mn_startChgvalue[i] = recive_data[i].MnStartChgBaseValue[trace_mn_mesen_changed_id[i]-1];;
               
					condition_Mn_startvalue[i] = recive_data[i].MnStartValue[trace_mn_mesen_changed_id[i]-1];;
					condition_Mn_endvalue[i] = recive_data[i].MnEndValue[trace_mn_mesen_changed_id[i]-1];;
	
	}

	now_Mn_endChgvalue[i] = recive_data[i].MnEndChgBaseValue[mn_count-1];
	now_Mn_startChgvalue[i] = recive_data[i].MnStartChgBaseValue[mn_count-1];
   
	now_Mn_startvalue[i] = recive_data[i].MnStartValue[mn_count-1];
	now_Mn_endvalue[i] = recive_data[i].MnEndValue[mn_count-1];
	
	
   
	
}

//kakuteiashi処理後、tick処理で判定する
//
//

//確定足のみで実施する　★確定はM1？H1？　現状はM1とする。
void ontick_kakuteiashi_Lib_MyFunc_Mn(){
	set_pattern(pre_pt);
	
	on_tick_recive_data_kakuninn();//受信処理 sn mn    

	set_pattern(now_pt);	
}
//ティックのみでする処理
void ontick_tick_Lib_MyFunc_Mn(){
   int pre_trade_condition_state = trade_condition_state;
	//各足のMn切り替わり判定、方向の判定
		for(int i = 0 ;  i < 2; i++){
			mesen_kirikawari_hantei(i);
		}
int flag_cancel = false;
		
#define debug_dd
#ifdef debug_dd_____
   printf("###ssss______________________");
   printf("nmcount[0] ="+ recive_data[0].recive_data_mn_count +" [1]= "+
      recive_data[1].recive_data_mn_count);

   printf("state="+trade_condition_state+"  c_dir= "+condition_direction +
   "  pre_MnMesen[1]="+pre_MnMesen[1]+ "  MnMesen[1]=" + MnMesen[1]+
   "  pre_MnMesen[0]="+pre_MnMesen[0]+ "  MnMesen[0]=" + MnMesen[0]);
   printf(
   "  cMn_endvalue[1]="+condition_Mn_endvalue[1] +
   "  Close[0]="+Close[0] +
   "  cMn_endvalue[0]="+condition_Mn_endvalue[0] +
   "  f_buy="+ (int)flag_buy+
   "  f_sell="+(int)flag_sell +
   "  f_close_buy="+ (int)flag_close_buy+
   "  f_close_sell="+(int)flag_close_sell +
   "  f_cancel="+(int)flag_cancel
   ); 
#endif // debug_dd
#ifdef debug_dd
if(recive_data[0].recive_data_mn_count == 3400){
   int j; j=1;
}
if(recive_data[0].recive_data_mn_count == 3350){
   int j; j=1;
}
if(recive_data[0].recive_data_mn_count == 3345){
   int j; j=1;
}
if(pre_MnMesen[1] != MnMesen[1]){
   printf("@@@@@@@@@@@@@@@@@@@@@MesenChg[1]->"+MnMesen[1]);

}
if(pre_MnMesen[0] != MnMesen[0]){
   printf("@@@@@@@@@@@@@@@@@@@@@MesenChg[0]->"+MnMesen[0]);

}
#endif // debug_dd	
	//前提条件の制御
		//前提条件判定：
			//上位足の転換が確認されたときを判定
			if( trade_condition_state==0||trade_condition_state==3){  //0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
				if(pre_MnMesen[1]!=MnMesen[1]){
					trade_condition_state=1;//エントリー前提条件成立状態
					//エントリー前提条件成立中方向　伸びる方向　上にプレイク期待なら１
					condition_direction = MnMesen[1];
				}
			}
		//キャンセル判定？？？？
			if(trade_condition_state == 1){// エントリー前提条件成立状態
			//エントリーキャンセルの閾値値を方向と逆方向の値になったら 状態をキャンセルする
				if(condition_direction ==1){
					if(condition_Mn_endvalue[1]>Close[0]){
						flag_cancel = true;
					}
				}else if( condition_direction ==-1){
					if(condition_Mn_endvalue[1]<Close[0]){
						flag_cancel = true;
					}
				}
				if(flag_cancel == true){
					//状態をキャンセル
					trade_condition_state=3;//エントリー前提条件成立状態→キャンセル
					printf("############Cancel condDir="+condition_direction+"   condition_Mn_endvalue="+condition_Mn_endvalue[1]+
					  "   Value= "+Close[0]);
				}
			}
		//前提条件成立中
			if(trade_condition_state == 1&&
			   pre_trade_condition_state == trade_condition_state //　すぐにエントリー判断すると短期長期同じ方向なのでいったん待つようにする
			   ){// エントリー前提条件成立状態
				//エントリー判定
				//上位足が切り替わりした状態、下位足の転換＋上位足の方向と一致した時
				if(condition_direction == MnMesen[0] &&
					MnMesen[0]!=pre_MnMesen[0]){
						//エントリー方向の記憶
						condition_entry_direction = condition_direction;
						//エントリー
						if(condition_direction == 1){
							flag_buy = true;
				            flag_close_buy = false;
				            flag_close_sell = true;
				        }else{
				            flag_sell = true;
				            flag_close_buy = true;
				            flag_close_sell = false;
						}
						trade_condition_state=2;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
				}
			}	
			

		//Exit判断
				//上位足がエントリー方向と逆になった場合、Close指示
			if(trade_condition_state==2){//２Entry状態
				
				//短期で目線切り替わりの時にExitとする
				 
//				if(condition_direction != MnMesen[0]){
				if(condition_direction != MnMesen[1]){
					if(condition_direction == 1){
			            flag_close_buy = true;
			            flag_close_sell = false;
			        }else{
			            flag_close_buy = false;
			            flag_close_sell = true;
					}
//					trade_condition_state=3;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
					trade_condition_state=1;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
					condition_direction =  MnMesen[1];
				}




#ifdef 0				
				if(condition_direction != MnMesen[1]){
					if(condition_direction == 1){
			            flag_close_buy = true;
			            flag_close_sell = false;
			        }else{
			            flag_close_buy = false;
			            flag_close_sell = true;
					}
//					trade_condition_state=3;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
					trade_condition_state=1;//0初期状態、１エントリー前提条件成立状態、２Entry状態、３何もない
					condition_direction =  MnMesen[1];
				}
#endif //0				
			}


#ifdef debug_dd
   printf("###ssss______________________");
   printf("nmcount[0] ="+ recive_data[0].recive_data_mn_count +" [1]= "+
      recive_data[1].recive_data_mn_count);

   printf("state="+trade_condition_state+"  c_dir= "+condition_direction +
   "  pre_MnMesen[1]="+pre_MnMesen[1]+ "  MnMesen[1]=" + MnMesen[1]+
   "  pre_MnMesen[0]="+pre_MnMesen[0]+ "  MnMesen[0]=" + MnMesen[0]);
   printf(
   "  cMn_endchg[1]= "+condition_Mn_endChgvalue [1] +
   "  cMn_endchg[0]= "+condition_Mn_endChgvalue[0] 
   );
   printf(
   "  cMn_endvalue[1]="+condition_Mn_endvalue[1] +
   "  cMn_endvalue[0]="+condition_Mn_endvalue[0] +
   "  Close[0]="+Close[0] +
   "  f_buy="+ (int)flag_buy+
   "  f_sell="+(int)flag_sell +
   "  f_close_buy="+ (int)flag_close_buy+
   "  f_close_sell="+(int)flag_close_sell +
   "  f_cancel="+(int)flag_cancel
   );   
   printf("###eeee______________________");
    
#endif // debug_dd		
				
}
void ontick_Lib_MyFunc_Mn(){

#ifdef old_logic_dell
	int pre_mn_count = recive_data[0].recive_data_mn_count;
	set_pattern(pre_pt);
	
	on_tick_recive_data_kakuninn();//受信処理 sn mn    

	set_pattern(now_pt);


	//判断
	int mn_count =recive_data[0].recive_data_mn_count;
	if(trace_mn_mesen_changed_id == -1 ){//現在の足が確定したことにする
	    trace_mn_mesen_changed_id = mn_count-1;
	}
	//受信前後で変化があったとき且つ指定のパターンになったとき
//	if( 
//		pre_pt[0].pt[0]!=now_pt[0].pt[0] ||
//		pre_pt[0].pt[1]!=now_pt[0].pt[1] ||
//		pre_pt[0].pt[2]!=now_pt[0].pt[2] ||
//		pre_pt[0].pt[3]!=now_pt[0].pt[3] 
//	){
	    if (pre_oder_mn_count +1 ==(int)mn_count){
	        tmp=1;
	    }
	    if (pre_oder_mn_count +2 ==(int)mn_count){
	        tmp=2;
	    }
	    if (pre_oder_mn_count +3 == (int)mn_count){
	        tmp=3;
	    }
	    if(pre_mn_count != mn_count){
	        tmp = 4;
	    }
	    
	    // MnEndChg超えたときにEntry
#ifdef commmmmm
	    超えた判定をどうするか？　今まではSN確定で、
	    足確定ではなくこえたらにしてみる
	    
	    現在の最終Mnの足のEndChgを超えたときMn湖心されるはず
	    その時Mn確定してそこで、パターンが確定するはず。
#endif //commmmmmm	    
	    if(trace_mn_mesen_changed_id >= mn_count){
	        return;// まだ、次のMnできてないならまつ
	    }
	    bool flag_Mn_chg = false;//Mn切り替わりありなし
        int MnDirection = (int)recive_data[0].MnDirection[trace_mn_mesen_changed_id];
	    double MnEndChgBaseValue = recive_data[0].MnEndChgBaseValue[trace_mn_mesen_changed_id];
	    datetime MnEndChgBaseTime= recive_data[0].MnEndChgBaseTime[trace_mn_mesen_changed_id];
#define debug1
#ifdef debug1
        datetime MnStartTime= recive_data[0].MnStartTime[trace_mn_mesen_changed_id];
#endif //debug	    
	    
	    if(MnDirection == -1){
	        //今の足下向き
	        if( MnEndChgBaseValue < Close[0]){
	            flag_buy = true;
	            flag_Mn_chg = true;
	            flag_close_buy = false;
	            flag_close_sell = true;
	        }
	    
	    }else if ( MnDirection == 1){
	        //今の足下向き
	        if( MnEndChgBaseValue > Close[0]){
	            flag_sell = true;
	            flag_Mn_chg = true;
	            flag_close_buy = true;
	            flag_close_sell = false;
	        }
	    }
	    if(flag_Mn_chg == true){
			//現在の
			pre_oder_mn_count = mn_count;
			//トレードしたMnのidxの記憶
			trace_mn_idx = mn_count-1;


			set_tp_sl_kirikawari();
			trace_mn_mesen_changed_id = trace_mn_mesen_changed_id+1;//次のMnIdxが対象



	     //   パターン成立？
	        //成立
	        
	        //不成立
	     //       flag_buy = false;
	     //       flag_sell = false;
	    }

#ifdef dellll	
		//指定のパターン
		struct_pattearn trade_pt[1];
		//3222->222
		↓
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
			int MnDirection1 = (int)//最後が形成したときのNMより前のものを使用する。
			    recive_data[0].MnDirection[mn_count-1-1];
			if( MnDirection1 == -1){
				flag_buy = true;
			}else{  
				flag_sell = true;
			} 
			set_tp_sl();
#ifdef USE_Tp_sl
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
#endif //USE_Tp_sl


			//現在の
			pre_oder_mn_count = mn_count;
			
			
			//トレードしたMnのidxの記憶
			trace_mn_idx = mn_count-1;
		}
#endif // dellll	

//	}


	//データコピー
#endif //old_logic_dell
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
    ret = flag_close_sell;
//    if(trace_at_mn_count +1 == recive_data[0].recive_data_mn_count){
        //ret = true;
    //}
    return(ret);
//    return(GetAfter_bar_candle()>60);
}

bool CloseBuycheck_Lib_MyFunc_Mn(){
    bool ret=false;
    ret = flag_close_buy;
//    if(trace_at_mn_count +1 == recive_data[0].recive_data_mn_count){
//        ret = true;
    //}
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
    Sl = 20000;
#endif //USE_close_next_mn    
}


void set_tp_sl_kirikawari(){

    double bid,ask,now_price;
    RefreshPrice(bid, ask);
    
    int mn_count =recive_data[0].recive_data_mn_count;
    double start_value = recive_data[0].MnStartValue[trace_mn_mesen_changed_id[0]];//基準の始まり
    double end_value = recive_data[0].MnEndValue[trace_mn_mesen_changed_id[0]];//基準の終わり

    double direct = recive_data[0].MnDirection[trace_mn_mesen_changed_id[0]];
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
    int idx = trace_mn_mesen_changed_id[0];
    double t=ask-bid;
    double d=chgPrice2Pips(MathAbs(start_value - end_value))*10;//point  /10でPIPS
    double pf = Tp/Sl;
    printf(s+"Mnidx="+idx+"Tp:"+Tp+"  Sl:"+Sl+"D:"+d+"pf:"+pf);
    double aaa = 0;
#ifdef USE_close_next_mn
    trace_at_mn_count = trace_mn_mesen_changed_id[0];
    Tp = 20000;
//    Sl = 20000;
#endif //USE_close_next_mn    
}