import { Injectable } from '@angular/core';

import { PoTableColumn, PoTableDetail } from '@po-ui/ng-components';

@Injectable()
export class AppComponentService  {

  getColumns(): Array<PoTableColumn> {
    return [
      { property: 'id', type: 'number', width: '8%' },
      { property: 'product' },
      { property: 'customer' },
      { property: 'time_since_purchase', label: 'Time since purchase', type: 'time', visible: false },
      { property: 'quantity', label: 'Quantity (Tons)', type: 'number', width: '15%', visible: false },
      { property: 'icms', label: 'ICMS', type: 'number', format: '1.2-5', visible: false },
      {
        property: 'status',
        type: 'label',
        width: '8%',
        labels: [
          { value: 'pendente', color: 'color-07', label: 'Pendente' },
          { value: 'transport', color: 'color-08', label: 'Aberto' },
          { value: 'production', color: 'color-11', label: 'Confirmado' }
        ]
      }
    ];
  }

  getColumns1(): Array<PoTableColumn> {
    return [
      { property: 'conta',label: 'Conta', width: '100px' },
      { property: 'descri',label: 'Descrição', width: '200px' },

    ];
  }

  getColumns2(): Array<PoTableColumn> {
    return [
      { property: 'conta',label: 'Conta', width: '100px' },
      { property: 'descri',label: 'Descrição', width: '200px' }
    ];
  }

  getItems(): Array<any> {
    return [
      {
        id: 1200,
        product: 'Rice',
        customer: 'Angeloni',
        status: 'pendente',
        subItm:[]
      },
      {
        id: 1355,
        product: 'Margarine',
        customer: 'Giassi',
        status: 'transport',
        subItm:[]
      },

      {
        id: 1712,
        product: 'Milk',
        customer: 'Carrefour',
        status: 'production',
        subItm:[]
      }
    ];
  }

  getItems1() {
    return [
      {
        id: 5325,
        conta: '11111111',
        descri: 'Conta teste 11111111',
      },
      {
        id: 22467,
        conta: '222222222',
        descri: 'Conta teste 222222222',
      },
      {
        id: 40670,
        conta: '33333333',
        descri: 'Conta teste 33333333',
      },
      {
        id: 34679,
        conta: '44444444',
        descri: 'Conta teste 44444444',
      }
    
    ];
  }


}