#define Lib_MyFunc_fractal 1

#define NUMofFractalsData   100// fractalデータ数
#define PERIODS_NUMBER 5
#define SUPPORT "support"
#define RESISTANCE "resistance"
#define EMPTY_DATA 1.7976931348623157e+308

#property indicator_color1 Green
#property indicator_color2 Gold
#property indicator_color3 DarkOrange
#property indicator_color4 Red
#property indicator_color5 FireBrick

#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID

int timeframes[PERIODS_NUMBER] = {PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
//int styles[PERIODS_NUMBER] = {indicator_style1, indicator_style2, indicator_style3, indicator_style4, indicator_style5};
//color colors[PERIODS_NUMBER] = {indicator_color1, indicator_color2, indicator_color3, indicator_color4, indicator_color5};
int styles[PERIODS_NUMBER] = {STYLE_DOT, STYLE_DOT, STYLE_SOLID, STYLE_SOLID, STYLE_SOLID};
color colors[PERIODS_NUMBER] = {Green, Gold, DarkOrange, Red, FireBrick};
int aa[2][5];

struct structfractaldata {
	double Price;
	datetime time;
	bool flag_toporlow;// true top  ,  false low  
};

structfractaldata Fractaldata[PERIODS_NUMBER][NUMofFractalsData];
int handle_fractal[PERIODS_NUMBER];
#define NUM_FRACTAL_GETDATA	50
double bufferFractal_top[NUM_FRACTAL_GETDATA];
double bufferFractal_low[NUM_FRACTAL_GETDATA];

double FractalTop[PERIODS_NUMBER][NUMofFractalsData];
double FractalLow[PERIODS_NUMBER][NUMofFractalsData];

void init_Lib_MyFunc_fractal(){
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++) {
		for(int i = 0; i< NUMofFractalsData;i++){
			Fractaldata[timeframe_index][i].Price=0;
			FractalTop[timeframe_index][i]=0.0;
			FractalLow[timeframe_index][i]=0.0;
		}
	}
	for(int i = 0;i<PERIODS_NUMBER;i++){
	    handle_fractal[i]=iFractals(_Symbol,(ENUM_TIMEFRAMES)timeframes[i]); 
	}
}


//EA用　要　確定足の時のみ動作の縛りが必要
void ontick__Lib_MyFunc_fractal(){//　確定足の時のみ呼び出し
	// データのコピー  前と異なっていたら　Add
	datetime t=TimeCurrent();
	bool ret;
	int not_serise_idx;
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++) {
//double FractalTop[timeframe_index][NUMofFractalsData];
//double FractalLow[timeframe_index][NUMofFractalsData];
        
		// データ取得
		ret = FillArraysFromBuffers(handle_fractal[timeframe_index],bufferFractal_top,bufferFractal_low,NUM_FRACTAL_GETDATA);
		if(ret){
			// top 探す
			for(int i = 0; i< NUM_FRACTAL_GETDATA; i++){
			    not_serise_idx = (NUM_FRACTAL_GETDATA-1)-i;
				if(bufferFractal_top[not_serise_idx]!= 0.0&&bufferFractal_top[not_serise_idx]!=EMPTY_DATA){
					Add_fractal_data(timeframe_index,bufferFractal_top[not_serise_idx],t,true);
					break;
				}
			}
			// low 探す
			for(int i = 0; i< NUM_FRACTAL_GETDATA; i++){
			    not_serise_idx = (NUM_FRACTAL_GETDATA-1)-i;
				if(bufferFractal_low[not_serise_idx]!= 0.0&& bufferFractal_low[not_serise_idx]!=EMPTY_DATA){
					Add_fractal_data(timeframe_index,bufferFractal_low[not_serise_idx],t,false);
					break;
				}
			}
		}else{  printf("error not get fractal data: time->"+ getTimeframeName(timeframe_index));
		        return ;
		    }
	}
}

//+------------------------------------------------------------------+ 
//| iFractals 指標から指標バッファを記入する                                  | 
//+------------------------------------------------------------------+ 
bool FillArraysFromBuffers(int ind_handle,// iFractals 指標ハンドル 
                            double &up_arrows[],       // 上矢印の指標バッファ 
                            double &down_arrows[],     // 上矢印の指標バッファ 
                            //int ind_handle,             // iFractals 指標ハンドル 
                          int amount                 // 複製された値の数 
                          ) 
 { 
//--- エラーコードをリセットする 
ResetLastError();
//--- インデックス0 を持つ指標バッファの値で FractalUpBuffer 配列の一部を記入する 
  if(CopyBuffer(ind_handle,0,0,amount,up_arrows)<0)
    { 
    //--- 複製が失敗したら、エラーコードを出す
    PrintFormat("Failed to copy data from the iFractals indicator to the FractalUpBuffer array, error code %d",
                GetLastError()); 
    //--- ゼロ結果で終了。 指標は計算されていないと見なされる
    return(false);
    }
//--- インデックス 1 を持つ指標バッファの値で FractalDownBuffer 配列の一部を記入する1
  if(CopyBuffer(ind_handle,1,0,amount,down_arrows)<0)
    {
    //--- 複製が失敗したら、エラーコードを出す
    PrintFormat("Failed to copy data from the iFractals indicator to the FractalDownBuffer array, error code %d",
                GetLastError());
    //--- ゼロ結果で終了。 指標は計算されていないと見なされる
    return(false);
    }
//--- 全てが成功
  return(true);
}

bool Add_fractal_data(int timeframesidx,double price,datetime t,bool flag){
	//ひとつずらす
	for(int i = 0; i< NUMofFractalsData-1;i++){
		Fractaldata[timeframesidx][i+1].Price=Fractaldata[timeframesidx][i].Price;
		Fractaldata[timeframesidx][i+1].time=Fractaldata[timeframesidx][i].time;
		Fractaldata[timeframesidx][i+1].flag_toporlow=Fractaldata[timeframesidx][i].flag_toporlow;

	}
	//最新値を追加する。
	Fractaldata[timeframesidx][0].Price=price;
	Fractaldata[timeframesidx][0].time=t;
	Fractaldata[timeframesidx][0].flag_toporlow=flag;


	if(flag == true){// Top
		for(int i = 0; i< NUMofFractalsData-1;i++){
			FractalTop[timeframesidx][i+1]=FractalTop[timeframesidx][i];
		}
		FractalTop[timeframesidx][0]=price;
		int sss = EMPTY_VALUE;
		sss = sss;
		
		
	}else {// Low
		for(int i = 0; i< NUMofFractalsData-1;i++){
			FractalLow[timeframesidx][i+1]=FractalLow[timeframesidx][i];
		}
		FractalLow[timeframesidx][0]=price;
	}

	return true;
}
bool Get_fractal_data_new( int timeframesidx,structfractaldata &retdata,bool flagtoporlow){
	return(Get_fractal_data(timeframesidx,retdata, flagtoporlow,0));
}

bool Get_fractal_data( int timeframesidx,structfractaldata &retdata,bool flag_toporlow,int offset){
	// offset 何個目を探すか？　　０で最新　、　１でその前
	int count = offset;
	for(int i=0;i<NUMofFractalsData;i++){
	    if( Fractaldata[timeframesidx][i].Price != 0.0 &&
	      Fractaldata[timeframesidx][i].Price !=EMPTY_DATA){
    		if(flag_toporlow == Fractaldata[timeframesidx][i].flag_toporlow){
    			count++;
    			if(count -1 == offset){
    				retdata.Price=Fractaldata[timeframesidx][i].Price;
    				retdata.time=Fractaldata[timeframesidx][i].time;
    				retdata.flag_toporlow=Fractaldata[timeframesidx][i].flag_toporlow;
    				return(true);
    			}
    		}
    	}
	}
	return(false);
}

double reg_sup_data[2][2][PERIODS_NUMBER];// 0;now  1;  old      Top 0  low 1   
// ind 用
void view_reg_sup(){
	structfractaldata retdata0;
	structfractaldata retdata1;
	bool ret0,ret1;
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++) {
		// データ取得
		ret0 = Get_fractal_data( timeframe_index,retdata0,true,0);// Top reg
		ret1 =Get_fractal_data( timeframe_index,retdata1,false,0);// Low sup
		reg_sup_data[0][0][timeframe_index] = retdata0.Price;
		reg_sup_data[0][1][timeframe_index] = retdata1.Price;

        //表示時間より上のレジサポを表示
		if(Period() <= timeframes[timeframe_index]) {
			//　データが異なったら描画する。
			double aaa = (double)0x7FEFFFFFFFFFFFFF;
			int aaa1 = 0x7FEFFFFFFFFFFFFF;
			long aaa2 =0x7FEFFFFFFFFFFFFF;
			double aaa3 = 1.7976931348623157e+308;//1.7976931348623157e+308 7FEFFFFFFFFFFFFFMAX_DBL;
			if(reg_sup_data[0][0][timeframe_index] != reg_sup_data[1][0][timeframe_index]
			     && reg_sup_data[0][0][timeframe_index]!= EMPTY_DATA){
				drawResistance(timeframe_index, reg_sup_data[0][0][timeframe_index]);
			}
			if(reg_sup_data[0][1][timeframe_index] != reg_sup_data[1][1][timeframe_index]
			        && reg_sup_data[0][1][timeframe_index]!= EMPTY_DATA  ){
				drawSupport(timeframe_index,reg_sup_data[0][1][timeframe_index]);
			}
		}
	}

    // 前回値を記憶
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++) {
		reg_sup_data[1][0][timeframe_index] = reg_sup_data[0][0][timeframe_index];
		reg_sup_data[1][1][timeframe_index] = reg_sup_data[0][1][timeframe_index];
	}
	
}
void drawResistance(int timeframe_index,double price){

	drawTrendLine(getTrendLineName(RESISTANCE, timeframes[timeframe_index]), price, colors[timeframe_index], styles[timeframe_index]);
}
void drawSupport(int timeframe_index,double price){
	drawTrendLine(getTrendLineName(SUPPORT, timeframes[timeframe_index]), price, colors[timeframe_index], styles[timeframe_index]);
}
string getTrendLineName(string object_type, int timeframe) {
	return(object_type + getTimeframeName(timeframe));
}
string getTimeframeName(int timeframe) {
	static int timeframe_periods[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
	static string timeframe_names[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
	
	for(int i = 0; i < ArraySize(timeframe_periods); i++)
		if(timeframe == timeframe_periods[i]) return (timeframe_names[i]);

	return("Unknown");
}

void drawTrendLine(string object_name, double price, color clr, int style) {

   int chart_ID =0;
//   if(ObjectFind(0,object_name)>=0) ObjectDelete(0,object_name);
   //	ObjectDelete(object_name);

	//ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
	ObjectCreate(0,object_name, OBJ_HLINE, 0, 0, price);


	//--- 線の色を設定する 
	ObjectSetInteger(chart_ID,object_name,OBJPROP_COLOR,clr); 
	//--- 線の表示スタイルを設定する 
	ObjectSetInteger(chart_ID,object_name,OBJPROP_STYLE,style); 
	//--- 線の幅を設定する 
	//  ObjectSetInteger(chart_ID,object_name,OBJPROP_WIDTH,width); 
}

















