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
    <DbdataColumnLinkedOperator :condition-size="props.conditionSize" :column="props.condition.column" :operator="props.condition.operator" @select="onSelectOperator" ref="refOperator" />
    <q-separator class="q-pl-sm" />
    <DbdataColumnOperatorLinkedInput class="dbdata-search-condition-value" :column="props.condition.column" :operator="props.condition.operator" :value="props.condition.input" @change="onChangeInput" ref="refInput" />
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { DbColumn } from '~/types/Domain.class'
import DbdataColumnLinkedOperator from '~/components/dbdata/column/LinkedOperator.vue'
import DbdataColumnOperatorLinkedInput from '~/components/dbdata/column/OperatorLinkedInput.vue'

const props = defineProps<{
    columns: DbColumn[],
    condition: Design.SearchCondition,
    refs:any[],
    conditionSize:number
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
const current = getCurrentInstance()
const validate = () : boolean | Promise<boolean> | Promise<[boolean, boolean]> => {
    const children:any = current!.subTree.children!
    const retOperator = children[2].component.exposed.validate() as boolean | Promise<boolean>
    const retInput = children[4].component.exposed.validate() as boolean | Promise<boolean>
    if(!(retOperator instanceof Promise) && !(retInput instanceof Promise))
        return retOperator && retInput
    const promiseOperator = retOperator instanceof Promise ? retOperator : new Promise<boolean>(resolve => resolve(retOperator))
    const promiseInput = retInput instanceof Promise ? retInput : new Promise<boolean>(resolve => resolve(retInput))
    return Promise.all([promiseOperator,promiseInput])
}
if(props.refs.length == 0)
    props.refs.push(current)

defineExpose({ validate })

</script>