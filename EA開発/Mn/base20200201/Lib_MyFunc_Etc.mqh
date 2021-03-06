
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+ 
//| 作成を処理する方法の列挙                                              | 
//+------------------------------------------------------------------+ 
enum Creation 
 { 
  Call_iEnvelopes,       // iEnvelopes を使用する 
  Call_IndicatorCreate,   // IndicatorCreateを使用する 
  Call_iRSI,             // iRSI を使用する 
  
  Call_iStochastic,       // use iStochastic を使用する 


 }; 
//--- 入力パラメータ 
input Creation             Envelopetype=Call_iEnvelopes;     // 関数の種類 
input int                  ma_period1=14;             // 移動平均の期間 
input int                  ma_shift1=0;               // シフト 
input ENUM_MA_METHOD       ma_method1=MODE_SMA;       // 平滑化の種類 
input ENUM_APPLIED_PRICE   applied_price_Envelope=PRICE_CLOSE; // 価格の種類 
input double               deviation1=0.2;//0.5;             // 堺の移動平均からの偏差 
input string               Envelopesymbol=" ";               // シンボル 
input ENUM_TIMEFRAMES     period1=PERIOD_CURRENT;     // 時間軸 
//--- 指標バッファ 
double         UpperBuffer[]; 
double         LowerBuffer[]; 
//--- iEnvelopes 指標ハンドルを格納する変数 
int    Envelopehandel; 
//--- 格納に使用される変数 
string EnvelopeName=Envelopesymbol; 
//--- チャートでの指標名 
string short_name; 
//--- Envelopes 指標に値の数を保存 
int    bars_calculated=0; 
//----------------------------------------------------------------------------------------

//////// EMA
input int EMA_period_A = 1200; // EMAの移動平均の期間
input ENUM_APPLIED_PRICE   EMAapplied_price=PRICE_CLOSE; // 価格の種類 
input ENUM_MA_METHOD       EMA_method=MODE_EMA;       // 平滑化の種類 
int EMAhandle_A;
double bufferEMA_A[];

//////// EMA
int EMAhandle_B;
double bufferEMA_B[];
input int EMA_period_B = 300; // EMAの移動平均の期間


//////// EMA
int EMAhandle_C;
double bufferEMA_C[];
input int EMA_period_C = 24; // EMAの移動平均の期間
//----------------------------------------------------------------------------------------


/////// STC Stochastic
//--- 入力パラメータ 
input Creation             type1=Call_iStochastic;     // 関数の種類 
input int                  Kperiod1=9;                 // K 期間（計算に使用されるバーの数） 
input int                  Dperiod1=3;                 // D 期間（主要な平滑化の期間） 
input int                  slowing1=3;                 // 最終平滑化期間  
input ENUM_MA_METHOD       STCma_method=MODE_SMA;       // 平滑化の種類   
input ENUM_STO_PRICE       price_field1=STO_LOWHIGH;   // 確率の計算方法 
input string               symbol1=" ";               // シンボル 
input ENUM_TIMEFRAMES     STCperiod=PERIOD_CURRENT;     // 時間軸 
//--- 指標バッファ 
double         StochasticBuffer[]; 
double         SignalBuffer[]; 
//---STC iStochastic 指標ハンドルを格納する変数 
int    STChandle; 
//--- 格納に使用される変数 
string name1=symbol1; 

//----------------------------------------------------------------------------------------
////// RSI 
//--- 入力パラメータ 
//input Creation             type1=Call_iRSI;               // 関数の種類 
input int                  RSIma_period=14;                 // 平均期間 
input ENUM_APPLIED_PRICE   RSIapplied_price=PRICE_CLOSE;   // 価格の種類 
input string               RSIsymbol=" ";                   // シンボル 
input ENUM_TIMEFRAMES     RSIperiod=PERIOD_CURRENT;       // 時間軸 
//--- 指標バッファ 
double         iRSIBuffer[]; 
//--- iRSI 指標ハンドルを格納する変数 
int    RSIhandle; 



//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------

// bolinger
int handle_Bolinger1,handle_Bolinger2,handle_Bolinger3;
int handle_Bolinger1_H1,handle_Bolinger2_H1,handle_Bolinger3_H1;
double Bolinger_bufferMiddle1[],Bolinger_bufferUpper1[],Bolinger_bufferLower1[];// 0;Middle 1:Upper 2:lower
double Bolinger_bufferMiddle1_H1[],Bolinger_bufferUpper1_H1[],Bolinger_bufferLower1_H1[];// 0;Middle 1:Upper 2:lower

double Bolinger_bufferMiddle2[],Bolinger_bufferUpper2[],Bolinger_bufferLower2[];// 0;Middle 1:Upper 2:lower
double Bolinger_bufferMiddle3[],Bolinger_bufferUpper3[],Bolinger_bufferLower3[];// 0;Middle 1:Upper 2:lower

double sigma;//現在価格が何σか　　Fast　M15
double sigma_H1;//現在価格が何σか　　H1足
double sigma_1;//1σの価格幅　　Fast　M15
double sigma_1_H1;//1σの価格幅　　H1足


//----------------------------------------------------------------------------------------
//GMMA
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//////  
input ENUM_MA_METHOD xMA_Method=MODE_EMA; // Averaging method
input int TrLength1=3;   // 1 trader averaging period 
input int TrLength2=5;   // 2 trader averaging period 
input int TrLength3=8;   // 3 trader averaging period 
input int TrLength4=10;  // 4 trader averaging period 
input int TrLength5=12;  // 5 trader averaging period
input int TrLength6=15;  // 6 trader averaging period 

input int InvLength1=30; // 1 investor averaging period
input int InvLength2=35; // 2 investor averaging period
input int InvLength3=40; // 3 investor averaging period
input int InvLength4=45; // 4 investor averaging period
input int InvLength5=50; // 5 investor averaging period
input int InvLength6=60; // 6 investor averaging period

input int xPhase=100;                 // Smoothing parameter
input ENUM_APPLIED_PRICE IPC=PRICE_CLOSE; // Price constant
input int Shift=0;                    // Horizontal shift of the indicator in bars
#define	MAX_PASS 10	// 過去データの保存する数
//----------------------------------------------------------------------------------------
int handle_GMMA;
double bufferGMMAFast1[];
double bufferGMMAFast2[];
double bufferGMMAFast3[];
double bufferGMMAFast4[];
double bufferGMMAFast5[];
double bufferGMMAFast6[];
double bufferGMMASlow1[];
double bufferGMMASlow2[];
double bufferGMMASlow3[];
double bufferGMMASlow4[];
double bufferGMMASlow5[];
double bufferGMMASlow6[];

double bufferKairiritu[];	//　かい離率 [%]
double bufferHennkaritu[];	//　変化率	[価格/1h]	1h あたりの変化量（価格の変化量）
int TrrendPattern_Slow[];		//　長期トレンドがパーフェクトか？ 1 UP 　0 なし　-1 DN
int TrrendPattern_Fast[];		//　短期トレンドがパーフェクトか？ 1 UP 　0 なし　-1 DN
int TrrendPattern_ALL[];			//　長期＆短期トレンドがパーフェクトか？ 1 UP 　0 なし　-1 DN
int bufferLocationGMMA_UP[];		// GMMAの位置　（トレンド方向によって意味が異なる）　UP方向
int bufferLocationGMMA_DN[];		// GMMAの位置　（トレンド方向によって意味が異なる）　DN方向

//----------------------------------------------------------------------------------------
               double xMA4_cur_m15 [],     
               xMA4_prev_m15 [],
               xMA4_2p_m15 [],
               xMA5_prev_m15 [],
               xMA8_cur_m15 [],
               xMA8_prev_m15 [],
               xMA8_2p_m15 [],
               xMA8_cur [],
               xMA8_prev [],
               xMA8_2p [],
               xMA8_3p [],
               xMA5_cur [],
               xMA5_prev [],
               xMA5_2p [],
               xMA13_cur [],
               xMA13_prev [],
               xMA13_2p [],
               xMA60_cur [],
               xMA60_prev [],
               xMA60_2p [],
               xMA24_cur_h1 [];
               int hMA4_cur_m15 ,
               hMA4_prev_m15 ,
               hMA4_2p_m15 ,
               hMA5_prev_m15 ,
               hMA8_cur_m15 ,
               hMA8_prev_m15 ,
               hMA8_2p_m15 ,
               hMA8_cur ,
               hMA8_prev ,
               hMA8_2p ,
               hMA8_3p ,
               hMA5_cur ,
               hMA5_prev ,
               hMA5_2p ,
               hMA13_cur ,
               hMA13_prev ,
               hMA13_2p ,
               hMA60_cur ,
               hMA60_prev ,
               hMA60_2p ,
               hMA24_cur_h1 ;
//----------------------------------------------------------------------------------------




///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

bool STC_K_D_GoldenCross(int i){
	bool flag =
      StochasticBuffer[1+i]<SignalBuffer[1+i]	&&					// main K がDを上抜き
      StochasticBuffer[0+i]>=SignalBuffer[0+i]						//
	;

	return flag;
}

bool STC_K_D_DedCross(int i){
	bool flag =
		StochasticBuffer[1+i]>SignalBuffer[1+i]	&&					// main K がDをした抜き
		StochasticBuffer[0+i]<=SignalBuffer[0+i]						//
	
	
	;
	
	return flag;
}

bool STC_K_IsKawaresugi_Area(){
	bool flag =  StochasticBuffer[0]>80.0;
	;
	
	return flag;
}

bool STC_K_IsUraresugi_Area(){
	bool flag =  StochasticBuffer[0]<20.0;
	;
	
	return flag;
}
bool STC_D_IsKawaresugi_Area(){
	bool flag =  SignalBuffer[0]>80.0;
	;
	
	return flag;
}

bool STC_D_IsUraresugi_Area(){
	bool flag =  SignalBuffer[0]<20.0;
	;
	
	return flag;
}

bool STC_D_EgeHighToMidCross( int shift){
	bool flag =
		SignalBuffer[1+shift]	> 80.0 &&					// 
		SignalBuffer[0+shift] <= 80.0 						//
	;
	return flag;
}

bool STC_D_EgeLowToMidCross(int shift){
	bool flag =
		SignalBuffer[1+shift]	< 20.0 &&					// 
		SignalBuffer[0+shift] >= 20.0 						//
	;
	return flag;
}

bool STC_D_EgeMidCToHighross( int shift){
	bool flag =
		SignalBuffer[1+shift]	< 80.0 &&					// 
		SignalBuffer[0+shift] >= 80.0 						//
	;
	return flag;
}

bool STC_D_EgeMidToLowCross(int shift){
	bool flag =
		SignalBuffer[1+shift]	> 20.0 &&					// 
		SignalBuffer[0+shift] <= 20.0 						//
	;
	return flag;
}






bool STC_K_EgeHighToLowCross(){
	bool flag =
		StochasticBuffer[1]	> 80.0 &&					// 
		StochasticBuffer[0] <= 80.0 						//
	;
	return flag;
}

bool STC_K_EgeLowToHighCross(){
	bool flag =
		StochasticBuffer[1]	< 20.0 &&					// 
		StochasticBuffer[0] >= 20.0 						//
	;
	return flag;
}



bool RSI_IsUpperArea(){
	bool flag =
		iRSIBuffer[0] > 50.0 						//
	;
	return flag;
}


int EMA_katamuki(double &buff[]){ // // up 1 ,down -1, 平行　0
	if (buff[0]>buff[katamukiDays]){
		return 1;
	}else if (buff[0]<buff[katamukiDays]){
		return -1;
	}else {
		return 0;
	}
}

int EMA_katamuki_A(){ // up 1 ,down -1, 平行　0
	if (bufferEMA_A[0]>bufferEMA_A[1]){
		return 1;
	}else if (bufferEMA_A[0]<bufferEMA_A[1]){
		return -1;
	}else {
		return 0;
	}
}
int EMA_katamuki_B(){ // up 1 ,down -1, 平行　0
	if (bufferEMA_B[0]>bufferEMA_B[1]){
		return 1;
	}else if (bufferEMA_B[0]<bufferEMA_B[1]){
		return -1;
	}else {
		return 0;
	}
}
int EMA_katamuki_C(){ // up 1 ,down -1, 平行　0
	if (bufferEMA_C[0]>bufferEMA_C[1]){
		return 1;
	}else if (bufferEMA_C[0]<bufferEMA_C[1]){
		return -1;
	}else {
		return 0;
	}
}

















int GetAfter_bar(){
		         int after_bar_count=0; // オーダーからのバーの本数 
		         after_bar_count = 0; 
		         if(Time_cur > OrderOpenTime() && OrderOpenTime() > 0)                          //if the current time is farther than the entry Point()...
		         { after_bar_count = (int)NormalizeDouble( ((Time_cur - OrderOpenTime() ) /60), 0 ); }    //define the distance in tfM1 mybars up to the entry Point()
	return (after_bar_count);
}

double chgPips2price(double d){return(d*Point()*10);}
double chgPrice2Pips(double d){return(d/(Point()*10));}







bool EMATouchJudgment() // 範囲内に入ったらtrue　以外はfalse
{
	bool ret;
	double tmp = chgPips2price(bandTouchWidth);
	
	ret=
		(bufferEMA_B[0]-chgPips2price(bandTouchWidth) < Close[0] )
		&&
		(bufferEMA_B[0]+chgPips2price(bandTouchWidth) > Close[0] )
	;
	return ret;
}


bool Buycheck3(){
	bool flag =
	EMATouchJudgment()
	&&
	bufferEMA_B[1]<Close[0]
;
		

EMATouchJudgment();			
		
//	MA_KindPerfectOrder(bufferEMA_A,bufferEMA_B,bufferEMA_C);	
#ifdef aaa		
   SetIndexBuffer SetIndexStyle(1,DRAW_LINE,clrYellowGreen);
	PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(4,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(5,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(6,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(7,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(8,PLOT_LINE_COLOR,clrBlue); 	
#endif
	return flag;
}

bool Sellcheck3(){
	bool flag =
		EMATouchJudgment()
   	&&
   	bufferEMA_B[1]>Close[0]
   	;
	return flag;
}

bool CloseBuycheck3(){
	bool flag =
		GetAfter_bar()>=NumberOfBarAfterTouch
		//||
		//帯域を抜けたら
		
		;
	;
	
	return flag;
}

bool CloseSellcheck3(){
	bool flag =
		GetAfter_bar()>=NumberOfBarAfterTouch;
	
	;
	
	return flag;
}


// GMMA ライブラリ
//GMMA短期と長期の両方がUPトレンド
bool isUpAllTrend(){
	
	return(
	bufferGMMAFast1[0]>bufferGMMAFast2[0]&&
	bufferGMMAFast2[0]>bufferGMMAFast3[0]&&
	bufferGMMAFast3[0]>bufferGMMAFast4[0]&&
	bufferGMMAFast4[0]>bufferGMMAFast5[0]&&
	bufferGMMAFast5[0]>bufferGMMAFast6[0]&&
	bufferGMMAFast6[0]>bufferGMMASlow1[0]&&
	bufferGMMASlow1[0]>bufferGMMASlow2[0]&&
	bufferGMMASlow2[0]>bufferGMMASlow3[0]&&
	bufferGMMASlow3[0]>bufferGMMASlow4[0]&&
	bufferGMMASlow4[0]>bufferGMMASlow5[0]&&
	bufferGMMASlow5[0]>bufferGMMASlow6[0]
	);
}
//GMMA長期がUPトレンド
bool isUpSlowTrend(){
   int s;
   s=1;
	return(
	bufferGMMASlow1[0+s]>bufferGMMASlow2[0+s]&&
	bufferGMMASlow2[0+s]>bufferGMMASlow3[0+s]&&
	bufferGMMASlow3[0+s]>bufferGMMASlow4[0+s]&&
	bufferGMMASlow4[0+s]>bufferGMMASlow5[0+s]&&
	bufferGMMASlow5[0+s]>bufferGMMASlow6[0+s]
	);	
}

//GMMA短期がUPトレンド
bool isUpFastTrend(){
	return(
	bufferGMMAFast1[0]>bufferGMMAFast2[0]&&
	bufferGMMAFast2[0]>bufferGMMAFast3[0]&&
	bufferGMMAFast3[0]>bufferGMMAFast4[0]&&
	bufferGMMAFast4[0]>bufferGMMAFast5[0]&&
	bufferGMMAFast5[0]>bufferGMMAFast6[0]
	);	
}


int GetTrrendPatternSlow(){
	int ret=0;
	if(isUpSlowTrend()){ret = 1;}
	else if (isDownSlowTrend()) {ret = -1;}
	return ret;
}
int GetTrrendPatternFast(){
	int ret=0;
	if(isUpFastTrend()){ret = 1;}
	else if (isDownFastTrend()) {ret = -1;}
	return ret;
}
//GMMA短期と長期の両方がDownトレンド
bool isDownAllTrend(){
	return(
	bufferGMMAFast1[0]<bufferGMMAFast2[0]&&
	bufferGMMAFast2[0]<bufferGMMAFast3[0]&&
	bufferGMMAFast3[0]<bufferGMMAFast4[0]&&
	bufferGMMAFast4[0]<bufferGMMAFast5[0]&&
	bufferGMMAFast5[0]<bufferGMMAFast6[0]&&
	bufferGMMAFast6[0]<bufferGMMASlow1[0]&&
	bufferGMMASlow1[0]<bufferGMMASlow2[0]&&
	bufferGMMASlow2[0]<bufferGMMASlow3[0]&&
	bufferGMMASlow3[0]<bufferGMMASlow4[0]&&
	bufferGMMASlow4[0]<bufferGMMASlow5[0]&&
	bufferGMMASlow5[0]<bufferGMMASlow6[0]
	);
	
}

//GMMA長期がDownトレンド
bool isDownSlowTrend(){
	return(
	bufferGMMASlow1[0]<bufferGMMASlow2[0]&&
	bufferGMMASlow2[0]<bufferGMMASlow3[0]&&
	bufferGMMASlow3[0]<bufferGMMASlow4[0]&&
	bufferGMMASlow4[0]<bufferGMMASlow5[0]&&
	bufferGMMASlow5[0]<bufferGMMASlow6[0]
	);
}
//GMMA短期がDownトレンド
bool isDownFastTrend(){
	return(
	bufferGMMAFast1[0]<bufferGMMAFast2[0]&&
	bufferGMMAFast2[0]<bufferGMMAFast3[0]&&
	bufferGMMAFast3[0]<bufferGMMAFast4[0]&&
	bufferGMMAFast4[0]<bufferGMMAFast5[0]&&
	bufferGMMAFast5[0]<bufferGMMAFast6[0]
	);
}


//　乖離率　
double kairiritu(double ma,double v){  // 移動平均の値、　現在の価格
	if(ma == 0.0 ) return 0.0;
	return(
		((v-ma)*100.0)/ma
	);
}

// 1h あたりの変化量（価格の変化量）
double hennkaritu(double now,double pass , int n, datetime &tt[]){// 現在値、過去の値、何個昔？　N本：変化率＝　（現在値ー過去の値）/N本　　or　時間求めて一時間あたりになおすか？
		long sabunn_Time_second = (long)NormalizeDouble( ((tt[0]- tt[n] ) ), 0 );     //define the distance in tfM1 mybars up to the entry Point()
		return( ((now-pass)/(n))*(  3600 *1/sabunn_Time_second)  );				
}


//　GMMAとの位置
//　||F1||F2||F3||F4||F5||F6||||S1||S2||S3||S4||S5||S6||      ・・・・F6、EMA２４、S1・・・・S6
//　UPトレンド上の時　　　上から下のイメージ　  |6|F1|5|F2|4|F3|3|F4|2|F5|1|F6||0||S1|-1|S2|-2|S3|-3|S4|-4|S5|-5|S6|-6|
//　DNトレンド上の時　　　下から上のイメージ　  |6|F1|5|F2|4|F3|3|F4|2|F5|1|F6||0||S1|-1|S2|-2|S3|-3|S4|-4|S5|-5|S6|-6|
int GMMA_location_Up(double v){
	// PFのときに見るべきだが、ずれたときもあるので遅い線から判断する
	// Up
	int ret;
	if ( bufferGMMASlow6[0]>v){ ret = -6;}
	else if (bufferGMMASlow5[0]>v){ret = -5;}
	else if (bufferGMMASlow4[0]>v){ret = -4;}
	else if (bufferGMMASlow3[0]>v){ret = -3;}
	else if (bufferGMMASlow2[0]>v){ret = -2;}
	else if (bufferGMMASlow1[0]>v){ret = -1;}
	else if (bufferGMMAFast6[0]>v){ret = 0;}
	else if (bufferGMMAFast5[0]>v){ret = 1;}
	else if (bufferGMMAFast4[0]>v){ret = 2;}
	else if (bufferGMMAFast3[0]>v){ret = 3;}
	else if (bufferGMMAFast2[0]>v){ret = 4;}
	else if (bufferGMMAFast1[0]>v){ret = 5;}
	else {ret = 6;}
	return(ret);
}
int GMMA_location_Dn(double v){
	// PFのときに見るべきだが、ずれたときもあるので遅い線から判断する
	// Downトレンド
	int ret;
	if ( bufferGMMASlow6[0]<v){ ret = -6;}
	else if (bufferGMMASlow5[0]<v){ret = -5;}
	else if (bufferGMMASlow4[0]<v){ret = -4;}
	else if (bufferGMMASlow3[0]<v){ret = -3;}
	else if (bufferGMMASlow2[0]<v){ret = -2;}
	else if (bufferGMMASlow1[0]<v){ret = -1;}
	else if (bufferGMMAFast6[0]<v){ret = 0;}
	else if (bufferGMMAFast5[0]<v){ret = 1;}
	else if (bufferGMMAFast4[0]<v){ret = 2;}
	else if (bufferGMMAFast3[0]<v){ret = 3;}
	else if (bufferGMMAFast2[0]<v){ret = 4;}
	else if (bufferGMMAFast1[0]<v){ret = 5;}
	else {ret = 6;}
	return(ret);
}
string StrSlowBandHigh;
void addStrSlowBandHigh(string s){
		StrSlowBandHigh = StrSlowBandHigh+s;
}
void setStrSlowBandHigh(){
#ifdef GMMA
	StrSlowBandHigh=  "SH:"+   (string) NormalizeDouble(GetSlowBandHigh(),5)+",Hk:"+      (string) NormalizeDouble(  bufferHennkaritu[0],5) +",T:"+(string)bolinger_Entry_Kind_type       ;
#else 
   StrSlowBandHigh=  "SH:"+   (string) NormalizeDouble(GetSlowBandHigh(),5)+",Hk:"+      (string) NormalizeDouble(  0,5) +",T:"+(string)bolinger_Entry_Kind_type       ;
#endif	
} 
string GetStrSlowBandHigh(){ // commentへ書き込む用
//		StrSlowBandHigh=  "SH:"+   (string) NormalizeDouble(GetSlowBandHigh(),5)+",Hk:"+      (string) NormalizeDouble(  bufferHennkaritu[0],5) +",T:"+(string)bolinger_Entry_Kind_type       ;
		return (StrSlowBandHigh);
}
double GetSlowBandHigh(){
#ifdef GMMA
	return (MathAbs(bufferGMMASlow1[0]-bufferGMMASlow6[0]));
#else 
   return 0.0;
#endif // GMMA	
}


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
void init_GMMA_DATA(){


	ArrayResize(bufferKairiritu,MAX_PASS);
	ArrayResize(bufferHennkaritu,MAX_PASS);
	ArrayResize(TrrendPattern_Slow,MAX_PASS);
	ArrayResize(TrrendPattern_Fast,MAX_PASS);
	ArrayResize(TrrendPattern_ALL,MAX_PASS);
	ArrayResize(bufferLocationGMMA_UP,MAX_PASS);
	ArrayResize(bufferLocationGMMA_DN,MAX_PASS);
	ArraySetAsSeries( bufferKairiritu,true);
	ArraySetAsSeries( bufferHennkaritu,true);
	ArraySetAsSeries( TrrendPattern_Slow,true);
	ArraySetAsSeries( TrrendPattern_Fast,true);
	ArraySetAsSeries( TrrendPattern_ALL,true);
	ArraySetAsSeries( bufferLocationGMMA_UP,true);
	ArraySetAsSeries( bufferLocationGMMA_DN,true);
	// 初期化

	ArrayInitialize(bufferKairiritu,0.0);	//　かい離率 [%]
	ArrayInitialize(bufferHennkaritu,0.0);	//　変化率	[価格/1h]	1h あたりの変化量（価格の変化量）
	ArrayInitialize(TrrendPattern_Slow,0);		//　長期トレンドがパーフェクトか？ 1 UP 　0 なし　-1 DN
	ArrayInitialize(TrrendPattern_Fast,0);		//　短期トレンドがパーフェクトか？ 1 UP 　0 なし　-1 DN
	ArrayInitialize(TrrendPattern_ALL,false);			//　長期＆短期トレンドがパーフェクトか？
	ArrayInitialize(bufferLocationGMMA_UP,0);		// GMMAの位置　（トレンド方向によって意味が異なる）　UP方向
	ArrayInitialize(bufferLocationGMMA_DN,0);		// GMMAの位置　（トレンド方向によって意味が異なる）　DN方向



	
}

void calc_GMMA_DATA(){
	int n = katamukiDays;
	bufferKairiritu[0]=kairiritu(bufferEMA_C[0]  , Close[0]);
	
	bufferHennkaritu[0]=hennkaritu(bufferEMA_C[0],bufferEMA_C[n],n,Time);
//	bufferHennkaritu[0]=hennkaritu(Close[0],Close[n],n,Time);
	TrrendPattern_Slow[0]=GetTrrendPatternSlow();
	TrrendPattern_Fast[0]=GetTrrendPatternFast();
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
////start　Sn///////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

// Sn データ宣言
//
struct struct_toplow_data{
   double value;  //価格
   datetime time;//　足の先頭時間　（その時間帯の足の先頭）
};
struct struct_Sn_data{
   struct_toplow_data Top;//Topデータ
   struct_toplow_data Low;
   int Direct;//方向　：　上向き１、下向き－１、　そのほか０
   datetime SubTime;//　TopとLowの間の時間　sec
   double HighValue;//　TopとLowの間の高さ　Pips
};

struct struct_Sn_torimatome_data{
   struct_Sn_data Sn[];//Snデータ本体
   long count;//　データ数
   int status;// 0:なし、1:仮データひとつtop 、2:仮データひとつlow 3:確定
};

//　Snデータ定義
struct_Sn_torimatome_data sn;

// Snデータ出力
void output_sn(){
   string str;
   string TAB="\t";
   
   addstring(str,"Sn_data Start:_____________________");
   addstring(str,"count="+ IntegerToString(sn.count) );
   addstring(str,"[i]"+TAB+"Top"+TAB+"Low"+TAB+"Direct"+TAB+"SubTime"+TAB+"HighValue"+TAB+"Toptime"+TAB+"Lowtime");
   for(int i=0;i< sn.count;i++){
      //str = "";
      addstring(str,""+
      TAB + "["+IntegerToString( i)+"]"+ 
      TAB + DoubleToString( sn.Sn[i].Top.value ) +
      TAB+ DoubleToString(sn.Sn[i].Low.value ) +
      TAB+ IntegerToString( sn.Sn[i].Direct) +
      TAB+ IntegerToString( sn.Sn[i].SubTime) +
      TAB+ DoubleToString(sn.Sn[i].HighValue)+

//      TAB + TimeToString( sn.Sn[i].Top.time ) +
//      TAB+ TimeToString(sn.Sn[i].Low.time ) 
      TAB + IntegerToString( sn.Sn[i].Top.time ) +
      TAB+ IntegerToString(sn.Sn[i].Low.time ) 

       ); 
      
   
   
   }
   addstring(str,"Sn_data End:_____________________");
   printf(str);
   return;
}


//Sn test data
double zigTop[]={0,0,3,0,4,0,6,0};
double zigLow[]={0,1,0,2,0,3,0,0};
int zignum= 8;

datetime zigtime[]={0,1,2,3,4,5,6,7,8,9,10,11};
#ifdef aaa
1 0
3 1
3 2
2 4
4 3
3 6
#endif 


void initsn_for_idx(struct_Sn_data& s){
   s.Top.value = 0.0;
   s.Low.value = 0.0;
   s.Top.time = 0;
   s.Low.time = 0;
   s.SubTime = 0;
   s.Direct = 0;
   s.HighValue = 0.0;
   return;
}

#define RESIZEYOBI 100
void init_sndata(){
   sn.count = 0;
   sn.status = 0;
   ArrayResize(sn.Sn,1,RESIZEYOBI);   
   
   initsn_for_idx(sn.Sn[0]);
   return;
}
void addSndata( struct_Sn_torimatome_data & s,double top , double low, datetime toptime,datetime lowtime,int status){

//double topk , double lowk, datetime toptimek,datetime lowtimek;

//追加時にサイズ確保（予備サイズをつかう）
//statusによって格納
   if ( sn.status == 1){
   
   }else
   
   if ( sn.status == 2 ){
   
   }else

   if ( sn.status == 3 ){
   
   }
   
   int count = sn.count;
   if ( count == 0){
      // そのまま登録   
   }else{
      //前回値を設定しておく
      // Hig　Lowを正しく設定しなおす　はじめはLowは０なので
      if( status == 1){
         //topとしてデータが来ている
         //前回のLowデータを取得
         low = s.Sn[count-1].Low.value; 
         lowtime = s.Sn[count-1].Low.time;
      }   
      if( status == 2){
         //lowとしてデータが来ている
         //前回のtopデータを取得
         top = s.Sn[count-1].Top.value; 
         toptime = s.Sn[count-1].Top.time;
      }   
   }

   int size = ArraySize( s.Sn );
   if( count == 0){
      size = 0;
   }else{
      ArrayResize(s.Sn,size+1,RESIZEYOBI);
   }
   
   s.Sn[size].Top.value = top;
   s.Sn[size].Low.value = low;
   s.Sn[size].Top.time = toptime;
   s.Sn[size].Low.time = lowtime;

   s.Sn[size].HighValue = MathAbs(top-low);
   if( toptime > lowtime ){
      // up
      s.Sn[size].SubTime = toptime - lowtime;
      s.Sn[size].Direct = 1;
   }else{
      // down
      s.Sn[size].SubTime = lowtime - toptime;
      s.Sn[size].Direct = -1;
   }
   s.count++; 
}
bool make_sndata(
   double& zigtop[],
   double& ziglow[],
   int datanum,// 上のデータの数
   int start_make_idx // どこからデータを作成するか
   
){
   bool ret;
   double top;
   double low;
   int findidx = -1;
   int status=0;// 0nasi,1top,2low,3
   datetime toptime; 
   datetime lowtime; 
   int count = sn.count;

   top = 0.0;
   low = 0.0;
   toptime = 0;
   lowtime = 0;
   status = 0;
  
   for(int i = start_make_idx ; i< datanum;i++){
   
   
      if (zigtop[i] >0){
         top = zigtop[i];
         status = status | 1;
         toptime = zigtime[i];
      }
      if (ziglow[i] >0){
         low = ziglow[i];
         lowtime = zigtime[i];
         status = status | 2;
      }
      if(status > 0){
         // top or　Lowのセットが見つかったので登録
         addSndata(sn,top,low,toptime,lowtime,status);
         //sn.status = 3; 
      
         top = 0.0;
         low = 0.0;
         toptime = 0;
         lowtime = 0;
         status = 0;
        
      }
   }
   
   
   return(ret);   

}

// trrend継続の判断　　　使う想定は現在の目線を判断　　　　トレンド継続中かを判断する。またはトレンドじゃないことがわかる

int sn_mesenn(int n){ // s1からsnまでの範囲で目線を判断する  上目線　1,下目線-1、わからない０
struct_Sn_data a;
struct_Sn_data b;
   int ret;
   ret = 0;
   
   double takane=0.0,yasune=0.0;
   
   int count = sn.count;
   if( n < 1){
      return 0;
   }
   a=sn.Sn[count-n-1];
   takane = a.Top.value;
   yasune = a.Low.value;
   int torrend = a.Direct; // up 1  down -1  0?
   
   for(int i = count-n-1+1; i< count;i++){
      b=sn.Sn[i];
#ifdef aaa      
      // トレンド？
      if( a.Top.value <= b.Top.value  && a.Low.value < b.Low.value ){
         // up trrend ダウ継続  
      }else   
      
      if( a.Top.value > b.Top.value  && a.Low.value >= b.Low.value ){
         // down　trrend ダウ継続
      }else{
         //?  
      }
#endif      


      //目線転換したとき

      ///起点となる高値安値を更新：　　ＵＰ高値更新の時、down安値更新した時
      if( torrend == 1 && yasune > b.Low.value){
         takane = b.Top.value;
         yasune = b.Low.value;
         torrend =  -1;
      }else if(torrend == -1 && takane < b.Top.value ){
         takane = b.Top.value;
         yasune = b.Low.value;
         torrend =  1;
      }
      
#ifdef aaa      
      if( torrend == 1 && takane< b.Top.value ||  torrend == -1 && yasune > b.Low.value){
         takane = b.Top.value;
         yasune = b.Low.value;
      }
#endif      
      //
      a=b;
   
   }
      

   return torrend;
}
//　キーとなるところをこえたかどうか　　これから伸びそうなところかどうかを判断（ここを超えると悲鳴が聞こえるポイントがレジサボになるはず）



void test_sn(){

   make_sndata(zigTop,zigLow,8,0);


#ifdef aaaa
   double& zigtop[],
   double& ziglow[],
   int datanum,// 上のデータの数
   int start_make_idx // どこからデータを作成するか
#endif
   output_sn();

   printf( "test end");
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
////End　Sn///////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////////////////////
///Span bollinger///////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////


//// span boll
int handle_span;
double bufferSpanA[];
double bufferSpanB[];
double bufferSpanChikou[];

int handle_span_tyouki;
double bufferSpanA_tyouki[];
double bufferSpanB_tyouki[];
double bufferSpanChikou_tyouki[];

//#define MaxBars_Span 1
#define MaxBars_Span 5  // debuggggg
//--- input parameters
input int InpTenkan=9;     // Tenkan-sen
input int InpKijun=26;     // Kijun-sen
input int InpSenkou=52;    // Senkou Span B
input ENUM_TIMEFRAMES tyouki_time_frame =PERIOD_H1; //長期足の時間

void init_span_boll(){
handle_span  = iCustom(Symbol(),Period(),"Mytest201901\\SpanModel",
InpTenkan,   //input int InpTenkan=9;     // Tenkan-sen
InpKijun,   //input int InpKijun=26;     // Kijun-sen
InpSenkou   //input int InpSenkou=52;    // Senkou Span B
);


handle_span_tyouki  = iCustom(Symbol(),PERIOD_H1,"Mytest201901\\SpanModel",
InpTenkan,   //input int InpTenkan=9;     // Tenkan-sen
InpKijun,   //input int InpKijun=26;     // Kijun-sen
InpSenkou   //input int InpSenkou=52;    // Senkou Span B

);

}
void make_data_span_boll(){
   if(CopyBuffer(handle_span ,2,0,MaxBars_Span ,bufferSpanA ) < MaxBars_Span ) return;
   if(CopyBuffer(handle_span ,3,0,MaxBars_Span ,bufferSpanB ) < MaxBars_Span ) return;
//   if(CopyBuffer(handle_span ,4,0,InpKijun ,bufferSpanChikou ) < MaxBars_Span ) return;

//    int aaaa = CopyBuffer(handle_span ,3,0,MaxBars_Span ,bufferSpanB );
//    int bbbb = CopyBuffer(handle_span ,4,0,InpKijun ,bufferSpanChikou );
//    /bbbb = CopyBuffer(handle_span ,4,InpKijun,5 ,bufferSpanChikou );
//              シフトして描画しているものは、表示上のようなバッファになっているため、取り出し位置を変えたほうが良い。
//　遅行線はInpkijun分ずらしただけなので、　CloseのInpkijunのところにClose最新が表示されている。　　※１の理由

   if(CopyBuffer(handle_span_tyouki ,2,0,MaxBars_Span ,bufferSpanA_tyouki ) < MaxBars_Span ) return;
   if(CopyBuffer(handle_span_tyouki ,3,0,MaxBars_Span ,bufferSpanB_tyouki ) < MaxBars_Span ) return;
//つかわない　※１の理由//   if(CopyBuffer(handle_span_tyouki ,4,0,InpKijun ,bufferSpanChikou_tyouki ) < MaxBars_Span ) return;


   if(CopyBuffer(handle_span ,4,0,InpKijun ,bufferSpanChikou ) < MaxBars_Span ) return;

   
   return;
}












///////////////////no2 end
//data
    // 各状態保持用
    int state_tyouki_chikou_innyou;// init 0, 1陽転中　-1陰転中
    int state_tyouki_kumo_innyou;// init 0, 1陽転中　-1陰転中
    int state_tanki__chikou_innyou;// init 0, 1陽転中　-1陰転中
    int state_tanki__kumo_innyou;// init 0, 1陽転中　-1陰転中
    //パターン中の状況判断用
    int mode_span_pattern;// init 0,1 pattern1から6
    int mode_span_pattern_old;// init 0,1 pattern1から6			変化した時のみ更新
    int mode_span_pattern_old_old;// init 0,1 pattern1から6			変化した時のみ更新
    int mode_span_pattern_zennkai_chg;// init 0,1 pattern1から6			前回のTickの値
    int state_wait_hanten;//雲内で反転を待ち中   init0；待ち状態　　下から上１、上から下へ-1　　
    int  flag_kumonai_hannten;//雲内で反転FLAG   init0；変化なし　　下から上１、上から下へ-1　　
	int pattern_mode[6+1];//パターン内のモード・状態遷移用  0が初期値（なりたて） idx 0は使わない
	bool flag_buy_No1;//買いフラグ　買う処理するまで残す。処理終わったら落とすこと
	bool flag_buy_No2;//買いフラグ　買う処理するまで残す。処理終わったら落とすこと
	int locate_info_kumo_youtenn;// ini 0 ,  雲の中 1,雲の中から上へ抜けて確定した　2
	bool flag_exit_mode_chg;//モード変わったらポジションあるなら切るためのフラグ ture exit、　false何もしない
	int state_ashi_kumoue_kakutei;//1 確定足が雲の上にある,0 雲の中にある。境界は雲の中判定にする、-1雲の下,init -99
	int state_ashi_kumoue_kakutei_old;//1 確定足が雲の上にある,0 雲の中にある。境界は雲の中判定にする、-1雲の下,init -99
	int reason_buysell;// 理由番号：　　買い理由；1雲上,2雲内上へ反転　売り理由；マイナス　　初期値0  設定はEntryの条件成立したときに
// init_span_bollnger_data
void init_span_bollnger_data(){
    state_tyouki_chikou_innyou=0;// init 0, 1陽転中　-1陰転中
    state_tyouki_kumo_innyou=0;// init 0, 1陽転中　-1陰転中
    state_tanki__chikou_innyou=0;// init 0, 1陽転中　-1陰転中
    state_tanki__kumo_innyou=0;// init 0, 1陽転中　-1陰転中
    mode_span_pattern=0;// init 0,1 pattern1から6
    mode_span_pattern_old=0;// init 0,1 pattern1から6
    state_wait_hanten=0;//雲内で反転を待ち中   init0；待ち状態　　下から上１、上から下へ-1　　
    flag_kumonai_hannten=0;//雲内で反転FLAG   init0；変化なし　　下から上１、上から下へ-1　　
	flag_buy_No1 =false;
	flag_buy_No2 =false;
	locate_info_kumo_youtenn=0;
	flag_exit_mode_chg = false;
	state_ashi_kumoue_kakutei=-99;
	state_ashi_kumoue_kakutei_old=-99;
	reason_buysell=0;// 理由番号：　　買い理由；1雲上,2雲内上へ反転　売り理由；マイナス　　初期値0  設定はEntryの条件成立したときに

ArraySetAsSeries(bufferSpanA,true);	
ArraySetAsSeries(bufferSpanB,true);	
ArraySetAsSeries(bufferSpanChikou,true);	
ArraySetAsSeries(bufferSpanA_tyouki,true);	
ArraySetAsSeries(bufferSpanB_tyouki,true);	
ArraySetAsSeries(bufferSpanChikou_tyouki,true);	
}


// func;


//雲内で反転確認   反転タイミングは確定足時、呼び出し時で確定した後に呼ばれる想定
//　[1]がさっき確定したばかりの足の情報、[2]がその前の足情報
// output   flag_kumonai_hannten:反転した時のみ　雲内反転　上へ１　下へ‐1、それ以外０
//chk_kumonai_hannten(Open[],Close[],high[],low[],state_wait_hanten);// output   flag_kumonai_hannten:反転した時のみ　雲内反転　上へ１　下へ‐1、それ以外０

void chk_kumonai_hannten(double &open[],double &close[],double &high[],double &low[],int wait_direct){
    flag_kumonai_hannten=0;
//下から上の判断１
	if(wait_direct == 1 ){
    	//前の足がした、確定足が上に向いた
    	if(close[1]>close[2]){
			flag_kumonai_hannten = 1;
		}
    }
//上から下への判断-1　
	if(wait_direct == -1 ){
    //前の足がうえ、確定足がしたに向いた
    	if(close[2]>close[1]){
			flag_kumonai_hannten = -1;
		}
    }
}

//確定足が雲の上か下か？state_ashi_kumoue_kakutei	1 確定足が雲の上にある,0 雲の中にある。境界は雲の中判定にする、-1雲の下,init -99
void chk_kumo_ue_shita(double &Close[]){
	state_ashi_kumoue_kakutei_old = state_ashi_kumoue_kakutei;
    
				if( Close[1] <= bufferSpanA[1] &&
				    Close[1] >= bufferSpanB[1]){
				    //雲の中
				    state_ashi_kumoue_kakutei = 0;// 
				}else if( Close[1] > bufferSpanA[1] &&
				    Close[1] > bufferSpanB[1]){
				    //雲の上で確定
				    state_ashi_kumoue_kakutei = 1;// 
				}else if(Close[1] < bufferSpanA[1] &&
				    Close[1] < bufferSpanB[1]){
				    //雲の下で確定
				    state_ashi_kumoue_kakutei = -1;// 
				}else{
					printf("arienai chk_kumo_ue");
				}
}



void set_mode_span_pattern(int p){
	if(mode_span_pattern != p){
//	if(mode_span_pattern_old != p){
		mode_span_pattern_old_old = mode_span_pattern_old;
		mode_span_pattern_old = mode_span_pattern;
		mode_span_pattern = p;
		
		//パターンモードの初期化
		for(int i = 0; i<6+1;i++){
			pattern_mode[i] = 0;
		}
		//モード変わったらポジションあるなら切るためのフラグ
		flag_exit_mode_chg = true;//モード変わったらポジションあるなら切るためのフラグ ture exit、　false何もしない
//		if(p==1){
//			pattern_mode[mode_span_pattern] = 0;// パターン１なりたて
//		}



#ifdef delll
#ifdef NOOOOO
        // 変化で売り買いチェック
        		if( mode_span_pattern_old == 2 &&  mode_span_pattern == 3 ){
        #ifdef USE_No2
        				flag_buy_No2 = true;
        #endif //USE_No2
        		}
#endif        		
        		if( mode_span_pattern_old == 2 &&  mode_span_pattern == 1 ){
        #ifdef USE_No2
        				flag_buy_No2 = true;
        #endif //USE_No2
        		}
#endif // delll

		
	}else{
		flag_exit_mode_chg = false;//モード変わったらポジションあるなら切るためのフラグ ture exit、　false何もしない
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
///↓他　My_Viewへマーク表示情報を送信用//////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

void set_view_no(int n,datetime t,double price){
    int e = 0;
    GlobalVariableSet("View_no",(double)n);
    ResetLastError();
//    double dret = GlobalVariableSet("view_no_datetime",(double)t);
    double dret = GlobalVariableSet("View_no_dxxxxxxxx",(double)t);
    if ( dret == 0){
        e = GetLastError();
        printf( "error = "+e);
        }
    GlobalVariableSet("view_no_price",(double)price);

double dt = (double)t;    
    
double View_no  = GlobalVariableGet("View_no");
ResetLastError();
datetime tt = (datetime)GlobalVariableGet("View_no_dxxxxxxxx");
    if ( tt == 0){
        e = GetLastError();
        printf( "error = "+e);
        }

#ifdef aaaaaaa
datetime ttt = (datetime)GlobalVariableGet("xxxx");
    if ( ttt == 0){
        e = GetLastError();
        printf( "error = "+e);
        }

double dtt= (double)tt;
#endif

double price_t = GlobalVariableGet("View_no_price");    

    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///↑↑↑↑↑他　My_Viewへマーク表示情報を送信用////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////
///↓他　エントリー時の情報作成　　コメント用///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

string GetEntryInfo(){
    string s;
    //１５M のボリンジャーバンドのσ
    //H1のボリンジャーバンドのσ
    //　15MのMiddleの傾き
    //　1HのMiddleの傾き
    // EMA 1200の傾き
    s=StringFormat("Fb%.1f:Lb%.1f:FK%.1f:LK%.1f:LLK%.1f",
                    sigma,sigma_H1,
                    ((Bolinger_bufferMiddle1[0]-Bolinger_bufferMiddle1[4])/5)/(Point()*10),
                    ((Bolinger_bufferMiddle1_H1[0]-Bolinger_bufferMiddle1_H1[4])/5)/(Point()*10),
                    ((bufferEMA_A[0]-bufferEMA_A[4])/5)/(Point()*10)
                    
    ); 
    return s;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
///↑↑↑↑↑他　エントリー時の情報作成////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////


#ifdef aaaaaaaaaaaaaaaaaaaaaaaaaaaaa
////@                  //---define variables---
////@               
////@                  double sl_buy, tp_buy, sl_sell, tp_sell;
////@                  double L_prev_m15, L_2p_m15, L_3p_m15; 
////@                  double H_prev_m15, H_2p_m15, H_3p_m15;
////@                  double O_cur_m15, O_prev_m15, O_2p_m15, C_prev_m15, C_2p_m15;
////@                  double MA4_cur_m15, MA4_prev_m15, MA4_2p_m15, MA5_prev_m15, MA8_cur_m15, MA8_prev_m15, MA8_2p_m15;
////@                  double MA8_cur, MA8_prev, MA8_2p, MA8_3p, MA5_cur, MA5_prev, MA5_2p, MA13_cur, MA13_prev, MA13_2p,  
////@                      MA60_cur, MA60_prev, MA60_2p, MA24_cur_h1;
////@                  double C_prev_h1, O_prev_h1, H_prev_h1, L_prev_h1, H_2p_h1, L_2p_h1;    
////@                  datetime Time_cur, Time_cur_m15; 
////@                  double shift_buy, shift_sell;
////@                  double Max_pos, Min_pos;    
////@                 //--------
////@                 // add iw
////@                 int mybars=Bars(_Symbol,_Period); 
////@               
////@               
////@                
////@                  //MANAGING TECHNICAL PARAMETERS (STATES AND PERMISSIONS) - ON BROKER'S AND CLIENT TERMINAL'S SIDES-------------------------------
////@                #ifdef aaaaaaaaaaaaaaaaaaaaaa  
////@                if(test==false) //check: test or trade (test - true, trade - false)
////@                {//parameters that are not checked when testing on history data---
////@                    
////@                   if(IsConnected() == false) //check the status of the main connection of the client terminal with the broker server
////@                   {
////@                    Print("Entry disabled-broker server offline"); 
////@                    Alert("Entry disabled-broker server offline");
////@                    return;
////@                   } 
////@                   
////@                   
////@                   if(IsTradeAllowed() == false) //check ability to trade using EAs (broker flow, permission to trade)
////@                   {
////@                    
////@                    Print("Entry disabled-broker trade flow busy and/or EA trading permission disabled :", IsTradeAllowed()); 
////@                    Alert("Entry disabled-broker trade flow busy and/or EA trading permission disabled :", IsTradeAllowed());
////@                    return;
////@                   } 
////@                   
////@                   
////@                   if( !AccountInfoInteger(ACCOUNT_TRADE_EXPERT) ) //check trade account properties
////@                   {
////@                    Print("Auto trading disabled for account :", AccountInfoInteger(ACCOUNT_LOGIN), "on trade server side"); 
////@                    Alert("Auto trading disabled for account :", AccountInfoInteger(ACCOUNT_LOGIN), "on trade server side"); 
////@                    return;
////@                   }
////@                   
////@                   
////@                   if(IsExpertEnabled() == false) //check if launching EAs is allowed in the client terminal
////@                   {
////@                    
////@                    Print("Entry disabled- robot's trading permission disabled in the terminal :", IsExpertEnabled()); 
////@                    Alert("Entry disabled- robot's trading permission disabled in the terminal :", IsExpertEnabled());
////@                    return;
////@                   } 
////@                   
////@                   
////@                  if(IsStopped() == true) //check the arrival of the command to complete mql4 program execution
////@                   {
////@                    Print("Entry disabled-command to complete mql4 program execution triggered"); 
////@                    Alert("Entry disabled-command to complete mql4 program execution triggered");
////@                    return;
////@                   } 
////@                   
////@                } //parameters not checked when testing on history data end here
////@               #endif // aaaaaaaaaaaaa 
////@                
////@                 //Manage the presence of a sufficient number of quotes in the terminal by a used symbol---
////@                     
////@                    if(mybars<100)
////@                    {
////@                     Print("insufficient number of mybars on the current chart");
////@                     return; 
////@                    }
////@                    
////@                 //Manage placing an EA on a necessary timeframe----
////@                 
////@                   if(Period() != PERIOD_M1)
////@                   {
////@                    Print("EA placed incorrectly, place EA on tf :", PERIOD_M1);
////@                    Alert("EA placed incorrectly, place EA on tf :", PERIOD_M1);
////@                    return;
////@                   }
////@                
////@                 //Manage placing the EA to necessary financial instruments----
////@                 string s=Symbol();
////@                  if(Symbol() != "EURUSD" && Symbol() != "USDCHF" && Symbol() != "USDJPY.") 
////@                    {
////@                    Print("EA placed incorrectly-invalid financial instrument"); 
////@                    Alert("EA placed incorrectly-invalid financial instrument");
////@                    return;
////@                   } 
////@                   
////@                   //----------
////@                      if(
////@                     CopyBuffer(hMA4_cur_m15 ,0,0,MaxBars,xMA4_cur_m15 ) <
////@                      MaxBars) return;
////@                     if(CopyBuffer(hMA4_prev_m15 ,0,0,MaxBars,xMA4_prev_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA4_2p_m15 ,0,0,MaxBars,xMA4_2p_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA5_prev_m15 ,0,0,MaxBars,xMA5_prev_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_cur_m15 ,0,0,MaxBars,xMA8_cur_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_prev_m15 ,0,0,MaxBars,xMA8_prev_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_2p_m15 ,0,0,MaxBars,xMA8_2p_m15 ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_cur ,0,0,MaxBars,xMA8_cur ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_prev ,0,0,MaxBars,xMA8_prev ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_2p ,0,0,MaxBars,xMA8_2p ) < MaxBars) return;
////@                     if(CopyBuffer(hMA8_3p ,0,0,MaxBars,xMA8_3p ) < MaxBars) return;
////@                     if(CopyBuffer(hMA5_cur ,0,0,MaxBars,xMA5_cur ) < MaxBars) return;
////@                     if(CopyBuffer(hMA5_prev ,0,0,MaxBars,xMA5_prev ) < MaxBars) return;
////@                     if(CopyBuffer(hMA5_2p ,0,0,MaxBars,xMA5_2p ) < MaxBars) return;
////@                     if(CopyBuffer(hMA13_cur ,0,0,MaxBars,xMA13_cur ) < MaxBars) return;
////@                     if(CopyBuffer(hMA13_prev ,0,0,MaxBars,xMA13_prev ) < MaxBars) return;
////@                     if(CopyBuffer(hMA13_2p ,0,0,MaxBars,xMA13_2p ) < MaxBars) return;
////@                     if(CopyBuffer(hMA60_cur ,0,0,MaxBars,xMA60_cur ) < MaxBars) return;
////@                     if(CopyBuffer(hMA60_prev ,0,0,MaxBars,xMA60_prev ) < MaxBars) return;
////@                     if(CopyBuffer(hMA60_2p ,0,0,MaxBars,xMA60_2p ) < MaxBars) return;
////@                     if(CopyBuffer(hMA24_cur_h1 ,0,0,MaxBars,xMA24_cur_h1 ) < MaxBars) return;
////@                     
////@                     
////@                     
////@                     MA4_cur_m15 =xMA4_cur_m15 [0];
////@                     MA4_prev_m15 =xMA4_prev_m15 [1];
////@                     MA4_2p_m15 =xMA4_2p_m15 [2];
////@                     MA5_prev_m15 =xMA5_prev_m15 [1];
////@                     MA8_cur_m15 =xMA8_cur_m15 [0];
////@                     MA8_prev_m15 =xMA8_prev_m15 [1];
////@                     MA8_2p_m15 =xMA8_2p_m15 [2];
////@                     MA8_cur =xMA8_cur [0];
////@                     MA8_prev =xMA8_prev [1];
////@                     MA8_2p =xMA8_2p [2];
////@                     MA8_3p =xMA8_3p [3];
////@                     MA5_cur =xMA5_cur [0];
////@                     MA5_prev =xMA5_prev [1];
////@                     MA5_2p =xMA5_2p [2];
////@                     MA13_cur =xMA13_cur [0];
////@                     MA13_prev =xMA13_prev [1];
////@                     MA13_2p =xMA13_2p [2];
////@                     MA60_cur =xMA60_cur [0];
////@                     MA60_prev =xMA60_prev [1];
////@                     MA60_2p =xMA60_2p [2];
////@                     MA24_cur_h1 =xMA24_cur_h1 [0];   
////@                   
////@                 //MANAGE FINANCIAL PARAMETERS RELATED TO LIMITING THE TOTAL RISK FOR THE CLIENT'S DEPOSIT-------------------------------
////@                 #ifdef aaaaaaaaaaaaaa
////@                 if(kol < 1) //no orders
////@                 {
////@                  if(AccountBalance() <=  NormalizeDouble( (Depo_first*((100 - Percent_risk_depo)/100)), 0))//if the risk limit for the entire deposit have been previously exceeded 
////@                   {
////@                    Print("Entry disabled-risk limit reached earlier=",Percent_risk_depo, " % for the entire deposit=", Depo_first);
////@                    Alert("Entry disabled-risk limit reached earlier=",Percent_risk_depo, " % for the entire deposit=", Depo_first); 
////@                    return;
////@                   }
////@                   
////@                   
////@                  if(AccountFreeMargin() < (1000*Lots)) //if margin funds allowed for opening orders on the current account are insufficient
////@                   {
////@                    Print("Insufficient margin funds. Free account margin = ",AccountFreeMargin());
////@                    Alert("Insufficient margin funds. Free account margin = ",AccountFreeMargin());
////@                    return; //...then exit
////@                   } 
////@                 }     
////@                 #endif //aaaaaaaaaaaa      
////@                //-------------- 
////@                       
////@                        
////@
////@                
////@               //    if(CopyBuffer(high, UPPER_BAND, 0, MaxBars, High) < MaxBars) {}
////@               //   if(CopyBuffer(low, UPPER_BAND, 0, MaxBars, Low) < MaxBars) {}
////@               //   if(CopyBuffer(open, UPPER_BAND, 0, MaxBars, Open) < MaxBars) {}
////@               //   if(CopyBuffer(close, UPPER_BAND, 0, MaxBars, Close) < MaxBars) {}
////@               //   if(CopyBuffer(time, UPPER_BAND, 0, MaxBars, Time) < MaxBars) {}
////@                
////@                   double bid;
////@                   double ask;
////@                   
////@                   
////@                RefreshPrice(bid, ask);
////@                   L_prev_m15 = iLow(NULL,PERIOD_M15,1);
////@                   L_2p_m15 = iLow(NULL,PERIOD_M15,2);
////@                   L_3p_m15 = iLow(NULL,PERIOD_M15,3);
////@                   H_prev_m15 = iHigh(NULL,PERIOD_M15,1);
////@                   H_2p_m15 = iHigh(NULL,PERIOD_M15,2);
////@                   H_3p_m15 = iHigh(NULL,PERIOD_M15,3);
////@                   
////@                   O_cur_m15 = iOpen(NULL,PERIOD_M15,0);
////@                   O_prev_m15 = iOpen(NULL,PERIOD_M15,1);
////@                   O_2p_m15 = iOpen(NULL,PERIOD_M15,2);
////@                   C_prev_m15 = iClose(NULL,PERIOD_M15,1);
////@                   C_2p_m15 = iClose(NULL,PERIOD_M15,2);
////@                   Time_cur_m15 = iTime(NULL,PERIOD_M15,0);
////@                   
////@                   C_prev_h1 = iClose(NULL,PERIOD_H1,1);
////@                   O_prev_h1 = iOpen(NULL,PERIOD_H1,1);
////@                   H_prev_h1 = iHigh(NULL,PERIOD_H1,1);
////@                   L_prev_h1 = iLow(NULL,PERIOD_H1,1);
////@                   H_2p_h1 = iHigh(NULL,PERIOD_H1,2);
////@                   L_2p_h1 = iLow(NULL,PERIOD_H1,2);
////@               
////@                   
////@               //chg iwa     kol = OrdersTotal();
////@                   kol = PositionsTotal();
////@                   Time_cur = TimeCurrent();
////@                  //
////@                if(kol < 1) //continue if there are no open orders
////@                    {
////@                     
////@//---MARKET ENTRY ALGORITHM - BUY-------------------------------------------------------------------------------------------
////@                     
////@                 if( 
////@                  //----REDUCE RISKS RELATED TO THE PRESENCE OF A STRONG VOLATILITY AT THE TIME OF MARKET ENTRY ----
////@                 
////@                    //Simulate the absence of a strong volatility in the recent history:
////@                    ( High[1] - Low[1]) <= 200*Point() &&                       //limit the amplitude of a lower timeframe (М1)
////@                    ( High[2] - Low[2]) <= 200*Point() &&
////@                    ( High[3] - Low[3]) <= 200*Point() && 
////@                    (H_prev_m15 - L_prev_m15) <= 300*Point() &&                 //limit the amplitude of a higher timeframe (М15)
////@                    (H_2p_m15 - L_2p_m15) <= 300*Point() && 
////@                    (H_3p_m15 - L_3p_m15) <= 300*Point() && 
////@                    (H_prev_m15 - L_3p_m15) <= 300*Point() &&                   //limit the amplitude of the channel made of the higher timeframe candles (М15)
////@                    (High[1] - Low[1]) >= (1.1*(High[2] - Low[2])) &&         //limit activity on the previous bar relative to the 2 nd bar in the quote history 
////@                    (High[1] - Low[1]) < (3.0*(High[2] - Low[2])) &&          //same
////@                 
////@                   
////@                  //----REDUCE RISKS RELATED TO RESISTANCE LEVELS AT THE TIME OF MARKET ENTRY-----
////@                 
////@                    //Simulate the case when local resistance levels are broken by the current price:
////@                      bid > High[1] &&           //on М1 (smaller scale)
////@                      bid > H_prev_m15 &&        //on М15 (larger scale)
////@                          
////@                   
////@                  //---REDUCE RISKS RELATED TO ENTERING THE OVERBOUGHT AREA AT THE TIME OF MARKET ENTRY-----
////@                 
////@                   //Simulate binding to the start of the wave to decrease the entry probability in the overbought area:
////@                    ((MA8_prev > Low[1] && MA8_prev < High[1]) || (MA8_2p > Low[2] && MA8_2p < High[2]) || //start of the wave - not farther than three mybars in data history (М1)
////@                    (MA8_3p > Low[3] && MA8_3p < High[3])) &&                                              //same
////@                     MA5_prev_m15 > L_prev_m15 && MA5_prev_m15 < H_prev_m15 &&                             //start of the wave - on the previous bar of the higher timeframe (М15)
////@                     
////@                 
////@                 //---REDUCE RISKS RELATED TO THE ABSENCE OF A CLEARLY DEFINED TREND AT THE TIME OF MARKET ENTRY-------
////@                 
////@                     //Simulate the candles direction on the lower timeframe:
////@               //chg iwa del      Close[2] > Open[2] &&      //upward candle direction on the 2 nd bar in history (М1)
////@               //chg iwa del      Close[1] > Open[1] &&      //previous candle's upward direction (М1)
////@                     
////@                     //Simulate direction of moving averages on the higher timeframe:
////@                     MA5_cur > MA5_2p &&  MA60_cur > MA60_2p &&     //upward МАs: use moving averages with the periods of 5 and 60 (М1)
////@                     
////@                     //Simulate the hierarchy of moving averages on the lower timeframe:
////@                     MA5_cur > MA8_cur && MA8_cur > MA13_cur &&     //form the "hierarchy" of three МАs on М1 (Fibo periods:5,8,13), this is the indirect sign of the upward movement
////@                     
////@                     //Simulate the location of the current price relative to the lower timeframes' moving averages:
////@                     bid > MA5_cur && bid > MA8_cur && bid > MA13_cur && bid > MA60_cur && //current price exceeds МА (5,8,13,60) on М1, this is an indirect sign of the upward movement 
////@                     
////@                     //Simulate the candle direction on the higher timeframe:
////@                     C_prev_m15 > O_prev_m15 &&       //previous candle's upward direction (М15)
////@                     
////@                     //Simulate the MA direction on the higher timeframe: 
////@                     MA4_cur_m15 > MA4_2p_m15 &&     //upward МА with the period of 4 (М15)
////@                     
////@                     //Simulate the hierarchy of moving averages on the higher timeframe: 
////@                     MA4_prev_m15 > MA8_prev_m15 &&  //form the "hierarchy" of two МАs on М15 (periods 4 and 8), this is the indirect sign of the upward movement
////@                     
////@                     //Simulate the location of the current price relative to the higher timeframes' moving averages:
////@                     bid > MA4_cur_m15 &&            //current price exceeds МА4 (М15), this is an indirect sign of the upward movement 
////@                     bid > MA24_cur_h1 &&            //current price exceeds МА24 (МН1), this is an indirect sign of the upward movement
////@                     
////@                     //Simulate a micro-trend inside the current candle of the lower timeframe, as well as the entry Point():
////@               //chg iwa      bid > Open[0] &&               //presence of the upward movement inside the current candle (М1)
////@                     bid >= Open[0] &&               //presence of the upward movement inside the current candle (М1)
////@                      
////@                    //Simulate sufficient activity of the previous process at the higher timeframe:
////@                    (C_prev_m15 - O_prev_m15) > (0.5*(H_prev_m15 - L_prev_m15)) &&  //share of the candle "body" exceeds 50% of the candle amplitude value (previous М15 candle)
////@                    (H_prev_m15 - C_prev_m15) < (0.25*(H_prev_m15 - L_prev_m15)) && //correction depth limitation is less than 25% of the candle amplitude (previous М15 candle)
////@                     H_prev_m15 > H_2p_m15 &&                                       //upward trend by local resistance levels (two М15 candles) 
////@                     O_prev_m15 < H_prev_m15 && O_prev_m15 > L_prev_m15 &&          //presence of a wick (previous М15 candle) relative to the current candle's Open price
////@                     
////@                    //Simulate sufficient activity of the previous process on the lower timeframe: 
////@                    (Close[1] - Open[1]) > (0.5*(High[1] - Low[1])) &&              //share of the candle "body" exceeds 50% of the candle amplitude value (previous М1 candle)
////@               //chg iwa del      (High[1] - Low[1]) > 70*Point() &&                                //previous candle has an amplitude exceeding the threshold one (excluding an evident flat)
////@                    (High[2] - Close[2]) < (0.25*(High[2] - Low[2])) &&             //correction depth limitation is less than 20% of the candle amplitude (the second candle in the М1 data histo////@ry)
////@                     High[1] > High[2] &&                                           //upward trend by local resistance levels (two М1 candles)
////@                     Open[1] < High[1] && Open[1] > Low[1]                         //presence of the wick (previous tfМ1 candle) relative to the current candle's Open price
////@                     )
////@                       {
////@                       //if the Buy entry algorithm conditions specified above are met, generate the Buy entry order:
////@                       sl_buy = NormalizeDouble((bid-StopLoss*Point()),Digits());
////@                       tp_buy = NormalizeDouble((ask+TakeProfit*Point()),Digits());
////@                       
////@                        numb = OrderSend(Symbol(),  OP_BUY,Lots,ask,3,sl_buy,tp_buy,"Reduce_risks",16384,0,Green); 
////@                        
////@                        if(numb > 0)
////@               
////@                          {
////@               //          if(OrderSelect(numb,SELECT_BY_TICKET,MODE_TRADES))
////@                           if(OrderSelect(numb,0,0))
////@                           {
////@                              Print("Buy entry : ",OrderOpenPrice());   
////@                           }
////@                          }
////@                        else
////@                           Print("Error when opening Buy order : ",GetLastError());
////@                        return;
////@                       }
////@               		
////@               // #############################################################################
////@                //######################################################################
////@                //#####################################################################   
////@//--- MARKET ENTRY ALGORITHM - SELL--------------------------------------------------------------------------------------------------
////@               
////@                 if( 
////@                    //----REDUCE RISKS RELATED TO THE PRESENCE OF A STRONG VOLATILITY AT THE TIME OF MARKET ENTRY ----
////@                 
////@                    //Simulate the absence of a strong volatility in the recent history:
////@                    ( High[1] - Low[1]) <= 200*Point() &&                       //limit the amplitude of a lower timeframe (М1)
////@                    ( High[2] - Low[2]) <= 200*Point() &&
////@                    ( High[3] - Low[3]) <= 200*Point() && 
////@                    (H_prev_m15 - L_prev_m15) <= 300*Point() &&                 //limit the amplitude of a higher timeframe (М15)
////@                    (H_2p_m15 - L_2p_m15) <= 300*Point() && 
////@                    (H_3p_m15 - L_3p_m15) <= 300*Point() && 
////@                    (H_prev_m15 - L_3p_m15) <= 300*Point() &&                   //limit the amplitude of the channel made of the higher timeframe candles (М15)
////@                    (High[1] - Low[1]) >= (1.1*(High[2] - Low[2])) &&         //limit activity on the previous bar relative to the 2 nd bar in the quote history 
////@                    (High[1] - Low[1]) < (3.0*(High[2] - Low[2])) &&          //same
////@                 
////@                   
////@                 //----REDUCE RISKS RELATED TO RESISTANCE LEVELS AT THE TIME OF MARKET ENTRY-----
////@                 
////@                    //Simulate the case when local resistance levels are broken by the current price:
////@                      bid < Low[1] &&           //on М1 (smaller scale)
////@                      bid < L_prev_m15 &&       //on М15 (larger scale)
////@                          
////@                   
////@                 //---REDUCE RISKS RELATED TO ENTERING IN THE OVERSOLD AREA AT THE TIME OF MARKET ENTRY-----
////@                 
////@                   //Simulate binding to the start of the wave to decrease the entry probability in the oversold area:
////@                    ((MA8_prev > Low[1] && MA8_prev < High[1]) || (MA8_2p > Low[2] && MA8_2p < High[2]) || //start of the wave - not farther than three mybars in data history (М1)
////@                    (MA8_3p > Low[3] && MA8_3p < High[3])) &&                                              //same
////@                     MA5_prev_m15 > L_prev_m15 && MA5_prev_m15 < H_prev_m15 &&                             //start of the wave - on the previous bar of the higher timeframe (М15)
////@                     
////@                 
////@                 //---REDUCE RISKS RELATED TO THE ABSENCE OF A CLEARLY DEFINED TREND AT THE TIME OF MARKET ENTRY-------
////@                 
////@                     //Simulate the candles direction on the lower timeframe:
////@               //chg iwa del      Close[2] < Open[2] &&      //downward candle direction on the 2 nd bar in history (М1)
////@               //chg iwa del      Close[1] < Open[1] &&      //previous candle's downward direction (М1)
////@                     
////@                     //Simulate direction of moving averages on the lower timeframe:
////@                     MA5_cur < MA5_2p &&  MA60_cur < MA60_2p &&     //downward МАs: use moving averages with the periods of 5 and 60 (М1)
////@                     
////@                     //Simulate the hierarchy of moving averages on the lower timeframe:
////@                     MA5_cur < MA8_cur && MA8_cur < MA13_cur &&    //form the "hierarchy" of three МАs on М1 (Fibo periods:5,8,13), this is the indirect sign of the downward movement
////@                     
////@                     //Simulate the location of the current price relative to the lower timeframes' moving averages:
////@                     bid < MA5_cur && bid < MA8_cur && bid < MA13_cur && bid < MA60_cur && //current price exceeds МА (5,8,13,60) on М1, this is an indirect sign of the downward movement
////@                     
////@                     //Simulate the candle direction on the higher timeframe:
////@                     C_prev_m15 < O_prev_m15 &&      //previous candle's downward direction (М15)
////@                     
////@                     //Simulate the candle direction on the higher timeframe: 
////@                     MA4_cur_m15 < MA4_2p_m15 &&     //previous candle's downward direction 4 (М15)
////@                     
////@                     //Simulate the MA direction on the higher timeframe: 
////@                     MA4_prev_m15 < MA8_prev_m15 &&  //form the "hierarchy" of two МАs on М1 (periods 4 and 8), this is the indirect sign of the downward movement
////@                     
////@                     //Simulate the location of the current price relative to the higher timeframes' moving averages:
////@                     bid < MA4_cur_m15 &&            //current price is lower than МА4 (М15), this is an indirect sign of the downward movement 
////@                     bid < MA24_cur_h1 &&            //current price is lower than МА24 (МН1), this is an indirect sign of the downward movement
////@                     
////@                     //Simulate a micro-trend inside the current candle of the lower timeframe, as well as the entry Point():
////@               //chg iwa      bid < Open[0] &&                //presence of the downward movement inside the current candle (М1)
////@                     bid <= Open[0] &&                //presence of the downward movement inside the current candle (М1)
////@                      
////@                    //Simulate sufficient activity of the previous process at the higher timeframe:
////@                    (O_prev_m15 - C_prev_m15) > (0.5*(H_prev_m15 - L_prev_m15)) &&  //share of the candle "body" exceeds 50% of the candle amplitude value (previous М15 candle)
////@                    (C_prev_m15 - L_prev_m15) < (0.25*(H_prev_m15 - L_prev_m15)) && //correction depth limitation is less than 25% of the candle amplitude (previous М15 candle)
////@                     L_prev_m15 < L_2p_m15 &&                                       //upward trend by local resistance levels (two М15 candles) 
////@                     O_prev_m15 < H_prev_m15 && O_prev_m15 > L_prev_m15 &&          //presence of a wick (previous М15 candle) relative to the current candle's Open price
////@                     
////@                    //Simulate sufficient activity of the previous process on the lower timeframe: 
////@                    (Open[1] - Close[1]) > (0.5*(High[1] - Low[1])) &&              //share of the candle "body" exceeds 50% of the candle amplitude value (previous М1 candle)
////@               //chg iwa del     (High[1] - Low[1]) > 70*Point() &&                                //previous candle has an amplitude exceeding the threshold one (excluding an evident flat)
////@                    (Close[2] - Low[2]) < (0.25*(High[2] - Low[2])) &&              //correction depth limitation is less than 20% of the candle amplitude (the second candle in the М1 data histo////@ry)
////@                     Low[1] < Low[2] &&                                             //downward trend by local resistance levels (two М1 candles)
////@                     Open[1] < High[1] && Open[1] > Low[1] )                        //presence of the wick (previous М1 candle) relative to the current candle's Open price
////@                              
////@                       {
////@                        //if the Sell entry algorithm conditions specified above are met, generate the Sell entry order:
////@                        
////@                        sl_sell = NormalizeDouble((ask+StopLoss*Point()),Digits());
////@                        tp_sell = NormalizeDouble((bid-TakeProfit*Point()),Digits());
////@                        
////@                        numb = OrderSend(Symbol(),OP_SELL,Lots,bid,3,sl_sell,tp_sell,"Reduce_risks",16384,0,Red);
////@                         
////@                        if(numb > 0)
////@                          {
////@                           
////@               //          if(OrderSelect(numb,SELECT_BY_TICKET,MODE_TRADES))
////@                           if(OrderSelect(numb,0,0))
////@                             {
////@                              Print("Sell entry : ",OrderOpenPrice());
////@                             }
////@                          }
////@                        else
////@                           Print("Error when opening Sell order : ",GetLastError());
////@                       }
////@                     //--- the market entry algorithm (Buy, Sell) ends here
////@                     return;
////@                    }
////@//--- Check open orders and financial instrument symbol to prepare position closing:  
////@               
////@                  for(f=0; f < kol; f++)
////@                    {
////@               //    if(!OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
////@               //      if(!OrderSelect(f,0,0))
////@                     if(!PositionGetTicket(f))
////@                        continue;
////@                     if(OrderType()<=OP_SELL &&   //check the order type 
////@                        OrderSymbol()==Symbol())  //check the symbol
////@                       {
////@                        
////@                        if(OrderType()==OP_BUY) //if the order is "Buy", move to closing Buy position:
////@                          {
////@                           
////@//------BUY POSITION CLOSING ALGORITHM------------------------------------------------------------------------------------------------- 
////@                         
////@                        
////@                    //The module to search for the price maximum inside the open position--------------
////@                        
////@                         //first, define the distance from the current Point() inside the open position up to the market entry Point():
////@                            
////@                            shift_buy = 0; 
////@                     
////@                          if(Time_cur > OrderOpenTime() && OrderOpenTime() > 0)                          //if the current time is farther than the entry Point()...
////@                           { shift_buy = NormalizeDouble( ((Time_cur - OrderOpenTime() ) /60), 0 ); }    //define the distance in tfM1 mybars up to the entry Point()
////@                           
////@                         //now, define the price maximum after the market entry:
////@                         
////@                           Max_pos = 0; 
////@                    
////@                          if(Time_cur > OrderOpenTime() && shift_buy > 0) 
////@                           { Max_pos = NormalizeDouble((High[iHighest(NULL,PERIOD_M1, MODE_HIGH ,(shift_buy + 1), 0)]), Digits());}
////@                          
////@                         //the module to search for the price maximum inside the open position ends here--  
////@                         
////@                         //Pass to closing the Buy position (OR logic options): 
////@                      
////@                           if( 
////@                           //REDUCE RISKS RELATED TO PRICE COLLAPSES AFTER MARKET ENTRY-----市場参入後にコラプス価格を引き下げるリスクを減らす-----------------
////@                           // 買いのクローズのチェック
////@                           	/*
////@                           	①足が始まってから時間20以内で、開始値より１００＊Point下がった場合
////@                           	②あああ
////@                           	③
////@                           	
////@                           	*/
////@                           
////@                             (bid < Open[0] && (Open[0] - bid) >= 100*Point() && (Time_cur - Time[0]) <= 20)           //entry conditions (in any area) in case of a price collapse (reference Poin////@t() - current M1 candle Open price)
////@                                    ||
////@                             (bid < O_cur_m15 && (O_cur_m15 - bid) >= 200*Point() && (Time_cur - Time_cur_m15) <= 120) //exit conditions (in any area) in case of a price collapse (reference Point////@() - current M15 candle Open price)
////@                                    ||
////@                             ((Time_cur - OrderOpenTime()) > 60 && Close[1] < Open[1] && 
////@                             (Open[1] - Close[1]) >= 200*Point())                                                      //exit conditions (in any area) in case of a price collapse (reference param////@eter - previous M1 candle amplitude)
////@                                    ||
////@                                    
////@                           //REDUCE RISKS RELATED TO UNCERTAIN PRICE MOVEMENT AMPLITUDE AFTER MARKET ENTRY--市場参入後の不安定な価格変動に関連したリスクを軽減する 
////@                            
////@                             //Manage fixed profit (per position):
////@                             (bid > OrderOpenPrice() && (bid - OrderOpenPrice()) >= 100*Point())                       //exit conditions in profit area (shadow take profit)
////@                                    ||
////@                                    
////@                            //Manage the maximum acceptable price deviation 
////@                            //from the current High after market entry:    
////@                            (shift_buy >= 1 &&                                                                          //shift no less than 1 bar from the entry Point()
////@                            Time_cur > OrderOpenTime() && Max_pos > 0 && OrderOpenTime() > 0 && OrderOpenPrice() > 0 && //there is the current maximum after the entry
////@                            Max_pos > OrderOpenPrice() &&                                                               //current maximum is in the profit area
////@                            bid < Max_pos &&                                                                            //there is the reversal price movement
////@                            (Max_pos - bid) >= 200*Point())                                                               //reverse deviation from the current maximum for market entry
////@                                   ||
////@                                     
////@                            //Manage pre-defined risk limit (per position):     
////@                             (bid < OrderOpenPrice() && (OrderOpenPrice() - bid) >= 200*Point())                          //exit conditions in the loss area (shadow stop loss)
////@                                   ||
////@                                   
////@                            //Manage pre-defined risk limit (for the entire deposit):
////@                             (AccountBalance() <=  NormalizeDouble( (Depo_first*((100 - Percent_risk_depo)/100)), 0)) )  //if the risk limit is exceeded for the entire deposit during the current ////@trading 
////@                  
////@                         
////@                             {
////@                              
////@                              if(!OrderClose(OrderTicket(),OrderLots(),bid,3,Violet))     //if the closing algorithm is processed, form the order for closing the Buy position
////@                                 Print("Error closing Buy position ",GetLastError());    //otherwise print Buy position closing error
////@                              return;
////@                             }
////@                       
////@                          }
////@                          else //otherwise, move to closing the Sell position:
////@                          {
////@                           
////@                          //------SELL POSITION CLOSING ALGORITHM------------------------------------------------------------------------------------
////@                          
////@                          
////@                           //The module to search for the price maximum inside the open position--------------
////@                        
////@                         //first, define the distance from the current Point() inside the open position up to the market entry Point():
////@                            
////@                            shift_sell = 0; 
////@                     
////@                          if(Time_cur > OrderOpenTime() && OrderOpenTime() > 0)                          //if the current time is farther than the entry Point()...
////@                           { shift_sell = NormalizeDouble( ((Time_cur - OrderOpenTime() ) /60), 0 ); }   //define the distance in M1 mybars up to the entry Point()
////@                           
////@                         //now, define the price minimum after entering the market:
////@                         
////@                           Min_pos = 0; 
////@                    
////@                          if(Time_cur > OrderOpenTime() && shift_sell > 0)  
////@                          { Min_pos = NormalizeDouble( (Low[iLowest(NULL,PERIOD_M1, MODE_LOW ,(shift_sell + 1), 0)]), Digits()); }
////@                          
////@                         //the module to search for the price maximum inside the open position ends here--  
////@                         
////@                         
////@                         //Pass to closing the open Sell position (OR logic options): 
////@                          
////@                          if( 
////@                           //REDUCE RISKS RELATED TO PRICE COLLAPSES AFTER MARKET ENTRY-----------------
////@                           
////@                             (bid > Open[0] && (bid - Open[0]) >= 100*Point() && (Time_cur - Time[0]) <= 20)          //exit conditions (in any area) during a price collapse (reference Point() - ////@current M1 candle Open price)
////@                                    ||
////@                             (bid > O_cur_m15 && (bid - O_cur_m15) >= 200*Point() && (Time_cur - Time_cur_m15) <= 120) //exit conditions (in any area) during a price collapse (reference Point() -////@ current M15 candle Open price)
////@                                    ||
////@                             ((Time_cur - OrderOpenTime()) > 60 && Close[1] > Open[1] && 
////@                             (Close[1] - Open[1]) >= 200*Point())                                                      //exit conditions in any zone during a price collapse (reference parameter -////@ previous M1 candle amplitude)
////@                                    ||
////@                                      
////@                          //REDUCE RISKS RELATED TO UNCERTAIN PRICE MOVEMENT AMPLITUDE AFTER MARKET ENTRY-- 
////@                            
////@                             //Manage fixed profit (per position):
////@                             (bid < OrderOpenPrice() && (OrderOpenPrice()- bid) >= 100*Point())                         //exit conditions in profit area (shadow take profit)
////@                                    ||
////@                                    
////@                            //Manage the maximum acceptable price deviation 
////@                            //from the current minimum after market entry:      
////@                            (shift_sell >= 1 &&                                                                         //shift no less than 1 bar from the entry Point()
////@                            Time_cur > OrderOpenTime() && Min_pos > 0 && OrderOpenTime() > 0 && OrderOpenPrice() > 0 && //there is the current minimum after entry
////@                            Min_pos < OrderOpenPrice() &&                                                               //current minimum is in the profit area
////@                            bid > Min_pos &&                                                                            //there is a reverse price movement
////@                            (bid - Min_pos) >= 200*Point())                                                               //reverse deviation from the current minimum to exit the market
////@                                   || 
////@                                     
////@                            //Manage pre-defined risk limit (per position):     
////@                            (bid > OrderOpenPrice() && (bid - OrderOpenPrice()) >= 200*Point())                            //exit conditions in the loss area (shadow stop loss)
////@                                   ||
////@                                   
////@                            //Manage pre-defined risk limit (for the entire deposit):
////@                            (AccountBalance() <=  NormalizeDouble( (Depo_first*((100 - Percent_risk_depo)/100)), 0)) )   //if the risk limit exceeded for the entire deposit during the current tra////@ding 
////@                  
////@                             {
////@                       
////@                              if(!OrderClose(OrderTicket(),OrderLots(),ask,3,Violet))     //if the close algorithm is executed, generate the Sell position close order
////@                                 Print("Error closing Sell position ",GetLastError());   //otherwise, print the Sell position closing error
////@                              return;
////@                             }  
////@                         
////@                          }
////@                       }
////@                    }
#endif // old code del                    



///////////////////////////////////////////////////////////////////////////////////////////
// 1   
// STC Dが８０からした売り、２０から上へ買い
bool Buycheck1(){
	bool flag =
		(STC_K_D_GoldenCross(1)
		&& 
		
		(	!STC_D_IsKawaresugi_Area()
				)
		&& IsLongDirectionEntry()
		&&(StochasticBuffer[1]<30)
		)
		 || 
		(false) 
		
		//&& RSI_IsUpperArea()
	;
//TEST11();


	

	return flag;
}

bool Sellcheck1(){
	bool flag =
		STC_K_D_DedCross(1)
		&& (!STC_K_IsUraresugi_Area())
		&&(!IsLongDirectionEntry())
		&&(StochasticBuffer[1]>70)
//		STC_D_EgeHighToMidCross(1)						//
//		&& (!IsLongDirectionEntry()	)
//
//		 || 
//
//		STC_D_EgeLowToMidCross(1)
//		&& (!IsLongDirectionEntry()	)


		//&& (RSI_IsUpperArea()== false)
	
	;
//	Print("SellCheck1 : m0 s0 m1 s0  ",flag,StochasticBuffer[0],SignalBuffer[0],StochasticBuffer[1],SignalBuffer[1]);
	return flag;
}

bool CloseBuycheck1(){
	bool flag =
		//STC_K_D_GoldenCross()
		//||
		STC_K_D_DedCross(1)



		//STC_D_EgeMidCToHighross(1)
		//false
	;
	
	return flag;
}

bool CloseSellcheck1(){
	bool flag =
		STC_K_D_GoldenCross(1)
		//||
		//STC_K_D_DedCross()
	
	
		//STC_D_EgeMidToLowCross(1)
		//false
	
	
	;
	
	return flag;
}









//===========


bool IsLongDirectionEntry(){ // true long , false sell
// long
return (Close[1]  > bufferEMA_A[1]);

// Short
//Close[1]  < bufferEMA_A[1]
} 

////@
////@



	



///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

bool Buycheck2(){
	bool flag =
		//位置
  		bufferEMA_B[0]>bufferEMA_A[0]
      &&
      	// 傾き
		bufferEMA_A[1]<bufferEMA_A[0]	//長期
		&& 
		bufferEMA_B[1]<bufferEMA_B[0]	//中期
		&& 

      (
         (
      		bufferEMA_A[0]<bufferEMA_C[0]
      		&& 
      		bufferEMA_A[1]>bufferEMA_C[1]
         )
   		||
   		(
      		bufferEMA_B[0]<bufferEMA_C[0]
      		&& 
      		bufferEMA_B[1]>bufferEMA_C[1]
   		)
	 )
		;
		
		
//	MA_KindPerfectOrder(bufferEMA_A,bufferEMA_B,bufferEMA_C);	
#ifdef aaa		
   SetIndexBuffer SetIndexStyle(1,DRAW_LINE,clrYellowGreen);
	PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(4,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(5,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(6,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(7,PLOT_LINE_COLOR,clrBlue); 	
	PlotIndexSetInteger(8,PLOT_LINE_COLOR,clrBlue); 	
#endif
	return flag;
}

bool Sellcheck2(){
	bool flag =
  		bufferEMA_B[0]<bufferEMA_A[0]
      &&
		bufferEMA_A[1]>bufferEMA_A[0]	//長期
		&& 
		bufferEMA_B[1]>bufferEMA_B[0]	//中期
		&& 
      (
         (
      		bufferEMA_A[0]>bufferEMA_C[0]
      		&& 
      		bufferEMA_A[1]<bufferEMA_C[1]
         )
   		||
   		(
      		bufferEMA_B[0]>bufferEMA_C[0]
      		&& 
      		bufferEMA_B[1]<bufferEMA_C[1]
      	)	
      )
   		
			;
			
//	Print("SellCheck1 : m0 s0 m1 s0  ",flag,StochasticBuffer[0],SignalBuffer[0],StochasticBuffer[1],SignalBuffer[1]);
	return flag;
}

bool CloseBuycheck2(){
	bool flag =
		bufferEMA_B[0] >= Close[0];
	;
	
	return flag;
}

bool CloseSellcheck2(){
	bool flag =
		bufferEMA_B[0] <= Close[0];
	
	;
	
	return flag;
}





int MA_KindPerfectOrder(double &A[],double &B[] ,double &C[]) // 3つのMAの上下の位置関係　　パーフェクトオーダー？  
		//long A長期　B中期　C短期 　　long　下から上の順　1:Perfect  ABC   2: ACB 真ん中　　  3:CAB　　下
		//short A長期　B中期　C短期 　　long　上から上の順　-1:Perfect  ABC   -2: ACB　真ん中　  -3:CAB　　上
		// 				other:0
{
	int ret = 0;

	if( (A[0]<B[0]) && (B[0] < C[0])){
		ret = 1;
	}else if ( (A[0]<C[0]) && (C[0] < B[0])){
		ret = 2;
	}else if ( (C[0]<A[0]) && (A[0] < B[0])){
		ret = 3;

	}else if ( (C[0]<B[0]) && (B[0] < A[0])){
		ret = -1;
	}else if ( (B[0]<C[0]) && (C[0] < A[0])){
		ret = -2;
	}else if ( (B[0]<A[0]) && (A[0] < C[0])){
		ret = -3;
		
	}
	return 		ret;
}		
bool IsLongPerfectOrderPosition(double &A[],double &B[] ,double &C[]) //線の位置がLongのパーフェクトオーダー
{
	return(MA_KindPerfectOrder(bufferEMA_A,bufferEMA_B,bufferEMA_C)==1);	
}
bool IsShortPerfectOrderPosition(double &A[],double &B[] ,double &C[]) //線の位置がShortのパーフェクトオーダー
{
	return(MA_KindPerfectOrder(bufferEMA_A,bufferEMA_B,bufferEMA_C)==-1);	
}


bool IsLongPerfectOrderKatamuki(double &A[],double &B[] ,double &C[]) //パーフェクトオーダーの傾きか？
{
	return (
		(EMA_katamuki(A)==1)
		&& (EMA_katamuki(B)==1)
		&& (EMA_katamuki(C)==1) 
	)
	;
}
bool IsShortPerfectOrderKatamuki(double &A[],double &B[] ,double &C[]) //
{
	return (
		(EMA_katamuki(A)==-1)
		&& (EMA_katamuki(B)==-1)
		&& (EMA_katamuki(C)==-1) 
	)
	;
}

//-----------------------------------------------------------------------------------------//
// 売り買いのロジック
//-----------------------------------------------------------------------------------------//
#ifdef aaa
bool Buycheck(){return Buycheck4();}
bool Sellcheck(){return Sellcheck4();}
bool CloseBuycheck(){return CloseBuycheck4();}
bool CloseSellcheck(){return  CloseSellcheck4();}
#endif
//GMMAとかい離率を用いたトレード

bool Buycheck4(){
	bool flag = isUpSlowTrend() 
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
	&& GetSlowBandHigh()>0.000455

//	&& bufferHennkaritu[0]>0.00095
	&& bufferHennkaritu[0]>0.01
	
	&&(	!STC_D_IsKawaresugi_Area()	)
	&&(STC_K_D_GoldenCross(1)
		//||STC_K_D_GoldenCross(1)||STC_K_D_GoldenCross(2)
	
	)
	//isUpSlowTrend()&&isUpAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))


	&&(Close[0] > bufferGMMAFast6[0])


		;
		
		
	return flag;
}

bool Sellcheck4(){
//	bool flag =isDownSlowTrend()&&isDownAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
	bool flag =isDownSlowTrend()
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
	&& GetSlowBandHigh()>0.000455


//	&& bufferHennkaritu[0]>0.00095
	&& bufferHennkaritu[0]>0.01

	&& (!STC_D_IsUraresugi_Area())
	&&(STC_K_D_DedCross(1)
	//	||STC_K_D_DedCross(3)||STC_K_D_DedCross(2)
	)

	
	&&(Close[0] < bufferGMMAFast6[0])
	;
	return flag;
}

bool CloseBuycheck4(){
//	bool flag =Close[0]< bufferGMMASlow1[0];
	bool flag =(isUpSlowTrend()==false)
	
	
	|| 
	( STC_K_D_DedCross(1)
	  &&(	!STC_D_IsUraresugi_Area()	)
	 )
	
	;
	;
	
	return flag;
}

bool CloseSellcheck4(){
//	bool flag =Close[0]> bufferGMMASlow1[0];
	bool flag =(isDownSlowTrend()==false)
	
	
	||
	( STC_K_D_GoldenCross(1)
	  && (!STC_D_IsKawaresugi_Area())
	)
	
	;
	
	
	;
	return flag;
}



//＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿

bool Buycheck5(){
	
	bool flag=false;
	double d;
	d=chgPips2price(NumOfBeard_pips);
	if( Close[1]>Open[1] ==true){
		if(((High[1] -Close[1])>d) ||((Open[1] -Low[1])>d)) {
			flag =true			
			;
			PrintFormat("P上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Close[1]), chgPrice2Pips(Open[1] -Low[1]));
//			PrintFormat("PP上髭\t%g\t, \t下髭\t%g", (High[1] -Close[1]), (Open[1] -Low[1]));
		}
	}else{
		if(((High[1] -Open[1])>d) ||((Close[1] -Low[1])>d)) {
			flag =true
			;
			PrintFormat("H上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Open[1]), chgPrice2Pips(Close[1] -Low[1]));
//			PrintFormat("HH上髭\t%g\t, \t下髭\t%g", (High[1] -Open[1]), (Close[1] -Low[1]));
		}
	}
	

	return flag;
}

bool Sellcheck5(){
	bool flag = false
   	;
	return flag;
}

bool CloseBuycheck5(){
	bool flag =
		GetAfter_bar()>1
	
//		GetAfter_bar()>=NumberOfBarAfterTouch
		//||
		//帯域を抜けたら
		
		;
	;
	
	return flag;
}

bool CloseSellcheck5(){
	bool flag =
			GetAfter_bar()>1

//		GetAfter_bar()>=NumberOfBarAfterTouch;
	
	;
	
	return flag;
}
#ifdef aaa
bool Buycheck(){return Buycheck6_Vhige();}
bool Sellcheck(){return Sellcheck6();}
bool CloseBuycheck(){return CloseBuycheck6();}
bool CloseSellcheck(){return  CloseSellcheck6();}
#endif




bool Buycheck6_Vhige(){//V下髭で上へ
	
	bool flag=false;
	double d;
	d=chgPips2price(NumOfBeard_pips);
	if( Close[1]>Open[1] ==true){
	   //陽線の時
		if(((High[1] -Close[1])>d) ||((Open[1] -Low[1])>d)) {
			flag =true			
			;
			//PrintFormat("P上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Close[1]), chgPrice2Pips(Open[1] -Low[1]));
//			PrintFormat("PP上髭\t%g\t, \t下髭\t%g", (High[1] -Close[1]), (Open[1] -Low[1]));
		}
	}else{
	//陰線の時
		if(((High[1] -Open[1])>d) ||((Close[1] -Low[1])>d)) {
					flag =true
			   ;
			//PrintFormat("H上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Open[1]), chgPrice2Pips(Close[1] -Low[1]));
			
//			PrintFormat("HH上髭\t%g\t, \t下髭\t%g", (High[1] -Open[1]), (Close[1] -Low[1]));
		}
	}

#ifdef aaa
	if( Close[2]>Open[2] ==true){
	   //陽線の時
		if(((High[2] -Close[2])>d) ||((Open[2] -Low[2])>d)) {
			//flag =true			
			//;
			//PrintFormat("P上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Close[1]), chgPrice2Pips(Open[1] -Low[1]));
//			PrintFormat("PP上髭\t%g\t, \t下髭\t%g", (High[1] -Close[1]), (Open[1] -Low[1]));
		}
	}else{
	//陰線の時
	   //ひとつ前が下髭で来たか？
//		if(((High[1] -Open[1])>d) ||((Close[1] -Low[1])>d)) {
		if(((Close[2] -Low[2])>d)) {
		   //現在の足が前回の足を超えた
		   if(Open[2] < Open[0]){
					flag =true
			   ;
			//PrintFormat("H上髭\t%g\t, \t下髭\t%g", chgPrice2Pips(High[1] -Open[1]), chgPrice2Pips(Close[1] -Low[1]));
			}
//			PrintFormat("HH上髭\t%g\t, \t下髭\t%g", (High[1] -Open[1]), (Close[1] -Low[1]));
		}
	}
#endif	

	return flag;
}

bool Sellcheck6(){
	bool flag = false
   	;
	return flag;
}

bool CloseBuycheck6(){
	bool flag =
		GetAfter_bar()>1
	
//		GetAfter_bar()>=NumberOfBarAfterTouch
		//||
		//帯域を抜けたら
		
		;
	;
	
	return flag;
}

bool CloseSellcheck6(){
	bool flag =
			GetAfter_bar()>3

//		GetAfter_bar()>=NumberOfBarAfterTouch;
	
	;
	
	return flag;
}


#ifdef aaa
bool Buycheck(){return Buycheck7();}
bool Sellcheck(){return Sellcheck7();}
bool CloseBuycheck(){return CloseBuycheck7();}
bool CloseSellcheck(){return  CloseSellcheck7();}
#endif

bool Buycheck7(){
	bool flag = isUpSlowTrend() 
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
//	&& GetSlowBandHigh()>0.000455

//	&& bufferHennkaritu[0]>0.00095
//	&& bufferHennkaritu[0]>0.01
	
//	&&(	!STC_D_IsKawaresugi_Area()	)
//	&&(STC_K_D_GoldenCross(1)
		//||STC_K_D_GoldenCross(1)||STC_K_D_GoldenCross(2)
	
//	)
	//isUpSlowTrend()&&isUpAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))


//	&&(Close[0] > bufferGMMAFast6[0])


		;
		
		
	return flag;
}

bool Sellcheck7(){
//	bool flag =isDownSlowTrend()&&isDownAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
	bool flag =isDownSlowTrend()
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
//	&& GetSlowBandHigh()>0.000455


//	&& bufferHennkaritu[0]>0.00095
//	&& bufferHennkaritu[0]>0.01

//	&& (!STC_D_IsUraresugi_Area())
//	&&(STC_K_D_DedCross(1)
	//	||STC_K_D_DedCross(3)||STC_K_D_DedCross(2)
//	)

	
//	&&(Close[0] < bufferGMMAFast6[0])
	;
	return flag;
}

bool CloseBuycheck7(){
//	bool flag =Close[0]< bufferGMMASlow1[0];
	bool flag =(isUpSlowTrend()==false)
	
	
//	|| 
//	( STC_K_D_DedCross(1)
//	  &&(	!STC_D_IsUraresugi_Area()	)
//	 )
	
	;
	;
	
	return flag;
}

bool CloseSellcheck7(){
//	bool flag =Close[0]> bufferGMMASlow1[0];
	bool flag =(isDownSlowTrend()==false)
	
	
//	||
//	( STC_K_D_GoldenCross(1)
//	  && (!STC_D_IsKawaresugi_Area())
//	)
	
	;
	
	
	;
	return flag;
}


// bolinger
#ifdef aaaa
bool Buycheck(){return Buycheck_bolinger_GMMA();}
bool Sellcheck(){return Sellcheck_bolinger_GMMA();}
bool CloseBuycheck(){return CloseBuycheck_bolinger_GMMA();}
bool CloseSellcheck(){return  CloseSellcheck_bolinger_GMMA();}
#endif
int bolinger_Entry_Kind_type;
int after_chg_bolinger_Entry_Kind_type;
void bolinger_Entry_Kind_Init(){
   bolinger_Entry_Kind_type = 0;
   after_chg_bolinger_Entry_Kind_type = 0;
}
int bolinger_Entry_Kind_Cal(int direct){// 1:UP -1;Downトレンド
int s=0; 
   bolinger_Entry_Kind_type=
			1*((Close[0+s]> Bolinger_bufferUpper1[0+s])  && (Low[1+s]< Bolinger_bufferUpper1[0+s])&&isUpAllTrend() )//UP1シグマ線をUp２シグマ領域へ
			+2*((Close[0+s]> Bolinger_bufferMiddle1[0])  && (Low[1+s]< Bolinger_bufferMiddle1[0])) //MAを下から上へ
			+4*((Close[0+s]> Bolinger_bufferLower1[0])  && (Low[1+s]< Bolinger_bufferLower1[0]) )//Low１シグマ線をMA方面へ横切る
			+8*((Close[0+s]> Bolinger_bufferLower2[0])  && (Low[1+s]< Bolinger_bufferLower2[0]) )//Low２シグマ線をLow1方面へ横切る
         +16*((Close[0+s]> Bolinger_bufferLower3[0])  && (Low[1+s]< Bolinger_bufferLower3[0]) )//Low3シグマ線をLow2方面へ横切る	
   ;
   return bolinger_Entry_Kind_type;
}
bool Buycheck_bolinger_GMMA(){
int s=0; 
	bool flag = 
		isUpSlowTrend() &&//UPトレンド（長期成立）
		//（角度も指定したほうが良いか？）
		//以下のいずれか成立時
		(
			((Close[0+s]> Bolinger_bufferUpper1[0+s])  && (Low[1+s]< Bolinger_bufferUpper1[0+s]) && isUpAllTrend())||//UP1シグマ線をUp２シグマ領域へ
//			((Close[0+s]> Bolinger_bufferMiddle1[0])  && (Close[1+s]< Bolinger_bufferMiddle1[0]) )||//MAを下から上へ
			((Close[0+s]> Bolinger_bufferMiddle1[0])  && ( Low[1+s]< Bolinger_bufferMiddle1[0]) )||//MAを下から上へ
			((Close[0+s]> Bolinger_bufferLower1[0])  && (Low[1+s]< Bolinger_bufferLower1[0]) )||//Low１シグマ線をMA方面へ横切る
			((Close[0+s]> Bolinger_bufferLower2[0])  && (Low[1+s]< Bolinger_bufferLower2[0]) )||//Low２シグマ線をLow1方面へ横切る
         ((Close[0+s]> Bolinger_bufferLower3[0])  && (Low[1+s]< Bolinger_bufferLower3[0]) )//Low3シグマ線をLow2方面へ横切る	
      )
      //&& (bufferHennkaritu[0]> (0.00034))
      ; 
      if( flag == true){
         bolinger_Entry_Kind_Cal(1);
      }
	//
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
//	&& GetSlowBandHigh()>0.000455

//	&& bufferHennkaritu[0]>0.00095
//	&& bufferHennkaritu[0]>0.01
	
//	&&(	!STC_D_IsKawaresugi_Area()	)
//	&&(STC_K_D_GoldenCross(1)
		//||STC_K_D_GoldenCross(1)||STC_K_D_GoldenCross(2)
	
//	)
	//isUpSlowTrend()&&isUpAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))


//	&&(Close[0] > bufferGMMAFast6[0])


		;
		
		
	return flag;
}

bool Sellcheck_bolinger_GMMA(){
//	bool flag =isDownSlowTrend()&&isDownAllTrend() && ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
//	bool flag =isDownSlowTrend()
	bool flag =false
	//&& ((bufferKairiritu[0]< 0.01)  && (bufferKairiritu[0]> -0.01))
//	&& GetSlowBandHigh()>0.000455


//	&& bufferHennkaritu[0]>0.00095
//	&& bufferHennkaritu[0]>0.01

//	&& (!STC_D_IsUraresugi_Area())
//	&&(STC_K_D_DedCross(1)
	//	||STC_K_D_DedCross(3)||STC_K_D_DedCross(2)
//	)

	
//	&&(Close[0] < bufferGMMAFast6[0])
	;
	return flag;
}

bool CloseBuycheck_bolinger_GMMA(){


//　利確超えるまではみない　自動損切とする。
//　利確超えたら確認する。
//return false;


   //MAを下抜き
   int s = 0;//Shift
	bool flag = false;//Close[0]< Bolinger_bufferMiddle1[0]&& Close[1]> Bolinger_bufferMiddle1[0]&& Close[2]> Bolinger_bufferMiddle1[0];
	// 買うタイミングがMAよりも下があるので、エントリー直後に
   int e = 0;

//   after_chg_bolinger_Entry_Kind_type = bolinger_Entry_Kind_type;
   //　反対のエリアで買ったもので、値段上がったものは段階的に損切エリアを上げる。
   // 現状のエリアを確認
   if (after_chg_bolinger_Entry_Kind_type == 0 ){after_chg_bolinger_Entry_Kind_type = bolinger_Entry_Kind_type;}
	int tmp_bolinger_Entry_Kind_type    = 16;
			//1*((Close[0+s]> Bolinger_bufferUpper1[0+s])  && (Close[1+s]< Bolinger_bufferUpper1[0+s]) )//UP1シグマ線をUp２シグマ領域へ

			if((Close[0+s]> Bolinger_bufferUpper3[0])==true){ //Up3以上
				tmp_bolinger_Entry_Kind_type    = 1;
			}else
			if((Close[0+s]> Bolinger_bufferUpper2[0])==true){ //Up2以上
				tmp_bolinger_Entry_Kind_type    = 2;
			}else
			if((Close[0+s]> Bolinger_bufferUpper1[0])==true){ //Up1以上
				tmp_bolinger_Entry_Kind_type    = 4;
			}else
			if((Close[0+s]> Bolinger_bufferMiddle1[0])==true){ //MA以上
				tmp_bolinger_Entry_Kind_type    = 8;
			}else
			if((Close[0+s]> Bolinger_bufferLower1[0])==true){ //Low１シグマ線をMA方面へ横切る
				tmp_bolinger_Entry_Kind_type    = 16;
			}else
			if((Close[0+s]> Bolinger_bufferLower2[0])==true){ //Low２シグマ線をLow1方面へ横切る
				tmp_bolinger_Entry_Kind_type    = 16;
			}else
         	if((Close[0+s]> Bolinger_bufferLower3[0])==true){ //Low3シグマ線をLow2方面へ横切る	
				tmp_bolinger_Entry_Kind_type    = 16;
			}
   ;
   if(tmp_bolinger_Entry_Kind_type < after_chg_bolinger_Entry_Kind_type )
   {
			after_chg_bolinger_Entry_Kind_type=tmp_bolinger_Entry_Kind_type;
	}

	if(after_chg_bolinger_Entry_Kind_type <= 1){    //　UP1-> Up2なのでUp1を下回ったらExit
      flag = Close[0+s]< Bolinger_bufferUpper1[0+s]&& Close[1+s]> Bolinger_bufferUpper1[0+s]
         ;//&& Close[2+s]> Bolinger_bufferUpper1[0];
      e = 1;
	}
	if(after_chg_bolinger_Entry_Kind_type <= 2 && flag==false){    //　MA-> Low1なのでMAを下回ったらExit
      flag = Close[0+s]< Bolinger_bufferMiddle1[0+s]&& Close[1+s]> Bolinger_bufferMiddle1[0+s]
         ;//&& Close[2+s]> Bolinger_bufferMiddle1[0+s];
      e = 2;
	}
	if(after_chg_bolinger_Entry_Kind_type <= 4&& flag==false){    //　Low1-> MAなのでLow1を下回ったらExit
      flag = Close[0+s]< Bolinger_bufferLower1[0+s]&& Close[1+s]> Bolinger_bufferLower1[0+s]
         ;//&& Close[2+s]> Bolinger_bufferLower1[0+s];
      e = 4;
	}
	if(after_chg_bolinger_Entry_Kind_type <= 8&& flag==false){    //　Low2-> Low1なのでLow2を下回ったらExit
      flag = Close[0+s]< Bolinger_bufferLower2[0+s]&& Close[1+s]> Bolinger_bufferLower2[0+s]
         ;//&& Close[2+s]> Bolinger_bufferLower2[0+s];
      e = 8;
	}
	if(after_chg_bolinger_Entry_Kind_type <= 16&& flag==false){   // Low3-> Low2なのでLow3を下回ったらExit 
      flag = Close[0+s]< Bolinger_bufferLower3[0+s]&& Close[1+s]> Bolinger_bufferLower3[0+s]
         ;//&& Close[2+s]> Bolinger_bufferLower3[0+s];
      e = 16;
	}
	if(after_chg_bolinger_Entry_Kind_type > 16&& flag==false){   // Low3-> Low2なのでLow3を下回ったらExit 
      printf( "error types kindno");
      e = 166;
   }	
	if(isUpSlowTrend() != true && flag==false){
//debug//
	   flag = true;
      e = 200;
	}
	
	if(flag == true) {
	   bolinger_Entry_Kind_Init();
		addStrSlowBandHigh("ex:"+(string)e);
	}
	
	return flag;
}

bool CloseSellcheck_bolinger_GMMA(){
   //MAを上抜き
	bool flag = Close[0]> Bolinger_bufferMiddle1[0];
	return flag;
	return flag;
}




bool Buycheck(){
	bool ret=false;

	return (ret);
	}
bool Sellcheck(){
		bool ret=false;

	
	if(testsq == 1 ){
		ret = true;
	}else if(testsq == 2){
		ret = true;
	
	}else if(testsq == 3){
		ret = true;
	}
	return (ret);
	}
bool CloseSellcheck  (){
	bool ret=false;
	if(testsq == 4 ){
		ret = true;
	}else if(testsq == 5 && testflag[5]==0){
		ret = true;
	}else if(testsq == 6&& testflag[6]==0){
		ret = true;
	}else if(testsq == 7&& testflag[7]==0){
				ret = true;
	}else if(testsq == 8&& testflag[8]==0){
				ret = true;
	
	}else if(testsq == 9){
				ret = false;
	}
	return (ret);
	}
bool CloseBuycheck(){
	return  (false);
	}

///////////////////////////////////////////////////////////////
/// 売り買いメソッド　個別　判断する関数
///////////////////////////////////////////////////////////////

bool buycheck_span_boll(){
   bool ret;
   ret = flag_buy_No1;
#ifdef dellll   
     bufferSpanA[0] > bufferSpanB[0] &&
     Close[1]>bufferSpanA[0] &&
     bufferSpanChikou[0] > Close[InpKijun-1]
     
//２　　ExtSpanABuffer　　>　ExtSpanBBuffer　　　赤で↑の雲
//３　　ExtSpanABuffer　　＜　ExtSpanBBuffer　　　青で↓の雲
   ;
#endif   
   return ret;

}
bool sellcheck_span_boll(){return false;}
bool exit_buycheck_span_boll(){

//return(     Close[1]<bufferSpanA[0] );
//return ( GetAfter_bar() > 10*15 );
//No.1 return ( GetAfter_bar() > 10*15 || bufferSpanB[0]>Close[0]);

bool ret = 
bufferSpanB[0]>Close[0] ||                                  //   パターン１のExit条件：雲下抜け・タッチ
(locate_info_kumo_youtenn == 2 && bufferSpanA[0]>Close[0]) ||   //   パターン１のExit条件：雲上抜けしてから雲上部にタッチ
flag_exit_mode_chg // mode 変化時クローズ
;
if(flag_exit_mode_chg){flag_exit_mode_chg=false;}
return ( ret );

//★



}
bool exit_sellcheck_span_boll(){return false;}
///////////////////no2
bool buycheck_span_boll_No2(){
   bool ret;
   ret = flag_buy_No2;
   

	double katamuki= ((Bolinger_bufferMiddle1[0]-Bolinger_bufferMiddle1[1])/1)/(Point()*10);//
	double bandwide_Fb = sigma_1*4/(Point()*10);//2σ[pips]

   //fillter 
   if(bandwide_Fb > 30){// ±2σ幅
	
		if(katamuki > 0.1){
		   if( sigma > 1.0){
				flag_buy_No2 = true;
		        ret = flag_buy_No2;
			}
		}
	}
   
   return ret;

}
bool sellcheck_span_boll_No2(){return false;}
bool exit_buycheck_span_boll_No2(){

//return(     Close[1]<bufferSpanA[0] );
return ( GetAfter_bar() > 10*15 );
//return ( GetAfter_bar() > 10*15 || bufferSpanB[0]>Close[0]);

#ifdef asdfasdfa
bool ret = 
bufferSpanB[0]>Close[0] ||                                  //   パターン１のExit条件：雲下抜け・タッチ
(locate_info_kumo_youtenn == 2 && bufferSpanA[0]>Close[0]) ||   //   パターン１のExit条件：雲上抜けしてから雲上部にタッチ
flag_exit_mode_chg // mode 変化時クローズ
;
if(flag_exit_mode_chg){flag_exit_mode_chg=false;}
return ( ret );
#endif
//★
}

bool exit_buycheck_span_boll_No2_bollnger(){

	return(
	Bolinger_bufferMiddle1[1]>Close[1] 		//Middleを下に行くとExit
	);

	return(
	bufferSpanB[0] >Close[0]||		//雲下抜けでExit
	Bolinger_bufferMiddle1[0]+sigma_1*RikakuSigma  <Close[0]      ||     //RikakuSigmaσ超えたら　Exit 利確
	Bolinger_bufferMiddle1[0]+sigma_1*ExitSigma >Close[0]   //ExitSigmaσより下に行ったら

	//||

	//GetAfter_bar() > 10*15





);
}



bool exit_sellcheck_span_boll_No2(){return false;}

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////End　売り買いチェックメソッド///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//ファイル読み込み/////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+ 
//| スクリプトプログラムを開始する関数                                          | 
//+------------------------------------------------------------------+ 

//input string InpFileName="Trend.bin"; // ファイル名 
//input string InpDirectoryName="Data"; // ディレクトリ名 

string InpFileName="test.txt"; // ファイル名 
string InpDirectoryName="Data"; // ディレクトリ名 

//void OnStart() 
void readtext()
{
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//OK
//      	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
      	int file_handle=FileOpen(".\\data\\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\\test2.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//C:\Users\makoto\AppData\Roaming\MetaQuotes\\tester\D0E8209F77C8CF37AD8BF550E51FF075\Agent-127.0.0.1-3000\Files\

	if(file_handle!=INVALID_HANDLE)
    	{
	  	PrintFormat("%s file is available for reading",InpFileName);
	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
	  	int	  str_size;
	  	string str;
	  	//--- ファイルからデータを読む
//	  	while(!FileIsEnding(file_handle))
	  	while(!(FileIsLineEnding(file_handle)  ||FileIsEnding(file_handle)))
	  	
		{
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str);
		}

		//--- ファイルを閉じる
	  	FileClose(file_handle);
	  	PrintFormat("Data is read, %s file is closed",InpFileName);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
}

void writetext()
{
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_BIN|FILE_ANSI);
	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_ANSI|FILE_TXT);
	if(file_handle!=INVALID_HANDLE)
    	{
	  	PrintFormat("%s file is available for reading",InpFileName);
	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
//	  	int	  str_size;
	  	string str;
	  	
#ifdef aaa	  	
	  	//--- ファイルからデータを読む
	  	while(!FileIsEnding(file_handle))
		{
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str);
		}
#endif
      str = (string)TimeCurrent();
      str = str + "\t" + "test"+ "\r\ntest2";
      FileSeek(file_handle,0, SEEK_END);
      FileWrite(file_handle,str);
      FileFlush(file_handle);
		//--- ファイルを閉じる
	  	FileClose(file_handle);
	  	PrintFormat("Data is read, %s file is closed",InpFileName);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
}


///////////////////////////////////////////////////////////////////////////////////////////
void writestring(string str)
{
//ファイルの最後にStrに追加　改行は\r\nでOK
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_BIN|FILE_ANSI);
	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_ANSI|FILE_TXT);
	if(file_handle!=INVALID_HANDLE)
    	{
	  	PrintFormat("%s file is available for reading",InpFileName);
	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
//	  	int	  str_size;
//	  	string str;
	  	
#ifdef aaa	  	
	  	//--- ファイルからデータを読む
	  	while(!FileIsEnding(file_handle))
		{
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str);
		}
#endif
//      str = (string)TimeCurrent();
//      str = str + "\t" + "test"+ "\r\ntest2";
      FileSeek(file_handle,0, SEEK_END);
      FileWrite(file_handle,str);
      FileFlush(file_handle);
		//--- ファイルを閉じる
	  	FileClose(file_handle);
	  	PrintFormat("Data is read, %s file is closed",InpFileName);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
}
///////////////////////////////////////////////////////////////////////////////////////////


//--- データ読み込みのパラメータ 
input string InpFileNameSignalDate="MACD.csv"; // ファイル名
input string InpDirectoryNameSignalDate="Data"; // ディレクトリ名


#property tester_file "data\\MACD23.csv"
#property tester_file "data\\MACD2_tab.csv"
#property tester_file "data\\test.txt"

//--- グローバル変数 
//int      ind=0;       // インデックス 
double   upbuff[300];   // 上向き矢印の指標バッファ 
double   downbuff[300]; // 下向き矢印の指標バッファ 
bool     sign_buff[]; // シグナル配列（true - 買、false - 売） 
datetime time_buff[]; // シグナル到着時の配列 
int      size_SignalDate=0;     // シグナル配列のサイズ 
// データの数（行の数）
//　時間
//　シグナル配列（true - 買、false - 売） 　




///////////////////////////////////////////////////////////////////////////////////////////

int init_MyFunc_Etc(){
	//                 TakeProfit     = 8000 	 ;   //take profit                                    
	//                 StopLoss       = 300;   //stop loss                                 

	/////////////////////////////////////////////////
	//   SetIndexBuffer(7,ArrowABuffer,INDICATOR_DATA);
	//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
	//   PlotIndexSetInteger(0, PLOT_ARROW, 128);//数字矢印   
	//   ArraySetAsSeries(ArrowABuffer,true);
	/////////////////////////////////////////////////

		//EMAhandle_A=iCustom(Symbol(),Period(),"..\Indicators\10Trend\Custom Moving Average Input Color",
		int handle_view=iCustom(Symbol(),Period(),"My_ViewNo"); 

	//
	init_span_bollnger_data();

	//Span
	init_span_boll();

	//Sn data
	init_sndata();

	//test_sn();


	testsq=0;//テスト用シーケンス番号
	testsq_time = 0;//テスト用時間
	for( int kk =0;kk<1000;kk++){
	   testflag[kk]=0;
	}


	bolinger_Entry_Kind_Init();
	writetext();
	//readtext();
	//InitreaddataSignalDate();
			/// TimeFreme
			OnInitCSignalITF();

	//--- 配列の指標バッファへの割り当て 
	  SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA); 
	  SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA); 
	  ArraySetAsSeries(UpperBuffer ,true);
	  ArraySetAsSeries(LowerBuffer ,true);


	//--- それぞれの線のシフトを設定 
	  PlotIndexSetInteger(0,PLOT_SHIFT,ma_shift1); 
	  PlotIndexSetInteger(1,PLOT_SHIFT,ma_shift1);   
	//--- 指標が描画するシンボルを決める 
	  EnvelopeName=Envelopesymbol; 
	//--- 左右のスペースを削する 
	  StringTrimRight(EnvelopeName); 
	  StringTrimLeft(EnvelopeName); 
	//---「EnvelopeName」文字列の長さがゼロになった場合 
	  if(StringLen(EnvelopeName)==0) 
	    { 
	    //--- 指標が接続されているチャートのシンボルを取る 
	     EnvelopeName=_Symbol; 
	    } 
	    
	    
	//-----------------------------------------------------------------------------------------//
	//Envelope
	//-----------------------------------------------------------------------------------------//
	//--- 指標ハンドルを作成する 
	#ifdef aaaaaa
	  if(Envelopetype==Call_iEnvelopes) 
	     Envelopehandel=iEnvelopes(EnvelopeName,period1,ma_period1,ma_shift1,ma_method1,applied_price_Envelope,deviation1); 
	  else 
	    { 
	    //--- 構造体を指標のパラメータで記入 
	     MqlParam pars[5]; 
	    //--- 移動平均の期間 
	     pars[0].type=TYPE_INT; 
	     pars[0].integer_value=ma_period1; 
	    //--- シフト 
	     pars[1].type=TYPE_INT; 
	     pars[1].integer_value=ma_shift1; 
	    //--- 平滑化の種類 
	     pars[2].type=TYPE_INT; 
	     pars[2].integer_value=ma_method1; 
	    //--- 価格の種類 
	     pars[3].type=TYPE_INT; 
	     pars[3].integer_value=applied_price_Envelope; 
	    //--- 価格の種類 
	     pars[4].type=TYPE_DOUBLE; 
	     pars[4].double_value=deviation1; 
	     Envelopehandel=IndicatorCreate(EnvelopeName,period1,IND_ENVELOPES,5,pars); 
	    } 
	//--- ハンドルが作成されなかった場合 
	  if(Envelopehandel==INVALID_HANDLE) 
	    { 
	    //--- 失敗した事実とエラーコードを出力する 
	    PrintFormat("Failed to create Envelopehandel of the iEnvelopes indicator for the symbol %s/%s, error code %d", 
	                 EnvelopeName, 
	                EnumToString(period1), 
	                GetLastError()); 
	    //--- 指標が早期に中止された 
	    return(INIT_FAILED); 
	    } 
	//--- Envelopes 指標が計算された銘柄/時間軸を表示 
	  short_name=StringFormat("iEnvelopes(%s/%s, %d, %d, %s,%s, %G)",EnvelopeName,EnumToString(period1), 
	  ma_period1,ma_shift1,EnumToString(ma_method1),EnumToString(applied_price_Envelope),deviation1); 
	  IndicatorSetString(INDICATOR_SHORTNAME,short_name); 
	#endif

	// EMA
	//--- iMA指標のハンドルを作成する
		//EMAhandle_A=iCustom(Symbol(),Period(),"..\Indicators\10Trend\Custom Moving Average Input Color",
		EMAhandle_A=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                            EMA_period_A,0,EMA_method,clrBlue,PRICE_CLOSE);
	//]EMAhandle_A=iMA(Symbol(),Period(),EMA_period_A,InpMAShiftFirst,EMA_method,PRICE_CLOSE);
	//  EMAhandle_A = iMA(NULL,0,EMA_period_A,0,EMA_method, EMAapplied_price);

	//--- ハンドルが作成されなかった場合 
		if(EMAhandle_A==INVALID_HANDLE)
		{
			//--- メッセージとエラーコードを出力する 
			PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
	                  Symbol(),
	                  EnumToString(Period()),
	                  GetLastError());
			//--- 指標が中断された 
			return(INIT_FAILED);
		}


	//  EMAhandle_A = iMA(NULL,0,EMA_period_A,0,EMA_method, EMAapplied_price);
	  SetIndexBuffer(2,bufferEMA_A,INDICATOR_DATA); 
	  ArraySetAsSeries(bufferEMA_A ,true);


		EMAhandle_B=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                            EMA_period_B,0,EMA_method,clrYellow,PRICE_CLOSE);
	//  EMAhandle_B = iMA(NULL,0,EMA_period_B,0,EMA_method, EMAapplied_price);




	//--- ハンドルが作成されなかった場合 
		if(EMAhandle_B==INVALID_HANDLE)
		{
			//--- メッセージとエラーコードを出力する 
			PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
	                  Symbol(),
	                  EnumToString(Period()),
	                  GetLastError());
			//--- 指標が中断された 
			return(INIT_FAILED);
		}
	  SetIndexBuffer(6,bufferEMA_B,INDICATOR_DATA); 
	  ArraySetAsSeries(bufferEMA_B ,true);

		EMAhandle_C=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                            EMA_period_C,0,EMA_method,clrYellowGreen,PRICE_CLOSE);
	//    EMAhandle_C = iMA(NULL,0,EMA_period_C,0,EMA_method, EMAapplied_price);


	//--- ハンドルが作成されなかった場合 
		if(EMAhandle_C==INVALID_HANDLE)
		{
			//--- メッセージとエラーコードを出力する 
			PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
	                  Symbol(),
	                  EnumToString(Period()),
	                  GetLastError());
			//--- 指標が中断された 
			return(INIT_FAILED);
		}
	  SetIndexBuffer(7,bufferEMA_C,INDICATOR_DATA); 
	  ArraySetAsSeries(bufferEMA_C ,true);


	// icustomでインジケータを追加できる。引数は2行目から。INPの順で指定）
	//	int Arrowhandle=iCustom(Symbol(),Period(),"..\indecators\My_Arrow_test",
	//                            );

	//int My1ViewsignalDatehandle=iCustom(Symbol(),Period(),"..\\indecators\\My1ViewsignalDate");


	//////////////////////////////////////////
	///// STC
	/////////////////////////////////////////
	//--- 配列の指標バッファへの割り当て 
	  SetIndexBuffer(3,StochasticBuffer,INDICATOR_DATA); 
	  ArraySetAsSeries(StochasticBuffer ,true);

	  SetIndexBuffer(4,SignalBuffer,INDICATOR_DATA); 
	  ArraySetAsSeries(SignalBuffer ,true);
	//--- 指標が描画するシンボルを決める 
	  name1=symbol1; 
	//--- 左右のスペースを削する 
	  StringTrimRight(name1); 
	  StringTrimLeft(name1); 
	//---「name1」文字列の長さがゼロになった場合 
	  if(StringLen(name1)==0) 
	    { 
	    //--- 指標が接続されているチャートのシンボルを取る 
	     name1=_Symbol; 
	    } 
	//--- 指標ハンドルを作成する 
	  if(type1==Call_iStochastic) 
	     STChandle=iStochastic(name1,STCperiod,Kperiod1,Dperiod1,slowing1,ma_method1,price_field1); 
	  else 
	    { 
	    //--- 構造体を指標のパラメータで記入     
	     MqlParam pars[5]; 
	    //--- 計算の K 期間 
	     pars[0].type=TYPE_INT; 
	     pars[0].integer_value=Kperiod1; 
	    //--- 主要な平滑化の D 期間 
	     pars[1].type=TYPE_INT; 
	     pars[1].integer_value=Dperiod1; 
	    //--- 最後の平滑化の K 期間 
	     pars[2].type=TYPE_INT; 
	     pars[2].integer_value=slowing1; 
	    //--- 平滑化の種類 
	     pars[3].type=TYPE_INT; 
	     pars[3].integer_value=ma_method1; 
	    //--- 確率の計算方法 
	     pars[4].type=TYPE_INT; 
	     pars[4].integer_value=price_field1; 
	     STChandle=IndicatorCreate(name1,STCperiod,IND_STOCHASTIC,5,pars); 
	    } 
	//--- ハンドルが作成されなかった場合 
	  if(STChandle==INVALID_HANDLE) 
	    { 
	    //--- 失敗した事実とエラーコードを出力する 
	    PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d", 
	                 name1, 
	                EnumToString(STCperiod), 
	                GetLastError()); 
	    //--- 指標が早期に中止された 
	    return(INIT_FAILED); 
	    } 
	/////////////////////////////////////////////////
	//  end STC init
	/////////////////////////////////////////////////



	//////////////////////////////////////////
	///// RSI 
	/////////////////////////////////////////
	//--- 配列の指標バッファへの割り当て 
	  SetIndexBuffer(5,iRSIBuffer,INDICATOR_DATA); 
	  ArraySetAsSeries(iRSIBuffer ,true); // 0要素を最新とするため

	//--- 指標が描画するシンボルを決める 
	  name1=RSIsymbol; 
	//--- 左右のスペースを削する 
	  StringTrimRight(name1); 
	  StringTrimLeft(name1); 
	//---「name1」文字列の長さがゼロになった場合 
	  if(StringLen(name1)==0) 
	    { 
	    //--- 指標が接続されているチャートのシンボルを取る 
	     name1=_Symbol; 
	    } 
	//--- 指標ハンドルを作成する 
	  if(type1==Call_iRSI) 
	     RSIhandle=iRSI(name1,RSIperiod,RSIma_period,RSIapplied_price); 
	  else 
	    { 
	    //--- 構造体を指標のパラメータで記入     
	     MqlParam pars[2]; 
	    //--- 移動平均の期間 
	     pars[0].type=TYPE_INT; 
	     pars[0].integer_value=RSIma_period; 
	    //--- 計算に使用するステップ値の制限 
	     pars[1].type=TYPE_INT; 
	     pars[1].integer_value=RSIapplied_price; 
	     RSIhandle=IndicatorCreate(name1,RSIperiod,IND_RSI,2,pars); 
	    } 
	//--- ハンドルが作成されなかった場合 
	  if(RSIhandle==INVALID_HANDLE) 
	    { 
	    //--- 失敗した事実とエラーコードを出力する 
	    PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d", 
	                 name1, 
	                EnumToString(RSIperiod), 
	                GetLastError()); 
	    //--- 指標が早期に中止された 
	    return(INIT_FAILED); 
	    } 
	//////////////////////////////////////////
	///// RSI end
	/////////////////////////////////////////

	//////////////////////////////////////////
	///// Bolinger 
	/////////////////////////////////////////
	handle_Bolinger1 = iCustom(Symbol(),Period(),"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	1.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_CURRENT//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);
	handle_Bolinger2 = iCustom(Symbol(),Period(),"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	2.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_CURRENT//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);
	handle_Bolinger3 = iCustom(Symbol(),Period(),"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	3.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_CURRENT//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);



	handle_Bolinger1_H1 = iCustom(Symbol(),PERIOD_H1,"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	1.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_H1//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);
	handle_Bolinger2_H1 = iCustom(Symbol(),PERIOD_H1,"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	2.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_H1//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);
	handle_Bolinger3_H1 = iCustom(Symbol(),PERIOD_H1,"Mytest201811\\BollingerBands",
	//--- 入力パラメータ 
	0,//input Creation             type=Call_iBands;         // 関数の種類 
	25,//input int                  bands_period=20;           // 移動平均の期間 
	0,//input int                  bands_shift=0;             // シフト 
	3.0,//input double               deviation=2.0;             // 標準偏差の数 
	PRICE_CLOSE,//input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 価格の種類 
	" ",//input string               symbol=" ";               // シンボル 
	PERIOD_H1//input ENUM_TIMEFRAMES     period=PERIOD_CURRENT;     // 時間軸 

	);

	//iCustom(Symbol(),PERIOD_H1,"10Trend\\Custom Moving Average Input Color",
	//                            300,0,MODE_SMA,clrBlue,PRICE_CLOSE);
	//////////////////////////////////////////
	///// GMMA 
	/////////////////////////////////////////
	//GMMA
	//#property tester_file "..\\..\\Indicators\\use\\gmma.ex5"
	//#property tester_file "..\\..\\Indicators\\use\\gmma.mq5"
	//handle_GMMA  = iCustom(Symbol(),Period(),"..\\..\\Indicators\\use\\gmma",

	//	handle_GMMA=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	//                            EMA_period_C,0,EMA_method,clrYellowGreen,PRICE_CLOSE);

	//handle_GMMA  = iCustom(Symbol(),Period(),"use\\gmma",

	#ifdef GMMA
	handle_GMMA  = iCustom(Symbol(),Period(),"use\\gmma_マーク付き",


	xMA_Method,//input Smooth_Method xMA_Method=MODE_EMA; // Averaging method
	TrLength1,//input int TrLength1=3;   // 1 trader averaging period 
	TrLength2,//input int TrLength2=5;   // 2 trader averaging period 
	TrLength3,//input int TrLength3=8;   // 3 trader averaging period 
	TrLength4,//input int TrLength4=10;  // 4 trader averaging period 
	TrLength5,//input int TrLength5=12;  // 5 trader averaging period
	TrLength6,//input int TrLength6=15;  // 6 trader averaging period 

	InvLength1,//input int InvLength1=30; // 1 investor averaging period
	InvLength2,//input int InvLength2=35; // 2 investor averaging period
	InvLength3,//input int InvLength3=40; // 3 investor averaging period
	InvLength4,//input int InvLength4=45; // 4 investor averaging period
	InvLength5,//input int InvLength5=50; // 5 investor averaging period
	InvLength6,//input int InvLength6=60; // 6 investor averaging period

	xPhase,//input int xPhase=100;                 // Smoothing parameter
	IPC ,//input Applied_price_ IPC=PRICE_CLOSE; // Price constant
	Shift//input int Shift=0;                    // Horizontal shift of the indicator in bars
		);
	init_GMMA_DATA();
	#endif // GMMA

	//////////////////////////////////////////
	///// GMMA end
	/////////////////////////////////////////

	//bolinger

	ArraySetAsSeries(Bolinger_bufferMiddle1,true);
	ArraySetAsSeries(Bolinger_bufferUpper1,true);
	ArraySetAsSeries(Bolinger_bufferLower1,true);
	//ArraySetAsSeries(Bolinger_bufferMiddle2,true);
	ArraySetAsSeries(Bolinger_bufferUpper2,true);
	ArraySetAsSeries(Bolinger_bufferLower2,true);
	//ArraySetAsSeries(Bolinger_bufferMiddle3,true);
	ArraySetAsSeries(Bolinger_bufferUpper3,true);
	ArraySetAsSeries(Bolinger_bufferLower3,true);

	ArraySetAsSeries(Bolinger_bufferMiddle1_H1,true);
	ArraySetAsSeries(Bolinger_bufferUpper1_H1,true);
	ArraySetAsSeries(Bolinger_bufferLower1_H1,true);




#ifdef aaaaaaaaaaaaaaaaaaaa
	                   hMA4_cur_m15 = iMA(NULL,PERIOD_M15,4,0,MODE_SMA, PRICE_TYPICAL);
	                   hMA4_prev_m15 = iMA(NULL,PERIOD_M15,4,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA4_2p_m15 = iMA(NULL,PERIOD_M15,4,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA5_prev_m15 = iMA(NULL,PERIOD_M15,5,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_cur_m15 = iMA(NULL,PERIOD_M15,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_prev_m15 = iMA(NULL,PERIOD_M15,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_2p_m15 = iMA(NULL,PERIOD_M15,8,0,MODE_SMA,PRICE_TYPICAL );
	               
	                   hMA8_cur = iMA(NULL,PERIOD_M1,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_prev = iMA(NULL,PERIOD_M1,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_2p = iMA(NULL,PERIOD_M1,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA8_3p = iMA(NULL,PERIOD_M1,8,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA5_cur = iMA(NULL,PERIOD_M1,5,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA5_prev = iMA(NULL,PERIOD_M1,5,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA5_2p = iMA(NULL,PERIOD_M1,5,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA13_cur = iMA(NULL,PERIOD_M1,13,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA13_prev = iMA(NULL,PERIOD_M1,13,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA13_2p = iMA(NULL,PERIOD_M1,13,0,MODE_SMA,PRICE_TYPICAL );  
	                   hMA60_cur = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA60_prev = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_TYPICAL );
	                   hMA60_2p = iMA(NULL,PERIOD_M1,60,0,MODE_SMA,PRICE_TYPICAL);
	                   hMA24_cur_h1 = iMA(NULL,PERIOD_H1,24,0,MODE_SMA,PRICE_TYPICAL);
	                   
	               //   ArraySetAsSeries(High, true);
	               //   ArraySetAsSeries(Low, true);
	               //   ArraySetAsSeries(Open, true);
	               //   ArraySetAsSeries(Close, true);
	                  ArraySetAsSeries(Time, true);
	                  
	                  ArraySetAsSeries(xMA4_cur_m15 ,true);
	                  ArraySetAsSeries(xMA4_prev_m15 ,true);
	                  ArraySetAsSeries(xMA4_2p_m15 ,true);
	                  ArraySetAsSeries(xMA5_prev_m15 ,true);
	                  ArraySetAsSeries(xMA8_cur_m15 ,true);
	                  ArraySetAsSeries(xMA8_prev_m15 ,true);
	                  ArraySetAsSeries(xMA8_2p_m15 ,true);
	                  ArraySetAsSeries(xMA8_cur ,true);
	                  ArraySetAsSeries(xMA8_prev ,true);
	                  ArraySetAsSeries(xMA8_2p ,true);
	                  ArraySetAsSeries(xMA8_3p ,true);
	                  ArraySetAsSeries(xMA5_cur ,true);
	                  ArraySetAsSeries(xMA5_prev ,true);
	                  ArraySetAsSeries(xMA5_2p ,true);
	                  ArraySetAsSeries(xMA13_cur ,true);
	                  ArraySetAsSeries(xMA13_prev ,true);
	                  ArraySetAsSeries(xMA13_2p ,true);
	                  ArraySetAsSeries(xMA60_cur ,true);
	                  ArraySetAsSeries(xMA60_prev ,true);
	                  ArraySetAsSeries(xMA60_2p ,true);
	                  ArraySetAsSeries(xMA24_cur_h1 ,true);   
#endif // old code del                  
	                  
	                  
	                  testn=0;
		
	return(0);
}



void OnTick_MyFunc_Etc(){

	// Span
	make_data_span_boll();



	
	//-----------------------------------------------------------------------------------------//
	//  指標ハンドルからデータをコピー
	//-----------------------------------------------------------------------------------------//
   if(CopyBuffer(EMAhandle_A ,0,0,MaxBars,bufferEMA_A ) < MaxBars) return;
   if(CopyBuffer(EMAhandle_B ,0,0,MaxBars,bufferEMA_B ) < MaxBars) return;
   if(CopyBuffer(EMAhandle_C ,0,0,MaxBars,bufferEMA_C ) < MaxBars) return;
//   if(CopyBuffer(Envelopehandel ,0,0,MaxBars,UpperBuffer ) < MaxBars) return;
//   if(CopyBuffer(Envelopehandel ,1,0,MaxBars,LowerBuffer ) < MaxBars) return;
   
   ///// STC
   if(CopyBuffer(STChandle ,MAIN_LINE,0,MaxBars,StochasticBuffer ) < MaxBars) return;
   if(CopyBuffer(STChandle ,SIGNAL_LINE,0,MaxBars,SignalBuffer ) < MaxBars) return;
   
   
   ///// RSI
   if(CopyBuffer(RSIhandle ,0,0,MaxBars,iRSIBuffer ) < MaxBars) return;
   
#ifdef GMMA
	// GMMA
   if(CopyBuffer( handle_GMMA ,0   ,0,MaxBars,bufferGMMAFast1 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,1   ,0,MaxBars,bufferGMMAFast2 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,2   ,0,MaxBars,bufferGMMAFast3 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,3   ,0,MaxBars,bufferGMMAFast4 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,4   ,0,MaxBars,bufferGMMAFast5 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,5   ,0,MaxBars,bufferGMMAFast6 ) < MaxBars) return;

   if(CopyBuffer(handle_GMMA ,6   ,0,MaxBars,bufferGMMASlow1 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,7   ,0,MaxBars,bufferGMMASlow2 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,8   ,0,MaxBars,bufferGMMASlow3 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,9   ,0,MaxBars,bufferGMMASlow4 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,10   ,0,MaxBars,bufferGMMASlow5 ) < MaxBars) return;
   if(CopyBuffer(handle_GMMA ,11   ,0,MaxBars,bufferGMMASlow6 ) < MaxBars) return;
#endif //GMMA
   // bolinger
   if(CopyBuffer(handle_Bolinger1 ,2   ,0,MaxBars,Bolinger_bufferMiddle1 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger1 ,0   ,0,MaxBars,Bolinger_bufferUpper1 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger1 ,1   ,0,MaxBars,Bolinger_bufferLower1 ) < MaxBars) return;

   if(CopyBuffer(handle_Bolinger2 ,2   ,0,MaxBars,Bolinger_bufferMiddle2 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger2 ,0   ,0,MaxBars,Bolinger_bufferUpper2 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger2 ,1   ,0,MaxBars,Bolinger_bufferLower2 ) < MaxBars) return;

   if(CopyBuffer(handle_Bolinger3 ,2   ,0,MaxBars,Bolinger_bufferMiddle3 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger3 ,0   ,0,MaxBars,Bolinger_bufferUpper3 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger3 , 1   ,0,MaxBars,Bolinger_bufferLower3 ) < MaxBars) return;
   // M U    L M  U L
   //   0      2    1


   if(CopyBuffer(handle_Bolinger1_H1 ,2   ,0,MaxBars,Bolinger_bufferMiddle1_H1 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger1_H1 ,0   ,0,MaxBars,Bolinger_bufferUpper1_H1 ) < MaxBars) return;
   if(CopyBuffer(handle_Bolinger1_H1 ,1   ,0,MaxBars,Bolinger_bufferLower1_H1 ) < MaxBars) return;

    //なんσ＝差d/σ　で出るはず。
    //　（Price-Middle）/（1σーMiddle）
    sigma_1= Bolinger_bufferUpper1[0]-Bolinger_bufferMiddle1[0];
    sigma=(Close[0]-Bolinger_bufferMiddle1[0])/(sigma_1);
    //なんσ＝差d/σ　で出るはず。
    //　（Price-Middle）/（1σーMiddle）
    sigma_1_H1 = Bolinger_bufferUpper1_H1[0]-Bolinger_bufferMiddle1_H1[0];
    sigma_H1=(Close[0]-Bolinger_bufferMiddle1_H1[0])/(sigma_1_H1);
	

#ifdef GMMA
	calc_GMMA_DATA();	// GMMA関連の過去データの作成
#endif //GMMA
	
}




void span_kakuteiashi_urikaihanndan(){
	//確定足のみ処理する
	if(flag_chg_ashi ){
		
		//各状態を更新する
		//長期
		double Close_tyouki_pre_InpKijun = iOpen(NULL,tyouki_time_frame,InpKijun);// 26個まえのCloseをとる
		if( Close[0]>Close_tyouki_pre_InpKijun ){  // 長期の遅延線がその時の足を上抜いたとき陽転、
		    state_tyouki_chikou_innyou= 1;
		}else if(Close[0]<Close_tyouki_pre_InpKijun ){
		    state_tyouki_chikou_innyou= -1;
		}
		if( bufferSpanA_tyouki[1]>bufferSpanB_tyouki[1]){
	        state_tyouki_kumo_innyou=1;// init 0, 1陽転中　-1陰転中
	    }else if(bufferSpanA_tyouki[1]<bufferSpanB_tyouki[1]){
	        state_tyouki_kumo_innyou=-1;// init 0, 1陽転中　-1陰転中
	    }else {
	        state_tyouki_kumo_innyou=0;// init 0, 1陽転中　-1陰転中
	    }


//	    state_tyouki_kumo_innyou=0;// init 0, 1陽転中　-1陰転中

        //短期
		if( Close[0]>Close[InpKijun] ){  // 短期の遅延線がその時の足を上抜いたとき陽転、
		    state_tanki__chikou_innyou= 1;
		}else if(Close[0]<Close[InpKijun] ){
		    state_tanki__chikou_innyou= -1;
		}
		
		if( bufferSpanA[1]>bufferSpanB[1]){
	        state_tanki__kumo_innyou=1;// init 0, 1陽転中　-1陰転中
	    }else if(bufferSpanA[1]<bufferSpanB[1]){
	        state_tanki__kumo_innyou=-1;// init 0, 1陽転中　-1陰転中
	    }else {
	        state_tanki__kumo_innyou=0;// init 0, 1陽転中　-1陰転中
	    }
		
		//各種状態変更
		chk_kumo_ue_shita(Close);////確定足が雲の上か下か？ state_ashi_kumoue_kakutei
		
		
		//パターン判断
		if(state_tyouki_chikou_innyou==1){
		    if(state_tanki__chikou_innyou==1){ //短期　遅行陽転
		        if(state_tanki__kumo_innyou==1){// 短期　雲陽転
        			//パターン１
        			set_mode_span_pattern(1);
        	    }else { // 短期　雲陰転
        	        
        	    }
        	}else{ // 短期遅行　陰転
		        if(state_tanki__kumo_innyou==1){// 短期　雲陽転
        			//パターン２
        			set_mode_span_pattern(2);
        	    }else { // 短期　雲陰転
        			//パターン３
        			set_mode_span_pattern(3);
        	    }
        	
        	
        	}
		}else{//長期　遅行陰転
		    if(state_tanki__chikou_innyou==1){ //短期　遅行陽転
		        if(state_tanki__kumo_innyou==1){// 短期　雲陽転
        			//パターン
        			set_mode_span_pattern(6);
        	    }else { // 短期　雲陰転
        			set_mode_span_pattern(5);
        	        
        	    }
        	}else{ // 短期遅行　陰転
		        if(state_tanki__kumo_innyou==1){// 短期　雲陽転
        	    }else { // 短期　雲陰転
        			//パターン
        			set_mode_span_pattern(4);
        	    }
        	
        	
        	}
		}
		//else if(){// 
			//パターン2
		//}	

        if( mode_span_pattern == 1){		
//            ArrowABuffer[0]=Close[0];
        }else{        
//            ArrowABuffer[0]=0.0;  
        }
		
		// パターンごとの処理
		//パターン１
	    if( mode_span_pattern == 1){
			//短期：雲内になるまえ0→雲に入るまで待つ状態
			if(pattern_mode[mode_span_pattern]==0){
				// 雲足内に入ったか確認
				
				//短期：AとBの間にclose値の確定足が、初めて来たとき
				if( bufferSpanA[1]>=Close[1]&&
					bufferSpanB[1]<=Close[1]){
					// 雲内に足がある
					pattern_mode[mode_span_pattern]++;//次のモードへ
				}
				
			}
			
			//短期：雲に入った1→（下がるのを待つ。雲の下限まで）
			if(pattern_mode[mode_span_pattern]==1){
				// 雲の中で下限まできたか？
				//　今回は雲に確定足が入った後の反転一回目があれば良しとする。
				    state_wait_hanten = 1;//雲内で反転を待ち中   init0；待ち状態　　下から上１、上から下へ-1　　
					pattern_mode[mode_span_pattern]++;//次のモードへ
			}
			//→十分下がった2→反転足を見つける  押し目見つける
			if(pattern_mode[mode_span_pattern]==2){
				
				//押し目
				chk_kumonai_hannten(Open,Close,High,Low,state_wait_hanten);// output   flag_kumonai_hannten:反転した時のみ　雲内反転　上へ１　下へ‐1、それ以外０
				if(flag_kumonai_hannten){
					reason_buysell=2;// 理由番号：　　買い理由；1雲上,2雲内上へ反転　売り理由；マイナス　　初期値0  設定はEntryの条件成立したときに
					pattern_mode[mode_span_pattern]++;//次のモードへ
				
						//押し目　シグマで反発？　ヒゲと実体から髭のところにアルファ線があるか？
						//上から　次の順だったら成立　Open 　α線　Low
						double alpa;
						//-3σ反発Bolinger_bufferMiddle1[0]-sigma_1*3
							alpa  = Bolinger_bufferMiddle1[0]-sigma_1*3;
							if( Open[1]>alpa && Close[1]>alpa && Low[1]<alpa){
								reason_buysell=22;// 理由番号：　　買い理由；
							}
						//-2σ反発Bolinger_bufferMiddle1[0]-sigma_1*2
							alpa  = Bolinger_bufferMiddle1[0]-sigma_1*2;
							if( Open[1]>alpa && Close[1]>alpa && Low[1]<alpa){
								reason_buysell=22;// 理由番号：　　買い理由；
							}
						//-1σ反発Bolinger_bufferMiddle1[0]-sigma_1*1
							alpa  = Bolinger_bufferMiddle1[0]-sigma_1*1;
							if( Open[1]>alpa && Close[1]>alpa && Low[1]<alpa){
								reason_buysell=21;// 理由番号：　　買い理由；
							}
						//０σ反発Bolinger_bufferMiddle1[0]
							alpa  = Bolinger_bufferMiddle1[0]-sigma_1*0;
							if( Open[1]>alpa && Close[1]>alpa && Low[1]<alpa){
								reason_buysell=20;// 理由番号：　　買い理由；
							}
						//+1σ反発Bolinger_bufferMiddle1[0]+sigma_1*1
							alpa  = Bolinger_bufferMiddle1[0]+sigma_1*1;
							if( Open[1]>alpa && Close[1]>alpa && Low[1]<alpa){
								reason_buysell=24;// 理由番号：　　買い理由；
							}
						
						
						
				}
				
				//P2,P3から来ているのなら　雲上でエントリー
				if(mode_span_pattern_old == 2||mode_span_pattern_old == 3){
					if( state_ashi_kumoue_kakutei == 1 &&(state_ashi_kumoue_kakutei_old ==0 || state_ashi_kumoue_kakutei_old ==-1)){
						//chk_kumo_ue_shita(Close);////確定足が雲の上か下か？ state_ashi_kumoue_kakutei
						reason_buysell=1;// 理由番号：　　買い理由；1雲上,2雲内上へ反転　売り理由；マイナス　　初期値0  設定はEntryの条件成立したときに
						pattern_mode[mode_span_pattern]++;//次のモードへ
					}
				}
			}
			//反転足を見つけた2→買い実施処理へ
			if(pattern_mode[mode_span_pattern]==3){
				//買いフラグON
#ifdef USE_No1				
				flag_buy_No1 = true;
#endif //USE_No1
                flag_buy_No2 = true;
				pattern_mode[mode_span_pattern]++;//次のモードへ
//				pattern_mode[mode_span_pattern]=0;//リセット
			}
			if(pattern_mode[mode_span_pattern]==4){//　買いポジション開始
				if( Close[1] < bufferSpanA[1] &&
				    Close[1] > bufferSpanB[1]){
				    //雲の中
				    locate_info_kumo_youtenn = 1;// ini 0 ,  雲の中 1,雲の中から上へ抜けて確定した　2
				}else if( Close[1] > bufferSpanA[1] &&
				    Close[1] > bufferSpanB[1]){
				    //雲の上で確定
				    locate_info_kumo_youtenn = 2;// ini 0 ,  雲の中 1,雲の中から上へ抜けて確定した　2
				    pattern_mode[mode_span_pattern]++;//次のモードへ
				}
            }			
			if(pattern_mode[mode_span_pattern]==5){//　雲の上で買いポジションあり
                
            }			
		}
        

	}// end 確定足時
	
	// 前回パターンを記憶（Tick毎）
	mode_span_pattern_zennkai_chg = mode_span_pattern;
	
	

    //set_view_no(int n,datetime t,double price){
    datetime t2 = TimeCurrent();
    datetime t = Time[0];
    set_view_no(mode_span_pattern,t,Close[0]);
}

