<template>
    <DialogConfirm ref="dialog" />
    <DialogAlert ref="alert" />
    <q-table
        flat bordered dense
        :rows="tables!"
        :columns="tableColumns"
        row-key="table_name"
        virtual-scroll
        class="table-selected-delete sticky-header-table"
        selection="multiple"
        v-model:selected="multiSelected"
        v-model:pagination="pagination"
        :visible-columns="visibleColumns"
        :filter-method="filteringRows"
        :filter="filterColumns"
    >
        <template v-slot:top-left>
            <SystemBtnOperation mode="register" feature="dbfeatures" />
            <q-space class="q-pl-md" />
            <SystemBtnOperation mode="bulk_truncate" feature="dbdata" @click="onBulkTruncateTable" />
            <q-space class="q-pl-md" />
            <SystemBtnOperation mode="bulk_delete" feature="dbfeatures" @click="onBulkDeleteTable" />
        </template>
        <template v-slot:top-right>
            <q-input borderless dense debounce="300" v-model="filterColumns.table_name" :placeholder="$t('metadata.table_name')">
                <template v-slot:append>
                    <q-icon name="search" />
                </template>
            </q-input>
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
                :options="tableColumns"
                option-value="name"
                options-cover
                class="select-table-filter-column"
            />
        </template>
        <template v-slot:body-cell="props">
            <q-td :props="props">
                <span v-if="props.col.name == 'id'">
                    <q-btn icon="shortcut" color="primary" size="8px" class="btn-inner-tables q-mr-sm" @click="onSelectTable(props.row)" />
                    <SystemBtnOperation mode="truncate" feature="dbdata" mini @click="onEraseTableData(props.row)" class="q-mr-sm" />
                    <SystemBtnOperation mode="delete" feature="dbfeatures" mini @click="onDeleteTable(props.row)" />
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
import { useSystemStore } from '~/stores/SystemStore'
import { UiHelper } from '~/utils/UiHelper'
import { useI18n } from 'vue-i18n'
const { t } = useI18n()

const props = defineProps<{
    connection: string | number,
    schema: string
}>()

const store = useDbConnectionsStore()
const dialog = useTemplateRef<any>("dialog")
const alert = useTemplateRef<any>("alert")
const tables = store.selectedSchema?.tables
const design = useSystemStore().designSetting
const pagination = ref(design.createTablePagination())

const multiSelected = ref([])
const tableColumns = UiHelper.createTableColumn(t)
const visibleColumns = ref(tableColumns.map(e => e.name))
const filterColumns = reactive({table_name:null})
const filteringRows = (rows: readonly any[], terms: any, cols: readonly any[], getCellValue: (col: any, row: any) => any) : readonly any[]  => {
    return rows.filter(e => {
        if(filterColumns.table_name == null || filterColumns.table_name == '')
            return true
        return e.table_name.indexOf(filterColumns.table_name) >= 0
    })
}

const onCreateNewTable = () => {

}

const onSelectTable = (target: any) => {
    store.selectedNode = [
        props.connection,
        props.schema,
        UiHelper.getSchemaSummary("tables").mode,
        target.table_id
    ].join(".")
}

const onEraseTableData = (target:any) => {
    dialog.value!.onConfirm("truncate", () : Promise<any> => {
        return new Promise<any>((resolve) => {
            resolve(null)
        })
    })
}
const onDeleteTable = (target:any) => {
    dialog.value!.onConfirm("delete", () : Promise<any> => {
        return new Promise<any>((resolve) => {
            resolve(null)
        })
    })
}

const onBulkDeleteTable = () => {
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

const onBulkTruncateTable = () => {
    if(multiSelected.value.length == 0){
        return alert.value.show(t('validate.no_select'))
    }
    dialog.value!.onConfirm("bulk_truncate", () : Promise<any> => {
        return new Promise<any>((resolve) => {
            resolve(null)
        })
    }, () => {
        multiSelected.value = []
    })
}

</script>
