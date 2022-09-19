#Include "PROTHEUS.ch"
#Include "RESTFUL.ch"

#xtranslate @{Header <(cName)>} => ::GetHeader( <(cName)> )
#xtranslate @{Param <n>} => ::aURLParms\[ <n> \]
#xtranslate @{EndRoute} => EndCase
#xtranslate @{Route} => Do Case
#xtranslate @{When <path>} => Case NGIsRoute( ::aURLParms, <path> )
#xtranslate @{Default} => Otherwise


WsRestful apicvn Description "WebService REST para testes"

    WsMethod GET Description "Sincronização de dados via GET" WsSyntax "/GET/{method}"

End WsRestful

WsMethod GET WsService apicvn

Local cJson      := ''
Local nList      := 0
Local nX         := 0
Local cCorte     := 10
Local nInit      := 1
Local nTerm      := cCorte
Local aList      := {}
Local aAux       := {}

    RpcSetType(3)
    RpcSetEnv('T1', 'D MG 01 ',,,'CTB')


    ::SetContentType('application/json')

        @{Route}
            @{When '/cabcvn/{id}'}
                
                aList  := fQryCabCvn(.F.,'')
                nDivid := Ceiling(Len(aList)/cCorte)

                For nX := 1 To nDivid
                    cJson := '['
                    //CVN_FILIAL,CVN_CODPLA,CVN_VERSAO,CVN_DTVIGI,CVN_DTVIGF,CVN_ENTREF,CVN_DSCPLA
                    For nList := nInit to Iif(nX=nDivid,Len(aList),nTerm)
                        cJson += '{'
                        cJson += '	"filial":"'+aList[nList,1]+'",'
                        cJson += '	"codigo":"'+aList[nList,2]+'",'
                        cJson += '	"versao":"'+aList[nList,3]+'",'
                        cJson += '	"dtvigini":"'+aList[nList,4]+'",'
                        cJson += '	"dtvigfim":"'+aList[nList,5]+'",'
                        cJson += '	"entref":"'+aList[nList,6]+'",'
                        cJson += '	"descricao":"'+aList[nList,7]+'",'
                        cJson += '  "items": ['+ aList[nList,8]+']
                        cJson += '},'
                    Next nList

                    nInit := nInit+cCorte
                    nTerm := nTerm+cCorte
                    cJson := Left(cJson, RAT(",", cJson) - 1)
                    cJson += ']'

                    Aadd(aAux,cJson)
                Next nX

                If Val(::aURLParms[2]) <= Len(aAux)
                    ::SetResponse(aAux[Val(::aURLParms[2])])
                Else
                    SetRestFault(400,'Ops')
                EndIf

            @{When '/searchcabcvn/{id}'}
                aList := fQryCabCvn(.T.,Alltrim(Upper(::aURLParms[2])))
                cJson := '['
                
                For nList := 1 to Len(aList)
                    cJson += '{'
                    cJson += '	"filial":"'+aList[nList,1]+'",'
                    cJson += '	"codigo":"'+aList[nList,2]+'",'
                    cJson += '	"versao":"'+aList[nList,3]+'",'
                    cJson += '	"dtvigini":"'+aList[nList,4]+'",'
                    cJson += '	"dtvigfim":"'+aList[nList,5]+'",'
                    cJson += '	"entref":"'+aList[nList,6]+'",'
                    cJson += '	"descricao":"'+aList[nList,7]+'",'
                    cJson += '  "items": ['+ aList[nList,8]+']
                    cJson += '},'
                Next nList

                cJson := Left(cJson, RAT(",", cJson) - 1)
                cJson += ']'
                
                If Len(aList)>0
                    ::SetResponse(cJson)
                Else
                    ::SetResponse('[]')
                EndIf
                
            @{Default}
                SetRestFault(400,"Ops")
                Return .F.    
        @{EndRoute}

Return .T.


Static Function fQryCabCvn(lSearch,cSearch)

Local cAliasSQL  := GetNextAlias()
Local cQuery     := ''
Local aRet       := {}
Local cJson      := ''
Local nX         := 1

    cQuery := " SELECT CVN_FILIAL,CVN_CODPLA,CVN_DSCPLA,CVN_DTVIGI,CVN_DTVIGF,CVN_ENTREF,CVN_VERSAO
    cQuery += " FROM "+RetSqlName('CVN')+" "
    cQuery += " WHERE D_E_L_E_T_=''
    //cQuery += " AND CVN_DTVIGF >= '"+dtos(date())+"'
    cQuery += Iif(lSearch," AND CVN_FILIAL = '"+cSearch+"'", " ")
    cQuery += " GROUP BY CVN_FILIAL,CVN_CODPLA,CVN_DSCPLA,CVN_DTVIGI,CVN_DTVIGF,CVN_ENTREF,CVN_VERSAO  
    //filtrar somentes os corretos
    cQuery += " ORDER BY 1"
    

    MPSysOpenQuery(cQuery,cAliasSQL)

    While (cAliasSQL)->(!EoF())
        Aadd(aRet,{;
            RemoveEspec((cAliasSQL)->CVN_FILIAL),;
            RemoveEspec((cAliasSQL)->CVN_CODPLA),;
            RemoveEspec((cAliasSQL)->CVN_VERSAO),;
            RemoveEspec((cAliasSQL)->CVN_DTVIGI),;
            RemoveEspec((cAliasSQL)->CVN_DTVIGF),;
            RemoveEspec((cAliasSQL)->CVN_ENTREF),;
            RemoveEspec((cAliasSQL)->CVN_DSCPLA) })

            dbSelectArea('CVN')            
            CVN->(DbSetOrder(5))//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_LINHA    
            CVN->(DbGoTop())
            CVN->(MsSeek((cAliasSQL)->CVN_FILIAL+(cAliasSQL)->CVN_CODPLA+(cAliasSQL)->CVN_VERSAO))
            
            While CVN->(!EOF()) .and. (cAliasSQL)->CVN_FILIAL+(cAliasSQL)->CVN_CODPLA+(cAliasSQL)->CVN_VERSAO == CVN->CVN_FILIAL+CVN->CVN_CODPLA+CVN->CVN_VERSAO //.and. CVN->CVN_CLASSE =='2'
                    
                    //CVN_TPUTIL CVN_CTAREL	CVN_STAPLA                    
                    cJson := '{'
                    cJson += '	"id":"'       +cValToChar(CVN->(RECNO()))+'",'
                    cJson += '	"contaRef":"' +RemoveEspec(CVN->CVN_CTAREF)+'",'
                    cJson += '	"descricao":"'+RemoveEspec(CVN->CVN_DSCCTA)+'",'
                    cJson += '	"classe":"'   +RemoveEspec(CVN->CVN_CLASSE)+'",'
                    cJson += '	"natcta":"'   +RemoveEspec(CVN->CVN_NATCTA)+'",'
                    cJson += '	"ctasup":"'   +RemoveEspec(CVN->CVN_CTASUP)+'",'
                    cJson += '	"linha":"'    +RemoveEspec(CVN->CVN_LINHA) +'"'
                    cJson += '},

                    
                  CVN->(DBSKIP())  
            endDo
        cJson := Left(cJson, RAT(",", cJson) - 1)
        aadd(aRet[nX],cJson)    
        cJson      := ''
        (cAliasSQL)->(DbSkip())
        nX++
    EndDo

Return aRet


Static Function RemoveEspec(cWord)
    cWord := OemToAnsi(AllTrim(cWord))
    cWord := FwNoAccent(cWord)
    cWord := FwCutOff(cWord)
    cWord := strtran(cWord,"ã","a")
    cWord := strtran(cWord,"º","")
    cWord := strtran(cWord,"%","")
    cWord := strtran(cWord,"*","")     
    cWord := strtran(cWord,"&","")
    cWord := strtran(cWord,"$","")
    cWord := strtran(cWord,"#","")
    cWord := strtran(cWord,"§","") 
    cWord := strtran(cWord,"ä","a")
    cWord := strtran(cWord,",","")
    cWord := strtran(cWord,".","")
    cWord := StrTran(cWord, "'", "")
    cWord := StrTran(cWord, "#", "")
    cWord := StrTran(cWord, "%", "")
    cWord := StrTran(cWord, "*", "")
    cWord := StrTran(cWord, "&", "E")
    cWord := StrTran(cWord, ">", "")
    cWord := StrTran(cWord, "<", "")
    cWord := StrTran(cWord, "!", "")
    cWord := StrTran(cWord, "@", "")
    cWord := StrTran(cWord, "$", "")
    cWord := StrTran(cWord, "(", "")
    cWord := StrTran(cWord, ")", "")
    cWord := StrTran(cWord, "_", "")
    cWord := StrTran(cWord, "=", "")
    cWord := StrTran(cWord, "+", "")
    cWord := StrTran(cWord, "{", "")
    cWord := StrTran(cWord, "}", "")
    cWord := StrTran(cWord, "[", "")
    cWord := StrTran(cWord, "]", "")
    cWord := StrTran(cWord, "?", "")
    cWord := StrTran(cWord, ".", "")
    cWord := StrTran(cWord, "\", "")
    cWord := StrTran(cWord, "|", "")
    cWord := StrTran(cWord, ":", "")
    cWord := StrTran(cWord, ";", "")
    cWord := StrTran(cWord, '"', '')
    cWord := StrTran(cWord, '°', '')
    cWord := StrTran(cWord, 'ª', '')
    cWord := strtran(cWord,""+'"'+"","")
    cWord := AllTrim(cWord)
Return cWord
