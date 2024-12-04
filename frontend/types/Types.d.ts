/* ----------------------------------------------------------
 * Types of ProxyForm
 * ---------------------------------------------------------- */

export declare namespace ProxyForm{
    interface PF{
        isValid() : boolean
        toDomain() : {}
    }

    interface ComponentInputAdapterPF extends PF{
        useModel(propName: string) : Ref | undefined
        usePrimary(propName: string) : string | number | boolean | null | undefined
    }

    interface InputRefsAggregator<T extends PF> extends ComponentInputAdapterPF, ProxyHandler<T>{
        props: string[]
        domain: T
        refs: Map<string, Ref>
    }

    declare interface CompositeProxy<T extends PF, R> extends ProxyHandler<T>{
        composites: ProxyForm[]
        primary: R<T>
        props: string[]
        methods : string[]
        prefix: string
        set(target: T, p: string | symbol, newValue: any, receiver: any): boolean
        get(target: T, p: string | symbol, receiver: any): any
    }
}

/* ----------------------------------------------------------
 * Types of Validator
 * ---------------------------------------------------------- */

export declare namespace Validator{
    type ValidateType = "required" | "range" | "rangeIncludeMinus" | "regex" | "custom" | "clength"

    type Rule = {
        from?: number,
        to?: number,
        regex?: RegExp,
        custom?: (input:string) => boolean,
        format?: string,
        rule: ValidateType,
        message: Message,
        overrideMessage?:string
    }
    
    type Mechanizm = {
        rule: Rule,
        isOk: Validation
    }
    
    type MessageConverter = (message: string | undefined, argFormat?:string, ...args:any[]) => string
    
    type Validation = (input: string) => boolean | string
    
    type Message = 
        "required" | "numeric" | "float" | "ascii" | "email" | "hiragana" | "katakana" | "zenkaku" | 
        "length_from_to" | "length_from" | "length_to" | "length_exactly" | "range_from_to" | "range_from" | "range_to"
    
    type Settings = {
        defaultDateFormat: string
        messages: Map<Message, string>
        converter: Converter
    }
    
    type Plugin = {
        settings: SettingsType,
        create: UseValidator
    }
    
    type IsOk = (input: string, rangeFrom: number | undefined, rangeTo: number | undefined, regex: RegExp | undefined) => boolean

    interface MessageAdapter{
        settings:Settings
        get(rule:Rule) : string
        ruleToMessageArgs (rule : Rule) : any[]
    }

    type UseValidator = (...rules: Validator.Rule[]) => Validator.Validation[]
}

/* ----------------------------------------------------------
 * Types of WebAPI
 * ---------------------------------------------------------- */
export declare namespace WebAPI{
    type WebAPISuccess<T> = {
        data: T,
        status: string
    }
    
    type WebAPIFailed = {
        data: any,
        status: number,
        url:string,
        method?: string,
        detail: WebAPIError
    }
    
    type WebAPIError = {
        message?: string,
        stackTrace?: string[]
        stackMessage?:string
    }
}

/* ----------------------------------------------------------
 * Types of Design
 * ---------------------------------------------------------- */
export declare namespace Design{
    type UIMode = "register" | "update" | "delete" | "truncate" | "bulk_delete" | "bulk_truncate" | "complete"

    type Lang = {
        name:string,
        qName:string,
        qResource: any,
        label?:string,
        value?:string
    }

    type SummaryType = {label:string, icon:string, show:boolean, mode:string}
    type SearchCondition = {column:any, input:any, key:number, operator?: number}
    type DataColumn = {name: string, required: boolean, label: string, field: (row:any) => any, format: (val:any) => string, sortable:boolean, data_type: string}
    type DatabaseTreeNodeHeaderType = "connection" | "schema" | "schemasummary" | "table" | "view" | "trigger" | "routine" | "event"
    type SystemOperation = {label:string, icon:string, mode:Design.UIMode, danger:boolean}
    type DbdataBindingInfo = { operators: Domain.CompareOperator[]}
}

/* ----------------------------------------------------------
 * Types of Domains
 * ---------------------------------------------------------- */
export declare namespace Domain{
    interface Unit{
        name:string
        from:number
        to:number
        inRange(val:number) : boolean
        exchange(val:number | undefined) : number
        exchangeToString(val:number | undefined) : string
    }
    type DbProduct = {label:string, value:string, enable:boolean}
    type OperatorType = "=" | "!=" | ">=" | ">" | "<=" | "<" | "IS" | "IS NOT" | "IS NULL" | "IS NOT NULL" | "IN" | "NOT IN" | "BETWEEN" | "NOT BETWEEN" | "LIKE" | "NOT LIKE"
    type CompareOperator = { type: OperatorType, label: string , id: number, description: string}

}

export declare namespace System{
    type DbProduct = {label:string, value:string, enable:boolean}
    type OperatorType = "=" | "!=" | ">=" | ">" | "<=" | "<" | "IS" | "IS NOT" | "IS NULL" | "IS NOT NULL" | "IN" | "NOT IN" | "BETWEEN" | "NOT BETWEEN" | "LIKE" | "NOT LIKE"
    type CompareOperator = { type: OperatorType, label: string , id: number, description: string}

}

/* ----------------------------------------------------------
 * Types of Auth
 * ---------------------------------------------------------- */
export declare namespace Auth{
    export const PermissionMap = {
        all: 1,        // all
        read: 2,       // read
        create: 3,     // create schema, table, column...etc
        update: 4,     // update schema, table, column...etc
        delete: 5,     // delete schema, table, column...etc
        execute: 6,    // excute my query
        bulk_read: 7,  // bulk read
        bulk_write: 8, // bulk create/update/delete/execute
        query: 9,      // query by schema
        readtable:10,   // reading dbconnection's table data
    }
    
    export type PermissionType = keyof typeof PermissionMap
    
    export const FunctionsMap = {
        users:1,           // ユーザー管理
        dbconnections:2,   // DB接続先管理
        dbschemas:3,       // DBスキーマ自体
        dbfeatures:4,      // DBスキーマ以下の機能（table/trigger/events/routine/view)
        dbdata:5,          // DBのデータ自体
    }
    
    export type FunctionsType = keyof typeof FunctionsMap
    
    type UserRoleMapping = { func:FunctionsType, perm:PermissionType[] }

    interface Role{
        has(func:Auth.FunctionsType, perm: Auth.PermissionType) : boolean
    }
}

type ClassPropKeys<T> = {[K in keyof T as T[K] extends (...args: any[]) => any ? never : K]: T[K]}