import { Component, ViewChild, OnInit } from '@angular/core';
import { UntypedFormBuilder, UntypedFormGroup, Validators } from '@angular/forms';
import { PoMenuItem, PoModalComponent, PoNotificationService, PoTableColumn, PoTableComponent } from '@po-ui/ng-components';
import { AppComponentService } from './app.component.service';
import { HttpClient, HttpHeaders } from '@angular/common/http'

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  providers: [AppComponentService],
  styleUrls: ['./app.component.css']
})

export class AppComponent implements OnInit {
  public innerWidth: any;

  menuItemSelected: string | any;
  idSelected: number = 0
  subItmSelected: any = []
  isHideLoading = false;

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

  ngOnInit() {
    this.innerWidth = window.innerWidth;
    this.columns = this.servicemenu.getColumns();
    this.items = this.servicemenu.getItems();

    this.teste()
    
  }

  isUndelivered(row: any, index: number) {
    return row.subItm.length > 0
  }

  check() {

    if(this.idSelected > 0){
      let itemAux: any = []

      this.items1.map((event) => {
        if(!!event.$selected){
          event.$selected = false
          
          itemAux.push({
            id: event.id,
            conta: event.conta,
            descri: event.descri,
          })       
        }
      })
      
      if(itemAux.length > 0){
        this.items.filter((item,index) =>{
          if(item.id === this.idSelected){

            item.$selected = false
            this.idSelected = 0

            this.items[index].subItm.forEach((element: any) => {
              itemAux.push(element)
            });
            
            const ids = itemAux.map((o: any) => o.id)
            const filtered = itemAux.filter(({id}: any, index: any) => !ids.includes(id, index + 1))
            
            this.items[index].subItm = filtered.length > 0 ? filtered : itemAux
          }
        });
      }
      
    }else {
      this.poNotification.warning('Nenhum item do Plano de Contas Referencial (CVN) foi selecionado...')
    }
  }

  selectedItem(row: any){
    this.idSelected = row.id
    this.fClearCpo()
  }

  unselectedItem(){
    this.idSelected = 0
    this.fClearCpo()
  }

  printMenuAction(menu: PoMenuItem) {
    this.menuItemSelected = menu.label;
    alert(this.menuItemSelected)
  }

  reactiveForm: UntypedFormGroup | any;

  @ViewChild(PoModalComponent, { static: true }) poModal: PoModalComponent | any;
  @ViewChild(PoTableComponent, { static: true }) poTable: PoTableComponent | any;

  columns: Array<PoTableColumn> = this.servicemenu.getColumns();
  columns1: Array<PoTableColumn> = this.servicemenu.getColumns1();
  columns2: Array<PoTableColumn> = this.servicemenu.getColumns2();

  items: Array<any> = this.servicemenu.getItems();
  items1: Array<any> = this.servicemenu.getItems1();

  constructor(
    public http: HttpClient,
    public poNotification: PoNotificationService,
    public servicemenu: AppComponentService, 
    private fb: UntypedFormBuilder,
    ) {
    this.createReactiveForm();
  }

  createReactiveForm() {
    this.reactiveForm = this.fb.group({
      campo1: ['', Validators.compose([Validators.required])],
      campo2: ['', Validators.compose([Validators.required])],
    });
  }

  saveForm() {
    if(this.subItmSelected.length > 0){
      this.items.filter((item) =>{

        if(this.idSelected === item.id){
          item.subItm.filter((subItem: any) =>{

            if(subItem.id === this.subItmSelected[0].id){
              subItem.campo1 = this.reactiveForm.controls.campo1.value
              subItem.campo2 = this.reactiveForm.controls.campo2.value
            }
          })
        }
      })

      this.fClearCpo()
      this.createReactiveForm();
      this.collapseAll();
    }

    this.subItmSelected = []
    this.idSelected = 0
  }

  showItem(row:any){
    this.items.forEach((item) =>{
      item.$selected = false
    })

    this.items.filter((item,index) =>{
      if(row.id === item.id){
        this.items[index].$selected = true
        this.idSelected = item.id
      }
    })
  }

  showSubItem(row:any){
    this.reactiveForm.controls.campo1.value = (!!row.campo1) ? row.campo1 : this.fClearCpo()
    this.reactiveForm.controls.campo2.value = (!!row.campo2) ? row.campo2 : this.fClearCpo()
    this.subItmSelected = [row]
  }

  collapseAll() {
    this.items.forEach((item, index) => {
      item.subItm.forEach((subItem: any) => {
        subItem.$showDetail = false
      });

      this.poTable.collapse(index);
    });
  }

  fClearCpo(){
    this.reactiveForm.controls.campo1.value = ''
    this.reactiveForm.controls.campo2.value = ''

    return ''
  }

  teste(){
    let url = 'http://localhost:8400/rest/apict1/planodecontas/1'

    this.http.get(url).subscribe((response:any) =>{
      response.forEach((element: any) => {
        console.log(element)
      });

      //this.isHideLoading = true
    })
  }


}