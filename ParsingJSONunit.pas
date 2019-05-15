//*using winapi functions for zero memory :)

Unit ParsingJSONuni;
interface 
uses 
Types,WinApi.windows;
type
  TJsonOCPP = class
  private
    FJsonMessage: string;
    FDisconnect: boolean;
    FJsonData: array of byte;
    FPayLoadLen: int64;
    FOpcode: byte;
    procedure TextFrame(Response: array of byte);
    procedure DataFrame(Response: array of byte);
    function DecodeMessage(Response: array of byte; Len: integer): string;
    procedure DecodeData(Response: array of byte; Len: integer);
  public
    property JsonMessage: string read FJsonMessage;
    property Disconnect: boolean read FDisconnect;
   constructor Create(Data: array of byte; DataSize: integer);
  end;
 
 
 implemenatation 
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 constructor TJsonOCPP.Create(Data: array of byte; DataSize: integer);//creating  json object,  then parsing message
var
  Databuf: array of byte;
  i: integer;
begin
  FPayLoadLen := 0;
  FOpcode := 0;
  ZeroMemory(@FJsonData, sizeof(FJsonData));
  FDisconnect := false;
  //initialization values
  FOpcode := Data[0] and 127;
  SetLength(Databuf, DataSize - 1);
  for i := 1 to DataSize - 1 do
  begin
    Databuf[i - 1] := Data[i];
  end;
  case FOpcode of // OPCODE 0..D .
    1:
      TextFrame(Databuf);
    2:
      DataFrame(Databuf);
    8:
      FDisconnect := true;
  end;
  SetLength(Databuf, 0);
  
end;
//////////////////////////////////////////////////////////////////////////////////////////////
  
  procedure TJsonOCPP.TextFrame(Response: array of byte);
var
  lenStr: string;
  Len: int64;// most value it's 16?bit's , type integer  give me error ,that's why i use int64, and lenStr
begin
  FPayLoadLen := Response[0] and 127;//take a lengh of message 
  if FPayLoadLen <= 125 then// reading https://tools.ietf.org/html/rfc6455#section-5.2
  begin
    FJsonMessage := DecodeMessage(Response, FPayLoadLen);
  end
  else if FPayLoadLen = 126 then
  begin
    lenStr := (inttostr(Response[1]) + inttostr(Response[2]));
    Len := strtoint(lenStr);
    FJsonMessage := DecodeMessage(Response, Len);
  end
  else if FPayLoadLen = 127 then
  begin
    lenStr := (inttostr(Response[1]) + inttostr(Response[2]) + inttostr(Response[3]) + inttostr(Response[4]) + inttostr(Response[5]) + inttostr(Response[6]) + inttostr(Response[7]) + inttostr(Response[8]));
    Len := strtoint(lenStr);
    FJsonMessage := DecodeMessage(Response, Len);
  end;
