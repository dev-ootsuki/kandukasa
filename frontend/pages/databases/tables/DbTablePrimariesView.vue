<template>
    <DialogConfirm ref="dialog" :handler="handler" />
    <q-table
        flat bordered dense
        :rows="primaries"
        :columns="defPrimaries"
        row-key="column_name"
        class="table-selected-delete sticky-header-table"
        virtual-scroll
        :visible-columns="defVisiblePrimaries"
    >
        <template v-slot:top-left>
            <SystemBtnOperation v-if="props.primaries == null || props.primaries.length == 0" mode="register" feature="dbfeatures" @click="onCreatePkey" />
            <SystemBtnOperation v-if="props.primaries != null && props.primaries.length > 0 && !cantDeletePrimaryKey" mode="delete" feature="dbfeatures" @click="onDeletePkey" />
            <span v-if="cantDeletePrimaryKey">{{$t('tables.cannot_remove_pkey')}}</span>
        </template>

        <template v-slot:top-right>
            <q-space class="q-pl-md" />
            <q-select
                v-model="defVisiblePrimaries"
                multiple
                outlined
                dense
                options-dense
                :display-value="$q.lang.table.columns"
                emit-value
                map-options
                :options="defPrimaries"
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

const props = defineProps<{
    primaries?:DbPrimaryKey[]
    columns:DbColumn[]
}>()

const store = useDbConnectionsStore()
const { t } = useI18n() 

// 共通系の定義
const dialog = useTemplateRef<any>("dialog")

// PKEY定義
const defPrimaries = TableHelper.convertColumn(props.primaries == null || props.primaries.length == 0 ? undefined : props.primaries?.[0], t)
const defVisiblePrimaries = ref(defPrimaries.map(e => e.name))
const cantDeletePrimaryKey = defPrimaries.map(e => props.columns.find(c => c.extra == "auto_increment")?.column_name == e.column_name) != null
const primaries = ref(props.primaries == null ? [] : props.primaries)
console.log(defPrimaries)

const onDeletePkey = (row:any) => {
  dialog.value.show("delete")
}
const onCreatePkey = () => {

}

const handler:Design.MultiDialogHandler = {
  delete: {
    submit:() : Promise<any> => {
      return store.deletePrimaryKey()
    },
    complete: () => {
        // TODO リロード？
    }
  }
}
</script>