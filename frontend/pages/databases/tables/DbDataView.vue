<template>
    <DialogConfirm ref="dialog" @submit="onSubmitDelete" @complete="onCompleteDelete" />
    <DialogAlert ref="alert" />
    <DialogSearchConditions :columns="columns" ref="searchConditionsDialog" @close="bindSearchConditions"/>
    <DialogDataRegistration :columns="columns" ref="dataRegistrationDialog" @complete="onReload" />
    <q-table
        flat bordered dense
        :rows="data"
        :columns="dataColumns"
        :row-key="system.dbDataPrimaryKey"
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
            <SystemBtnOperation mode="register" feature="dbdata" @click="onCreateRecord" />
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
</template>
<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
import type { Design } from '~/types/Types'
import DialogSearchConditions from '~/pages/databases/tables/DialogSearchConditions.vue'
import DialogDataRegistration from '~/pages/databases/tables/DialogDataRegistration.vue'
import { DbData, DbColumn } from '~/types/Domain.class'
import { useSystemStore } from '~/stores/SystemStore'

const store = useDbConnectionsStore()
const { selectedTable } = storeToRefs(store)
const design = useSystemStore().designSetting
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")
const { t } = useI18n() 
const system = useSystemStore().systemSetting

const props = defineProps<{
    columns:DbColumn[]
}>()
// 検索条件
const searchConditions: { conditions: Design.SearchCondition[], andor:string} = { conditions:[], andor:"AND" }
const searchConditionsDialog = ref<InstanceType<typeof DialogSearchConditions>>()
const dataRegistrationDialog = ref<InstanceType<typeof DialogDataRegistration>>()
const showSearchConditions = () => {
  searchConditionsDialog.value!.show(searchConditions)
}

// データ表示のテーブルに関わる設定
const pagination = ref(design.createTablePagination())
pagination.value.sortBy = selectedTable.value!.primaries.at(0)?.column_name
// データ表示テーブルのカラム
const dataColumns = TableHelper.createDataColumns(t, props.columns)
// データ表示テーブルの表示カラム
const visibleColumns = ref(dataColumns.map(e => e.name))
// データ自体
const data = ref<any[]>([])
// データ表示テーブルで選択中のレコード
const multiSelected = ref<any[]>([])
// 検索時
const onSearch = (props?: any) => {
  const condition = {
    pagination: props?.pagination !== undefined ? props.pagination : pagination.value.toPlain !== undefined ? pagination.value.toPlain() : pagination.value,
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
    .getTableData(condition)
    .then(res => {
      data.value = res.results
      pagination.value = design.toPagination(res.pagination)
    })
}
if(data.value.length == 0){
    onSearch()
}
// 検索条件閉じたとき
const bindSearchConditions = (v:any) => {
  searchConditions.andor = v.andor
  searchConditions.conditions = v.conditions
  onSearch()
}
// データ一覧で選んだレコード
const selectedRow = ref()
const handler: Design.MultiDialogHandler = {
    delete: {
        submit: () :Promise<any> => {
          const keys = [selectedRow.value[system.dbDataPrimaryKey!]]
          return store.deleteTableData(keys)
        },
        complete: () => {
          multiSelected.value = []
          onReload()
      }
    },
    bulk_delete: {
        submit: () : Promise<any> => {
          const keys = multiSelected.value.map(e => e[system.dbDataPrimaryKey!])
          return store.deleteTableData(keys)
        },
        complete: () => {
          multiSelected.value = []
          onReload()
        }
    }
}
const onSubmitDelete = (mode:Design.DialogEventType) => {
  handler[mode]!.submit()
  .then(data => {
    dialog.value.complete()
  })
  .catch(data => {
    dialog.value.hide()
  })
}
const onCompleteDelete = (mode:Design.DialogEventType) => {
  return handler[mode]?.complete?.()
}

// データテーブルで削除時@1レコード
const onDeleteRecord = (row:any) => {
  selectedRow.value = row
  dialog.value!.show("delete")  
}
// 複数削除
const onBulkDeleteData = () => {
  if(multiSelected.value.length == 0){
    return alert.value.show(t('validate.no_select'))
  }
  dialog.value!.show("bulk_delete")
}

const onReload = () => {
  pagination.value = design.createTablePagination()
  searchConditions .conditions = []
  searchConditions.andor = "AND"
  onSearch()
}

const onEditRecord = (row: any) => {
  dataRegistrationDialog.value!.show("update", row)
}

const onCreateRecord = () => {
  const data = new DbData(props.columns)
  dataRegistrationDialog.value!.show("register", data)
}
</script>