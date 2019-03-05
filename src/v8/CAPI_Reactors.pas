unit CAPI_Reactors;

{$inline on}

interface

uses
    CAPI_Utils;

procedure Reactors_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PInteger); CDECL;
procedure Reactors_Get_AllNames_GR(); CDECL;
function Reactors_Get_Name(): PAnsiChar; CDECL;
procedure Reactors_Set_Name(const Value: PAnsiChar); CDECL;
function Reactors_Get_First(): Integer; CDECL;
function Reactors_Get_Next(): Integer; CDECL;
function Reactors_Get_Count(): Integer; CDECL;
function Reactors_Get_kV(): Double; CDECL;
procedure Reactors_Set_kV(Value: Double); CDECL;
function Reactors_Get_kvar(): Double; CDECL;
procedure Reactors_Set_kvar(Value: Double); CDECL;
function Reactors_Get_Phases(): Integer; CDECL;
procedure Reactors_Set_Phases(Value: Integer); CDECL;
function Reactors_Get_SpecType(): Integer; CDECL;
function Reactors_Get_IsDelta(): Wordbool; CDECL;
procedure Reactors_Set_IsDelta(Value: Wordbool); CDECL;
function Reactors_Get_Parallel(): Wordbool; CDECL;
procedure Reactors_Set_Parallel(Value: Wordbool); CDECL;
function Reactors_Get_LmH(): Double; CDECL;
procedure Reactors_Set_LmH(Value: Double); CDECL;
function Reactors_Get_Bus1(): PAnsiChar; CDECL;
function Reactors_Get_Bus2(): PAnsiChar; CDECL;
procedure Reactors_Set_Bus1(const Value: PAnsiChar); CDECL;
procedure Reactors_Set_Bus2(const Value: PAnsiChar); CDECL;
function Reactors_Get_R(): Double; CDECL;
procedure Reactors_Set_R(Value: Double); CDECL;
function Reactors_Get_X(): Double; CDECL;
procedure Reactors_Set_X(Value: Double); CDECL;
function Reactors_Get_Rp(): Double; CDECL;
procedure Reactors_Set_Rp(Value: Double); CDECL;
function Reactors_Get_RCurve(): PAnsiChar; CDECL;
procedure Reactors_Set_RCurve(const Value: PAnsiChar); CDECL;
function Reactors_Get_LCurve(): PAnsiChar; CDECL;
procedure Reactors_Set_LCurve(const Value: PAnsiChar); CDECL;
procedure Reactors_Get_Rmatrix(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Rmatrix_GR(); CDECL;
procedure Reactors_Set_Rmatrix(ValuePtr: PDouble; ValueCount: Integer); CDECL;
procedure Reactors_Get_Xmatrix(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Xmatrix_GR(); CDECL;
procedure Reactors_Set_Xmatrix(ValuePtr: PDouble; ValueCount: Integer); CDECL;
procedure Reactors_Get_Z(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Z_GR(); CDECL;
procedure Reactors_Set_Z(ValuePtr: PDouble; ValueCount: Integer); CDECL;
procedure Reactors_Get_Z1(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Z1_GR(); CDECL;
procedure Reactors_Set_Z1(ValuePtr: PDouble; ValueCount: Integer); CDECL;
procedure Reactors_Get_Z2(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Z2_GR(); CDECL;
procedure Reactors_Set_Z2(ValuePtr: PDouble; ValueCount: Integer); CDECL;
procedure Reactors_Get_Z0(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
procedure Reactors_Get_Z0_GR(); CDECL;
procedure Reactors_Set_Z0(ValuePtr: PDouble; ValueCount: Integer); CDECL;


implementation

uses
    CAPI_Constants,
    DSSGlobals,
    Executive,
    Reactor,
    SysUtils,
    PointerList,
    Utilities,
    ucomplex;

type
    ReactorProps = (bus1 = 1, bus2, phases, kvar, kv, conn, Rmatrix, Xmatrix, Parallel, R, X, Rp, Z1, Z2, Z0, Z, RCurve, LCurve, LmH);

//------------------------------------------------------------------------------
function ActiveReactor(out e: TReactorObj): TReactorObj; inline;
begin
    e := NIL;
    if ActiveCircuit[ActiveActor] <> NIL then
        e := ActiveCircuit[ActiveActor].Reactors.Active;
    Result := e;
end;
//------------------------------------------------------------------------------
procedure ReactorPropSideEffects(prop: ReactorProps; reactor: TReactorObj);
begin
    with reactor do
    begin
    // Some specials ...
        case prop of
            ReactorProps.bus1:
            begin
                PropertyValue[2] := GetBus(2);   // this gets modified
                PrpSequence^[2] := 0;       // Reset this for save function
            end;
            ReactorProps.bus2:
                if CompareText(StripExtension(GetBus(1)), StripExtension(GetBus(2))) <> 0 then
                begin
                    IsShunt := FALSE;
                    Bus2Defined := TRUE;
                end;
            ReactorProps.phases: //IF Fnphases <> Parser.IntValue THEN 
            begin
            // Nphases := Parser.IntValue ;
                NConds := nphases;  // Force Reallocation of terminal info
                Yorder := Fnterms * Fnconds;
            end;
            ReactorProps.kvar:
                SpecType := 1;   // X specified by kvar, kV
            ReactorProps.Rmatrix, ReactorProps.Xmatrix:
                SpecType := 3;
            ReactorProps.X:
                SpecType := 2;   // X specified directly rather than computed from kvar
            ReactorProps.Rp:
                RpSpecified := TRUE;
            ReactorProps.Z1:
            begin
                SpecType := 4;    // have to set Z1 to get this mode
                if not Z2Specified then
                    Z2 := Z1;
                if not Z0Specified then
                    Z0 := Z1;
            end;
            ReactorProps.Z2:
                Z2Specified := TRUE;
            ReactorProps.Z0:
                Z0Specified := TRUE;
            ReactorProps.Z:
            begin
                R := Z.re;
                X := Z.im;
                SpecType := 2;
            end;
            ReactorProps.RCurve:
                RCurveObj := XYCurveClass[ActiveActor].Find(RCurve);
            ReactorProps.LCurve:
                LCurveObj := XYCurveClass[ActiveActor].Find(LCurve);
            ReactorProps.LmH:
            begin
                SpecType := 2;
                X := L * TwoPi * BaseFrequency;
            end
        else
        end;

    //YPrim invalidation on anything that changes impedance values
        case prop of
            ReactorProps.phases..ReactorProps.Z:
                YprimInvalid[ActiveActor] := TRUE;
            ReactorProps.RCurve:
                if RCurveObj = NIL then
                    DoSimpleMsg('Resistance-frequency curve XYCurve.' + RCurve + ' not Found.', 2301);
            ReactorProps.LCurve:
                if LCurveObj = NIL then
                    DoSimpleMsg('Inductance-frequency curve XYCurve.' + LCurve + ' not Found.', 2301);
            ReactorProps.LmH:
                YprimInvalid[ActiveActor] := TRUE;
        else
        end;
    end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PInteger); CDECL;
var
    Result: PPAnsiCharArray;
    elem: TReactorObj;
    lst: TPointerList;
    k: Integer;
begin
    Result := DSS_RecreateArray_PPAnsiChar(ResultPtr, ResultCount, (0) + 1);
    Result[0] := DSS_CopyStringAsPChar('NONE');
    if ActiveCircuit[ActiveActor] <> NIL then
        with ActiveCircuit[ActiveActor] do
            if Reactors.ListSize > 0 then
            begin
                lst := Reactors;
                DSS_RecreateArray_PPAnsiChar(Result, ResultPtr, ResultCount, (lst.ListSize - 1) + 1);
                k := 0;
                elem := lst.First;
                while elem <> NIL do
                begin
                    Result[k] := DSS_CopyStringAsPChar(elem.Name);
                    Inc(k);
                    elem := lst.Next;
                end;
            end;
end;

procedure Reactors_Get_AllNames_GR(); CDECL;
// Same as Reactors_Get_AllNames but uses global result (GR) pointers
begin
    Reactors_Get_AllNames(GR_DataPtr_PPAnsiChar, GR_CountPtr_PPAnsiChar)
end;

//------------------------------------------------------------------------------
function Reactors_Get_First(): Integer; CDECL;
var
    elem: TReactorObj;
    lst: TPointerList;
begin
    Result := 0;
    if ActiveCircuit[ActiveActor] <> NIL then
    begin
        lst := ActiveCircuit[ActiveActor].Reactors;
        elem := lst.First;
        if elem <> NIL then
        begin
            repeat
                if elem.Enabled then
                begin
                    ActiveCircuit[ActiveActor].ActiveCktElement := elem;
                    Result := 1;
                end
                else
                    elem := lst.Next;
            until (Result = 1) or (elem = NIL);
        end;
    end;
end;
//------------------------------------------------------------------------------
function Reactors_Get_Name_AnsiString(): Ansistring; inline;
var
    elem: TReactorObj;
begin
    Result := '';
    if ActiveReactor(elem) <> NIL then
        Result := elem.Name;
end;

function Reactors_Get_Name(): PAnsiChar; CDECL;
begin
    Result := DSS_GetAsPAnsiChar(Reactors_Get_Name_AnsiString());
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Name(const Value: PAnsiChar); CDECL;
var
    ActiveSave: Integer;
    S: String;
    Found: Boolean;
    elem: TReactorObj;
    lst: TPointerList;
begin
    if ActiveCircuit[ActiveActor] <> NIL then
    begin
        lst := ActiveCircuit[ActiveActor].Reactors;
        S := Value;  // Convert to Pascal String
        Found := FALSE;
        ActiveSave := lst.ActiveIndex;
        elem := lst.First;
        while elem <> NIL do
        begin
            if (CompareText(elem.Name, S) = 0) then
            begin
                ActiveCircuit[ActiveActor].ActiveCktElement := elem;
                Found := TRUE;
                Break;
            end;
            elem := lst.Next;
        end;
        if not Found then
        begin
            DoSimpleMsg('Reactor "' + S + '" Not Found in Active Circuit.', 5003);
            elem := lst.Get(ActiveSave);    // Restore active Reactor
            ActiveCircuit[ActiveActor].ActiveCktElement := elem;
        end;
    end;
end;
//------------------------------------------------------------------------------
function Reactors_Get_Next(): Integer; CDECL;
var
    elem: TReactorObj;
    lst: TPointerList;
begin
    Result := 0;
    if ActiveCircuit[ActiveActor] <> NIL then
    begin
        lst := ActiveCircuit[ActiveActor].Reactors;
        elem := lst.Next;
        if elem <> NIL then
        begin
            repeat
                if elem.Enabled then
                begin
                    ActiveCircuit[ActiveActor].ActiveCktElement := elem;
                    Result := lst.ActiveIndex;
                end
                else
                    elem := lst.Next;
            until (Result > 0) or (elem = NIL);
        end
    end;
end;
//------------------------------------------------------------------------------
function Reactors_Get_Count(): Integer; CDECL;
begin
    Result := 0;
    if Assigned(ActiveCircuit[ActiveActor]) then
        Result := ActiveCircuit[ActiveActor].Reactors.ListSize;
end;
//------------------------------------------------------------------------------
function Reactors_Get_Bus1_AnsiString(): Ansistring; inline;
var
    pReactor: TReactorObj;
begin
    Result := '';
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.GetBus(1);
    end
end;

function Reactors_Get_Bus1(): PAnsiChar; CDECL;
begin
    Result := DSS_GetAsPAnsiChar(Reactors_Get_Bus1_AnsiString());
end;
//------------------------------------------------------------------------------
function Reactors_Get_Bus2_AnsiString(): Ansistring; inline;
var
    pReactor: TReactorObj;
begin
    Result := '';
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.GetBus(2);
    end
end;

function Reactors_Get_Bus2(): PAnsiChar; CDECL;
begin
    Result := DSS_GetAsPAnsiChar(Reactors_Get_Bus2_AnsiString());
end;
//------------------------------------------------------------------------------
function Reactors_Get_LCurve_AnsiString(): Ansistring; inline;
var
    pReactor: TReactorObj;
begin
    Result := '';
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.LCurve;
    end
end;

function Reactors_Get_LCurve(): PAnsiChar; CDECL;
begin
    Result := DSS_GetAsPAnsiChar(Reactors_Get_LCurve_AnsiString());
end;
//------------------------------------------------------------------------------
function Reactors_Get_RCurve_AnsiString(): Ansistring; inline;
var
    pReactor: TReactorObj;
begin
    Result := '';
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.RCurve;
    end
end;

function Reactors_Get_RCurve(): PAnsiChar; CDECL;
begin
    Result := DSS_GetAsPAnsiChar(Reactors_Get_RCurve_AnsiString());
end;
//------------------------------------------------------------------------------
function Reactors_Get_Parallel(): Wordbool; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := FALSE;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.IsParallel;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_IsDelta(): Wordbool; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := FALSE;
    if ActiveReactor(pReactor) <> NIL then
    begin
        if pReactor.Connection > 0 then
            Result := TRUE;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_kV(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
        with pReactor do
        begin
            Result := kvrating;
        end
end;
//------------------------------------------------------------------------------
function Reactors_Get_kvar(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.kvarRating;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_LmH(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.L * 1000.0;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_Phases(): Integer; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.Nphases;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_SpecType(): Integer; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.SpecType;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_R(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.R;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_X(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.X;
    end
end;
//------------------------------------------------------------------------------
function Reactors_Get_Rp(): Double; CDECL;
var
    pReactor: TReactorObj;
begin
    Result := 0.0;
    if ActiveReactor(pReactor) <> NIL then
    begin
        Result := pReactor.Rp;
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_IsDelta(Value: Wordbool); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.Connection := Integer(Value);
        ReactorPropSideEffects(ReactorProps.conn, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Parallel(Value: Wordbool); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.IsParallel := Value;
        ReactorPropSideEffects(ReactorProps.Parallel, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Bus1(const Value: PAnsiChar); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.SetBus(1, Value);
        ReactorPropSideEffects(ReactorProps.bus1, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Bus2(const Value: PAnsiChar); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.SetBus(2, Value);
        ReactorPropSideEffects(ReactorProps.bus2, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_LCurve(const Value: PAnsiChar); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.LCurve := Value;
        ReactorPropSideEffects(ReactorProps.LCurve, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_RCurve(const Value: PAnsiChar); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.RCurve := Value;
        ReactorPropSideEffects(ReactorProps.RCurve, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_kV(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.kvrating := Value;
        ReactorPropSideEffects(ReactorProps.kv, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_kvar(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.kvarRating := Value;
        ReactorPropSideEffects(ReactorProps.kvar, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_LmH(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.L := Value / 1000.0;
        ReactorPropSideEffects(ReactorProps.LmH, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Phases(Value: Integer); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        if (Value <> pReactor.NPhases) then
        begin
            pReactor.NPhases := Value;
            ReactorPropSideEffects(ReactorProps.phases, pReactor);
        end;
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_R(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.R := Value;
        ReactorPropSideEffects(ReactorProps.R, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_X(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.X := Value;
        ReactorPropSideEffects(ReactorProps.X, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Rp(Value: Double); CDECL;
var
    pReactor: TReactorObj;
begin
    if ActiveReactor(pReactor) <> NIL then
    begin
        pReactor.Rp := Value;
        ReactorPropSideEffects(ReactorProps.Rp, pReactor);
    end
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Rmatrix(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    k: Integer;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) then
        if (Sqr(pReactor.Nphases) = ValueCount) then
            with pReactor do
            begin
                for k := 0 to ValueCount do
                begin
                    Rmatrix[k + 1] := ValuePtr[k];
                end;
                ReactorPropSideEffects(ReactorProps.Rmatrix, pReactor);
            end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Xmatrix(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    k: Integer;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) then
        if (Sqr(pReactor.Nphases) = ValueCount) then
            with pReactor do
            begin
                for k := 0 to ValueCount do
                begin
                    Xmatrix[k + 1] := ValuePtr[k];
                end;
                ReactorPropSideEffects(ReactorProps.Xmatrix, pReactor);
            end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Get_Rmatrix(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    k: Integer;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if (ActiveReactor(pReactor) <> NIL) then
        if (pReactor.Rmatrix <> NIL) then
            with pReactor do
            begin
                Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (Sqr(Nphases) - 1) + 1);
                for k := 0 to ResultCount[0] do
                begin
                    ResultPtr[k] := Rmatrix[k + 1];
                end;
            end;
end;

procedure Reactors_Get_Rmatrix_GR(); CDECL;
// Same as Reactors_Get_Rmatrix but uses global result (GR) pointers
begin
    Reactors_Get_Rmatrix(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Get_Xmatrix(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    k: Integer;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if (ActiveReactor(pReactor) <> NIL) then
        if (pReactor.Xmatrix <> NIL) then
            with pReactor do
            begin
                Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (Sqr(Nphases) - 1) + 1);
                for k := 0 to ResultCount[0] do
                begin
                    ResultPtr[k] := Xmatrix[k + 1];
                end;
            end;
end;

procedure Reactors_Get_Xmatrix_GR(); CDECL;
// Same as Reactors_Get_Xmatrix but uses global result (GR) pointers
begin
    Reactors_Get_Xmatrix(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Get_Z1(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if ActiveReactor(pReactor) <> NIL then
        with pReactor do
        begin
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, 2);
            Result[0] := Z1.Re;
            Result[1] := Z1.Im;
        end;
end;

procedure Reactors_Get_Z1_GR(); CDECL;
// Same as Reactors_Get_Z1 but uses global result (GR) pointers
begin
    Reactors_Get_Z1(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Get_Z2(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if ActiveReactor(pReactor) <> NIL then
        with pReactor do
        begin
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, 2);
            Result[0] := Z2.Re;
            Result[1] := Z2.Im;
        end;
end;

procedure Reactors_Get_Z2_GR(); CDECL;
// Same as Reactors_Get_Z2 but uses global result (GR) pointers
begin
    Reactors_Get_Z2(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Get_Z0(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if ActiveReactor(pReactor) <> NIL then
        with pReactor do
        begin
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, 2);
            Result[0] := Z0.Re;
            Result[1] := Z0.Im;
        end;
end;

procedure Reactors_Get_Z0_GR(); CDECL;
// Same as Reactors_Get_Z0 but uses global result (GR) pointers
begin
    Reactors_Get_Z0(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Get_Z(var ResultPtr: PDouble; ResultCount: PInteger); CDECL;
var
    Result: PDoubleArray;
    pReactor: TReactorObj;
begin
    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, (0) + 1);
    if ActiveReactor(pReactor) <> NIL then
        with pReactor do
        begin
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, 2);
            Result[0] := R;
            Result[1] := X;
        end;
end;

procedure Reactors_Get_Z_GR(); CDECL;
// Same as Reactors_Get_Z but uses global result (GR) pointers
begin
    Reactors_Get_Z(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;

//------------------------------------------------------------------------------
procedure Reactors_Set_Z2(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) and (ValueCount = 2) then
        with pReactor do
        begin
            Z2 := Cmplx(Value[0], Value[1]);
            ReactorPropSideEffects(ReactorProps.Z2, pReactor);
        end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Z1(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) and (ValueCount = 2) then
        with pReactor do
        begin
            Z1 := Cmplx(Value[0], Value[1]);
            ReactorPropSideEffects(ReactorProps.Z1, pReactor);
        end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Z0(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) and (ValueCount = 2) then
        with pReactor do
        begin
            Z0 := Cmplx(Value[0], Value[1]);
            ReactorPropSideEffects(ReactorProps.Z0, pReactor);
        end;
end;
//------------------------------------------------------------------------------
procedure Reactors_Set_Z(ValuePtr: PDouble; ValueCount: Integer); CDECL;
var
    Value: PDoubleArray;
    pReactor: TReactorObj;
begin
    Value := PDoubleArray(ValuePtr);
    if (ActiveReactor(pReactor) <> NIL) and (ValueCount = 2) then
        with pReactor do
        begin
            Z := Cmplx(Value[0], Value[1]);
            ReactorPropSideEffects(ReactorProps.Z, pReactor);
        end;
end;
//------------------------------------------------------------------------------

end.