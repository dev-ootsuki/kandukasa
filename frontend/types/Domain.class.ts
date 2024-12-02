import type { Domain, ProxyForm } from '~/types/Types'

export class ByteUnit implements Domain.Unit{
    name:string = ''
    from:number
    to:number
    digit:number 
    constructor(name: string, from:number,to:number, digit:number = 0){
        this.name = name
        this.from = from
        this.to = to
        this.digit = digit == 0 ? 0 : Math.pow(10, digit)
    }
    inRange(val:number) : boolean {
        return this.from <= val && this.to >= val
    }
    exchange(val:number | undefined) : number{
        if(val === undefined || val === null)
            return 0
        return Math.round(val / this.from * this.digit) / this.digit
    }
    exchangeToString(val:number | undefined) : string{
        return this.exchange(val) + this.name
    }
}

class DomainObject implements ProxyForm.PF{
    isValid(): boolean {
        return true
    }
    toDomain(): {} {
        return this
    }
}

export class DbConnection extends DomainObject{
    id: number | undefined
    name: string | undefined
    db_type: string | undefined
    host: string | undefined
    port: number | undefined
    default_dabase_name:string | undefined
    login_name: string | undefined
    password: string | undefined
    timeout: number = 60
    use_ssl: boolean = false
    ssl_key: string | undefined
    ssl_cert: string | undefined
    ssl_ca: string | undefined
    description: string | undefined
    db_instance: DbInstance | undefined
    constructor(){
        super()
    }
    override isValid() : boolean{
        // if(!this.use_ssl)
        //     return true
        // return this.ssl_key != null && this.ssl_cert != null && this.ssl_ca != null
        return true
    }
}

export class DbInstance extends DomainObject{
    schemas:DbSchema[] = []
    engines:DbEngine[] = []
    characters:DbCharacters[] = []
    privileges:DbPrivileges[] = []
    collations:DbCollations[] = []
}

export class DbCollations extends DomainObject{
    collation_name?:string
    description?:string
}

export class DbPrivileges extends DomainObject{
    column_name?:string
    grantee?:string
    privileges?:string
    table_name?:string
    table_schema?:string
    privilegesList(): string[]{
        return this.privileges === undefined ? [] : this.privileges.split(",")
    }
}

export class DbEngine extends DomainObject{
    comment?:string
    engine?:string
    savepoints?:string
    transactions?:string
    xa?:string
}

export class DbCharacters extends DomainObject{
    character_set_name?:string
    default_collate_name?:string
    description?:string
    maxlen?:number
}

export class DbSchema extends DomainObject{
    schema_name?: string
    system_catalog?: string
    default_character_set_name?: string
    default_collation_name?:string
    sql_path?: string | null
    default_encryption?: "NO" | "YES"
    options?: string
    grantee?: null | string
    table_catalog?: null | string
    table_schema?: null | string
    privilege_type?: null | string
    is_grantable?: null | string
    id?: number
    schema_id?: string
    tables: DbTable[] = []
    triggers: DbTrigger[] = []
    views: DbView[] = []
    routines: DbRoutine[] = []
    events: DbEvent[] = []
    constructor(){
        super()
    }
    isChildrenEmpty: () => boolean = () : boolean =>{
        return this.tables == null && this.triggers == null && this.views == null && this.routines == null && this.events == null
    }
    totalUsageTables: () => number = () : number => {
        let total = 0
        this.tables?.forEach(e => total += e.data_length)
        return total
    }
    totalUsageIndexes: () => number = () : number => {
        let total = 0
        this.tables?.forEach(e => total += e.index_length)
        return total
    }
}

export class DbEvent extends DomainObject{
    event_id?:string
}

export class DbRoutine extends DomainObject{
    routine_id?:string
}

export class DbView extends DomainObject{
    view_id?:string
}

export class DbTrigger extends DomainObject{
    trigger_id?:string
}

export class DbTable extends DomainObject{
    id?:number
    schema_id?:string
    table_id?:string
    table_name?:string
    data_length:number = 0
    index_length: number = 0
    auto_increment?: boolean = false
    avg_row_length?: number = 0
    check_time?:Date
    checksum?:number
    create_options?:string
    create_time?:Date
    data_free:number = 0
    engine:string = ''
    max_data_length:number = 0
    row_format:string = ''
    table_catalog:string = ''
    table_collation:string = ''
    table_comment?:string
    table_rows:number = 0
    table_schema:string = ''
    table_type:string = ''
    update_time?:Date
    version:number = 0
    columns: DbColumn[] = []
    primaries: DbPrimaryKey[] = []
    constructor(){
        super()
    }
}

export class DbPrimaryKey{
    column_name?:string
}
export class Pagination{
    rowsPerPage:number = 0
    page: number = 1
    rowsNumber: number = 0
    sortBy?: string
    descending: boolean = false
    constructor(pageSize: number){
        this.rowsPerPage = pageSize
    }
    setSort(sortKey:string, descending?:boolean) : Pagination{
        this.sortBy = sortKey
        if(descending === true)
            this.descending = true
        return this
    }
    setPageInfo(page:number, rowsNumber: number) : Pagination{
        this.page = page
        this.rowsNumber =rowsNumber
        return this
    }
    toPlain() : Pagination{
        const ret = new Pagination(this.rowsPerPage)
        Object.getOwnPropertyNames(this).map(e => {
            (ret as any)[e] = (this as any)[e]
        })
        return ret
    }
}


export class DbData{
    [K:string]:any
}

export class DbColumn extends DomainObject{
    constructor(){
        super()
    }
}
