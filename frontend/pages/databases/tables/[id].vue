<template>
  <DialogConfirm ref="dialog" @submit="onSubmitDelete" @complete="onCompleteDelete" />
  <DialogAlert ref="alert" />
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
              :columns="defColumns"
              row-key="column_name"
              class="table-selected-delete sticky-header-table"
              selection="multiple"
              v-model:selected="multiDefSelected"
              virtual-scroll
              :visible-columns="defVisibleColumns"
            >
              <template v-slot:top-right>
                  <q-space class="q-pl-md" />
                  <q-select
                      v-model="defVisibleColumns"
                      multiple
                      outlined
                      dense
                      options-dense
                      :display-value="$q.lang.table.columns"
                      emit-value
                      map-options
                      :options="defColumns"
                      option-value="name"
                      options-cover
                      class="select-table-filter-column"
                  />
                </template>
                <template v-slot:body-cell="props">
                <q-td :props="props">
                    <span v-if="props.col.name == system.dbDataPrimaryKey">
                        <SystemBtnOperation mode="update" feature="dbfeatures" mini class="q-mr-sm" @click="onEditColDef(props.row)" />
                        <SystemBtnOperation mode="delete" feature="dbfeatures" mini @click="onDeleteColDef(props.row)" />
                    </span>
                    <p v-if="props.col.name != system.dbDataPrimaryKey">
                        {{props.value}}
                    </p>
                </q-td>
              </template>
            </q-table>
          </q-tab-panel>
        </q-tab-panels>

        <q-tab-panels v-model="tab" animated>
          <q-tab-panel name="data">
            <DataView :columns="columns"/>
          </q-tab-panel>
        </q-tab-panels>
      </q-card>
    </div>
  </div>
</template>
  
<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import DataView from '~/pages/databases/tables/data.vue'
import { useI18n } from 'vue-i18n'
const store = useDbConnectionsStore()
const { selectedTable } = storeToRefs(store)
const { t } = useI18n() 

// 初期表示前の設定
if(selectedTable?.value == null)
    navigateTo('/')

import { useSystemStore } from '~/stores/SystemStore'

// 共通系の定義
const system = useSystemStore().systemSetting
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")
const tab = ref('info')

// カラム定義
if(store.selectedTable?.columns === undefined){
  await store.getTableInfo(selectedTable.value!.table_id!)
}
const defColumns = TableHelper.createColumns(t)
const defVisibleColumns = ref(defColumns.map(e => e.name))
const multiDefSelected = ref([])

// infoのカラム定義情報
const columns = selectedTable.value != null ? selectedTable.value!.columns : []

const onSubmitDelete = () => {

}
const onCompleteDelete = () => {

}
</script>