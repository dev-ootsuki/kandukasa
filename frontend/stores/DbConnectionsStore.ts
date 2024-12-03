import { defineStore } from 'pinia'
import { DbConnection, DbEvent, DbSchema, DbTable,DbTrigger,DbView,DbRoutine, DbData, Pagination } from '~/types/Domain.class'
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
            const res = await webapi()<WebAPI.WebAPISuccess<DbConnection[]> | WebAPI.WebAPIFailed>('/db_connection/', {
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
                return con
            })
        },
        async getSchemaInfo(conId: number, schemaId: string) : Promise<DbSchema>{
            const con = await this.getDbConnectionById([conId])
            return webapi()<WebAPI.WebAPISuccess<DbSchema[]> | WebAPI.WebAPIFailed>(`/db_connection/${conId}/${schemaId}`)
            .then(data => {
                const schema = con.db_instance?.schemas.find(e => e.schema_id == schemaId)!
                schema.events = data?.data.events
                schema.tables = data?.data.tables
                schema.views = data?.data.views
                schema.triggers = data?.data.triggers
                schema.routines = data?.data.routines
                return schema
            })
        },
        async getTableInfo(conId:number, schemaId:string, tableId: string) : Promise<DbTable>{
            const con = this.selected
            return webapi()<WebAPI.WebAPISuccess<DbTable[]> | WebAPI.WebAPIFailed>(`/db_connection/${conId}/${schemaId}/${tableId}`)
            .then(data => {
                const table = con?.db_instance?.schemas.find(e => e.schema_id == schemaId)?.tables.find(e => e.table_id == tableId)!
                table.columns = data?.data.columns
                table.primaries = data?.data.primaries
                return table
            })
        },
        async getTableData(id:number, schema_id:string, table_id: string, conditions:any) : Promise<{results: DbData[], pagination: Pagination}>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${id}/${schema_id}/${table_id}/query`, {
                method:"POST",
                body: conditions  
            })
            .then(data => {
                return data.data
            })
        },
        async deleteTableData(id:number, schema_id:string, table_id:string, keys:any[]) : Promise<void>{
            return webapi()<WebAPI.WebAPISuccess<DbData[]> | WebAPI.WebAPIFailed>(`/db_connection/${id}/${schema_id}/${table_id}/bulk_record_delete`, {
                method:"DELETE",
                body: {
                    keys:keys
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
        setSelectedSchema(id:number, schemaId: string) : DbSchema | null{
            const _selectedDb = this.setSelectedDb(id)
            if(_selectedDb == null)
                return null
            const _selectedSchema = _selectedDb.db_instance?.schemas.find(e => e.schema_id == schemaId)
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
        setSelectedTable(id:number, schemaId: string, tableId:string) : DbTable | null{
            const _selectedSchema = this.setSelectedSchema(id, schemaId)
            if(_selectedSchema == null)
                return null
            const _selectedTable = _selectedSchema.tables.find(e => e.table_id == tableId)!
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
        setSelectedTrigger(id:number, schemaId: string, triggerId:string) : DbTrigger | null{
            const _selectedSchema = this.setSelectedSchema(id, schemaId)
            if(_selectedSchema == null)
                return null
            const _selectedTrigger = _selectedSchema.triggers.find(e => e.trigger_id == triggerId)!
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
        setSelectedView(id:number, schemaId: string, viewId:string) : DbView | null{
            const _selectedSchema = this.setSelectedSchema(id, schemaId)
            if(_selectedSchema == null)
                return null
            const _selectedView = _selectedSchema.views.find(e => e.view_id == viewId)!
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
        setSelectedEvent(id:number, schemaId: string, eventId:string) : DbEvent | null{
            const _selectedSchema = this.setSelectedSchema(id, schemaId)
            if(_selectedSchema == null)
                return null
            const _selectedEvent = _selectedSchema.events.find(e => e.event_id == eventId)!
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
        setSelectedRoutine(id:number, schemaId: string, routineId:string) : DbRoutine | null{
            const _selectedSchema = this.setSelectedSchema(id, schemaId)
            if(_selectedSchema == null)
                return null
            const _selectedRoutine = _selectedSchema.routines.find(e => e.routine_id == routineId)!
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
