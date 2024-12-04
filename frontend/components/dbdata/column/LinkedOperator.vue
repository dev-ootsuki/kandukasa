<template>
    <q-select 
        :options="operators"
        v-model="selected"
        option-label="name"
        option-value="value"
        @update:model-value="onSelect"
        :rules="validator"
        ref="select"
        style="width: 150px;"
    />
</template>

<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { DbColumn } from '~/types/Domain.class'
import { QSelect } from 'quasar'
const { t } = useI18n()
const props = defineProps<{
    column:DbColumn,
    operator?:number,
    conditionSize:number
}>()
const store = useDbConnectionsStore()
const selected = ref()
const validator = useValidator(qRequired)
const dbDataType = store.selectedDb!.db_instance?.ui_data_types
const operators = computed(() => {
    const uiDataType = props.column != null ? dbDataType?.findUiDataTypeByDbColumn(props.column) : undefined
    selected.value = undefined
    return props.column != null ? UiHelper.generateColumnAvailableOperators(t, uiDataType!, props.column) : undefined
})
if(props.operator != null)
    selected.value = operators.value?.find(e => e.value == props.operator)

const select = ref<InstanceType<typeof QSelect>>()
const validate = () : boolean | Promise<boolean> => {
    if(props.column == null && props.conditionSize == 1)
        return true
    if(select.value != null){
        return select.value.validate()
    }
    return true
}
defineExpose({
    validate
})
const emits = defineEmits<{
  (e: 'select', v: number | undefined): void;
}>()
const onSelect = () => {
    emits('select', selected.value?.value)
}
</script>