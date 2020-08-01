unit CAPI_ISources;

interface

uses
    CAPI_Utils;

procedure ISources_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PInteger); CDECL;
procedure ISources_Get_AllNames_GR(); CDECL;
function ISources_Get_Count(): Integer; CDECL;
function ISources_Get_First(): Integer; CDECL;
function ISources_Get_Next(): Integer; CDECL;
function ISources_Get_Name(): PAnsiChar; CDECL;
procedure ISources_Set_Name(const Value: PAnsiChar); CDECL;
function ISources_Get_Amps(): Double; CDECL;
procedure ISources_Set_Amps(Value: Double); CDECL;
function ISources_Get_AngleDeg(): Double; CDECL;
function ISources_Get_Frequency(): Double; CDECL;
procedure ISources_Set_AngleDeg(Value: Double); CDECL;
procedure ISources_Set_Frequency(Value: Double); CDECL;

// API Extensions
function ISources_Get_idx(): Integer; CDECL;
procedure ISources_Set_idx(Value: Integer); CDECL;

implementation

uses
    CAPI_Constants,
    PointerList,
    Isource,
    DSSGlobals,
    CktElement,
    SysUtils;

//------------------------------------------------------------------------------
function _activeObj(out obj: TIsourceObj): Boolean; inline;
begin
    Result := False;
    obj := NIL;
    if InvalidCircuit then
        Exit;
    
    obj := IsourceClass.GetActiveObj();
    if obj = NIL then
    begin
        if DSS_CAPI_EXT_ERRORS then
        begin
            DoSimpleMsg('No active ISource object found! Activate one and retry.', 8989);
        end;
        Exit;
    end;
    
    Result := True;
end;
//------------------------------------------------------------------------------
procedure ISources_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PInteger); CDECL;
var
    Result: PPAnsiCharArray;
begin
    Result := DSS_RecreateArray_PPAnsiChar(ResultPtr, ResultCount, 1);
    Result[0] := DSS_CopyStringAsPChar('NONE');
    if InvalidCircuit then
        Exit;

    Generic_Get_AllNames(ResultPtr, ResultCount, IsourceClass.ElementList, True);
end;

procedure ISources_Get_AllNames_GR(); CDECL;
// Same as ISources_Get_AllNames but uses global result (GR) pointers
begin
    ISources_Get_AllNames(GR_DataPtr_PPAnsiChar, GR_CountPtr_PPAnsiChar)
end;

//------------------------------------------------------------------------------
function ISources_Get_Count(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;

    Result := IsourceClass.ElementList.ListSize;
end;
//------------------------------------------------------------------------------
function ISources_Get_First(): Integer; CDECL;
var
    pElem: TIsourceObj;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;

    pElem := IsourceClass.ElementList.First;
    if pElem = NIL then
        Exit;

    repeat
        if pElem.Enabled then
        begin
            ActiveCircuit.ActiveCktElement := pElem;
            Result := 1;
        end
        else
            pElem := IsourceClass.ElementList.Next;
    until (Result = 1) or (pElem = NIL);
end;
//------------------------------------------------------------------------------
function ISources_Get_Next(): Integer; CDECL;
var
    pElem: TIsourceObj;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;

    pElem := IsourceClass.ElementList.Next;
    if pElem = NIL then
        Exit;
        
    repeat
        if pElem.Enabled then
        begin
            ActiveCircuit.ActiveCktElement := pElem;
            Result := IsourceClass.ElementList.ActiveIndex;
        end
        else
            pElem := IsourceClass.ElementList.Next;
    until (Result > 0) or (pElem = NIL);
end;
//------------------------------------------------------------------------------
function ISources_Get_Name(): PAnsiChar; CDECL;
var
    elem: TIsourceObj;
begin
    Result := NIL;
    if not _activeObj(Elem) then
        Exit;
    Result := DSS_GetAsPAnsiChar(elem.Name);
end;
//------------------------------------------------------------------------------
procedure ISources_Set_Name(const Value: PAnsiChar); CDECL;
// Set element active by name

begin
    if InvalidCircuit then
        Exit;

    if IsourceClass.SetActive(Value) then
    begin
        ActiveCircuit.ActiveCktElement := IsourceClass.ElementList.Active;
    end
    else
    begin
        DoSimpleMsg('ISource "' + Value + '" Not Found in Active Circuit.', 77003);
    end;
end;
//------------------------------------------------------------------------------
function ISources_Get_Amps(): Double; CDECL;
var
    elem: TIsourceObj;
begin
    Result := 0.0;
    if not _activeObj(Elem) then
        Exit;
    Result := elem.Amps;
end;
//------------------------------------------------------------------------------
procedure ISources_Set_Amps(Value: Double); CDECL;
var
    elem: TIsourceObj;
begin
    if not _activeObj(Elem) then
        Exit;
    elem.Amps := Value;
end;
//------------------------------------------------------------------------------
function ISources_Get_AngleDeg(): Double; CDECL;
var
    elem: TIsourceObj;
begin
    Result := 0.0;
    if not _activeObj(Elem) then
        Exit;
    Result := elem.Angle;
end;
//------------------------------------------------------------------------------
function ISources_Get_Frequency(): Double; CDECL;
var
    elem: TIsourceObj;
begin
    Result := 0.0;
    if not _activeObj(Elem) then
        Exit;
    Result := elem.SrcFrequency;
end;
//------------------------------------------------------------------------------
procedure ISources_Set_AngleDeg(Value: Double); CDECL;
var
    elem: TIsourceObj;
begin
    if not _activeObj(Elem) then
        Exit;
    elem.Angle := Value;
end;
//------------------------------------------------------------------------------
procedure ISources_Set_Frequency(Value: Double); CDECL;
var
    elem: TIsourceObj;
begin
    if not _activeObj(Elem) then
        Exit;
    elem.SrcFrequency := Value;
end;
//------------------------------------------------------------------------------
function ISources_Get_idx(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := ISourceClass.ElementList.ActiveIndex;
end;
//------------------------------------------------------------------------------
procedure ISources_Set_idx(Value: Integer); CDECL;
var
    pISource: TISourceObj;
begin
    if InvalidCircuit then
        Exit;
    pISource := ISourceClass.ElementList.Get(Value);
    if pISource = NIL then
    begin
        DoSimpleMsg('Invalid ISource index: "' + IntToStr(Value) + '".', 656565);
        Exit;
    end;
    ActiveCircuit.ActiveCktElement := pISource;
end;
//------------------------------------------------------------------------------
end.
