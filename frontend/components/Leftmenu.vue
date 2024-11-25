<template>
    <q-list>
        <q-item-label header class="q-pt-sm">
            {{$t('link_name')}}
            <q-btn round flat icon="refresh" size="1em" @click="onReload"/>
        </q-item-label>

        <q-item>
            <q-tree
                ref="leftTree"
                :nodes="qnode"
                node-key="key"
                selected-color="primary"
                v-model:selected="selected"
                @lazy-load="onLazyLoad"
            >
                <template v-slot:header-connection="prop">
                    <div class="row items-center">
                        <q-icon name="storage" color="primary" size="20px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-schema="prop">
                    <div class="row items-center">
                        <q-icon name="schema" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-tablesummary="prop">
                    <div class="row items-center">
                        <q-icon name="newspaper" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-viewsummary="prop">
                    <div class="row items-center">
                        <q-icon name="perm_media" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-triggersummary="prop">
                    <div class="row items-center">
                        <q-icon name="local_fire_department" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-routinesummary="prop">
                    <div class="row items-center">
                        <q-icon name="functions" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>
                <template v-slot:header-eventsummary="prop">
                    <div class="row items-center">
                        <q-icon name="calendar_month" color="primary" size="16px" class="q-mr-sm" />
                        <div class="q-tree-header-label">{{prop.node.label}}</div>
                    </div>
                </template>

            </q-tree>
            

        </q-item>
    </q-list>
</template>

<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { QTree } from 'quasar'
import { useI18n } from 'vue-i18n'
const { t } = useI18n()
const store = useDbConnectionsStore()
const { qnode, outerSlectedNodeId } = storeToRefs(store)

const selected = ref('')
const leftTree = ref<InstanceType<typeof QTree>>()

watch(selected, async (newval:any, oldval:any) => {
    selected.value = newval
    // expand
    if(newval !== undefined && newval != null){
        onOpenTreeNode(newval)
    }
    // close
    else{
        onCloseTreeNode(oldval)
    }
})

store.findDbConnectionsAll()
const onReload = () => {
    location.reload()
}

const onOpenTreeNode = (newval:any) => {
    const node = leftTree.value?.getNodeByKey(newval)
    leftTree.value?.setExpanded(newval, true)
    const keys = newval.split(".")
    // keys.length == 1 == DBInstance
    if(keys.length == 1){
        if(node.children != null && node.children.length > 0){  // == lazyload is already over!
            handler[node.header].navi(node, newval)
        }
        else{  
            // not running onLazyLoad
            // letter, run "onLazyLoad"

            // node.children.length == 0 
            // means no schema or not lazyload.
            //
            // 1. no schema
            // can't expand cause this node not have children
            // 2. not lazyload
            // OK! correct processing
            // When QTree receives "expand" event, it call "onLazyLoad" if it has'nt yet been loaded 
        }
    }
    // keys.length == 2 == schema
    else if(keys.length == 2){
        if(node.children != null && node.children.length > 0){ // == lazyload is already over!
            handler[node.header].navi(node, newval)
        }
        else{  
            // not running onLazyLoad
            // letter, run "onLazyLoad"

            // node.children.length == 0 is yet been loaded
            // cause this node has summaries of "tables" "triggers" "views" "events" "routines"
        }
    }
    // summary of tables | views | triggers | routines | events
    else if(keys.length == 3){
        // data is exists!
        handler["schema"].navi(node, newval, keys[2])
    }
    // table | view | trigger | event
    else if(keys.length == 4){
        // data is exists!

        // when outerSlectedNodeId changed, parent is not expand
        const parentKey = [keys[0], keys[1], keys[2]].join(".")
        if(!leftTree.value?.isExpanded(parentKey))
            leftTree.value?.setExpanded(parentKey, true)
        handler[node.header].navi(node, newval)
    }
    // others select? == error?
    else{

    }
}

watch(outerSlectedNodeId, (newval, oldval) =>{
    outerSlectedNodeId.value = newval
    if(newval != null)
        selected.value = newval
})

const onCloseTreeNode = (oldval:any) => {
    const node = leftTree.value?.getNodeByKey(oldval)
    leftTree.value?.setExpanded(oldval, false)
    // TODO purge store.selected* ?
}
const emptyHandler :(node:any,key:any,done:any,fail:any) => Promise<any> = () => {
    return new Promise<void>(resolve => {
        resolve()
    })
}
const handler = {
    connection: {
        exec: (node:any, key:any, done:any, fail:any) => {
            return store
            .getDbInstanceInfo(key)
            .then(db => {
                const schemaNodes = UiHelper.createNode(db.db_instance!.schemas, {
                    keys: ["id", "schema_id"],
                    label:"schema_name",
                    header:"schema"
               })
                done(schemaNodes)
                return db
            })
        },
        navi: (node:any,key:any,show?:string) => {
            store.setSelectedDb(parseInt(key))
            navigateTo(`/databases/${key}`)
        },
    },
    schema: {
        exec:(node:any, key:any, done:any, fail:any) => {
            const keys = key.split(".")
            return store
            .getSchemaInfo(parseInt(keys[0]), keys[1])
            .then(data => {
                const tables = {
                    label: t('leftmenu.tables'),
                    key:`${key}.tables`,
                    header:"tablesummary",
                    children:UiHelper.createNode(data.tables, {
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
                    children:UiHelper.createNode(data.views, {
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
                    children:UiHelper.createNode(data.triggers, {
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
                    children:UiHelper.createNode(data.events, {
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
                    children:UiHelper.createNode(data.routines, {
                        keys:["id", "schema_id", "routines", "routine_name"],
                        label:"routine_name",
                        header:"routine",
                        lazy:false
                    }),
                    lazy:false
                }
                done([tables, views, triggers, routines, events])
                return data
            })
        },
        navi: (node:any,key:any,show?:string) => {
            const keys = key.split(".")
            store.setSelectedSchema(parseInt(keys[0]),keys[1])
            navigateTo(`/databases/schemas/${keys[1]}?show=${show !== undefined ? show : "all"}`)
        }
    },
    table: {
        exec: emptyHandler,
        navi: (node:any, key:any, show?:string) => {
            const keys = key.split(".")
            store.setSelectedTable(parseInt(keys[0]), keys[1], keys[3])
            navigateTo(`/databases/tables/${keys[3]}`)
        }
    },
    trigger: {
        exec: emptyHandler,
        navi: (node:any, key:any, show?:string) => {
            const keys = key.split(".")
            store.setSelectedTrigger(parseInt(keys[0]), keys[1], keys[3])
            navigateTo(`/databases/triggers/${keys[3]}`)
        }
    },
    routine: {
        exec: emptyHandler,
        navi: (node:any, key:any, show?:string) => {
            const keys = key.split(".")
            store.setSelectedRoutine(parseInt(keys[0]), keys[1], keys[3])
            navigateTo(`/databases/routines/${keys[3]}`)
        }
    },
    event: {
        exec: emptyHandler,
        navi: (node:any, key:any, show?:string) => {
            const keys = key.split(".")
            store.setSelectedEvent(parseInt(keys[0]), keys[1], keys[3])
            navigateTo(`/databases/events/${keys[3]}`)
        }
    },
    view: {
        exec: emptyHandler,
        navi: (node:any, key:any, show?:string) => {
            const keys = key.split(".")
            store.setSelectedView(parseInt(keys[0]), keys[1], keys[3])
            navigateTo(`/databases/views/${keys[3]}`)
        }
    }
    // TODO add event, routine, view
} as {[K:string]:{exec:Function, navi:Function}}

const onLazyLoad  = ({ node, key, done, fail }:{node:any,key:string,done:(children:any[]) => any, fail:any}) => {
    handler[node.header].exec(node, key, done, fail)
    .finally(() => handler[node.header].navi(node, key))
}
</script>