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
                v-model:selected="selectedNode"
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
const { qnode, selectedNode } = storeToRefs(store)
const leftTree = ref<InstanceType<typeof QTree>>()

// 外から現在選択中のツリーのノードを選択できるようにstoreに放り込んでwatchしておく
// A condition that is thrown into "DbConnectionsStore" and "watch" so 
// that the node in the currently selected tree can be selected from the outside.
watch(selectedNode, async (newval:any, oldval:any) => {
    selectedNode.value = newval
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
    // 接続自体を選択
    // keys.length == 1 == DBInstance
    if(keys.length == 1){
        if(node.children != null && node.children.length > 0){  // == lazyload is already over!
            handler[node.header].navi(node, newval)
        }
        else{
            // node.childrenが空 = スキーマがないかlazyloadされていない
            // lazyloadされてないとき：setExpanded呼んだらonLazyLoadが走る
            // lazyloadされているとき：
            // スキーマがないので正常

            // not running onLazyLoad
            // after "setExpanded", run "onLazyLoad"

            // node.children.length == 0 
            // means no schema or not lazyload.
            //
            // 1. no schema
            // can't expand cause this node not have children
            // 2. not lazyload
            // OK! correct processing
            // When QTree receives "expand" event, it call "onLazyLoad" if it hasn't yet been loaded 
        }
    }

    // スキーマを選択
    // keys.length == 2 == schema
    else if(keys.length == 2){
        // 大体は接続自体を選択したときと一緒
        // Same as above for the most part.
        if(node.children != null && node.children.length > 0){ // == lazyload is already over!
            handler[node.header].navi(node, newval)
        }
        else{
            // スキーマ自体はlazyloadされたら絶対に5つ(tables/triggers/views/events/routines)が入るから
            // node.childrenがない = lazyloadされてない

            // not running onLazyLoad
            // letter, run "onLazyLoad"

            // node.children.length == 0 is yet been loaded
            // cause this node has summaries of "tables" "triggers" "views" "events" "routines"
        }
    }

    // スキーマ以下機能を選択
    // summary of tables | views | triggers | routines | events
    else if(keys.length == 3){
        // 以下機能ではデータは既にあって要素はロードされている
        // data is exists!
        handler["schema"].navi(node, newval, keys[2])
    }

    // tables -> table名 選択みたいなとき
    // table | view | trigger | event
    else if(keys.length == 4){
        // データは既にあって要素はロードされている
        // 外からノード開くようにstore操作した場合親(tables/views/triggers/routines/events)要素が開いてないない
        // 場合があるので、閉じてたら開く

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

const onCloseTreeNode = (oldval:any) => {
    const node = leftTree.value?.getNodeByKey(oldval)
    leftTree.value?.setExpanded(oldval, false)
    // TODO purge store.selected* ?
}

// 何もしないデフォルトハンドラ
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
                const schemaNodes = TreeHelper.createNode(db.db_instance!.schemas, {
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
                const children = TreeHelper.createSchemaChildren(t, key,data)
                done(children)
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
} as {[K:string]:{exec:Function, navi:Function}}

const onLazyLoad  = ({ node, key, done, fail }:{node:any,key:string,done:(children:any[]) => any, fail:any}) => {
    handler[node.header].exec(node, key, done, fail)
    .finally(() => handler[node.header].navi(node, key))
}
</script>