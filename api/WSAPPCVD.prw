#include "protheus.ch"
#include "fwmvcdef.ch"
#include "restful.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} apicvd
API para inserção e consulta de produtos (SB1)

@author Daniel Mendes
@since 06/07/2020
@version 1.0
*/
//-------------------------------------------------------------------
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
        */

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
        
        /* modelo MVC
        *if oModel:VldData()
        *    lOk := oModel:CommitData()
        *    //cJson := '{"CONTA":"' + CVD->CVD_CONTA + '"';
        *    //        + ',"msg":"'  + "Sucesso"          + '"';
        *    //        +'}'
        *    ::SetResponse(cJson)
        *else
        *    ConErr(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
        *    SetRestFault(400)
        *endif
        *oModel:Destroy()
        *FreeObj(oModel)
        */
        
    else
        SetRestFault(400, "Vinculo já existente! " )
    endif

    RestArea(aAreaCVD)

    //if !Empty(cAlias)
    //    DBSelectArea(cAlias)
    //endif
else
    ConErr(cError)
    setRestFault(400)
endif

return lOk
