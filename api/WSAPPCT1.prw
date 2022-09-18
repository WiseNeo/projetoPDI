#Include "PROTHEUS.ch"
#Include "RESTFUL.ch"

#xtranslate @{Header <(cName)>} => ::GetHeader( <(cName)> )
#xtranslate @{Param <n>} => ::aURLParms\[ <n> \]
#xtranslate @{EndRoute} => EndCase
#xtranslate @{Route} => Do Case
#xtranslate @{When <path>} => Case NGIsRoute( ::aURLParms, <path> )
#xtranslate @{Default} => Otherwise


WsRestful apict1 Description "WebService REST para testes"

    WsMethod GET Description "Sincroniza��o de dados via GET" WsSyntax "/GET/{method}"

End WsRestful

WsMethod GET WsService apict1

Local cJson      := ''
Local nList      := 0
Local nX         := 0
Local cCorte     := 10
Local nInit      := 1
Local nTerm      := cCorte
Local aList      := {}
Local aAux       := {}
Local aUsrPass   := {}
Local aUser      := {}


    RpcSetType(3)
    RpcSetEnv('T1', 'D MG 01 ',,,'CTB')


    ::SetContentType('application/json')

        @{Route}
            @{When '/planodecontas/{id}'}
                
                aList  := fQryCt1(.F.,'')
                nDivid := Ceiling(Len(aList)/cCorte)

                For nX := 1 To nDivid
                    cJson := '['

                    For nList := nInit to Iif(nX=nDivid,Len(aList),nTerm)
                        cJson += '{'
                        cJson += '	"id":"'+aList[nList,8]+'",'
                        cJson += '	"filial":"'+aList[nList,1]+'",'
                        cJson += '	"conta":"'+aList[nList,2]+'",'
                        cJson += '	"descricao":"'+aList[nList,3]+'",'
                        cJson += '	"classe":"'+aList[nList,4]+'",'
                        cJson += '	"normal":"'+aList[nList,5]+'",'
                        cJson += '	"ntsped":"'+aList[nList,6]+'",'
                        cJson += '	"dtexist":"'+aList[nList,7]+'",'
                        cJson += '  "items": ["'+ aList[nList,9]+'"]"
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

            @{When '/searchplanodecontas/{id}'}
                aList := fQryCt1(.T.,Alltrim(Upper(::aURLParms[2])))
                cJson := '['
                
                For nList := 1 to Len(aList)
                        cJson += '{'
                        cJson += '	"id":"'+aList[nList,8]+'",'
                        cJson += '	"filial":"'+aList[nList,1]+'",'
                        cJson += '	"conta":"'+aList[nList,2]+'",'
                        cJson += '	"descricao":"'+aList[nList,3]+'",'
                        cJson += '	"classe":"'+aList[nList,4]+'",'
                        cJson += '	"normal":"'+aList[nList,5]+'",'
                        cJson += '	"ntsped":"'+aList[nList,6]+'",'
                        cJson += '	"dtexist":"'+aList[nList,7]+'",'
                        cJson += '  "items": ['+ aList[nList,9]+']
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


Static Function fQryCt1(lSearch,cSearch)

Local cAliasSQL  := GetNextAlias()
Local cAliasSQL2 := GetNextAlias()
Local cQuery     := ''
Local aRet       := {}
Local cJson      := ''
Local nX         := 1

    cQuery := " SELECT * FROM "+RetSqlName('CT1')+" "
	cQuery += " WHERE D_E_L_E_T_ = ' ' " //AND B1_MSBLQL != '1' "
    cQuery += Iif(lSearch," AND CT1_CONTA = '"+cSearch+"' ", " ")
    

    MPSysOpenQuery(cQuery,cAliasSQL)

    While (cAliasSQL)->(!EoF())
        
        Aadd(aRet,{;
            RemoveEspec((cAliasSQL)->CT1_FILIAL) ,;
            RemoveEspec((cAliasSQL)->CT1_CONTA)  ,;
            RemoveEspec((cAliasSQL)->CT1_DESC01) ,;
            RemoveEspec((cAliasSQL)->CT1_CLASSE) ,;
            RemoveEspec((cAliasSQL)->CT1_NORMAL) ,;
            RemoveEspec((cAliasSQL)->CT1_NTSPED) ,;
            RemoveEspec((cAliasSQL)->CT1_DTEXIS) ,;
              cvaltochar((cAliasSQL)->R_E_C_N_O_)  })

           //popular um array na CT1, verificando se j� tem vinculo na CVD - se j� existe na CVD 
           cQuery :=" SELECT CT1_FILIAL FILIAL, CVD_CODPLA CODPLA,CVD_VERSAO VERSAO, CT1_CONTA CONTA, CVD_CTAREF CONTAREF"
           cQuery +=" FROM "+RetSqlName('CT1')+" CT1 "
           cQuery +=" INNER JOIN "+RetSqlName('CVD')+" CVD ON CVD_FILIAL = CT1_FILIAL "
           cQuery +=" AND CT1_CONTA = CVD_CONTA "
           cQuery +=" AND CT1_CLASSE ='2' "
           if lSearch
            cQuery +=" AND CT1_CONTA = '"+cSearch+"' "
           EndIf
           cQuery +=" AND CT1.D_E_L_E_T_ = '' "
           cQuery +=" AND CVD.D_E_L_E_T_ = '' "
           cQuery +=" GROUP BY CT1_FILIAL, CVD_CODPLA,CVD_VERSAO, CT1_CONTA, CVD_CTAREF "
           cQuery +=" ORDER BY 1 "

           MPSysOpenQuery(cQuery,cAliasSQL2)
           
           dbSelectArea((cAliasSQL2))            
           (cAliasSQL2)->(DbGotop())
           
           if (cAliasSQL2)->(!EOF()) 
                While (cAliasSQL2)->(!EOF()) 
                //cJson := '['        
                     //CT1_FILIAL, CVD_CODPLA,CVD_VERSAO, CT1_CONTA, CVD_CTAREF 
                     cJson += '{'
                     cJson += '	"filial":"'+FILIAL+'",'
                     cJson += '	"codpla":"'+CODPLA+'",'
                     cJson += '	"versao":"'+VERSAO+'",'
                     cJson += '	"conta" :"'+CONTA+'",'
                     cJson += '	"contaRef":"'+CONTAREF+'"
                     cJson += '},
                 //cJson += ']'    
                     (cAliasSQL2)->(DBSKIP())
                endDo
           endIf
           (cAliasSQL2)->(DBCloseArea())
        aadd(aRet[nX],cJson)
        cJson :=''
        (cAliasSQL)->(DbSkip())
        nX++
    EndDo

Return aRet

Static Function RemoveEspec(cWord)
    cWord := OemToAnsi(AllTrim(cWord))
    cWord := FwNoAccent(cWord)
    cWord := FwCutOff(cWord)
    cWord := strtran(cWord,"�","a")
    cWord := strtran(cWord,"�","")
    cWord := strtran(cWord,"%","")
    cWord := strtran(cWord,"*","")     
    cWord := strtran(cWord,"&","")
    cWord := strtran(cWord,"$","")
    cWord := strtran(cWord,"#","")
    cWord := strtran(cWord,"�","") 
    cWord := strtran(cWord,"�","a")
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
    cWord := StrTran(cWord, '�', '')
    cWord := StrTran(cWord, '�', '')
    cWord := strtran(cWord,""+'"'+"","")
    cWord := AllTrim(cWord)
Return cWord
