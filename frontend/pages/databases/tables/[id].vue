<template>
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
              :columns="UiHelper.createDataColumns(columns)"
              row-key="column_name"
              virtual-scroll
              class="table-selected-delete sticky-header-table"
            />
          </q-tab-panel>
        </q-tab-panels>
      </q-card>
    </div>
  </div>
</template>
  
<script lang="ts" setup>
import { useDbConnectionsStore } from '@/stores/DbConnectionsStore'
const store = useDbConnectionsStore()
const { selectedTable } = storeToRefs(store)
const tab = ref('info')
if(selectedTable?.value == null)
    navigateTo('/')

const data = ref<any[]>([])
if(store.selectedTable?.columns === undefined){
    await store.getTableInfo(selectedTable.value!.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!)
    data.value = await store.getTableData(selectedTable.value!.id!, selectedTable.value!.schema_id!, selectedTable.value!.table_id!)
}    
const columns = selectedTable.value != null ? selectedTable.value!.columns : []
</script>