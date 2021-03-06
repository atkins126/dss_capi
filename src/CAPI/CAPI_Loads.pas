
unit CAPI_Loads;

interface

uses
    CAPI_Utils;

procedure Loads_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PAPISize); CDECL;
function Loads_Get_First(): Integer; CDECL;
function Loads_Get_idx(): Integer; CDECL;
function Loads_Get_Name(): PAnsiChar; CDECL;
function Loads_Get_Next(): Integer; CDECL;
procedure Loads_Set_idx(Value: Integer); CDECL;
procedure Loads_Set_Name(const Value: PAnsiChar); CDECL;
function Loads_Get_kV(): Double; CDECL;
function Loads_Get_kvar(): Double; CDECL;
function Loads_Get_kW(): Double; CDECL;
function Loads_Get_PF(): Double; CDECL;
procedure Loads_Set_kV(Value: Double); CDECL;
procedure Loads_Set_kvar(Value: Double); CDECL;
procedure Loads_Set_kW(Value: Double); CDECL;
procedure Loads_Set_PF(Value: Double); CDECL;
function Loads_Get_Count(): Integer; CDECL;
function Loads_Get_AllocationFactor(): Double; CDECL;
function Loads_Get_Cfactor(): Double; CDECL;
function Loads_Get_Class_(): Integer; CDECL;
function Loads_Get_CVRcurve(): PAnsiChar; CDECL;
function Loads_Get_CVRvars(): Double; CDECL;
function Loads_Get_CVRwatts(): Double; CDECL;
function Loads_Get_daily(): PAnsiChar; CDECL;
function Loads_Get_duty(): PAnsiChar; CDECL;
function Loads_Get_Growth(): PAnsiChar; CDECL;
function Loads_Get_IsDelta(): Boolean; CDECL;
function Loads_Get_kva(): Double; CDECL;
function Loads_Get_kwh(): Double; CDECL;
function Loads_Get_kwhdays(): Double; CDECL;
function Loads_Get_Model(): Integer; CDECL;
function Loads_Get_NumCust(): Integer; CDECL;
function Loads_Get_PctMean(): Double; CDECL;
function Loads_Get_PctStdDev(): Double; CDECL;
function Loads_Get_Rneut(): Double; CDECL;
function Loads_Get_Spectrum(): PAnsiChar; CDECL;
function Loads_Get_Status(): Integer; CDECL;
function Loads_Get_Vmaxpu(): Double; CDECL;
function Loads_Get_Vminemerg(): Double; CDECL;
function Loads_Get_Vminnorm(): Double; CDECL;
function Loads_Get_Vminpu(): Double; CDECL;
function Loads_Get_xfkVA(): Double; CDECL;
function Loads_Get_Xneut(): Double; CDECL;
function Loads_Get_Yearly(): PAnsiChar; CDECL;
procedure Loads_Set_AllocationFactor(Value: Double); CDECL;
procedure Loads_Set_Cfactor(Value: Double); CDECL;
procedure Loads_Set_Class_(Value: Integer); CDECL;
procedure Loads_Set_CVRcurve(const Value: PAnsiChar); CDECL;
procedure Loads_Set_CVRvars(Value: Double); CDECL;
procedure Loads_Set_CVRwatts(Value: Double); CDECL;
procedure Loads_Set_daily(const Value: PAnsiChar); CDECL;
procedure Loads_Set_duty(const Value: PAnsiChar); CDECL;
procedure Loads_Set_Growth(const Value: PAnsiChar); CDECL;
procedure Loads_Set_IsDelta(Value: Boolean); CDECL;
procedure Loads_Set_kva(Value: Double); CDECL;
procedure Loads_Set_kwh(Value: Double); CDECL;
procedure Loads_Set_kwhdays(Value: Double); CDECL;
procedure Loads_Set_Model(Value: Integer); CDECL;
procedure Loads_Set_NumCust(Value: Integer); CDECL;
procedure Loads_Set_PctMean(Value: Double); CDECL;
procedure Loads_Set_PctStdDev(Value: Double); CDECL;
procedure Loads_Set_Rneut(Value: Double); CDECL;
procedure Loads_Set_Spectrum(const Value: PAnsiChar); CDECL;
procedure Loads_Set_Status(Value: Integer); CDECL;
procedure Loads_Set_Vmaxpu(Value: Double); CDECL;
procedure Loads_Set_Vminemerg(Value: Double); CDECL;
procedure Loads_Set_Vminnorm(Value: Double); CDECL;
procedure Loads_Set_Vminpu(Value: Double); CDECL;
procedure Loads_Set_xfkVA(Value: Double); CDECL;
procedure Loads_Set_Xneut(Value: Double); CDECL;
procedure Loads_Set_Yearly(const Value: PAnsiChar); CDECL;
procedure Loads_Get_ZIPV(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure Loads_Get_ZIPV_GR(); CDECL;
procedure Loads_Set_ZIPV(ValuePtr: PDouble; ValueCount: TAPISize); CDECL;
function Loads_Get_pctSeriesRL(): Double; CDECL;
procedure Loads_Set_pctSeriesRL(Value: Double); CDECL;
function Loads_Get_RelWeight(): Double; CDECL;
procedure Loads_Set_RelWeight(Value: Double); CDECL;

// API extensions
function Loads_Get_Phases(): Integer; CDECL;
procedure Loads_Set_Phases(Value: Integer); CDECL;
function Loads_Get_Bus1(): PAnsiChar; CDECL;
procedure Loads_Set_Bus1(const Value: PAnsiChar); CDECL;


implementation

uses
    CAPI_Constants,
    DSSGlobals,
    Executive,
    Load,
    SysUtils,
    math;

type
    LoadProps = (
        phases = 1, bus1 = 2, kV = 3, kW = 4, pf = 5, model = 6, yearly = 7, daily = 8, duty = 9, growth = 10, conn = 11, kvar = 12,
        Rneut = 13, Xneut = 14, status = 15, cls = 16, Vminpu = 17, Vmaxpu = 18, Vminnorm = 19, Vminemerg = 20, xfkVA = 21,
        allocationfactor = 22, kVA = 23, pctmean = 24, pctstddev = 25, CVRwatts = 26, CVRvars = 27, kwh = 28, kwhdays = 29,
        Cfactor = 30, CVRcurve = 31, NumCust = 32, ZIPV = 33, pctSeriesRL = 34, RelWeight = 35, Vlowpu = 36,
        puXharm = 37, XRhar = 38
    );

//------------------------------------------------------------------------------
procedure LoadPropSideEffects(prop: LoadProps; load: TLoadObj); //incomplete
begin
    with load do
    begin
    // << SIDE EFFECTS >>
    // keep kvar nominal up to date WITH kW and PF
        case prop of
            LoadProps.phases:
            begin
            // -> SetNcondsForConnection  // Force Reallocation of terminal info
                case Connection of
                    0:
                        NConds := Fnphases + 1;
                    1:
                        case Fnphases of
                            1, 2:
                                NConds := Fnphases + 1; // L-L and Open-delta
                        else
                            NConds := Fnphases;
                        end;
                else  {nada}
                end;
            // <- SetNcondsForConnection
                UpdateVoltageBases;
            end;

            LoadProps.kV:
                UpdateVoltageBases;

            LoadProps.kW:
                LoadSpecType := 0;

            LoadProps.pf:
            begin
                PFChanged := TRUE;
                PFSpecified := TRUE;
            end;
            {Set shape objects;  returns nil if not valid}
            {Sets the kW and kvar properties to match the peak kW demand from the Loadshape}
            LoadProps.yearly:
            begin
                YearlyShapeObj := LoadShapeClass.Find(YearlyShape);
                if Assigned(YearlyShapeObj) then
                    with YearlyShapeObj do
                        if UseActual then
                            SetkWkvar(MaxP, MaxQ);
            end;
            LoadProps.daily:
            begin
                DailyShapeObj := LoadShapeClass.Find(DailyShape);
                if Assigned(DailyShapeObj) then
                    with DailyShapeObj do
                        if UseActual then
                            SetkWkvar(MaxP, MaxQ);
                {If Yearly load shape is not yet defined, make it the same as Daily}
                if YearlyShapeObj = NIL then
                    YearlyShapeObj := DailyShapeObj;
            end;
            LoadProps.duty:
            begin
                DutyShapeObj := LoadShapeClass.Find(DutyShape);
                if Assigned(DutyShapeObj) then
                    with DutyShapeObj do
                        if UseActual then
                            SetkWkvar(MaxP, MaxQ);
            end;
            LoadProps.growth:
                GrowthShapeObj := GrowthShapeClass.Find(GrowthShape);

            LoadProps.kvar:
            begin
                LoadSpecType := 1;
                PFSpecified := FALSE;
            end;// kW, kvar
 {*** see set_xfkva, etc           21, 22: LoadSpectype := 3;  // XFKVA*AllocationFactor, PF  }
            LoadProps.pctMean:
                LoadSpecType := 2;  // kVA, PF
 {*** see set_kwh, etc           28..30: LoadSpecType := 4;  // kWh, days, cfactor, PF }
            LoadProps.CVRCurve:
                CVRShapeObj := LoadShapeClass.Find(CVRshape);
        end;
    end;
end;
//------------------------------------------------------------------------------
function _activeObj(out obj: TLoadObj): Boolean; inline;
begin
    Result := False;
    obj := NIL;
    if InvalidCircuit then
        Exit;
    
    obj := ActiveCircuit.Loads.Active;
    if obj = NIL then
    begin
        if DSS_CAPI_EXT_ERRORS then
        begin
            DoSimpleMsg('No active Load object found! Activate one and retry.', 8989);
        end;
        Exit;
    end;
    
    Result := True;
end;
//------------------------------------------------------------------------------
procedure Set_Parameter(const parm: String; const val: String);
var
    cmd: String;
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
        
    SolutionAbort := FALSE;  // Reset for commands entered from outside
    cmd := Format('load.%s.%s=%s', [elem.Name, parm, val]);
    DSSExecutive.Command := cmd;
end;
//------------------------------------------------------------------------------
procedure Loads_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PAPISize); CDECL;
begin
    DefaultResult(ResultPtr, ResultCount);
    if InvalidCircuit then
        Exit;
    Generic_Get_AllNames(ResultPtr, ResultCount, ActiveCircuit.Loads, False);
end;
//------------------------------------------------------------------------------
function Loads_Get_First(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := Generic_CktElement_Get_First(ActiveCircuit.Loads);
end;
//------------------------------------------------------------------------------
function Loads_Get_Next(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := Generic_CktElement_Get_Next(ActiveCircuit.Loads);
end;
//------------------------------------------------------------------------------
function Loads_Get_idx(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := ActiveCircuit.Loads.ActiveIndex
end;
//------------------------------------------------------------------------------
procedure Loads_Set_idx(Value: Integer); CDECL;
var
    pLoad: TLoadObj;
begin
    if InvalidCircuit then
        Exit;
    pLoad := ActiveCircuit.Loads.Get(Value);
    if pLoad = NIL then
    begin
        DoSimpleMsg('Invalid Load index: "' + IntToStr(Value) + '".', 656565);
        Exit;
    end;
    ActiveCircuit.ActiveCktElement := pLoad;
end;
//------------------------------------------------------------------------------
function Loads_Get_Name(): PAnsiChar; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(pLoad) then
        Exit;
        
    Result := DSS_GetAsPAnsiChar(pLoad.Name);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Name(const Value: PAnsiChar); CDECL;
begin
    if InvalidCircuit then
        Exit;
    if LoadClass.SetActive(Value) then
    begin
        ActiveCircuit.ActiveCktElement := LoadClass.ElementList.Active;
        ActiveCircuit.Loads.Get(LoadClass.Active);
    end
    else
    begin
        DoSimpleMsg('Load "' + Value + '" Not Found in Active Circuit.', 5003);
    end;
end;
//------------------------------------------------------------------------------
function Loads_Get_kV(): Double; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(pLoad) then
        Exit;
                
    Result := pLoad.kVLoadBase;
end;
//------------------------------------------------------------------------------
function Loads_Get_kvar(): Double; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(pLoad) then
        Exit;
                
    Result := pLoad.kvarBase;
end;
//------------------------------------------------------------------------------
function Loads_Get_kW(): Double; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(pLoad) then
        Exit;
                
    Result := pLoad.kWBase;
end;
//------------------------------------------------------------------------------
function Loads_Get_PF(): Double; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(pLoad) then
        Exit;
                
    Result := pLoad.PFNominal;
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kV(Value: Double); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;

    pLoad.kVLoadBase := Value;
    pLoad.UpdateVoltageBases;  // side effects
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kvar(Value: Double); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;

    pLoad.kvarBase := Value;
    pLoad.LoadSpecType := 1;
    pLoad.RecalcElementData;  // set power factor based on kW, kvar
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kW(Value: Double); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;

    pLoad.kWBase := Value;
    pLoad.LoadSpecType := 0;
    pLoad.RecalcElementData; // sets kvar based on kW and pF
end;
//------------------------------------------------------------------------------
procedure Loads_Set_PF(Value: Double); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;

    pLoad.PFNominal := Value;
    pLoad.LoadSpecType := 0;
    pLoad.RecalcElementData; //  sets kvar based on kW and pF
end;
//------------------------------------------------------------------------------
function Loads_Get_Count(): Integer; CDECL;
begin
    Result := 0;
    if Assigned(ActiveCircuit) then
        Result := ActiveCircuit.Loads.ListSize;
end;
//------------------------------------------------------------------------------
function Loads_Get_AllocationFactor(): Double; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(pLoad) then
        Exit;

    Result := pLoad.AllocationFactor;
end;
//------------------------------------------------------------------------------
function Loads_Get_Cfactor(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;

    Result := elem.CFactor;
end;
//------------------------------------------------------------------------------
function Loads_Get_Class_(): Integer; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0;
    if not _activeObj(elem) then
        Exit;

    Result := elem.LoadClass;
end;
//------------------------------------------------------------------------------
function Loads_Get_CVRcurve(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;

    Result := DSS_GetAsPAnsiChar(elem.CVRshape);
end;
//------------------------------------------------------------------------------
function Loads_Get_CVRvars(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;

    Result := elem.CVRvars;
end;
//------------------------------------------------------------------------------
function Loads_Get_CVRwatts(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;

    Result := elem.CVRwatts;
end;
//------------------------------------------------------------------------------
function Loads_Get_daily(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;

    Result := DSS_GetAsPAnsiChar(elem.DailyShape);
end;
//------------------------------------------------------------------------------
function Loads_Get_duty(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;

    Result := DSS_GetAsPAnsiChar(elem.DailyShape);
end;
//------------------------------------------------------------------------------
function Loads_Get_Growth(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;

    Result := DSS_GetAsPAnsiChar(elem.GrowthShape);
end;
//------------------------------------------------------------------------------
function Loads_Get_IsDelta(): Boolean; CDECL;
var
    elem: TLoadObj;
begin
    Result := FALSE;
    if not _activeObj(elem) then
        Exit;
    if elem.Connection > 0 then
        Result := TRUE;
end;
//------------------------------------------------------------------------------
function Loads_Get_kva(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.kVABase;
end;
//------------------------------------------------------------------------------
function Loads_Get_kwh(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.kWh;
end;
//------------------------------------------------------------------------------
function Loads_Get_kwhdays(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.kWhDays;
end;
//------------------------------------------------------------------------------
function Loads_Get_Model(): Integer; CDECL;
var
    elem: TLoadObj;
begin
    Result := dssLoadConstPQ;
    if not _activeObj(elem) then
        Exit;

    case elem.FLoadModel of
        1:
            Result := dssLoadConstPQ;
        2:
            Result := dssLoadConstZ;
        3:
            Result := dssLoadMotor;
        4:
            Result := dssLoadCVR;
        5:
            Result := dssLoadConstI;
        6:
            Result := dssLoadConstPFixedQ;
        7:
            Result := dssLoadConstPFixedX;
        8:
            Result := dssLoadZIPV;
    end;
end;
//------------------------------------------------------------------------------
function Loads_Get_NumCust(): Integer; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.NumCustomers;
end;
//------------------------------------------------------------------------------
function Loads_Get_PctMean(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.puMean * 100.0;
end;
//------------------------------------------------------------------------------
function Loads_Get_PctStdDev(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.puStdDev * 100.0;
end;
//------------------------------------------------------------------------------
function Loads_Get_Rneut(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.Rneut;
end;
//------------------------------------------------------------------------------
function Loads_Get_Spectrum(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;
    Result := DSS_GetAsPAnsiChar(elem.Spectrum);
end;
//------------------------------------------------------------------------------
function Loads_Get_Status(): Integer; CDECL;
var
    elem: TLoadObj;
begin
    Result := dssLoadVariable;
    if not _activeObj(elem) then
        Exit;

    if elem.ExemptLoad then
        Result := dssLoadExempt
    else if elem.FixedLoad then
        Result := dssLoadFixed;
end;
//------------------------------------------------------------------------------
function Loads_Get_Vmaxpu(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.MaxPU;
end;
//------------------------------------------------------------------------------
function Loads_Get_Vminemerg(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.MinEmerg;
end;
//------------------------------------------------------------------------------
function Loads_Get_Vminnorm(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.MinNormal;
end;
//------------------------------------------------------------------------------
function Loads_Get_Vminpu(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.MinPU;
end;
//------------------------------------------------------------------------------
function Loads_Get_xfkVA(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.ConnectedkVA;
end;
//------------------------------------------------------------------------------
function Loads_Get_Xneut(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.Xneut;
end;
//------------------------------------------------------------------------------
function Loads_Get_Yearly(): PAnsiChar; CDECL;
var
    elem: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(elem) then
        Exit;
    Result := DSS_GetAsPAnsiChar(elem.YearlyShape);
end;

//------------------------------------------------------------------------------
procedure Loads_Set_AllocationFactor(Value: Double); CDECL;
begin
    Set_Parameter('AllocationFactor', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Cfactor(Value: Double); CDECL;
begin
    Set_Parameter('Cfactor', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Class_(Value: Integer); CDECL;
begin
    Set_Parameter('Class', IntToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_CVRcurve(const Value: PAnsiChar); CDECL;
begin
    Set_Parameter('CVRcurve', Value);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_CVRvars(Value: Double); CDECL;
begin
    Set_Parameter('CVRvars', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_CVRwatts(Value: Double); CDECL;
begin
    Set_Parameter('CVRwatts', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_daily(const Value: PAnsiChar); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;

    elem.DailyShape := Value;
    LoadPropSideEffects(LoadProps.daily, elem);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_duty(const Value: PAnsiChar); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;

    elem.DutyShape := Value;
    LoadPropSideEffects(LoadProps.duty, elem);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Growth(const Value: PAnsiChar); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;

    elem.GrowthShape := Value;
    LoadPropSideEffects(LoadProps.growth, elem);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_IsDelta(Value: Boolean); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.Connection := Integer(Value);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kva(Value: Double); CDECL;
begin
    Set_Parameter('kva', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kwh(Value: Double); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.Set_kWh(Value);
  //LoadPropSideEffects(LoadProps.kwh, elem);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_kwhdays(Value: Double); CDECL;
begin
    Set_Parameter('kwhdays', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Model(Value: Integer); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.FLoadModel := Value; // enums match the integer codes
end;
//------------------------------------------------------------------------------
procedure Loads_Set_NumCust(Value: Integer); CDECL;
begin
    Set_Parameter('NumCust', IntToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_PctMean(Value: Double); CDECL;
begin
    Set_Parameter('%mean', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_PctStdDev(Value: Double); CDECL;
begin
    Set_Parameter('%stddev', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Rneut(Value: Double); CDECL;
begin
    Set_Parameter('Rneut', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Spectrum(const Value: PAnsiChar); CDECL;
begin
    Set_Parameter('Spectrum', Value);
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Status(Value: Integer); CDECL;
begin
    case Value of
        dssLoadVariable:
            Set_Parameter('status', 'v');
        dssLoadFixed:
            Set_Parameter('status', 'f');
        dssLoadExempt:
            Set_Parameter('status', 'e');
    end;
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Vmaxpu(Value: Double); CDECL;
begin
    Set_Parameter('VmaxPu', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Vminemerg(Value: Double); CDECL;
begin
    Set_Parameter('VminEmerg', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Vminnorm(Value: Double); CDECL;
begin
    Set_Parameter('VminNorm', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Vminpu(Value: Double); CDECL;
begin
    Set_Parameter('VminPu', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_xfkVA(Value: Double); CDECL;
begin
    Set_Parameter('XfKVA', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Xneut(Value: Double); CDECL;
begin
    Set_Parameter('Xneut', FloatToStr(Value));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Yearly(const Value: PAnsiChar); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.YearlyShape := Value;
    LoadPropSideEffects(LoadProps.yearly, elem);
end;
//------------------------------------------------------------------------------
procedure Loads_Get_ZIPV(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
    begin
        DefaultResult(ResultPtr, ResultCount);
        Exit;
    end;
    DSS_RecreateArray_PDouble(ResultPtr, ResultCount, elem.nZIPV);
    Move(elem.ZipV[1], ResultPtr^, elem.nZIPV * SizeOf(Double));
end;

procedure Loads_Get_ZIPV_GR(); CDECL;
// Same as Loads_Get_ZIPV but uses global result (GR) pointers
begin
    Loads_Get_ZIPV(GR_DataPtr_PDouble, GR_CountPtr_PDouble)
end;
//------------------------------------------------------------------------------
procedure Loads_Set_ZIPV(ValuePtr: PDouble; ValueCount: TAPISize); CDECL;
var
    elem: TLoadObj;
begin
    if ValueCount <> 7 then
    begin
        DoSimpleMsg(Format('ZIPV requires 7 elements, %d were provided!', [ValueCount]), 5890);
        Exit;
    end;

    if not _activeObj(elem) then
        Exit;

    // allocate space for 7
    elem.nZIPV := 7;
    Move(ValuePtr[0], elem.ZIPV[1], elem.nZIPV * SizeOf(Double));
end;
//------------------------------------------------------------------------------
function Loads_Get_pctSeriesRL(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := -1.0; // signify  bad request
    if not _activeObj(elem) then
        Exit;
    Result := elem.puSeriesRL * 100.0;
end;
//------------------------------------------------------------------------------
procedure Loads_Set_pctSeriesRL(Value: Double); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.puSeriesRL := Value / 100.0;
end;
//------------------------------------------------------------------------------
function Loads_Get_RelWeight(): Double; CDECL;
var
    elem: TLoadObj;
begin
    Result := 0.0;
    if not _activeObj(elem) then
        Exit;
    Result := elem.RelWeighting;
end;
//------------------------------------------------------------------------------
procedure Loads_Set_RelWeight(Value: Double); CDECL;
var
    elem: TLoadObj;
begin
    if not _activeObj(elem) then
        Exit;
    elem.RelWeighting := Value;
end;
//------------------------------------------------------------------------------
function Loads_Get_Phases(): Integer; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := 0;
    if not _activeObj(pLoad) then
        Exit;
    Result := pLoad.Nphases;
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Phases(Value: Integer); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;
    
    if (Value <> pLoad.NPhases) then
    begin
        pLoad.NPhases := Value;
        LoadPropSideEffects(LoadProps.phases, pLoad);
    end;
end;
//------------------------------------------------------------------------------
function Loads_Get_Bus1(): PAnsiChar; CDECL;
var
    pLoad: TLoadObj;
begin
    Result := NIL;
    if not _activeObj(pLoad) then
        Exit;
    Result := DSS_GetAsPAnsiChar(pLoad.GetBus(1));
end;
//------------------------------------------------------------------------------
procedure Loads_Set_Bus1(const Value: PAnsiChar); CDECL;
var
    pLoad: TLoadObj;
begin
    if not _activeObj(pLoad) then
        Exit;
    pLoad.SetBus(1, Value);
    // LoadPropSideEffects(LoadProps.bus1, pLoad); -- Nothing
end;
//------------------------------------------------------------------------------
end.
