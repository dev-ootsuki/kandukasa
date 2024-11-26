<template>
  <confirmation-dialog ref="dialog" />
  <alert-dialog ref="alert" />
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <databases-breadcrumbs />
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
              :columns="UiHelper.createColumns($t)"
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
            >
              <template v-slot:top-left>
                <q-btn icon="add" color="primary" :label="$t('common.new_registration_exec')" @click="onCreateNewData" />
                <q-space class="q-pl-md" />
                <q-btn icon="delete_forever" color="negative" :label="$t('common.bulk_delete_exec')" @click="onBulkDeleteData" />
              </template>

              <template v-slot:top-right>
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
                    <span v-if="props.col.name == '_internal_kandukasa_exchange_id_'">
                        <q-btn icon="edit" color="primary" size="8px" class="btn-inner-tables q-mr-sm" @click="onEditRecord(props.row)" />
                        <q-btn icon="delete_forever" color="negative" size="8px" class="btn-inner-tables q-mr-sm" @click="onDeleteRecord(props.row)" />
                    </span>
                    <p v-if="props.col.name != '_internal_kandukasa_exchange_id_'">
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
import { useSystemStore } from '~/stores/SystemStore'
import { useI18n } from 'vue-i18n'
const { t } = useI18n() 
const store = useDbConnectionsStore()
const design = useSystemStore().design
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")
const { selectedTable } = storeToRefs(store)
const tab = ref('info')

if(selectedTable?.value == null)
    navigateTo('/')

if(store.selectedTable?.columns === undefined){
  await store.getTableInfo(selectedTable.value!.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!)
}

const pagination = ref(design.createTablePagination())
pagination.value.sortBy = selectedTable.value!.primaries.at(0)?.column_name

const columns = selectedTable.value != null ? selectedTable.value!.columns : []
const dataColumns = UiHelper.createDataColumns(t, columns)
const visibleColumns = ref(dataColumns.map(e => e.name))

const data = ref<any[]>([])
const multiSelected = ref<any[]>([])

const onSearch = (props?: any) => {
  const condition = {
    pagination: props?.pagination !== undefined ? props.pagination : pagination.value.toPlain(),
    conditions: []
  }
  store
    .getTableData(selectedTable.value?.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!, condition)
    .then(res => {
      data.value = res.results
      pagination.value = design.toPagination(res.pagination)
    })
}

watch(tab, (newval, oldval) => {
  tab.value = newval
  if(newval == 'data' && data.value.length == 0){
    onSearch()
  }
})

const onEditRecord = (row: any) => {

}
const onDeleteRecord = (row:any) => {

}

const onBulkDeleteData = () => {
  if(multiSelected.value.length == 0){
    return alert.value.show(t('validate.no_select'))
  }
  dialog.value!.onConfirm("bulk_delete", () : Promise<any> => {
        return new Promise<any>((resolve) => {
            resolve(null)
        })
    }, () => {
        multiSelected.value = []
  })  
}

const onCreateNewData = () => {

}
</script>