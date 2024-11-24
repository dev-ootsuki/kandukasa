<template>
    <execution-confirmation-dialog :mode="operation" v-model="confirmDialog" @submit="onSubmit" />
    <q-table
        flat bordered dense
        :rows="tables!"
        :columns="UiHelper.createTableColumn($t)"
        row-key="table_name"
        virtual-scroll
        class="table-selected-delete sticky-header-table"
        selection="multiple"
        v-model:selected="multiSelected"
        v-model:pagination="defaultPagination"
    >
        <template v-slot:body-cell="props">
            <q-td :props="props">
                <span v-if="props.col.name == 'id'">
                    <q-btn icon="edit" color="primary" size="8px" class="btn-inner-tables q-mr-sm" />
                    <q-btn icon="edit_off" color="negative" size="8px" class="btn-inner-tables q-mr-sm" @click="onEraseTableData(props.row)" />
                    <q-btn icon="delete_forever" color="negative" size="8px" class="btn-inner-tables" @click="onDeleteTable(props.row)" />
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
import { type UIMode } from '~/types/Const'

const store = useDbConnectionsStore()
const tables = store.selectedSchema?.tables
const design = useSystemStore().designSetting
const defaultPagination = ref({ rowsPerPage: design.tablesPageSize })

const confirmDialog = ref(false)
let rowDomain = ref({})
const multiSelected = ref([])
const operation = ref<UIMode>("register")

const onEraseTableData = (target:any) => {
    rowDomain = target
    confirmDialog.value = true
    operation.value = "truncate"
}
const onDeleteTable = (target:any) => {
    rowDomain = target
    confirmDialog.value = true
    operation.value = "delete"
}
const onSubmit = () => {
    console.log(`${operation.value}`, rowDomain)
}
</script>

<style lang="sass">

/* https://quasar.dev/vue-components/table#example--sticky-header */

</style>