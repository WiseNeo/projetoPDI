#Include "protheus.ch"
#INCLUDE "TBICONN.CH"

STATIC _oCTBAX001
STATIC lUsaProc := .F.
STATIC __aRptLog := {}

/*/{Protheus.doc} CTBX001
    (long_description)
    @type  Function
    @author Douglas Rodrigues da Silva
    @since 29/09/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

Function CTBX001()
    
    Local lUsaProc  := .F.
    Local nSeconds
    //FILIAL, CONTA, ENTREF, CODPLA, CTAREF, CUSTO, TPUTIL, CLASSE, NATCTA, CTASUP, VERSAO, D_E_L_E_T_ 
    Local aCampos	:= {{"FILIAL"	,TamSX3("CVD_FILIAL")[3],TamSX3("CVD_FILIAL")[1],0},;					
                        {"CONTA"	,TamSX3("CVD_CONTA")[3] ,TamSX3("CVD_CONTA") [1],0},;
                        {"ENTREF"	,TamSX3("CVD_ENTREF")[3],TamSX3("CVD_ENTREF")[1],0},;
                        {"CODPLA"	,TamSX3("CVD_CODPLA")[3],TamSX3("CVD_CODPLA")[1],0},;
                        {"CTAREF"	,TamSX3("CVD_CTAREF")[3],TamSX3("CVD_CTAREF")[1],0},;
                        {"CUSTO"	,TamSX3("CVD_CUSTO")[3] ,TamSX3("CVD_CUSTO") [1],0},;
                        {"TPUTIL"	,TamSX3("CVD_TPUTIL")[3],TamSX3("CVD_TPUTIL")[1],0},;
                        {"CLASSE"	,TamSX3("CVD_CLASSE")[3],TamSX3("CVD_CLASSE")[1],0},;
                        {"NATCTA"	,TamSX3("CVD_NATCTA")[3],TamSX3("CVD_NATCTA")[1],0},;
                        {"CTASUP"	,TamSX3("CVD_CTASUP")[3],TamSX3("CVD_CTASUP")[1],0},;
                        {"VERSAO"	,TamSX3("CVD_VERSAO")[3],TamSX3("CVD_VERSAO")[1],0}}

    //-----------------------------------------------------
    // Crio tabela temporaroa p/ gravar as inconsistencias
    //-----------------------------------------------------
    CriaTmp(aCampos)

    nSeconds := Seconds()
	Conout("INICIO" + "|" + dtoc(dDatabase) + "|" + Time() + "|" + AllTrim(Str(nSeconds))) //"INICIO"

    // efetuo a criação da procedure que irá alimentar os dados para o relatorio.
    lUsaProc := CtbCriaProc()

    //Inclusão de Registros
    Ctbx001GrInc(xFilial("CVD")             ,;
                        "01234"             ,;
                        "10"                ,;
                        "000001"            ,;
                        "3.11.01.11.01.07"  ,;
                        "00001"             ,;
                        "A"                 ,;
                        "2"                 ,;
                        "01"                ,;
                        "1.01"              ,;
                        "0001" )

Return 

/*-------------------------------------------------------------------------
Funcao        : CriaTmp
Autor         : Renato Campos
Data          : 11/08/2012
Uso           : Cria a tabela temporaria a ser usada na impressão do relatorio
-------------------------------------------------------------------------*/
Static Function CriaTmp( aCampos)
Local aArea	:= GetArea()
Local cArqAlias	:= "CTBAX001"

//DeleteTmp()

    _oCTBAX001 := FWTemporaryTable():New(cArqAlias)
    _oCTBAX001:SetFields(aCampos)
    _oCTBAX001:AddIndex("1",{"FILIAL","CONTA","ENTREF"})

    _oCTBAX001:Create()

RestArea(aArea)

Return

/*-------------------------------------------------------------------------
Funcao        : DeleteTmp
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de exclusão do temporario do banco
-------------------------------------------------------------------------*/
Static Function DeleteTmp()

Local aArea := GetArea()

If _oCTBAX001 <> Nil
	_oCTBAX001:Delete()
	_oCTBAX001 := Nil
Endif

RestArea(aArea)

Return

/*-------------------------------------------------------------------------
Funcao		  : CtbCriaProc()
Autor         : Douglas Silva
Data          : 29/09/2022
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbCriaProc()

Local cQuery	:= ""
Local nPTratRec	:= 0
Local lOk		:= .T.
Local cNomeTab	:= ""

//----------------------------------------------------------------------------------------------
// Exclusao da procedure pois o FWTemporaryTable fornece um novo nome de tabela a cada execucao
//----------------------------------------------------------------------------------------------
If TCSPExist("CTBAX001_" + cEmpAnt )
	CtbSqlExec( "Drop procedure CTBAX001_" + cEmpAnt )
Endif	

//-----------------------------
// Obtem o nome real da tabela
//-----------------------------
If _oCTBAX001 <> Nil
	cNomeTab := _oCTBAX001:GetRealName()
EndIf

    cQuery := "Create Procedure CTBAX001_" + cEmpAnt + "(" + CRLF
    cQuery += "    @IN_FILIAL   Char( " + StrZero(TAMSX3('CVD_FILIAL'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CONTA    Char( " + StrZero(TAMSX3('CVD_CONTA'    )[1],2) + " )," + CRLF
    cQuery += "    @IN_ENTREF   Char( " + StrZero(TAMSX3('CVD_ENTREF'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CODPLA   Char( " + StrZero(TAMSX3('CVD_CODPLA'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CTAREF   Char( " + StrZero(TAMSX3('CVD_CTAREF'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CUSTO    Char( " + StrZero(TAMSX3('CVD_CUSTO'    )[1],2) + " )," + CRLF
    cQuery += "    @IN_TPUTIL   Char( " + StrZero(TAMSX3('CVD_TPUTIL'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CLASSE   Char( " + StrZero(TAMSX3('CVD_CLASSE'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_NATCTA   Char( " + StrZero(TAMSX3('CVD_NATCTA'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_CTASUP   Char( " + StrZero(TAMSX3('CVD_CTASUP'   )[1],2) + " )," + CRLF
    cQuery += "    @IN_VERSAO   Char( " + StrZero(TAMSX3('CVD_VERSAO'   )[1],2) + " )," + CRLF
    cQuery += "    @OUT_RESULT    Char( 01 ) OutPut" + CRLF
    cQuery += "    " + CRLF
    cQuery += ")" + CRLF
    cQuery += "as" + CRLF
    cQuery += "    " + CRLF
    cQuery += "begin" + CRLF
    cQuery += "    select @OUT_RESULT = '0'" + CRLF
    cQuery += "    " + CRLF
    cQuery += "    begin tran" + CRLF
    cQuery += "    INSERT INTO TRBX001 ( FILIAL, CONTA, ENTREF, CODPLA, CTAREF, CUSTO, TPUTIL, CLASSE, NATCTA, CTASUP, VERSAO, D_E_L_E_T_ ) " + CRLF
    cQuery += "    VALUES ( @IN_FILIAL, @IN_CONTA, @IN_ENTREF, @IN_CODPLA, @IN_CTAREF, @IN_CUSTO, @IN_TPUTIL, @IN_CLASSE, @IN_NATCTA, @IN_CTASUP, @IN_VERSAO, ' ' )" + CRLF
    cQuery += "    commit tran " + CRLF
    cQuery += "    " + CRLF
    cQuery += "    select @OUT_RESULT = '1'" + CRLF
    cQuery += "End" + CRLF
    cQuery += "    " + CRLF

    cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
    cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())),.F.)
    cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

    //---------------------------------------------------------------------------------------------------------
    // Esta adequacao foi implementada pois o nome real da tabela criada no SQL fazia o MSParse apagar a query
    //---------------------------------------------------------------------------------------------------------
    cQuery := StrTran( cQuery,"TRBX001",cNomeTab)

    If !TCSPExist( "CTBAX001_" + cEmpAnt )
        lOk := CtbSqlExec(cQuery)
    EndIf

Return lOk

/*-------------------------------------------------------------------------
Funcao        : CtbSqlExec
Autor         : Douglas Rodrigues da Silva
Data          : 29/09/2022
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno	:= .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( "Erro na instrução de execução do SQL" + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement ) 
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CT350GrInc³ Autor ³ Simone Mie Sato       ³ Data ³ 14.05.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as Inconsistencias no Arq. de Trabalho.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT350GrInc(dData,cLote,cDoc,cMoeda,nVlrDeb,nVlrCrd,cDescInc)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba350                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = FILIAL                                               ³±±
±±³          ³ ExpC1 = CONTA                                                ³±±
±±³          ³ ExpC2 = ENTREF                                               ³±±
±±³          ³ ExpC3 = CODPLA                                               ³±±
±±³          ³ ExpN1 = CTAREF                                               ³±±
±±³          ³ ExpN2 = CUSTO                                                ³±±
±±³          ³ ExpC4 = TPUTIL                                               ³±±
±±³          ³ ExpC4 = CLASSE                                               ³±±
±±³          ³ ExpC4 = NATCTA                                               ³±±
±±³          ³ ExpC4 = VERSAO                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
         
Function Ctbx001GrInc(cFILIAL,cCONTA,cENTREF,cCODPLA,cCTAREF,cCUSTO,cTPUTIL,cCLASSE,cNATCTA,cCTASUP,cVERSAO)

    Local aResult       := {}

    Default cFILIAL 	:= ""
    Default cCONTA 		:= ""
    Default cENTREF 	:= ""
    Default cCODPLA 	:= ""
    Default cCTAREF		:= ""
    Default cCUSTO 		:= ""
    Default cTPUTIL	    := ""
    Default cCLASSE	    := ""
    Default cNATCTA	    := ""
    Default cCTASUP	    := ""
    Default cVERSAO	    := ""

    __aRptLog := {}

If TCSPExist("CTBAX001_" + cEmpAnt )

	lUsaProc := .T.	
	aResult := TCSPEXEC( "CTBAX001_" + cEmpAnt,  cFILIAL, cCONTA, cENTREF, cCODPLA, cCTAREF, cCUSTO, cTPUTIL, cCLASSE, cNATCTA, cCTASUP, cVERSAO)

	If Empty(aResult)
  		conout("Falha na chamada do processo de inclusão dos dados para o relatorios. Gravação será efetuada de forma padrão.") 
   		lUsaProc := .F.
	EndIf

EndIf

//Se não conseguir utilizar a procedure
IF !lUsaProc
	If Valtype(__aRptLog) # "A" 
		__aRptLog := {}
	Endif
  
	If aScan( __aRptLog , { |x| 	x[1] == cFILIAL .And. ;
									x[1] == cCONTA .And. ;
									x[2] == cENTREF .And. ;
									x[3] == cCODPLA .And. ;
									x[4] == cCTAREF .And. ;
									x[5] == cCUSTO .And. ;
									x[6] == cTPUTIL .And. ;
									x[7] == cCLASSE .And. ;
                                    x[7] == cNATCTA .And. ;
                                    x[7] == cCTASUP .And. ;
                                    x[7] == cVERSAO } ) == 0
	
		aAdd(__aRptLog,{cFILIAL,cCONTA,cENTREF,cCODPLA,cCTAREF,cCUSTO,cTPUTIL,cCLASSE,cNATCTA,cCTASUP,cVERSAO })
	
		If Select("CTBAX001") <= 0
			dbUseArea( .T., "TOPCONN", "CTBAX001", "CTBAX001", .F., .F. )
			TcRefresh("CTBAX001")
		Endif

		dbSelectArea("CTBAX001")
		Reclock("CTBAX001",.T.)

		CTBAX001->FILIAL	:= cFILIAL
		CTBAX001->CONTA	    := cCONTA 
		CTBAX001->ENTREF	:= cENTREF
		CTBAX001->CODPLA	:= cCODPLA
		CTBAX001->CTAREF    := cCTAREF
		CTBAX001->CUSTO	    := cCUSTO 
		CTBAX001->TPUTIL	:= cTPUTIL
		CTBAX001->CLASSE	:= cCLASSE
        CTBAX001->NATCTA	:= cNATCTA
        CTBAX001->CTASUP	:= cCTASUP
        CTBAX001->VERSAO	:= cVERSAO
        
		MsUnlock()
	Endif
EndIf


Return
