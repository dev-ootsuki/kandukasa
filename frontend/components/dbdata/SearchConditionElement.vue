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
    />
    <DbdataColumnLinkedOperator :column="props.condition.column" :operator="props.condition.operator" @select="onSelectOperator" />
    <DbdataColumnLinkedInput :column="props.condition.column" :operator="props.condition.operator" />
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { DbColumn } from '~/types/Domain.class'

const props = defineProps<{
    columns: DbColumn[],
    condition: Design.SearchCondition,
    all?:boolean
}>()

const onSelectOperator = (id:number) => {
    console.log("set operator ", id)
    props.condition.operator = id
}

const conditionColumns = props.columns

</script>