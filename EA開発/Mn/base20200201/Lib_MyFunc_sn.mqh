//input
input double AD_Nobi_Ritu = 1.0;//AD伸び率　同じだけ伸びるのであれば1.0
input double Songiri_Asobi_PIPS =0.0;//損切の基準を増やすPIPS　あそび
input int Filter_K_no =-1;//Kインプットの番号によってどう変わるかを考察する1-11ぐらい？
//data

#define NUM_OF_RECIVE_DATA 19
double recive_entry[NUM_OF_RECIVE_DATA];
double recive_entry_old[NUM_OF_RECIVE_DATA];
string key_name_prefix;
bool flag_chg_sn_entrydata;// エントリーデータの変化あり　true、エントリーデータ変化なしfalse
int handle_sn;
bool flag_sn_buy;
bool flag_sn_sell;
double Tp;
double Sl;
int view_debub_count;
//init
void init_Lib_MyFunc_sn(){
	flag_chg_sn_entrydata = false;
	flag_sn_buy = false;
	flag_sn_sell= false;
	init_recive_sn_entry_key_name_prefix();
	for(int i = 0 ; i< NUM_OF_RECIVE_DATA;i++){
		recive_entry[i] = 0;
		recive_entry_old[i] = 0;
	}
	
//	handle_sn = iCustom(Symbol(),PERIOD_M15,"\\201907_Sn\\v0.7目線頂点SN確認用\\My_矢印テストmesen_頂点の表示_データ出力",
	handle_sn = iCustom(Symbol(),Period(),"\\201907_Sn\\v0.7目線頂点SN確認用\\My_矢印テストmesen_頂点の表示_データ出力",
	0,//input int      Input_use_easy_calc=1; //0:計算範囲少なく,1:Full
	1000,//input int      calcnum=1000; //計算範囲：足の数
	0//input int      flag_all_view_sn = 0; //0all snview,1chg
		
	
	);

	view_debub_count = 0;
	
}
void init_recive_sn_entry_key_name_prefix(){
	key_name_prefix = PeriodToString(_Period)+_Symbol;
}


//ontick
void ontick_Lib_MyFunc_sn(){
    double now_price = Close[0];
	// データ取得
	Sn_recive_entry(recive_entry,key_name_prefix);
	Sn_recive_entry_diff_chk();//flag_chg_sn_entrydata
	
	if( flag_chg_sn_entrydata == true){// 受信データ変化
		//エントリー可能か判断
		view_debug_recive_entry();//エントリー受信データ出力


		//fillter Z
		if(Filter_K_no == -1|| Filter_K_no ==recive_entry[4]){// [4]　SnEntry_Zno
			
	//		if(direct==1){// buy
			if( recive_entry[1] == 1 ){// buy
				flag_sn_buy =true;
			}else{// sel
				flag_sn_sell = true;
	//			//Tp = AD*1-chgPrice2Pips(MathAbs(D-SnEntry_Price))*10;
	//			Tp = (recive_entry[6]-chgPrice2Pips(MathAbs(recive_entry[11]-recive_entry[0])))*10;
	//			//Sl =chgPrice2Pips(MathAbs(SnEntry_Price-A))*10;
	//			Sl =chgPrice2Pips(MathAbs(recive_entry[0]-recive_entry[9]))*10;
			}
	#ifdef izen
			//Tp = AD*1-chgPrice2Pips(MathAbs(D-SnEntry_Price))*10;
	//			Tp = (recive_entry[6]-chgPrice2Pips(MathAbs(recive_entry[11]-recive_entry[0])))*10;
			Tp = (recive_entry[6]-chgPrice2Pips(MathAbs(recive_entry[11]-now_price)))*10;
			//Sl =chgPrice2Pips(MathAbs(SnEntry_Price-A))*10;
	//			Sl =chgPrice2Pips(MathAbs(recive_entry[0]-recive_entry[9]))*10;
			Sl =chgPrice2Pips(MathAbs(now_price-recive_entry[9]))*10;
	#endif
	        // Tp = AD*AD_Nobi_Ritu
			Tp = (recive_entry[6] * AD_Nobi_Ritu)*10; // AD伸び率分だけTP設定
			//Sl =chgPrice2Pips(MathAbs(SnEntry_Price-A))*10;
			Sl =chgPrice2Pips(MathAbs(now_price-recive_entry[9]))*10  + Songiri_Asobi_PIPS*10;


			Sl=Sl;
		}	
	}

	//後処理　過去データ用に保存
	Sn_rec_recive_entry();
}

bool buychek_sn(){
	bool flag = flag_sn_buy;
	flag_sn_buy = false;
	return(flag);	
}
bool sellchek_sn(){
	bool flag = flag_sn_sell;
	flag_sn_sell = false;
	return(flag);	
}





//受信部分 確保された配列に格納、　　引数は配列名とプレフィックス(時間軸と通貨名）
void Sn_recive_entry(double & getdata[],string key_name_prefix){

	getdata[0]=GlobalVariableGet("SnEntry_Price"+key_name_prefix);
	getdata[1]=GlobalVariableGet("SnEntry_Direct"+key_name_prefix);
	getdata[2]=GlobalVariableGet("SnEntry_PreA_Price"+key_name_prefix);
	getdata[3]=GlobalVariableGet("SnEntry_PreAb_PIPS"+key_name_prefix);
	getdata[4]=GlobalVariableGet("SnEntry_Zno"+key_name_prefix);
	getdata[5]=GlobalVariableGet("SnEntry_Sendid"+key_name_prefix);

	getdata[6]=GlobalVariableGet("SnEntry_AD_PIPS"+key_name_prefix);
	getdata[7]=GlobalVariableGet("SnEntry_a_Price"+key_name_prefix);
	getdata[8]=GlobalVariableGet("SnEntry_b_Price"+key_name_prefix);
	getdata[9]=GlobalVariableGet("SnEntry_A_Price"+key_name_prefix);
	getdata[10]=GlobalVariableGet("SnEntry_C_Price"+key_name_prefix);
	getdata[11]=GlobalVariableGet("SnEntry_D_Price"+key_name_prefix);
	getdata[12]=GlobalVariableGet("SnEntry_snidx"+key_name_prefix);
	getdata[13]=GlobalVariableGet("tmp_pre_kitenn_snidx"+key_name_prefix);
	getdata[14]=GlobalVariableGet("SnEntry_mesen_idx"+key_name_prefix);
	getdata[15]=GlobalVariableGet("SnEntry_tmptime"+key_name_prefix);
}

void view_debug_recive_entry(){
	string st = "";
		printf("["+view_debub_count+"]"+
"SnEntry_Price="+		recive_entry[0]+
"SnEntry_Direct="+		recive_entry[1]
);

		printf("SnEntry_PreA_Price="+	recive_entry[2]+
"SnEntry_PreAb_PIPS="+	recive_entry[3]);

		printf("SnEntry_Zno="+			recive_entry[4]+
"SnEntry_Sendid="+		recive_entry[5]);

		printf("SnEntry_AD_PIPS="+		recive_entry[6]+
"SnEntry_a_Price="+		recive_entry[7]);

		printf("SnEntry_b_Price="+		recive_entry[8]+
"SnEntry_A_Price="+		recive_entry[9]);

		printf("SnEntry_C_Price="+		recive_entry[10]+
"SnEntry_D_Price="+		recive_entry[11]);

		printf("SnEntry_snidx="+		recive_entry[12]+
"tmp_pre_kitenn_snidx="+recive_entry[13]
);

datetime tt = (datetime)recive_entry[15];
printf("SnEntry_mesen_idx="+		recive_entry[14]+
"SnEntry_tmptime="+recive_entry[15]+"SnEntry_tmptime="+TimeToString(tt)
);


}



void	Sn_rec_recive_entry(){
	
	for(int i= 0 ; i< NUM_OF_RECIVE_DATA;i++){
		recive_entry_old[i] = recive_entry[i];
	}
}

void	Sn_recive_entry_diff_chk(){//flag_chg_sn_entrydata
	int i;
	flag_chg_sn_entrydata = false;
	for(i= 0 ; i< NUM_OF_RECIVE_DATA;i++){
		if(	recive_entry_old[i] != recive_entry[i] ){
			flag_chg_sn_entrydata = true;
			//return;
			break;
		}
	}
}



