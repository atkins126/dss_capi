unit CAPI_PDElements;

interface

uses
    CAPI_Utils;

function PDElements_Get_Count(): Integer; CDECL;
function PDElements_Get_FaultRate(): Double; CDECL;
function PDElements_Get_First(): Integer; CDECL;
function PDElements_Get_IsShunt(): Boolean; CDECL;
function PDElements_Get_Next(): Integer; CDECL;
function PDElements_Get_pctPermanent(): Double; CDECL;
procedure PDElements_Set_FaultRate(Value: Double); CDECL;
procedure PDElements_Set_pctPermanent(Value: Double); CDECL;
function PDElements_Get_Name(): PAnsiChar; CDECL;
procedure PDElements_Set_Name(const Value: PAnsiChar); CDECL;
function PDElements_Get_AccumulatedL(): Double; CDECL;
function PDElements_Get_Lambda(): Double; CDECL;
function PDElements_Get_Numcustomers(): Integer; CDECL;
function PDElements_Get_ParentPDElement(): Integer; CDECL;
function PDElements_Get_RepairTime(): Double; CDECL;
function PDElements_Get_Totalcustomers(): Integer; CDECL;
function PDElements_Get_FromTerminal(): Integer; CDECL;
function PDElements_Get_TotalMiles(): Double; CDECL;
function PDElements_Get_SectionID(): Integer; CDECL;
procedure PDElements_Set_RepairTime(Value: Double); CDECL;

// Extensions below
procedure PDElements_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllMaxCurrents(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllMaxCurrents_GR(const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllPctNorm(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllPctNorm_GR(const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllPctEmerg(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllPctEmerg_GR(const AllNodes: Boolean); CDECL;
procedure PDElements_Get_AllCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllCurrents_GR(); CDECL;
procedure PDElements_Get_AllCurrentsMagAng(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllCurrentsMagAng_GR(); CDECL;
procedure PDElements_Get_AllCplxSeqCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllCplxSeqCurrents_GR(); CDECL;
procedure PDElements_Get_AllSeqCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllSeqCurrents_GR(); CDECL;
procedure PDElements_Get_AllPowers(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllPowers_GR(); CDECL;
procedure PDElements_Get_AllSeqPowers(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllSeqPowers_GR(); CDECL;
procedure PDElements_Get_AllNumPhases(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllNumPhases_GR(); CDECL;
procedure PDElements_Get_AllNumConductors(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllNumConductors_GR(); CDECL;
procedure PDElements_Get_AllNumTerminals(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
procedure PDElements_Get_AllNumTerminals_GR(); CDECL;

implementation

uses
    CAPI_Constants,
    DSSGlobals,
    PDElement,
    PDClass,
    SysUtils,
    PointerList,
    Bus,
    XYCurve,
    ucomplex,
    ArrayDef,
    Utilities,
    Math,
    MathUtil;
    
type
    PDoubleArray = CAPI_Utils.PDoubleArray;
    PIntegerArray = OBJPAS.PIntegerArray;

//------------------------------------------------------------------------------
function _activeObj(out obj: TPDElement): Boolean; inline;
begin
    Result := False;
    obj := NIL;
    if InvalidCircuit then
        Exit;
    
    with ActiveCircuit do
    begin
        if ActiveCktElement = NIL then 
        begin
            if DSS_CAPI_EXT_ERRORS then
            begin
                DoSimpleMsg('No active PD Element found! Activate one and retry.', 8989);
            end;
            Exit;
        end;

        if not (ActiveCktElement is TPDElement) then
        begin
            if DSS_CAPI_EXT_ERRORS then
            begin
                DoSimpleMsg('No active PD Element found! Activate one and retry.', 8989);
            end;
            Exit;
        end;
        
        obj := ActiveCktElement as TPDElement;
    end;
    Result := True;
end;
//------------------------------------------------------------------------------
function PDElements_Get_Count(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    
    Result := ActiveCircuit.PDElements.ListSize;
end;
//------------------------------------------------------------------------------
function PDElements_Get_FaultRate(): Double; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.Faultrate;
end;
//------------------------------------------------------------------------------
function PDElements_Get_First(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := Generic_CktElement_Get_First(ActiveCircuit.PDElements);
end;
//------------------------------------------------------------------------------
function PDElements_Get_Next(): Integer; CDECL;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
    Result := Generic_CktElement_Get_Next(ActiveCircuit.PDelements);
    if Result <> 0 then Result := 1; //TODO: inconsistent with the rest
end;
//------------------------------------------------------------------------------
function PDElements_Get_IsShunt(): Boolean; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := FALSE;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.IsShunt;
end;
//------------------------------------------------------------------------------
function PDElements_Get_pctPermanent(): Double; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.PctPerm;
end;
//------------------------------------------------------------------------------
procedure PDElements_Set_FaultRate(Value: Double); CDECL;
var
    ActivePDElement: TPDElement;
begin
    if not _activeObj(ActivePDElement) then
        Exit;
    ActivePDElement.FaultRate := Value;
end;
//------------------------------------------------------------------------------
procedure PDElements_Set_pctPermanent(Value: Double); CDECL;
var
    ActivePDElement: TPDElement;
begin
    if not _activeObj(ActivePDElement) then
        Exit;
    ActivePDElement.PctPerm := Value;
end;
//------------------------------------------------------------------------------
function PDElements_Get_Name(): PAnsiChar; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := NIL;   // return null if not a PD element
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := DSS_GetAsPAnsiChar(Format('%s.%s', [ActivePDElement.Parentclass.Name, ActivePDElement.Name]));  // full name
end;

//------------------------------------------------------------------------------
procedure PDElements_Set_Name(const Value: PAnsiChar); CDECL; //TODO: rewrite to use a hashmap?
var
    ActivePDElement: TPDElement;
    TestString: String;
begin
    if InvalidCircuit then
        Exit;
        
    with ActiveCircuit do
    begin
        TestString := Value;
        // Search through list of PD Elements until we find this one
        ActivePDElement := PDElements.First;
        while Assigned(ActivePDElement) do
            with ActivePDelement do
            begin
                if (CompareText(TestString, Format('%s.%s', [Parentclass.Name, Name])) = 0) then
                begin
                    ActiveCktElement := ActivePDElement;
                    Break;
                end;
                ActivePDElement := PDElements.Next;
            end;
    end;
end;
//------------------------------------------------------------------------------
function PDElements_Get_AccumulatedL(): Double; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.AccumulatedBrFltRate;
end;
//------------------------------------------------------------------------------
function PDElements_Get_Lambda(): Double; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.BranchFltRate;
end;
//------------------------------------------------------------------------------
function PDElements_Get_Numcustomers(): Integer; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.BranchNumCustomers;
end;
//------------------------------------------------------------------------------
function PDElements_Get_ParentPDElement(): Integer; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0;
    if not _activeObj(ActivePDElement) then
        Exit;
    if ActivePDElement.ParentPDElement <> NIL then    // leaves ActiveCktElement as is
    begin
        ActiveCircuit.ActiveCktElement := ActivePDElement.ParentPDElement;
        Result := ActiveCircuit.ActivecktElement.ClassIndex;
    end;
end;
//------------------------------------------------------------------------------
function PDElements_Get_RepairTime(): Double; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.HrsToRepair;
end;
//------------------------------------------------------------------------------
function PDElements_Get_Totalcustomers(): Integer; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0;
    if InvalidCircuit then
        Exit;
        
    with ActiveCircuit do
        if ActiveCktElement is TPDElement then
        begin
            ActivePDElement := ActiveCktelement as TPDElement;
            Result := ActivePDElement.BranchTotalCustomers;
        end;
end;
//------------------------------------------------------------------------------
function PDElements_Get_FromTerminal(): Integer; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.FromTerminal;
end;
//------------------------------------------------------------------------------
function PDElements_Get_TotalMiles(): Double; CDECL;
// Total miles of line from here on down to the end of the feeder
var
    ActivePDElement: TPDElement;
begin
    Result := 0.0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.AccumulatedMilesDownStream;
end;
//------------------------------------------------------------------------------
function PDElements_Get_SectionID(): Integer; CDECL;
var
    ActivePDElement: TPDElement;
begin
    Result := 0;
    if not _activeObj(ActivePDElement) then
        Exit;
    Result := ActivePDElement.BranchSectionID;
end;
//------------------------------------------------------------------------------
procedure PDElements_Set_RepairTime(Value: Double); CDECL;
var
    ActivePDElement: TPDElement;
begin
    if not _activeObj(ActivePDElement) then
        Exit;
    ActivePDElement.HrsToRepair := Value;
end;
//------------------------------------------------------------------------------
procedure PDElements_Get_AllNames(var ResultPtr: PPAnsiChar; ResultCount: PAPISize); CDECL;
var
    Result: PPAnsiCharArray;
    idx_before, k, numEnabled: Integer;
    elem: TPDElement;
    pList: TPointerList;
begin
    DefaultResult(ResultPtr, ResultCount);
    if InvalidCircuit then
        Exit;

    pList := ActiveCircuit.PDElements;
    if pList.ListSize <= 0 then
        Exit;
    
    idx_before := pList.ActiveIndex;
    k := 0;
    numEnabled := pList.ListSize;
//    elem := pList.First;
//    while elem <> NIL do
//    begin
//        if elem.Enabled then 
//            Inc(numEnabled);
//        elem := pList.Next;
//    end;
    elem := pList.First;
    DSS_RecreateArray_PPAnsiChar(Result, ResultPtr, ResultCount, numEnabled);
    
    
    while elem <> NIL do
    begin
        // if (elem.Enabled or DSS_CAPI_ITERATE_DISABLED) then
        begin
            Result[k] := DSS_CopyStringAsPChar(elem.DSSClassName + '.' + elem.Name);
            Inc(k);
        end;
        elem := pList.Next;
    end;
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;
//------------------------------------------------------------------------------
function _PDElements_Get_pctCapacity_for(const AllNodes: Boolean; const What: integer; RatingIdx: Integer; pElem: TPDElement; cBuffer: pComplexArray): Double; inline;
var
    i: Integer;
    EmergAmps,
    NormAmps,
    Currmag,
    MaxCurrent: Double;
    NumNodes: Integer;
begin
    Result := 0;
    MaxCurrent := 0.0;
    
    if AllNodes then
        NumNodes := pElem.NConds * pElem.NTerms
    else
        NumNodes := pElem.Nphases;
    
    for i := 1 to NumNodes do
    begin
        Currmag := Cabs(Cbuffer^[i]);
        if Currmag > MaxCurrent then
            MaxCurrent := Currmag;
    end;
    if What = 0 then
    begin
        Result := MaxCurrent;
        Exit;
    end;
    
    NormAmps := pElem.NormAmps;
    EmergAmps := pElem.EmergAmps;
    if (RatingIdx <= pElem.NumAmpRatings) and (pElem.NumAmpRatings > 1) then
    begin
        NormAmps := pElem.AmpRatings[RatingIdx];
        EmergAmps := pElem.AmpRatings[RatingIdx];
    end;

    case What of
        1: if NormAmps <> 0 then Result := 100 * MaxCurrent / NormAmps;
        2: if EmergAmps <> 0 then Result := 100 * MaxCurrent / EmergAmps;
    end;
end;

procedure _PDElements_Get_x(var ResultPtr: PDouble; ResultCount: PAPISize; const What: integer; const AllNodes: Boolean);
// Internal helper function to calculate for all PDElements
// MaxCurrent (0), CapacityNorm (1), CapacityEmerg (2), Power (3)
var
    Result: CAPI_Utils.PDoubleArray;
    k, idx_before, maxSize, RatingIdx: Integer;
    pElem: TPDElement;
    pList: TPointerList;
    LocalPower: Complex;
    cBuffer: pComplexArray;
    RSignal: TXYCurveObj;
begin
    cBuffer := NIL;
    if (MissingSolution) or (ActiveCircuit.PDElements.ListSize <= 0) then 
    begin
        DefaultResult(ResultPtr, ResultCount, -1.0);
        Exit;
    end;

    pList := ActiveCircuit.PDElements;
    idx_before := pList.ActiveIndex;
    k := 0;
    pElem := pList.First;
    case What of
    3: 
        begin
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, pList.ListSize * 2); // complex
            while pElem <> NIL do
            begin
                if pElem.Enabled then
                begin
                    LocalPower := pElem.Power[1];
                    Result[k] := Localpower.re * 0.001;
                    Result[k + 1] := Localpower.im * 0.001;
                end;
                Inc(k, 2);
                pElem := pList.Next;
            end;
        end;
    0, 1, 2:
        try
            RatingIdx := -1;
            if SeasonalRating then
            begin
                if SeasonSignal <> '' then
                begin
                    RSignal := XYCurveClass.Find(SeasonSignal);
                    if RSignal <> NIL then
                    begin
                        RatingIdx := trunc(RSignal.GetYValue(ActiveCircuit.Solution.DynaVars.intHour));
                    end
                    else
                        SeasonalRating := FALSE;   // The XYCurve defined doesn't exist
                end
                else
                    SeasonalRating := FALSE;    // The user didn't define the seasonal signal
            end;

            maxSize := GetMaxCktElementSize();
            Getmem(cBuffer, sizeof(Complex) * maxSize);
            Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, pList.ListSize); // real
            while pElem <> NIL do
            begin
                if pElem.Enabled then
                begin
                    pElem.GetCurrents(cBuffer);
                    Result[k] := _PDElements_Get_pctCapacity_for(AllNodes, What, RatingIdx, pElem, cBuffer);
                end;
                Inc(k);
                pElem := pList.Next;
            end;
        finally
            if Assigned(cBuffer) then
                Freemem(cBuffer);
        end;
    end;
    
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllMaxCurrents(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
begin
    _PDElements_Get_x(ResultPtr, ResultCount, 0, AllNodes);
end;

procedure PDElements_Get_AllMaxCurrents_GR(); CDECL;
// Same as PDElements_Get_AllMaxCurrents but uses global result (GR) pointers
begin
    PDElements_Get_AllMaxCurrents(GR_DataPtr_PDouble, GR_CountPtr_PDouble, AllNodes)
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllPctNorm(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
begin
    _PDElements_Get_x(ResultPtr, ResultCount, 1, AllNodes);
end;

procedure PDElements_Get_AllPctNorm_GR(const AllNodes: Boolean); CDECL;
// Same as PDElements_Get_AllPctNorm but uses global result (GR) pointers
begin
    PDElements_Get_AllPctNorm(GR_DataPtr_PDouble, GR_CountPtr_PDouble, AllNodes)
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllPctEmerg(var ResultPtr: PDouble; ResultCount: PAPISize; const AllNodes: Boolean); CDECL;
begin
    _PDElements_Get_x(ResultPtr, ResultCount, 2, AllNodes);
end;

procedure PDElements_Get_AllPctEmerg_GR(const AllNodes: Boolean); CDECL;
// Same as PDElements_Get_AllPctEmerg but uses global result (GR) pointers
begin
    PDElements_Get_AllPctEmerg(GR_DataPtr_PDouble, GR_CountPtr_PDouble, AllNodes)
end;

//------------------------------------------------------------------------------
procedure _PDElements_Get_AllCurrents_x(var ResultPtr: PDouble; ResultCount: PAPISize; const What: Integer);
// What=1 for polar form, otherwise rectangular
type
    PPolar = ^Polar;
var
    idx_before: Integer;
    pElem: TPDElement;
    pList: TPointerList;
    cBuffer: pComplexArray;
    NValuesTotal, NValues, i: Integer;
    CResultPtr: PPolar;
begin
    if (InvalidCircuit) or (ActiveCircuit.PDElements.ListSize <= 0) then 
    begin
        DefaultResult(ResultPtr, ResultCount);
        Exit;
    end;
    pList := ActiveCircuit.PDElements;
    idx_before := pList.ActiveIndex;

    // Get the total number of (complex) elements
    pElem := pList.First;
    NValuesTotal := 0;
    while pElem <> NIL do
    begin
        Inc(NValuesTotal, pElem.NConds * pElem.NTerms);
        pElem := pList.Next;
    end;

    DSS_RecreateArray_PDouble(ResultPtr, ResultCount, NValuesTotal * 2);
    CResultPtr := PPolar(ResultPtr);

    // Get the actual values
    pElem := pList.First;
    while pElem <> NIL do
    begin
        NValues := pElem.NConds * pElem.NTerms;
        if pElem.Enabled then
            pElem.GetCurrents(pComplexArray(CResultPtr));
            
        Inc(CResultPtr, NValues);
        pElem := pList.Next;
    end;
    
    case What of
        1: //Polar (Mag/Angle)
        begin
            cBuffer := pComplexArray(ResultPtr);
            CResultPtr := PPolar(ResultPtr);
            for i := 1 to NValuesTotal do
            begin
                CResultPtr^ := ctopolardeg(cBuffer^[i]);
                inc(CResultPtr);
            end;
        end;
    end;
    
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllCurrents_x(ResultPtr, ResultCount, 0);
end;

procedure PDElements_Get_AllCurrents_GR(); CDECL;
// Same as PDElements_Get_AllCurrentsMagAng but uses global result (GR) pointers
begin
    PDElements_Get_AllCurrents(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;
//------------------------------------------------------------------------------
procedure PDElements_Get_AllCurrentsMagAng(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllCurrents_x(ResultPtr, ResultCount, 1);
end;

procedure PDElements_Get_AllCurrentsMagAng_GR(); CDECL;
// Same as PDElements_Get_AllCurrentsMagAng but uses global result (GR) pointers
begin
    PDElements_Get_AllCurrentsMagAng(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;

//------------------------------------------------------------------------------
procedure _PDElements_Get_AllxSeqCurrents(var ResultPtr: PDouble; ResultCount: PAPISize; magnitude: boolean);
type
    PPolar = ^Polar;
var
    Result: PDoubleArray;
    idx_before: Integer;
    pList: TPointerList;
    pElem: TPDElement;
    cBuffer: pComplexArray;
    i012v, i012: pComplex;
    maxSize, NTermsTotal, i, j, k: Integer;
begin
    if (MissingSolution) or (ActiveCircuit.PDElements.ListSize <= 0) then 
    begin
        DefaultResult(ResultPtr, ResultCount);
        Exit;
    end;
    
    pList := ActiveCircuit.PDElements;
    idx_before := pList.ActiveIndex;

    // Get the total number of (complex) elements, max. terminals, max. conductors
    pElem := pList.First;
    NTermsTotal := 0;
    while pElem <> NIL do
    begin
        Inc(NTermsTotal, pElem.NTerms);
        pElem := pList.Next;
    end;

    // Get the actual values
    pElem := pList.First;
    i012v := AllocMem(SizeOf(Complex) * 3 * NTermsTotal);
    i012 := i012v; // this is a running pointer
    maxSize := GetMaxCktElementSize();
    cBuffer := AllocMem(SizeOf(Complex) * maxSize);
    while pElem <> NIL do
    begin
        with pElem do
        begin
            if pElem.Enabled then
                GetCurrents(cBuffer)
            else
                FillByte(cBuffer^, SizeOf(Complex) * maxSize, 0);
            
            // _CalcSeqCurrents(pElem, i012);
            if NPhases <> 3 then
            begin
                {Handle non-3 phase elements}
                if (Nphases = 1) and ActiveCircuit.PositiveSequence then
                begin
                    {Populate only phase 1 quantities in Pos seq}
                    Inc(i012);
                    for j := 1 to NTerms do
                    begin
                        k := (j - 1) * NConds;
                        i012^ := cBuffer[1 + k];
                        Inc(i012, 3);  // inc to pos seq of next terminal
                    end;
                    Dec(i012);
                end
                // if neither 3-phase or pos seq model, just put in -1.0 for each element
                else
                begin
                    for i := 1 to 3 * NTerms do
                    begin
                        i012^ := Cmplx(-1.0, 0.0);  // Signify n/A
                        Inc(i012);
                    end;
                end;
            end
            else
            begin    // for 3-phase elements
                for j := 1 to NTerms do
                begin
                    k := (j - 1) * NConds;
                    Phase2SymComp(pComplexArray(@cBuffer[1 + k]), pComplexArray(i012));
                    Inc(i012, 3);
                end;
            end;
        end;
        pElem := pList.Next;
    end;
    
    if magnitude then
    begin
        Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, NTermsTotal * 3);
        i012 := i012v;
        for i := 0 to NTermsTotal * 3 - 1 do
        begin
            Result[i] := Cabs(i012^);
            Inc(i012);
        end;
    end
    else
    begin
        Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, NTermsTotal * 3 * 2);
        Move(i012v^, ResultPtr[0], NTermsTotal * 3 * 2 * SizeOf(Double));
    end;

    ReallocMem(i012v, 0);
    
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllSeqCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllxSeqCurrents(ResultPtr, ResultCount, True);
end;

procedure PDElements_Get_AllSeqCurrents_GR(); CDECL;
// Same as PDElements_Get_AllSeqCurrents but uses global result (GR) pointers
begin
    PDElements_Get_AllSeqCurrents(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllCplxSeqCurrents(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllxSeqCurrents(ResultPtr, ResultCount, False);
end;

procedure PDElements_Get_AllCplxSeqCurrents_GR(); CDECL;
// Same as PDElements_Get_AllCplxSeqCurrents but uses global result (GR) pointers
begin
    PDElements_Get_AllCplxSeqCurrents(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllPowers(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
// Return complex kW, kvar in each conductor for each terminal, for each PDElement
var
    Result: PDoubleArray;
    NValuesTotal, NValues, i: Integer;
    idx_before: Integer;
    pList: TPointerList;
    pElem: TPDElement;
    CResultPtr: PComplex;
begin
    if (InvalidCircuit) or (ActiveCircuit.PDElements.ListSize <= 0) then 
    begin
        DefaultResult(ResultPtr, ResultCount);
        Exit;
    end;
    pList := ActiveCircuit.PDElements;
    idx_before := pList.ActiveIndex;

    // Get the total number of (complex) elements
    pElem := pList.First;
    NValuesTotal := 0;
    while pElem <> NIL do
    begin
        Inc(NValuesTotal, pElem.NConds * pElem.NTerms);
        pElem := pList.Next;
    end;

    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, NValuesTotal * 2);
    CResultPtr := PComplex(ResultPtr);

    // Get the actual values
    pElem := pList.First;
    while pElem <> NIL do
    begin
        NValues := pElem.NConds * pElem.NTerms;
        
        if pElem.Enabled then
            pElem.GetPhasePower(pComplexArray(CResultPtr));
            
        Inc(CResultPtr, NValues);
        pElem := pList.Next;
    end;
    
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);

    for i := 0 to (2 * NValuesTotal) - 1 do
        Result[i] *= 0.001;
end;

procedure PDElements_Get_AllPowers_GR(); CDECL;
// Same as PDElements_Get_AllPowers but uses global result (GR) pointers
begin
    PDElements_Get_AllPowers(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllSeqPowers(var ResultPtr: PDouble; ResultCount: PAPISize); CDECL;
// All seq Powers of each PD element
// returns kW + j kvar
var
    Result: PDoubleArray;
    NValuesTotal, MaxNValues, i, j, k, n, iCount: Integer;
    idx_before: Integer;
    pList: TPointerList;
    pElem: TPDElement;
    CResultPtr: PComplex;
    cBuffer: pComplexArray;
    VPh, V012: Complex3;
    IPh, I012: Complex3;
    S: Complex;
begin
    if (MissingSolution) or (ActiveCircuit.PDElements.ListSize <= 0) then 
    begin
        DefaultResult(ResultPtr, ResultCount);
        Exit;
    end;
    pList := ActiveCircuit.PDElements;
    idx_before := pList.ActiveIndex;

    // Get the total number of (complex) elements
    pElem := pList.First;
    NValuesTotal := 0;
    MaxNValues := 0;
    
    while pElem <> NIL do
    begin
        if pElem.Enabled then
        begin
            Inc(NValuesTotal, 3 * pElem.NTerms);
            MaxNValues := Max(MaxNValues, pElem.NConds * pElem.NTerms);
        end;
        pElem := pList.Next;
    end;

    Result := DSS_RecreateArray_PDouble(ResultPtr, ResultCount, NValuesTotal * 2);
    CResultPtr := PComplex(ResultPtr);
    cBuffer := Allocmem(sizeof(Complex) * MaxNValues);

    // Get the actual values
    pElem := pList.First;
    iCount := 0;
    while pElem <> NIL do
    begin
        with ActiveCircuit, pElem do
        begin
//            if not pElem.Enabled then  
//            begin
//                pElem := pList.Next;
//                continue;
//            end;
            
            if NPhases <> 3 then
            begin
                if (Nphases = 1) and PositiveSequence then
                begin
                    if pElem.Enabled then  
                        GetCurrents(cBuffer)
                    else
                        FillByte(cBuffer^, SizeOf(Complex) * MaxNValues, 0);

                    Inc(iCount, 2);  // Start with kW1
                    {Put only phase 1 quantities in Pos seq}
                    for j := 1 to NTerms do
                    begin
                        k := (j - 1) * NConds;
                        n := NodeRef^[k + 1];
                        Vph[1] := Solution.NodeV^[n];  // Get voltage at node
                        S := Cmul(Vph[1], conjg(cBuffer^[k + 1]));   // Compute power per phase
                        Result[icount] := S.re * 0.003; // 3-phase kW conversion
                        Result[icount + 1] := S.im * 0.003; // 3-phase kvar conversion
                        Inc(icount, 6);
                    end;
                    Dec(iCount, 2);
                end
                else
                begin
                    for i := 0 to 2 * 3 * NTerms - 1 do
                        Result[iCount + i] := -1.0;  // Signify n/A
                        
                    Inc(iCount, 6 * NTerms);
                end;
            end
            else
            begin
                if pElem.Enabled then  
                    GetCurrents(cBuffer)
                else
                    FillByte(cBuffer^, SizeOf(Complex) * MaxNValues, 0);
            
                for j := 1 to NTerms do
                begin
                    k := (j - 1) * NConds;
                    for i := 1 to 3 do
                        Vph[i] := Solution.NodeV^[NodeRef^[i + k]];
                    for i := 1 to 3 do
                        Iph[i] := cBuffer^[k + i];

                    Phase2SymComp(@Iph, @I012);
                    Phase2SymComp(@Vph, @V012);

                    for i := 1 to 3 do
                    begin
                        S := Cmul(V012[i], conjg(I012[i]));
                        Result[icount] := S.re * 0.003; // 3-phase kW conversion
                        Result[icount + 1] := S.im * 0.003; // 3-phase kW conversion
                        Inc(icount, 2);
                    end;
                end;
            end;
            Inc(CResultPtr, 3 * pElem.NTerms);
            pElem := pList.Next;
        end;
    end;
    ReAllocMem(cBuffer, 0);

    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;

procedure PDElements_Get_AllSeqPowers_GR(); CDECL;
// Same as PDElements_Get_AllPowers but uses global result (GR) pointers
begin
    PDElements_Get_AllSeqPowers(GR_DataPtr_PDouble, GR_CountPtr_PDouble);
end;

//------------------------------------------------------------------------------
procedure _PDElements_Get_AllNum_x(var ResultPtr: PInteger; ResultCount: PAPISize; const what: Integer);
var
    idx_before, numEnabled: Integer;
    pElem: TPDElement;
    pList: TPointerList;
    pval: PInteger;
begin
    if InvalidCircuit then
    begin
        DefaultResult(ResultPtr, ResultCount, -1);
        Exit;
    end;
    pList := ActiveCircuit.PDElements;
    if pList.ListSize <= 0 then
    begin
        DefaultResult(ResultPtr, ResultCount, -1);
        Exit;
    end;
    
    idx_before := pList.ActiveIndex;
    numEnabled := pList.ListSize;
//    pElem := pList.First;
//    while pElem <> NIL do
//    begin
//        if pElem.Enabled then 
//            Inc(numEnabled);
//        pElem := pList.Next;
//    end;
    pElem := pList.First;
    
    DSS_RecreateArray_PInteger(ResultPtr, ResultCount, numEnabled);
    pval := ResultPtr;
    
    case what of
        0:
            while pElem <> NIL do
            begin
                // if pElem.Enabled then
                begin
                    pval^ := pElem.NPhases;
                    Inc(pval);
                end;
                pElem := pList.Next;
            end;
        1:
            while pElem <> NIL do
            begin
                // if pElem.Enabled then
                begin
                    pval^ := pElem.Nconds;
                    Inc(pval);
                end;
                pElem := pList.Next;
            end;
        2:
            while pElem <> NIL do
            begin
                // if pElem.Enabled then
                begin
                    pval^ := pElem.Nterms;
                    Inc(pval);
                end;
                pElem := pList.Next;
            end;
    end;
        
    if (idx_before > 0) and (idx_before <= pList.ListSize) then
        pList.Get(idx_before);
end;
//------------------------------------------------------------------------------
procedure PDElements_Get_AllNumPhases(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllNum_x(ResultPtr, ResultCount, 0);
end;

procedure PDElements_Get_AllNumPhases_GR(); CDECL;
// Same as PDElements_Get_AllNumPhases but uses global result (GR) pointers
begin
    PDElements_Get_AllNumPhases(GR_DataPtr_PInteger, GR_CountPtr_PInteger);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllNumConductors(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllNum_x(ResultPtr, ResultCount, 1);
end;

procedure PDElements_Get_AllNumConductors_GR(); CDECL;
// Same as PDElements_Get_AllNumConductors but uses global result (GR) pointers
begin
    PDElements_Get_AllNumConductors(GR_DataPtr_PInteger, GR_CountPtr_PInteger);
end;

//------------------------------------------------------------------------------
procedure PDElements_Get_AllNumTerminals(var ResultPtr: PInteger; ResultCount: PAPISize); CDECL;
begin
    _PDElements_Get_AllNum_x(ResultPtr, ResultCount, 2);
end;

procedure PDElements_Get_AllNumTerminals_GR(); CDECL;
// Same as PDElements_Get_AllNumPhases but uses global result (GR) pointers
begin
    PDElements_Get_AllNumTerminals(GR_DataPtr_PInteger, GR_CountPtr_PInteger);
end;

//------------------------------------------------------------------------------

end.
