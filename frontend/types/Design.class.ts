import type { Design } from '~/types/Types'
import * as Domain from '~/types/Domain.class'

export class Config{
    id:number = 0
    before?: Config
    lang?: Design.Lang
    isDark: boolean = true
    primary?:string
    secondary?:string
    accent?:string
    positive?:string
    negative?:string
    info?:string
    warning?:string
    bgLight?:string
    textLight?:string
    bgEins?:string
    textEins?:string
    bgZwei?:string
    textZwei?:string
    bgDrei?:string
    textDrei?:string
    defaultPageSize:number = 50
    tablesPageSize:number = 20
    leftmenuWitdh:number = 300
    leftmenuOpen: boolean = true
    touch(): void{
        if(this.before?.id === this.id)
            this.id++
    }
    isTouch(): boolean{
        return this.before?.id !== this.idz
    }
    createTablePagination(): Domain.Pagination {
        return new Domain.Pagination(this.tablesPageSize)
    }
    toPagination(arg:{[K:string]:any}) : Domain.Pagination{
        const ret = new Domain.Pagination(this.tablesPageSize)
        ret.page = arg.page
        ret.rowsNumber = arg.rowsNumber
        ret.rowsPerPage = arg.rowsPerPage
        ret.descending = arg.descending
        ret.sortBy = arg.sortBy
        return ret
    }
}

