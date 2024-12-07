import { defineStore } from 'pinia'
import { DbConnection, DbEvent, DbSchema, DbTable,DbTrigger,DbView,DbRoutine, DbColumn, DbData, Pagination, DbUiDataTypes } from '~/types/Domain.class'
import type { WebAPI } from '~/types/Types'

type State = {
    dbConnections: DbConnection[],
    selectedDb: DbConnection | null,
    selectedSchema: DbSchema | null,
    selectedTable: DbTable | null,
    selectedTrigger: DbTrigger | null,
    selectedView: DbView | null,
    selectedRoutine: DbRoutine | null,
    selectedEvent: DbEvent | null
    node: any[],
    selectedNode: string | null
}

export const useDbConnectionsStore = defineStore('dbConnections', {
    // convert to a function
    state: (): State => ({
      dbConnections: [],
      selectedDb: null,
      selectedSchema: null,
      selectedTable: null,
      selectedTrigger: null,
      selectedView: null,
      selectedRoutine: null,
      selectedEvent: null,
      node: [],
      selectedNode: null
    }),
    getters: {
        selected(state: State){
            return state.selectedDb
        },
        qnode(state: State){
            return state.node
        },
        selectedNodeId(state: State){
            return state.selectedNode
        },
        selectedDbDataTypes(state: State) : DbUiDataTypes | undefined{
            return state.selectedDb?.db_instance?.ui_data_types
        }
    },
    actions: {
        createRootNode() : any[] {
            this.node = []
            this.node = TreeHelper.createNode(this.dbConnections, {keys:["id"],label:"name", header:"connection"})
            return this.node
        },
        async findDbConnectionsAll() : Promise<DbConnection[]>{
            return webapi()<WebAPI.WebAPISuccess<DbConnection[]> | WebAPI.WebAPIFailed>
                ('/db_connection')
                .then(res => {
                    this.dbConnections = res.data
                    this.createRootNode()
                    return this.dbConnections
                })
                .catch(res => {
                    return res.data
                })
        },
        async getDbConnectionById(ids: number[]) : Promise<DbConnection>{
            const id = ids != null && ids.length > 0 && ids[0] > 0 ? ids[0] : 0
            const newObject = new Promise<DbConnection>((resolve) => resolve(new DbConnection()))
            if(id == 0)
                return newObject
            let ret:DbConnection | undefined = this.dbConnections.find(e => {
                return e.id == id
            })
            if( ret !== null && ret !== undefined)
                return new Promise<DbConnection>((resolve) => resolve(ret!))
            const res = await webapi()<WebAPI.WebAPISuccess<DbConnection> | WebAPI.WebAPIFailed>(`/db_connection/${id}`)
            ret = res.data
            if(ret !== undefined && ret !== null)
                this.dbConnections.push(ret)
            return ret === undefined ? newObject : new Promise<DbConnection>((resolve) => resolve(ret))
        },
        async saveDbConnection(domain: DbConnection){
            return webapi()<WebAPI.WebAPISuccess<DbConnection[]> | WebAPI.WebAPIFailed>('/db_connection/', {
                method: "POST",
                body: {
                    "db_connection": domain
                }
            })
        },
        async modifyDbConnection(domain: DbConnection){
            domain.db_instance = undefined
            const res = await webapi()<WebAPI.WebAPISuccess<DbConnection[]> | WebAPI.WebAPIFailed>(`/db_connection/${domain.id}`, {
                method: "PUT",
                body: {
                    "db_connection": domain
                }
            })
        },
        async deleteDbConnection(id: number) {
            const res = await webapi()<WebAPI.WebAPISuccess<DbConnection[]> | WebAPI.WebAPIFailed>(`/db_connection/${id}`, {
                method: "DELETE"
            })
        },
        async getDbInstanceInfo(conId: number) : Promise<DbConnection>{
            const con = await this.getDbConnectionById([conId])
            return webapi()<WebAPI.WebAPISuccess<{schemas:DbSchema[]}> | WebAPI.WebAPIFailed>(`/db_connection/${con.id}`)
            .then(data => {
                con.db_instance = data.data.db_instance
                con.db_instance!.ui_data_types = new DbUiDataTypes(data.data.db_instance.ui_data_types)
                return con
            })
        },
        async getSchemaInfo(schemaId: string) : Promise<DbSchema>{
            return webapi()<WebAPI.WebAPISuccess<DbSchema[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${schemaId}`)
            .then(data => {
                const schema = this.selectedDb!.db_instance?.schemas.find(e => e.schema_id == schemaId)!
                schema.events = data?.data.events
                schema.tables = data?.data.tables
                schema.views = data?.data.views
                schema.triggers = data?.data.triggers
                schema.routines = data?.data.routines
                return schema
            })
        },
        async getTableInfo(tableId: string) : Promise<DbTable>{
            return webapi()<WebAPI.WebAPISuccess<DbTable[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${tableId}`)
            .then(data => {
                const table = this.selectedSchema!.tables.find(e => e.table_id == tableId)!
                table.columns = data?.data.columns
                table.primaries = data?.data.primaries
                return table
            })
        },
        async truncateTables(tables: DbTable[]) : Promise<DbTable[]> {
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/bulk_truncate`, {
                method:"DELETE",
                body:{
                    data:{
                        tables: tables.map(e => e.table_name)
                    }
                }
            })
            .then(data => {
                return tables
            })
        },
        async deleteTables(tables: DbTable[]) : Promise<DbTable[]>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/bulk_drop`, {
                method:"DELETE",
                body:{
                    data:{
                        tables: tables.map(e => e.table_name)
                    }
                }
            })
            .then(data => {
                return tables
            })
        },
        async deleteColumnDef(column: DbColumn) : Promise<DbColumn>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${this.selectedTable?.table_id}/${column.column_name}`, {
                method:"DELETE"
            })
            .then(data => {
                return data.data
            })
        },
        async deletePrimaryKey() : Promise<any>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${this.selectedTable?.table_id}/delete_pkey`, {
                method:"DELETE"
            })
            .then(data => {
                return data.data
            })
        },
        async getTableData(conditions:any) : Promise<{results: DbData[], pagination: Pagination}>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${this.selectedTable?.table_id}/query`, {
                method:"POST",
                body: conditions  
            })
            .then(data => {
                return data.data
            })
        },
        async deleteTableData(keys:any[]) : Promise<void>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${this.selectedTable?.table_id}/bulk_record_delete`, {
                method:"DELETE",
                body: {
                    keys:keys
                }
            })
            .then(data => {
                return data.data
            })
        },
        async createTableData(data:DbData) : Promise<DbData> {
            // TODO ファイルの場合の実装
            const containBlob = this.selectedTable?.columns.find(e => e.data_type == "blob") != null
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}/${this.selectedTable?.table_id}/create_data`, {
                method:"POST",
                body: {
                    data:data
                }
            })
            .then(data => {
                return data.data
            })
        },
        async registerTable(table:DbTable) : Promise<DbTable>{
            // TODO 実装？
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${this.selectedDb?.id}/${this.selectedSchema?.schema_id}`, {
                method:"POST",
                body: {
                    table:table
                }
            })
            .then(data => {
                return data.data
            })
        },
        setSelectedDb(id: number) : DbConnection | null{
            this.selectedDb = this.dbConnections.find(e => e.id == id)!
            this.selectedEvent = null
            this.selectedRoutine = null
            this.selectedSchema = null
            this.selectedTable = null
            this.selectedTrigger = null
            this.selectedView = null
            return this.selectedDb
        },
        setSelectedSchema(schemaId: string) : DbSchema | null{
            if(this.selectedDb == null)
                return null
            const _selectedSchema = this.selectedDb.db_instance?.schemas.find(e => e.schema_id == schemaId)
            if(_selectedSchema == null){
                this.selectedDb = null
                return null
            }
            this.selectedSchema = _selectedSchema
            this.selectedEvent = null
            this.selectedRoutine = null
            this.selectedTable = null
            this.selectedTrigger = null
            this.selectedView = null
            return this.selectedSchema
        },
        setSelectedTable(tableId:string) : DbTable | null{
            if(this.selectedSchema == null)
                return null
            const _selectedTable = this.selectedSchema.tables.find(e => e.table_id == tableId)!
            if(_selectedTable == null){
                this.selectedTable = null
                return null
            }
            this.selectedTable = _selectedTable
            this.selectedEvent = null
            this.selectedRoutine = null
            this.selectedTrigger = null
            this.selectedView = null            
            return this.selectedTable
        },
        setSelectedTrigger(triggerId:string) : DbTrigger | null{
            const _selectedTrigger = this.selectedSchema!.triggers.find(e => e.trigger_id == triggerId)!
            if(_selectedTrigger == null){
                this.selectedTrigger = null
                return null
            }
            this.selectedTrigger = _selectedTrigger
            this.selectedEvent = null
            this.selectedRoutine = null
            this.selectedTable = null
            this.selectedView = null            
            return this.selectedTrigger
        },
        setSelectedView(viewId:string) : DbView | null{
            const _selectedView = this.selectedSchema!.views.find(e => e.view_id == viewId)!
            if(_selectedView == null){
                this.selectedView = null
                return null
            }
            this.selectedTrigger = null
            this.selectedEvent = null
            this.selectedRoutine = null
            this.selectedTable = null
            this.selectedView = _selectedView            
            return this.selectedView
        },
        setSelectedEvent(eventId:string) : DbEvent | null{
            const _selectedEvent = this.selectedSchema!.events.find(e => e.event_id == eventId)!
            if(_selectedEvent == null){
                this.selectedEvent = null
                return null
            }
            this.selectedTrigger = null
            this.selectedEvent = _selectedEvent
            this.selectedRoutine = null
            this.selectedTable = null
            this.selectedView = null            
            return this.selectedEvent
        },
        setSelectedRoutine(routineId:string) : DbRoutine | null{
            const _selectedRoutine = this.selectedSchema!.routines.find(e => e.routine_id == routineId)!
            if(_selectedRoutine == null){
                this.selectedRoutine = null
                return null
            }
            this.selectedTrigger = null
            this.selectedEvent = null
            this.selectedRoutine = _selectedRoutine
            this.selectedTable = null
            this.selectedView = null            
            return this.selectedRoutine
        }
    }
})
