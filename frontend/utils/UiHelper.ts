import type { Design } from '~/types/Types'
import * as DomainClass from '~/types/Domain.class'
import { useSystemStore } from '~/stores/SystemStore'

/**
 * 操作全般
 * mode: 操作モード
 * label: 画面表示上のラベル
 * icon: ボタンなどに配置するラベルのmaterial design名称
 * dangar: 危険な操作か
 */
const SystemOperations:Design.SystemOperation[] = [{
        mode: "register",
        label: 'common.new_registration_exec',
        icon: "add",
        danger:false
    },{
        mode: "update",
        label: 'common.update_exec',
        icon: "edit",
        danger:false
    },{
        mode:"delete",
        label: "common.delete_exec",
        icon: "delete_forever",
        danger:true
    },{
        mode:"truncate",
        label:"common.truncate_exec",
        icon:"edit_off",
        danger:true
    },{
        mode:"bulk_delete",
        label:"common.bulk_delete_exec",
        icon:"delete_forever",
        danger:true
    },{
        mode:"bulk_truncate",
        label:"common.bulk_truncate_exec",
        icon:"edit_off",
        danger:true
}]

/**
 * スキーマの下にある機能まとめ
 */
const SchemaSummaries = {
    // なし
    "none" :  {label:'',icon:'',show:false, mode:"none"},
    // トリガーのみ
    "triggers": {label: 'leftmenu.triggers', icon: "local_fire_department", show:true, "mode": "triggers"},
    // テーブルのみ
    "tables" : {label:'leftmenu.tables', icon:"newspaper", show:true, "mode":"tables"},
    // ビューのみ
    "views" : {label:'leftmenu.views', icon:"perm_media", show:true, "mode":"views"},
    // ルーチンのみ
    "routines": {label:'leftmenu.routines', icon:"functions",show:true, "mode":"routines"},
    // イベントのみ
    "events":{label:'leftmenu.events', icon:"calendar_month", show:true, "mode":"events"},
    // 全部 = スキーマ選択時そのもの
    "all":{label:'leftmenu.all',icon:"summarize",show:true, "mode":"all"}
} as {[K:string]:Design.SummaryType}

/**
 * 各種定義（スキーマ・テーブル詳細・テーブル一覧など）で無視するプロパティ
 */
const IgnoreConvertProps = ["id", "schema_id", "table_id", "column_id", "trigger_id", "event_id", "view_id", "routine_id", "events", "views", "triggers", "tables", "routines"]
/**
 * テーブル一覧を並べる時の表示順序 = indexkey
 */
const TablesOrderDifinitions = ["id", "table_name", "auto_increment", "table_rows", "data_length", "index_length", "avg_row_length", "max_data_length", "engine", "table_collation", "check_time", "table_comment", "table_catalog", "table_type", "create_options", "row_format", "data_free", "checksum", "update_time", "version"]
/**
 * テーブル詳細を並べる時の表示順序 = indexkey
 */
const ColumnsOrderDifinitions = ["column_name", "ordinal_position", "data_type", "is_nullable", "column_default", "character_maximum_length", "character_octet_length", "numeric_precision", "numeric_scale", "datetime_precision", "character_set_name", "collation_name", "column_type", "column_key", "extra", "privileges", "column_comment", "generation_expression", "srs_id"]

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

    static getSchemaSummary(mode: string) : Design.SummaryType {
        return SchemaSummaries[mode]
    }

    static findSystemOperaion(mode:Design.UIMode) : Design.SystemOperation{
        const ret = SystemOperations.find(e => e.mode == mode)
        if(ret != null)
            return ret
        return SystemOperations[0]
    }
}

export class TreeHelper{
    /**
     * convert object[] to Quasar Tree (QTree) Node
     * @param elems Object[]
     * @param config id set. finalize ids.join(".")
     * @returns QNode
     */
    static createNode(elems: any[], config:{keys:string[], label: string, header:Design.DatabaseTreeNodeHeaderType, expandable?:boolean, selectable?:boolean, lazy?:boolean}) : any[]{
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
                lazy: config.lazy !== undefined ? config.lazy : true,
            }
        })
        return nodes
    }
    static createSchemaChildren(t:Function, key:string, data:DomainClass.DbSchema) : any[] {
        const tables = {
            label: t('leftmenu.tables'),
            key:`${key}.tables`,
            header:"tablesummary",
            children:TreeHelper.createNode(data.tables, {
                keys:["id", "schema_id", "tables", "table_name"],
                label:"table_name",
                header:"table",
                lazy:false
            }),
            lazy:false
        }
        const views = {
            label:t('leftmenu.views'),
            key:`${key}.views`,
            header:"viewsummary",
            children:TreeHelper.createNode(data.views, {
                keys:["id", "schema_id", "views", "table_name"],
                label:"table_name",
                header:"view",
                lazy:false
            }),
            lazy:false
        }
        const triggers = {
            label:t('leftmenu.triggers'),
            key:`${key}.triggers`,
            header:"triggersummary",
            children:TreeHelper.createNode(data.triggers, {
                keys:["id", "schema_id", "triggers", "trigger_name"],
                label:"trigger_name",
                header:"trigger",
                lazy:false
            }),
            lazy:false
        }
        const events = {
            label:t('leftmenu.events'),
            key:`${key}.events`,
            header:"eventsummary",
            children:TreeHelper.createNode(data.events, {
                keys:["id", "schema_id", "events", "event_name"],
                label:"event_name",
                header:"event",
                lazy:false
            }),
            lazy:false
        }
        const routines = {
            label:t('leftmenu.routines'),
            key:`${key}.routines`,
            header:"routinesummary",
            children:TreeHelper.createNode(data.routines, {
                keys:["id", "schema_id", "routines", "routine_name"],
                label:"routine_name",
                header:"routine",
                lazy:false
            }),
            lazy:false
        }
        return [tables, views, triggers, routines, events]
    }
}

export class TableHelper{
    /**
     * ignore [ information of spec to this apps ]
     */
    /**
     * convert object to QTable Column
     * @param elem results of query
     * @returns QTableColmun[]
     */    
    static convertColumn(elem: any | undefined, $t: Function) : any[]{
        if(elem === undefined)
            return []
        return Object.getOwnPropertyNames(elem).map(e => {
            if(IgnoreConvertProps.includes(e))
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
    static createTableColumn($t: Function) : any[]{
        return TablesOrderDifinitions.map(each => {
            return {
                name: each,
                required: false,
                label: each != "id" ? $t(`metadata.${each}`) : $t('common.operation'),
                field: (row:any) => row[each],
                format: (val:any) => `${val}`,
                sortable:false
            }
        })
    }
    static createColumns($t: Function) : any[]{
        return ColumnsOrderDifinitions.map(each => {
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

    static createDataColumns($t:Function, columns:any[]) : Design.DataColumn[]{
        const system = useSystemStore().systemSetting
        const ret = columns.map(each => {
            return {
                name: each["column_name"],
                required: false,
                label: each["column_name"],
                field: (row:any) => row[each["column_name"]],
                format: (val:any) => `${val}`,
                sortable:true,
                data_type: each["data_type"]
            }
        })
        return [{
            name: system.dbDataPrimaryKey!,
            required: false,
            label: $t('common.operation'),
            field:(row:any) => '',
            format: (val:any) => '',
            sortable: false,
            data_type: "system_primary"
        }].concat(ret)
    }
}
