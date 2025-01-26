<template>
    <DialogConfirm ref="dialog" :handler="handler" />
    <DialogPrimaryRegistration ref="registrationDialog" :columns="props.columns" />
    <q-table
        flat bordered dense
        :rows="primaries"
        :columns="headerPrimaries"
        row-key="column_name"
        class="table-selected-delete sticky-header-table"
        virtual-scroll
        :visible-columns="headerVisiblePrimaries"
    >
        <template v-slot:top-left>
            <SystemBtnOperation v-if="props.primaries == null || props.primaries.length == 0" mode="register" feature="dbfeatures" @click="onCreatePkey" />
            <SystemBtnOperation v-if="props.primaries != null && props.primaries.length > 0 && !cantDeletePrimaryKey" mode="delete" feature="dbfeatures" @click="onDeletePkey" />
            <span v-if="cantDeletePrimaryKey">{{$t('tables.cannot_remove_pkey')}}</span>
        </template>

        <template v-slot:top-right>
            <q-space class="q-pl-md" />
            <q-select
                v-model="headerVisiblePrimaries"
                multiple
                outlined
                dense
                options-dense
                :display-value="$q.lang.table.columns"
                emit-value
                map-options
                :options="headerPrimaries"
                option-value="name"
                options-cover
                class="select-table-filter-column"
            />
        </template>
    </q-table>
</template>
<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { useI18n } from 'vue-i18n'
import { DbPrimaryKey, DbColumn } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import DialogPrimaryRegistration from './DialogPrimaryRegistration.vue'

const props = defineProps<{
    primaries?:DbPrimaryKey[]
    columns:DbColumn[]
}>()

const store = useDbConnectionsStore()
const { t } = useI18n() 

// 共通系の定義
const dialog = useTemplateRef<any>("dialog")

// PKEY定義
// view上のヘッダ定義
const headerPrimaries = TableHelper.createKeyColumnUsages(t)
// ヘッダを画面上で表示/非表示切り替えする時の見えるリスト
const headerVisiblePrimaries = ref(headerPrimaries.map(e => e.name))
// primaryの定義元カラム(複数あり)
const defPrimaries = props.primaries!.map(e => props.columns.find(c => c.column_name == e.column_name))
// pkeyが1つ、かつ、それがauto_incrimentなら消せない
const cantDeletePrimaryKey = defPrimaries != null && defPrimaries.length == 1 && defPrimaries[0]!.extra == 'auto_increment'
// 操作するのでprimaryをpropsからrefにしておく
const primaries = ref(props.primaries == null ? [] : props.primaries)

// 登録用
const registrationDialog = useTemplateRef<any>("registrationDialog")

const onDeletePkey = (row:any) => {
  dialog.value.show("delete")
}
const onCreatePkey = () => {
  registrationDialog.value.show()
}

const handler:Design.MultiDialogHandler = {
  delete: {
    submit:() : Promise<any> => {
      return store.deletePrimaryKey()
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