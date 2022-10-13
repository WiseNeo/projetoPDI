import { Component, ViewChild, OnInit } from '@angular/core';
import { AppComponentService } from './app.component.service';
import { HttpClient } from '@angular/common/http'
import { ProAppConfigService } from '@totvs/protheus-lib-core';
import { BehaviorSubject, debounceTime, distinctUntilChanged, first, map as mapObservable, Observable, Subject, takeUntil, takeWhile, throttleTime } from 'rxjs';


import { 
  PoMenuItem,
  PoModalAction,
  PoModalComponent,
  PoNotificationService,
  PoTableColumn,
  PoTableComponent
} from '@po-ui/ng-components';
import { NumberValueAccessor } from '@angular/forms';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  providers: [AppComponentService],
  styleUrls: ['./app.component.css']
})

export class AppComponent implements OnInit {

  inputSearchCT1: string = '';
  CCusto: String = '';
  menuItemSelected: string | any;
  idPrimSelec: number = 0;
  indexPrimSelec: number = 0;
  idSecSelec: number = 0;
  indexSecSelec: number = 0;
  idCvdSelect: number = 0;
  hideLoadCT1 = false;
  hideLoadCTT = true;
  hideLoadCVN = false;

  columnCVN: Array<PoTableColumn> = this.servicemenu.getColumnCVN();
  columnCT1: Array<PoTableColumn> = this.servicemenu.gerColumnCT1();
  columnsCVNDetail: Array<PoTableColumn> = this.servicemenu.getColumnCVNDetail();

  items: Array<any> = []
  itemCT1: Array<any> = []
  itemCTT: Array<any> = []

  @ViewChild(PoModalComponent, { static: true }) poModal: PoModalComponent | any;
  @ViewChild(PoTableComponent, { static: true }) poTable: PoTableComponent | any;

  public readonly columnCVD: Array<PoTableColumn> = [
    { property: 'conta', label: 'Conta', width: '10%' },
    { property: 'desccta', label: 'Descrição Conta', width: '30%' },
    {
      property: 'ccusto',
      label: 'Centro de Custo',
      type: 'link',
      action: (value: any, row: any) => {
        this.hideLoadCTT = false
        this.loadCTT(row)
      },
    }
  ];

  public readonly columnCTT: Array<PoTableColumn> = [
    { property: 'ccusto', label: 'Centro de Custo', width: '40%' },
    { property: 'descri', label: 'Descrição', width: '60%' }
  ];

  constructor(
    public http: HttpClient,
    public poNotification: PoNotificationService,
    public servicemenu: AppComponentService,
    private proAppConfigService: ProAppConfigService
    ) {}

    private closeApp() {
      if (this.proAppConfigService.insideProtheus()) {
          this.proAppConfigService.callAppClose();
      } else {
          alert('O App não está sendo executado dentro do Protheus.');
      }
  }


  close: PoModalAction = {
    action: () => {
      this.closeModal();
    },
    label: 'Close',
    danger: true
  };

  confirm: PoModalAction = {
    action: () => {
      this.confirmModal();
    },
    label: 'Confirm'
  };


  menus: Array<PoMenuItem> = [
    { 
      label: 'Home',
      action: this.printMenuAction.bind(this),
      icon: 'po-icon po-icon-home',
      shortLabel: 'Home'
    },
    { 
      label: 'Plano de Contas',
      action: this.printMenuAction.bind(this),
      icon: 'po-icon po-icon-document-filled',
      shortLabel: 'P. Contas'
    },
  ];

  innerWidth: any;

  ngOnInit() {
    this.innerWidth = window.innerWidth;
    this.updateHeight(this.innerWidth);

    this.restore()
    this.loadCT1()
    this.loadCVN()
  }


    // Ajusta a altura da tabela de acordo com a resolução
  /* istanbul ignore next */
  updateHeight(height: number) {

    let adjustheight: number = 0
    if (height <= 1200) {
      adjustheight = 300;
    } else if (height >= 1201 && height <= 1899) {
      adjustheight = 400;
    } else if (height >= 1900 && height <= 2190) {
      adjustheight = 700;
    } else if (height >= 2191) {
      adjustheight = 800;
    }
    return adjustheight
  }

  isUndelivered(row: any, index: number) {
    return row.subItm.length > 0
  }
  

  closeModal() {
    this.poModal.close();
  }

  confirmModal(){
    const auxCvd = this.items[this.indexPrimSelec]
      .subItm[this.indexSecSelec]
      .cvditem

    auxCvd.filter((item: any, index: number) =>{
      if(item.id === this.idCvdSelect){
        this.items[this.indexPrimSelec]
          .subItm[this.indexSecSelec]
          .cvditem[index].ccusto = this.CCusto
      }
    })

    this.poModal.close()
  }

  check() {
    if(this.idPrimSelec > 0){
      let itemAux: any = []

      this.itemCT1.map((event) => {
        if(!!event.$selected){
          event.$selected = false
          
          itemAux.push({
            id: event.id,
            conta: event.conta,
            desccta: event.descri,
            ccusto: 'Selecione'
          })       
        }
      })
      
      if(itemAux.length > 0){
        this.items[this.indexPrimSelec]
          .subItm[this.indexSecSelec]
          .cvditem.forEach((element: any) => {
          itemAux.push(element)
        });
        
        const ids = itemAux.map((o: any) => o.id)
        const filtered = itemAux.filter(({id}: any, index: any) => !ids.includes(id, index + 1))
        
        this.items[this.indexPrimSelec]
          .subItm[this.indexSecSelec]
          .cvditem = filtered.length > 0 ? filtered : itemAux
      }
      
    }else {
      this.poNotification.warning('Nenhum item do Plano de Contas Referencial (CVN) foi selecionado...')
    }
  }

  selectedItem(row: any){
    this.idPrimSelec = row.id
  }

  unselectedItem(){
    this.idPrimSelec = 0
  }

  selecCTT(row: any){
    this.CCusto = row.ccusto
  }

  unSelecCTT(){
    this.CCusto = ''
  }

  printMenuAction(menu: PoMenuItem) {
    this.menuItemSelected = menu.label;
    alert(this.menuItemSelected)
  }

  saveForm() {
    //this.collapseAll();
    this.idPrimSelec = 0
    this.indexPrimSelec = 0
    this.idSecSelec = 0
    this.indexSecSelec = 0
    this.idCvdSelect = 0
  }

  showItem(row:any){
    this.items.forEach((item) =>{
      item.$selected = false
    })
    this.items.filter((item,index) =>{
      
      if(row.id === item.id){
        this.items[index].$selected = true
        this.idPrimSelec = item.id
        this.indexPrimSelec = index
      }
    })
  }

  showSecItem(row:any){
    this.items[this.indexPrimSelec].subItm.map((item: any,index: number) =>{

      if(row.id === item.id){
        this.items[this.indexPrimSelec].subItm[index].$selected = true
        this.idSecSelec = item.id
        this.indexSecSelec = index
      }
    })
  }

  collapseAll() {
    this.items.forEach((item, index) => {
      item.subItm.forEach((subItem: any) => {
        subItem.$showDetail = false
      });

      this.poTable.collapse(index);
    });
  }

  loadCT1(){
    const url = 'http://localhost:8400/rest/apict1/planodecontas/1'

    this.http.get(url).subscribe((response:any) =>{
      response.forEach((element: any) => {
        this.itemCT1.push(
          {
            id: parseInt(element.id),
            conta: element.conta,
            descri: element.descricao
          }
        )
      });
      
      this.hideLoadCT1 = true
    })
  }

  searchCT1(){
    this.itemCT1 = []

    if(!!this.inputSearchCT1){
      const url = `http://localhost:8400/rest/apict1/searchplanodecontas/${this.inputSearchCT1}`
      this.http.get(url).subscribe((response:any) =>{
        response.forEach((element: any) => {
          this.itemCT1.push(
            {
              id: parseInt(element.id),
              conta: element.conta,
              descri: element.descricao
            }
          )
        });

        this.hideLoadCT1 = true
      })
    }else{
      this.hideLoadCT1 = false
      this.loadCT1()
    }
  }

  loadCVN(){
    const url = 'http://localhost:8400/rest/apicvn/cabcvn/1'
    let idAux = 0

    this.http.get(url).subscribe((response:any) =>{
      response.forEach((element: any, index: number) => {

        this.items.push(
          {
            id: idAux = idAux + 1,
            filial: element.filial,
            codigo: element.codigo,
            descri: element.descricao,
            dtvigini: element.dtvigini,
            dtvigfim: element.dtvigfim,
            versao: element.versao,
          }
        )

        this.items[index].subItm = []

        if(element.items.length > 0){
          element.items.map((item : any) =>{

            this.items[index].subItm.push({
              id: parseInt(item.id),
              linha: item.linha,
              contaRef: item.contaRef,
              ctasup: item.ctasup,
              descricao: item.descricao,
              classe: item.classe,
              natcta: item.natcta,
              cvditem: []
            })

          })
        }

      });

      this.hideLoadCVN = true
    })
  }

  loadCTT(row: any){
    const url = 'http://localhost:8400/rest/apictt/centrodecustos/1'

    this.http.get(url).subscribe((response:any) =>{
      response.forEach((element: any) => {
        this.itemCTT.push(
          {
            id: parseInt(element.id),
            ccusto: element.ccusto,
            descri: element.descricao
          }
        )
      });

      this.hideLoadCTT = true
      this.idCvdSelect = row.id
      this.poModal.open();
    })
  }


  restore() {
    this.inputSearchCT1 = '';
  }

  changePesqCT1(pesq : string){
    this.inputSearchCT1 = pesq
  }

}