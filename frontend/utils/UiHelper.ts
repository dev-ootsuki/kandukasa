import type { Design } from '@/types/Types'
export class UiHelper{
    /**
     * Get current instance's ref ID
     * @returns ref's ID
     */
    static getRefId() : string{
        const _ref = getCurrentInstance()?.vnode?.ref as any
        return _ref?.r?.split(".")[1]
    }

    /**
     * convert object[] to Quasar Tree (QTree) Node
     * @param elems Object[]
     * @param config id set. finalize ids.join(".")
     * @returns QNode
     */
    static createNode(elems: any[], config:{keys:string[], label: string, header:"connection" | "schema" | "schemasummary" | "table" | "view" | "trigger" | "routine" | "event", expandable?:boolean, selectable?:boolean, lazy?:boolean}) : any[]{
        if(elems == null)
            return []
        const nodes = elems?.map(e => {
            return {
                key: config.keys.map(key => { return e[key] !== undefined ? e[key] : key }).join("."),
                header: config.header,
                label: e[config.label],
                children:null,
                expandable: config.expandable !== undefined ? config.expandable : true,
                selectable: config.selectable !== undefined ? config.selectable : true,
                lazy: config.lazy !== undefined ? config.lazy : true
            }
        })
        return nodes
    }

    /**
     * check id or ids(array) all number
     * @param id ids
     * @returns true is all number
     */
    static isNumberRouteId(id: string | string[]) : boolean{
        if(typeof id === 'string' && id == "0")
            return true
        if(Array.isArray(id))
            return id.every(e => { UiHelper.isNumberRouteId(e) })
        return typeof id === 'string' && /^\d+$/.test(id)
    }

    /**
     * convert id:string to id:number
     * @param id 
     * @returns number
     */
    static toNumberRouteId(id: string | string[]) : number[]{
        if(!Array.isArray(id))
            return [parseInt((id.toString()))]
        return (id as unknown as Array<string>).map(e => { return parseInt(e) })
    }

    /**
     * ignore [ information of spec to this apps ]
     */
    private static ignoreConvertProps = ["id", "schema_id", "table_id", "column_id", "trigger_id", "event_id", "view_id", "routine_id", "events", "views", "triggers", "tables", "routines"]
    /**
     * convert object to QTable Column
     * @param elem results of query
     * @returns QTableColmun[]
     */    
    static convertColumn(elem: any | undefined, $t: Function) : any[]{
        if(elem === undefined)
            return []
        return Object.getOwnPropertyNames(elem).map(e => {
            if(this.ignoreConvertProps.includes(e))
                return undefined
            return {
                name: e,
                required: true,
                label: $t(`metadata.${e}`),
                field: (row:any) => row[e],
                format: (val:any) => `${val}`,
                sortable: true
            }
        }).filter(e => e)
    }
    private static tablesDifinitions = ["id", "table_name", "auto_increment", "table_rows", "data_length", "index_length", "avg_row_length", "max_data_length", "engine", "table_collation", "check_time", "table_comment", "table_catalog", "table_type", "create_options", "row_format", "data_free", "checksum", "update_time", "version"]
    static createTableColumn($t: Function) : any[]{
        return this.tablesDifinitions.map(each => {
            return {
                name: each,
                required: true,
                label: each != "id" ? $t(`metadata.${each}`) : $t('common.operation'),
                field: (row:any) => row[each],
                format: (val:any) => `${val}`,
                sortable:false
            }
        })
    }

    /**
     * Leftmenu Depth 3 = table or trigger or views or events or routines
     * this is provided functions to detemine and process these 
     */
    private static SchemaSummaries = {
        "none" :  {label:'',icon:'',show:false, mode:"none"},
        "triggers": {label: 'leftmenu.triggers', icon: "local_fire_department", show:true, "mode": "triggers"},
        "tables" : {label:'leftmenu.tables', icon:"newspaper", show:true, "mode":"tables"},
        "views" : {label:'leftmenu.views', icon:"perm_media", show:true, "mode":"views"},
        "routines": {label:'leftmenu.routines', icon:"functions",show:true, "mode":"routines"},
        "events":{label:'leftmenu.events', icon:"calendar_month", show:true, "mode":"events"},
        "all":{label:'leftmenu.all',icon:"summarize",show:true, "mode":"all"}
    } as {[K:string]:Design.SummaryType}
    static getSchemaSummary(mode: string) : Design.SummaryType {
        return this.SchemaSummaries[mode]
    }
    static uiModeToTitleKey(mode:Design.UIMode) : string{
        if(mode == "register")
            return 'common.new_registration_exec'
        if(mode == "update")
            return 'common.update_exec'
        if(mode == "delete")
            return 'common.delete_exec'
        if(mode == "truncate")
            return 'common.truncate_exec'
        if(mode == "bulk_delete")
            return 'common.bulk_delete_exec'
        if(mode == 'bulk_truncate')
            return 'common.bulk_truncate_exec'
        return ''
    }
}
/**
 * leftmenu depth3 types
 */



