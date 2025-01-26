<template>
    <DialogConfirm ref="dialog" :handler="handler" />
    <DialogForeignRegistration ref="registrationDialog" :columns="props.columns" />
    <DialogAlert ref="alert" />
    <q-table
        flat bordered dense
        :rows="foreigns"
        :columns="headerForeigns"
        row-key="column_name"
        class="table-selected-delete sticky-header-table"
        virtual-scroll
        :visible-columns="headerVisibleForeigns"
        selection="multiple"
        v-model:selected="multiSelected"
    >
        <template v-slot:top-left>
            <SystemBtnOperation mode="register" feature="dbdata" @click="onCreateFkey" />
            <q-space class="q-pl-md" />
            <SystemBtnOperation mode="bulk_delete" feature="dbdata" @click="onBulkDeleteFkey" />
        </template>

        <template v-slot:top-right>
            <q-space class="q-pl-md" />
            <q-select
                v-model="headerVisibleForeigns"
                multiple
                outlined
                dense
                options-dense
                :display-value="$q.lang.table.columns"
                emit-value
                map-options
                :options="headerForeigns"
                option-value="name"
                options-cover
                class="select-table-filter-column"
            />
        </template>
        <template v-slot:body-cell="props">
            <q-td :props="props">
                <span v-if="props.col.name == 'id'">
                    <SystemBtnOperation mode="delete" feature="dbfeatures" mini @click="onDeleteFkey(props.row)" />
                </span>
                <p v-if="props.col.name != 'id'">
                    {{props.value}}
                </p>
            </q-td>
        </template>

    </q-table>
</template>
<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { useI18n } from 'vue-i18n'
import { DbForeignKey, DbColumn } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import DialogForeignRegistration from './DialogForeignRegistration.vue'

const props = defineProps<{
    foreigns?:DbForeignKey[]
    columns:DbColumn[]
}>()

const store = useDbConnectionsStore()
const { t } = useI18n() 

// 共通系の定義
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")

// FKEY定義
// view上のヘッダ定義
const headerForeigns = TableHelper.createKeyColumnUsages(t, true)
// ヘッダを画面上で表示/非表示切り替えする時の見えるリスト
const headerVisibleForeigns = ref(headerForeigns.map(e => e.name))
// 操作するのでforeignsをpropsからrefにしておく
const foreigns = ref(props.foreigns == null ? [] : props.foreigns)
// 一括選択用
const multiSelected = ref<DbForeignKey[]>([])
// 単一項目削除用
const selectedRow = ref<DbForeignKey>()
// 登録用
const registrationDialog = useTemplateRef<any>("registrationDialog")

const onDeleteFkey = (row:any) => {
  selectedRow.value = row
  dialog.value.show("delete")
}
const onBulkDeleteFkey = () => {
    if(multiSelected.value.length == 0){
    return alert.value.show(t('validate.no_select'))
  }
  dialog.value!.show("bulk_delete")

}
const onCreateFkey = () => {
  registrationDialog.value.show()
}

const handler:Design.MultiDialogHandler = {
  delete: {
    submit:() : Promise<any> => {
      return store.deleteForeignKeys([selectedRow.value!])
    },
    complete: () => {
      store
        .getTableInfo(store.selectedTable!.table_id!)
        .then(data => {
        })
    }
  },
  bulk_delete: {
    submit: () : Promise<any> => {
        return store.deleteForeignKeys(multiSelected.value)
    },
    complete: () => {
        store
        .getTableInfo(store.selectedTable!.table_id!)
        .then(data => {
        })
    }
  }
}
</script>