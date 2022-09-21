import { Injectable } from '@angular/core';

import { PoTableColumn, PoTableDetail } from '@po-ui/ng-components';

@Injectable()
export class AppComponentService  {

  getColumnCVN(): Array<PoTableColumn> {
    return [
      { property: 'filial', label: 'Filial'},
      { property: 'codigo', label: 'Codigo' },
      { property: 'descri', label: 'Descrição' },
      { property: 'versao', label: 'Versão' },
      { property: 'dtvigini', label: 'Dt Ini Vigencia' },
      { property: 'dtvigfim', label: 'Dt Fin Vigencia' },
      /*{
        property: 'status',
        type: 'label',
        width: '8%',
        labels: [
          { value: 'pendente', color: 'color-07', label: 'Pendente' },
          { value: 'transport', color: 'color-08', label: 'Aberto' },
          { value: 'production', color: 'color-11', label: 'Confirmado' }
        ]
      }*/
    ];
  }

  gerColumnCT1(): Array<PoTableColumn> {
    return [
      { property: 'conta',label: 'Conta', width: '100px' },
      { property: 'descri',label: 'Descrição', width: '200px' },

    ];
  }

  getColumnCVNDetail(): Array<PoTableColumn> {
    return [
      { property: 'contaRef',label: 'Conta Referencial', width: '100px' },
      { property: 'descricao',label: 'Descrição Cta Ref', width: '200px' },
      { property: 'classe',label: 'Classe' },
      { property: 'natcta',label: 'Natureza Conta' },
      { property: 'ctasup',label: 'Conta Superior' },
      { property: 'linha',label: 'Linha' },
    ];
  }



}