<template>
    <q-select
    :options="conditionColumns"
    outlined
    dense
    options-dense
    option-value="name"
    options-cover
    emit-value
    map-options
    class="variable-conditions-key"
    v-model="props.condition.column"
    />
    <DbdataColumnLinkedOperator />
    <DbdataColumnLinkedInput />
    ここに演算子がいる
    <q-input v-model="props.condition.input" dense class="variable-conditions-value q-pl-md" />
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { useSystemStore } from '~/stores/SystemStore'
const system = useSystemStore().systemSetting

const props = defineProps<{
    columns: Design.DataColumn[],
    condition: Design.SearchCindition,
    all?:boolean
}>()

const conditionColumns = props.columns.filter(e => e.name != system.dbDataPrimaryKey)

</script>