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
    <DbdataColumnLinkedOperator class="q-pl-sm" :condition-size="props.conditionSize" :column="props.condition.column" :operator="props.condition.operator" @select="onSelectOperator" />
    <DbdataColumnOperatorLinkedInput :class="inputClassName" :column="props.condition.column" :operator="props.condition.operator" :value="props.condition.input[0]" @change="onChangeInput" />
    <DbdataColumnOperatorLinkedInput v-if="selectBetweenOperation" class="dbdata-search-condition-value-harf q-pl-sm" :column="props.condition.column" :operator="props.condition.operator" :value="props.condition.input[1]" @change="onChangeInput2nd" />
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { DbColumn } from '~/types/Domain.class'
import { DoubleParamsOperatorTypes } from '~/utils/UiHelper'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import DbdataColumnLinkedOperator from '~/components/dbdata/column/LinkedOperator.vue'
import DbdataColumnOperatorLinkedInput from '~/components/dbdata/column/OperatorLinkedInput.vue'

const props = defineProps<{
    columns: DbColumn[],
    condition: Design.SearchCondition,
    refs:any[],
    conditionSize:number
}>()
const db = useDbConnectionsStore().selectedDb
const inputClassName = ref("dbdata-search-condition-value q-pl-sm")
const selectBetweenOperation = computed(() => {
    const ret = DoubleParamsOperatorTypes.find(e => e.id ==props.condition.operator) != null
    if(ret)
        inputClassName.value = "dbdata-search-condition-value-harf q-pl-sm"
    return ret
})
const onSelectOperator = (id:number | undefined) => {
    props.condition.operator = id
    if(selectBetweenOperation)
        props.condition.input.push(null)
    else
        props.condition.input = [props.condition.input[0]]
}

const onChangeInput = (val:any) => {
    props.condition.input[0] = val
}
const onChangeInput2nd = (val:any) => {
    props.condition.input[1] = val
}

const conditionColumns = props.columns.filter(e => {
    return db?.db_instance?.ui_data_types?.findUiDataTypeByDbColumn(e) != "blob"
})

const onChangeColumn = () => {
    props.condition.input = [null]
    props.condition.operator = undefined
}
const current = getCurrentInstance()
const validate = () : boolean | Promise<boolean> | Promise<[boolean, boolean]> | Promise<[boolean, boolean, boolean]> => {
    const children:any = current!.subTree.children!
    const retOperator = children[1].component.exposed.validate() as boolean | Promise<boolean>
    const retInput = children[2].component.exposed.validate() as boolean | Promise<boolean>
    if(!selectBetweenOperation.value){
        if(!(retOperator instanceof Promise) && !(retInput instanceof Promise))
            return retOperator && retInput
        const promiseOperator = retOperator instanceof Promise ? retOperator : new Promise<boolean>(resolve => resolve(retOperator))
        const promiseInput = retInput instanceof Promise ? retInput : new Promise<boolean>(resolve => resolve(retInput))
        return Promise.all([promiseOperator,promiseInput])
    }
    else{
        const retInput2nd = children[3].component.exposed.validate() as boolean | Promise<boolean>
        if(!(retOperator instanceof Promise) && !(retInput instanceof Promise) && !(retInput2nd instanceof Promise))
            return retOperator && retInput && retInput2nd
        const promiseOperator = retOperator instanceof Promise ? retOperator : new Promise<boolean>(resolve => resolve(retOperator))
        const promiseInput = retInput instanceof Promise ? retInput : new Promise<boolean>(resolve => resolve(retInput))
        const promiseInput2nd = retInput2nd instanceof Promise ? retInput2nd : new Promise<boolean>(resolve => resolve(retInput2nd))
    
        return Promise.all([promiseOperator,promiseInput,promiseInput2nd])
    }
}
if(props.refs != null && props.refs.length == 0)
    props.refs.push(current)

defineExpose({ validate })

</script>