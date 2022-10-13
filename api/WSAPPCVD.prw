#include "PROTHEUS.ch"
#include "RESTFUL.ch"

#xtranslate @{Header <(cName)>} => ::GetHeader( <(cName)> )
#xtranslate @{Param <n>} => ::aURLParms\[ <n> \]
#xtranslate @{EndRoute} => EndCase
#xtranslate @{Route} => Do Case
#xtranslate @{When <path>} => Case NGIsRoute( ::aURLParms, <path> )
#xtranslate @{Default} => Otherwise

WsRestful apicvd Description "WebService REST para testes"

    WsMethod POST Description "Sincronização de dados via POST"  WsSyntax "/POST/{method}"

End WsRestful

WsMethod POST WsService apicvd
    Local cJson := ::GetContent()
    Local oParser

    ::SetContentType( 'application/json' )

    @{Route}
        @{When '/'}
            If FwJsonDeserialize(cJson,@oParser)
                aAreaCVD := CVD->( GetArea() )
                CVD->(DbSetOrder(1))//CVD_FILIAL+CVD_CONTA+CVD_ENTREF+CVD_CTAREF+CVD_CUSTO+CVD_VERSAO
                If !CVD->( DbSeek( xFilial("CVD") + AvKey(oParser:conta,"CVD_CONTA") + AvKey(oParser:entref,"CVD_ENTREF") + AvKey(oParser:ctaref,"CVD_CTAREF") + AvKey(oParser:ccusto,"CVD_CUSTO") + AvKey(oParser:versao,"CVD_VERSAO")) )
                    RecLock('CVD',.T.)
                        CVD->CVD_FILIAL := xFilial("CVD")
                        CVD->CVD_CONTA  := oParser:conta
                        CVD->CVD_ENTREF := oParser:entref 
                        CVD->CVD_CODPLA := oParser:codpla 
                        CVD->CVD_CTAREF := oParser:ctaref
                        CVD->CVD_CLASSE := oParser:classe
                        CVD->CVD_CUSTO  := oParser:ccusto
                        CVD->CVD_TPUTIL := oParser:tputil
                        CVD->CVD_VERSAO := oParser:versao
                        CVD->CVD_NATCTA := oParser:natcta
                        CVD->CVD_CTASUP := oParser:ctasup  
                    CVD->(MSunlock())

                    cJson := "{'conta':' " + CVD->CVD_CONTA + "',"
                    cJson += "'msg':'Sucesso'"
                    cJson += "}"

                    ::SetResponse(cJson)
                Else
                    SetRestFault(400, "Vinculo já existente! " )
                EndIf

            Else
                SetRestFault(400,'Ops')
                Return .F.
            EndIf
        @{Default}
            SetRestFault(400,"Ops")
            Return .F.
    @{EndRoute}
Return .T.



/*
WSRESTFUL apicvd DESCRIPTION "Serviço REST para manipulação da CVD"

   // WSDATA CodProduto As String

    WSMETHOD POST DESCRIPTION "Retorna o produto informado na URL" WSSYNTAX "/apicvd" PATH "/apicvd" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST WSSERVICE apicvd
local jCvd
local cError as char
local cJson as char
local cAlias as char
local lOk as logical
local aAreaCVD as array

Self:SetContentType("application/json")

jCvd := JsonObject():New()
cError := jCvd:fromJson( self:getContent() )
lOk := .F.

if Empty(cError)
    aAreaCVD := CVD->( GetArea() )
    //cAlias := Alias()
    CVD->(DbSetOrder(1))//CVD_FILIAL+CVD_CONTA+CVD_ENTREF+CVD_CTAREF+CVD_CUSTO+CVD_VERSAO
    if !CVD->( DbSeek( xFilial("CVD") + jCvd["conta"] + jCvd["entref"] + jCvd["ctaref"] + jCvd["ccusto"] + jCvd["versao"]) )
        
        /* modelo MVC
        * oModel := FwLoadModel("CTBA020")
        * oModel:setOperation(MODEL_OPERATION_INSERT)
        * oModel:Activate()
        * oModel:setValue("CT1MASTER", "B1_COD", jCvd["conta"])
        */
        /* JSON MODELO
        "conta":  "101010101           ",
        "entref": "10",
        "codpla": "000010",
        "ctaref": "1.01.01.01.01                 ",
        "classe": "2",
        "ccusto": "",
        "tputil": "A",
        "versao": "0001",
        "natcta": "01",
        "ctasup": "1.01.01.01                    "
        *//*

        RecLock('CVD',.T.)
        CVD->CVD_FILIAL := xFilial("CVD")
		CVD->CVD_CONTA  := jCvd["conta"]
		CVD->CVD_ENTREF := jCvd["entref"]
		CVD->CVD_CODPLA := jCvd["codpla"]
		CVD->CVD_CTAREF := jCvd["ctaref"]
		CVD->CVD_CLASSE := jCvd["classe"] 
		CVD->CVD_CUSTO  := jCvd["ccusto"]
		CVD->CVD_TPUTIL := jCvd["tputil"]
		CVD->CVD_VERSAO := jCvd["versao"]
		CVD->CVD_NATCTA := jCvd["natcta"]
		CVD->CVD_CTASUP := jCvd["ctasup"]    
        CVD->(MSunlock())

        cJson := "{'conta':' " + CVD->CVD_CONTA + "',"
        cJson += "'msg':'Sucesso'"
        cJson += "}"    
        ::SetResponse(cJson)
        
      
    else
        SetRestFault(400, "Vinculo já existente! " )
    endif

    RestArea(aAreaCVD)

else
    ConErr(cError)
    setRestFault(400)
endif

return lOk
*/
