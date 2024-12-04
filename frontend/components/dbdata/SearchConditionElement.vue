<template>
    <q-select
        :options="conditionColumns"
        outlined
        dense
        options-dense
        option-label="column_name"
        options-cover
        emit-value
        map-options
        class="variable-conditions-key"
        v-model="props.condition.column"
        @update:model-value="onChangeColumn"
    />
    <q-separator class="q-pl-sm" />
    <DbdataColumnLinkedOperator :column="props.condition.column" :operator="props.condition.operator" @select="onSelectOperator" ref="operator" />
    <q-separator class="q-pl-sm" />
    <DbdataColumnOperatorLinkedInput class="dbdata-search-condition-value" :column="props.condition.column" :operator="props.condition.operator" :value="props.condition.input" @change="onChangeInput" ref="input" />
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { DbColumn } from '~/types/Domain.class'

const props = defineProps<{
    columns: DbColumn[],
    condition: Design.SearchCondition,
    all?:boolean
}>()

const onSelectOperator = (id:number | undefined) => {
    props.condition.operator = id
}

const onChangeInput = (val:any) => {
    props.condition.input = val
}

const conditionColumns = props.columns

const onChangeColumn = () => {
    props.condition.input = null
    props.condition.operator = undefined
}

const validate = () : boolean => {
    return true
}

defineExpose({ validate })

</script>