

void addstring(string& s,string ss){ //改行付き
	s=s+ss+"\r\n";
}
void addstring_nochgline(string& s,string ss){ //
	s=s+ss;
}


double chgPips2price(double d){return(d*Point()*10);}
double chgPrice2Pips(double d){return(d/(Point()*10));}


void test_writestring_file(string filename,string str,bool add)  //  表示文字列、　true　既存の文字のあとに追加、false　上書き（数が足りないと過去のものが残る）
{
//ファイルの最後にStrに追加　改行は\r\nでOK
	//--- ファイルを開く 
	ResetLastError();
//	int file_handle=FileOpen(InpDirectoryName+"/"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("C:\\Users\\makoto\\AppData\\Roaming\\MetaQuotes\\terminal\\D0E8209F77C8CF37AD8BF550E51FF075\\MQL5\\Experts\\Data\\test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("test.txt",FILE_READ|FILE_BIN|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_READ|FILE_ANSI);
//	int file_handle=FileOpen("Data\\test.txt",FILE_WRITE |FILE_BIN|FILE_ANSI);
	int file_handle=FileOpen("Data\\"+filename,FILE_READ|FILE_WRITE |FILE_ANSI|FILE_TXT);
	if(file_handle!=INVALID_HANDLE)
    	{
//debug	  	PrintFormat("%s file is available for reading",filename);
//debug	  	PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
	  	//--- 追加の変数
//	  	int	  str_size;
//	  	string str;
         string tmp;

if ( add== true){	  	
	  	//--- ファイルからデータを読む
	  	while(!FileIsEnding(file_handle))
		{
		        tmp=FileReadString(file_handle);

#ifdef aaa	  	
		      	//--- 時間を書くのに使用されるシンボルの数を見つける
		        str_size=FileReadInteger(file_handle,INT_VALUE);
		      	//--- 文字列を読む
		        str=FileReadString(file_handle,str_size);
		      	//--- 文字列を出力する
		      	PrintFormat(str);
#endif
		}
}		
//      str = (string)TimeCurrent();
//      str = str + "\t" + "test"+ "\r\ntest2";
//      FileSeek(file_handle,0, SEEK_END);
      FileWrite(file_handle,str);
      FileFlush(file_handle);
		//--- ファイルを閉じる
	  	FileClose(file_handle);
//debug	  	PrintFormat("Data is read, %s file is closed",filename);
    	}
	else
  	PrintFormat("Failed to open %s file, Error code = %d",filename,GetLastError());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M2: return("M2");
      case PERIOD_M3: return("M3");
      case PERIOD_M4: return("M4");
      case PERIOD_M5: return("M5");
      case PERIOD_M6: return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H2: return("H2");
      case PERIOD_H3: return("H3");
      case PERIOD_H4: return("H4");
      case PERIOD_H6: return("H6");
      case PERIOD_H8: return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
     }
   return(NULL);
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
