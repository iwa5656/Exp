#define Lib_MyFunc_MA 1


//data
double buffer_f[],buffer_m[],buffer_s[];
bool flag_buy_ma;
bool flag_sell_ma;
int handle[4];
#define MaxBars 8

input int ma_f_period=3;//MA短期
input int ma_m_period=8;//MA中期
input int ma_s_period=100;//MA長期
input ENUM_APPLIED_PRICE   MAapplied_price=PRICE_CLOSE; // 価格の種類 
input ENUM_MA_METHOD       MA_method=MODE_SMA;       // 平滑化の種類 


void init_Lib_MyFunc_MA(){

	//data ini
	flag_buy_ma=false;
	flag_sell_ma=false;

	//handle
	handle[0]=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                           ma_f_period,0,MA_method,clrRed,MAapplied_price);
	handle[1]=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                           ma_m_period,0,MA_method,clrBlue,MAapplied_price);
	handle[2]=iCustom(Symbol(),Period(),"10Trend\\Custom Moving Average Input Color",
	                           ma_s_period,0,MA_method,clrYellow,MAapplied_price);


}

void ontick_Lib_MyFunc_MA(){
	//データコピー

	
	//フラグ設定
   if(CopyBuffer(handle[0] ,0,0,MaxBars,buffer_f ) < MaxBars) return;
   if(CopyBuffer(handle[1] ,0,0,MaxBars,buffer_m ) < MaxBars) return;
   if(CopyBuffer(handle[2] ,0,0,MaxBars,buffer_s ) < MaxBars) return;


}
#ifndef USE_series2PhysicsIdx
#define USE_series2PhysicsIdx 1
int series2PhysicsIdx(int i){
    return(MaxBars-1)-i;
}
#endif
bool buycheck_MA(){
	bool ret;
	int idx0 = series2PhysicsIdx(0);
	// MA順番になっているf>m>s　＆＆　バー＞ｆ
	ret = 
		(buffer_s[series2PhysicsIdx(4)]+buffer_s[series2PhysicsIdx(3)])<(buffer_s[series2PhysicsIdx(2)]+buffer_s[series2PhysicsIdx(1)])&& //傾き

		(buffer_f[idx0]>buffer_m[idx0] )&&
		(buffer_m[idx0]>buffer_s[idx0] )&&
		Close[0]>buffer_f[0]
		;
	return ret;
}
bool sellcheck_MA(){
	bool ret;
	int idx0 = series2PhysicsIdx(0);

	// MA順番になっているf<m<s　＆＆　バー<ｆ
	ret = 
		(buffer_s[series2PhysicsIdx(4)]+buffer_s[series2PhysicsIdx(3)])>(buffer_s[series2PhysicsIdx(2)]+buffer_s[series2PhysicsIdx(1)])&& //傾き
		(buffer_f[idx0]<buffer_m[idx0] )&&
		(buffer_m[idx0]<buffer_s[idx0] )&&
		Close[0]<buffer_f[0]
		;
	return ret;
}













