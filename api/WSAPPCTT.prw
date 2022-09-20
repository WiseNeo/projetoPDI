#Include "PROTHEUS.ch"
#Include "RESTFUL.ch"

#xtranslate @{Header <(cName)>} => ::GetHeader( <(cName)> )
#xtranslate @{Param <n>} => ::aURLParms\[ <n> \]
#xtranslate @{EndRoute} => EndCase
#xtranslate @{Route} => Do Case
#xtranslate @{When <path>} => Case NGIsRoute( ::aURLParms, <path> )
#xtranslate @{Default} => Otherwise


WsRestful apictt Description "WebService REST para testes"

    WsMethod GET Description "Sincronização de dados via GET" WsSyntax "/GET/{method}"

End WsRestful

WsMethod GET WsService apictt

Local cJson      := ''
Local nList      := 0
Local nX         := 0
Local cCorte     := 20
Local nInit      := 1
Local nTerm      := cCorte
Local aList      := {}
Local aAux       := {}

    RpcSetType(3)
    RpcSetEnv('T1', 'D MG 01 ',,,'CTB')

    ::SetContentType('application/json')

        @{Route}
            @{When '/centrodecustos/{id}'}
                
                aList  := fQryCtt(.F.,'')
                nDivid := Ceiling(Len(aList)/cCorte)

                For nX := 1 To nDivid
                    cJson := '['

                    For nList := nInit to Iif(nX=nDivid,Len(aList),nTerm)
                        cJson += '{'
                        cJson += '	"id":"'+aList[nList,3]+'",'
                        cJson += '	"ccusto":"'+aList[nList,1]+'",'
                        cJson += '	"descricao":"'+aList[nList,2]+'"'
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

            @{When '/searchcentrodecustos/{id}'}
                aList := fQryCtt(.T.,Alltrim(Upper(::aURLParms[2])))
                cJson := '['
                
                For nList := 1 to Len(aList)
                        cJson += '{'
                        cJson += '	"id":"'+aList[nList,3]+'",'
                        cJson += '	"ccusto":"'+aList[nList,1]+'",'
                        cJson += '	"descricao":"'+aList[nList,2]+'"'
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


Static Function fQryCtt(lSearch,cSearch)

Local cAliasSQL  := GetNextAlias()
Local cQuery     := ''
Local aRet       := {}

    cQuery := " SELECT CTT_CUSTO,CTT_DESC01,R_E_C_N_O_ FROM " + RetSQLName("CTT") + "   " 
    cQuery += " WHERE D_E_L_E_T_ = ' '  " 
    cQuery += " AND CTT_BLOQ != '1'  " 
    cQuery += " AND CTT_CLASSE = '2'  " 
    cQuery += " AND CTT_FILIAL = '"+cFilAnt+"'  " 
    cQuery += Iif(lSearch," AND CTT_CUSTO+UPPER(CTT_DESC01) like '%"+Upper(cSearch)+"%' ", " ")
    cQuery += " ORDER BY 3  " 

    MPSysOpenQuery(cQuery,cAliasSQL)

    While (cAliasSQL)->(!EoF())

        Aadd(aRet,{;
            RemoveEspec((cAliasSQL)->CTT_CUSTO) ,;
            RemoveEspec((cAliasSQL)->CTT_DESC01),;
            cvaltochar((cAliasSQL)->R_E_C_N_O_) })

        (cAliasSQL)->(DbSkip())
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
