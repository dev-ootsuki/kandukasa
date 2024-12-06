<template>
  <DialogConfirm ref="dialog" />
  <DialogAlert ref="alert" />
  <SearchConditionsDialog :columns="columns" ref="searchConditionsDialog" @close="bindSearchConditions"/>
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <LayoutBreadcrumbsDatabase />
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <q-card class="bg-eins text-eins">
        <q-tabs
          v-model="tab"
          dense
          inline-label
          align="left"
          indicator-color="text-eins"
          class="bg-secondary text-white shadow-2"
          :breakpoint="0"
        >
          <q-tab name="info" :label="$t('tables.info')" icon="info" />
          <q-tab name="data" :label="$t('tables.data')" icon="newspaper" />
        </q-tabs>

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="info">
            <q-table
              flat bordered dense
              :rows="columns!"
              :columns="TableHelper.createColumns($t)"
              row-key="column_name"
              virtual-scroll
              class="table-selected-delete sticky-header-table"
            />
          </q-tab-panel>
        </q-tab-panels>

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="data">
            <q-table
              flat bordered dense
              :rows="data"
              :columns="dataColumns"
              row-key="_internal_kandukasa_exchange_id_"
              virtual-scroll
              class="table-selected-delete sticky-header-table"
              selection="multiple"
              v-model:selected="multiSelected"
              v-model:pagination="pagination"
              :visible-columns="visibleColumns"
              @request="onSearch"
              :rows-per-page-options="system.rowPerPageOptions"
            >
              <template v-slot:top-left>
                <SystemBtnOperation mode="register" feature="dbdata" />
                <q-space class="q-pl-md" />
                <SystemBtnOperation mode="bulk_delete" feature="dbdata" @click="onBulkDeleteData" />
              </template>

              <template v-slot:top-right>
                <q-btn :label="$t('common.search_conditions')" icon="rule" color="primary" @click="showSearchConditions" />
                <q-btn round flat icon="refresh" text-color="primary" @click="onReload" />
                <q-space class="q-pl-md" />
                <q-select
                    v-model="visibleColumns"
                    multiple
                    outlined
                    dense
                    options-dense
                    :display-value="$q.lang.table.columns"
                    emit-value
                    map-options
                    :options="dataColumns"
                    option-value="name"
                    options-cover
                    class="select-table-filter-column"
                />
              </template>            
              <template v-slot:body-cell="props">
                <q-td :props="props">
                    <span v-if="props.col.name == system.dbDataPrimaryKey">
                        <SystemBtnOperation mode="update" feature="dbdata" mini class="q-mr-sm" @click="onEditRecord(props.row)" />
                        <SystemBtnOperation mode="delete" feature="dbdata" mini @click="onDeleteRecord(props.row)" />
                    </span>
                    <p v-if="props.col.name != system.dbDataPrimaryKey">
                        {{props.value}}
                    </p>
                </q-td>
              </template>
            </q-table>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>
    </div>
  </div>
</template>
  
<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
const store = useDbConnectionsStore()
const { selectedTable } = storeToRefs(store)
// 初期表示前の設定
if(selectedTable?.value == null)
    navigateTo('/')

import { useSystemStore } from '~/stores/SystemStore'
import { useI18n } from 'vue-i18n'
import type { Design } from '~/types/Types'
import SearchConditionsDialog from '~/pages/databases/tables/SearchConditionsDialog.vue'
const { t } = useI18n() 
const system = useSystemStore().systemSetting
const design = useSystemStore().designSetting
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")
const tab = ref('info')


if(store.selectedTable?.columns === undefined){
  await store.getTableInfo(selectedTable.value!.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!)
}
const searchConditions: { conditions: Design.SearchCondition[], andor:string} = { conditions:[], andor:"AND" }
const searchConditionsDialog = ref<InstanceType<typeof SearchConditionsDialog>>()
const showSearchConditions = () => {
  searchConditionsDialog.value!.show(searchConditions)
}
// データ表示のテーブルに関わる設定
const pagination = ref(design.createTablePagination())
pagination.value.sortBy = selectedTable.value!.primaries.at(0)?.column_name
// infoのカラム定義情報
const columns = selectedTable.value != null ? selectedTable.value!.columns : []
// データ表示テーブルのカラム
const dataColumns = TableHelper.createDataColumns(t, columns)
// データ表示テーブルの表示カラム
const visibleColumns = ref(dataColumns.map(e => e.name))
// データ自体
const data = ref<any[]>([])
// データ表示テーブルで選択中のレコード
const multiSelected = ref<any[]>([])
// 検索時
const onSearch = (props?: any) => {
  const condition = {
    pagination: props?.pagination !== undefined ? props.pagination : pagination.value.toPlain(),
    andor: searchConditions.andor,
    dbdata: {
        conditions: searchConditions.conditions.map(e => {
          return {
            column: e.column?.column_name,
            operator: e.operator,
            input: e == null ? [null] : e.input == null ? [null] : e.input
          }
      })
    }
  }
  store
    .getTableData(selectedTable.value?.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!, condition)
    .then(res => {
      data.value = res.results
      pagination.value = design.toPagination(res.pagination)
    })
}
// 初回は表示しないでタブ移動でデータにいった時にロードする
watch(tab, (newval, oldval) => {
  tab.value = newval
  if(newval == 'data' && data.value.length == 0){
    onSearch()
  }
})
// 検索条件閉じたとき
const bindSearchConditions = (v:any) => {
  searchConditions.andor = v.andor
  searchConditions.conditions = v.conditions
  onSearch()
}

// データテーブルで削除時@1レコード
const onDeleteRecord = (row:any) => {
  dialog.value!.onConfirm("delete", () : Promise<any> => {
        const keys = [row[system.dbDataPrimaryKey!]]
        return store.deleteTableData(selectedTable.value!.id!,selectedTable.value?.schema_id!, selectedTable.value?.table_id!, keys)
    }, () => {
        multiSelected.value = []
        onReload()
  })  
}
// 複数削除
const onBulkDeleteData = () => {
  if(multiSelected.value.length == 0){
    return alert.value.show(t('validate.no_select'))
  }
  dialog.value!.onConfirm("bulk_delete", () : Promise<any> => {
        const keys = multiSelected.value.map(e => e[system.dbDataPrimaryKey!])
        return store.deleteTableData(selectedTable.value!.id!,selectedTable.value?.schema_id!, selectedTable.value?.table_id!, keys)
    }, () => {
        multiSelected.value = []
        onReload()
  })  
}

const onReload = () => {
  pagination.value = design.createTablePagination()
  onSearch()
}

const onEditRecord = (row: any) => {

}

const onCreateNewData = () => {

}
</script>