<template>
    <q-select 
        :options="operators"
        v-model="selected"
        option-label="name"
        option-value="value"
        @update:model-value="onSelect"
        style="width: 150px;"
    />
</template>

<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { DbColumn } from '~/types/Domain.class'
const { t } = useI18n()
const props = defineProps<{
    column:DbColumn,
    operator:number
}>()
const store = useDbConnectionsStore()
const selected = ref(props.operator)
const dbDataType = store.selectedDb!.db_instance?.ui_data_types
const operators = computed(() => {
    const uiDataType = props.column != null ? dbDataType?.findUiDataTypeByDbColumn(props.column) : undefined
    return props.column != null ? UiHelper.generateColumnAvailableOperators(t, uiDataType!, props.column) : undefined
})
// TODO expose validator
// TODO default 0
const emits = defineEmits<{
  (e: 'select', v: number): void;
}>()
const onSelect = () => {
    console.log("emits")
    emits('select', selected.value)
}
</script>