<template>
    <!-- datetime / date / time -->
    <q-input 
        filled 
        dense 
        v-model="input" 
        :rules="validator" 
        :class="props.class"
        @update:model-value="onChange" 
        ref="datetime"
        v-if="componentTypeName == 'datetime'" 
    >
        <template v-slot:prepend v-if="uiDataType == 'datetime' || uiDataType == 'date'">
            <q-icon name="event" class="cursor-pointer">
                <q-popup-proxy cover transition-show="scale" transition-hide="scale">
                <q-date v-model="input" mask="YYYY-MM-DD HH:mm" @update:model-value="onChange">
                    <div class="row items-center justify-end">
                        <q-btn v-close-popup label="Close" color="primary" flat />
                    </div>
                </q-date>
                </q-popup-proxy>
            </q-icon>
        </template>

        <template v-slot:append v-if="uiDataType == 'datetime' || uiDataType == 'time'">
            <q-icon name="access_time" class="cursor-pointer">
                <q-popup-proxy cover transition-show="scale" transition-hide="scale" @update:model-value="onChange">
                <q-time v-model="input" mask="YYYY-MM-DD HH:mm" format24h>
                    <div class="row items-center justify-end">
                    <q-btn v-close-popup label="Close" color="primary" flat />
                    </div>
                </q-time>
                </q-popup-proxy>
            </q-icon>
        </template>
    </q-input>
    
    <!-- boolean -->
    <q-toggle
      :label="input == null ? 'FALSE' : input === 0 ? 'FALSE' : 'TRUE'"
      color="negative"
      :false-value="0"
      :true-value="1"
      v-model="input"
      :rules="validator"
      @update:model-value="onChange"
      :class="props.class"
      ref="bool"
      v-if="componentTypeName == 'bool'"
    />

    <!-- blob (file) -->
    <q-input 
        type="file" 
        v-model="input" 
        dense
        :rules="validator"
        @update:model-value="onChange"
        :class="props.class"
        ref="file"
        v-if="componentTypeName == 'file'"
    />
    <!-- characters / text / numerics / giometries / floats / bit /binaries -->
    <q-input 
        v-model="input" 
        dense 
        :rules="validator" 
        :class="props.class"
        @update:model-value="onChange" 
        ref="characters"
        v-if="componentTypeName == 'characters'" 
    />


</template>

<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { DbColumn } from '~/types/Domain.class'
import type { Validator } from '~/types/Types'
import * as DomainClass from '~/types/Domain.class'
import { QInput, QToggle, QDate } from 'quasar'
const props = defineProps<{
    column:DbColumn,
    value:any,
    class?:string
}>()
const store = useDbConnectionsStore()
const dbDataType = store.selectedDbDataTypes
const input = ref(props.value)

const uiDataType = computed<DomainClass.UiDataType>(() => {
    input.value = props.value
    return dbDataType!.findUiDataTypeByDbColumn(props.column)
})
const componentTypeName = computed(() => {
    if(uiDataType.value == 'datetime' || uiDataType.value == 'date' || uiDataType.value == 'time')
        return "datetime"
    if(uiDataType.value == 'bool')
        return "bool"
    if(uiDataType.value == "blob")
        return "file"
    // == uiDataType == 'characters' || uiDataType == 'text' || uiDataType == 'numerics' || 
    // uiDataType == 'geometries' || uiDataType == 'floats' || uiDataType == 'bit' || uiDataType == 'binaries'
    return "characters"
})
const datetime = ref<InstanceType<typeof QInput>>()
const bool = ref<InstanceType<typeof QToggle>>()
const characters = ref<InstanceType<typeof QInput>>()
const file = ref<InstanceType<typeof QInput>>()
const componentMap = { datetime, bool, characters, file }

const validator = computed(() => {
    const rules:Validator.Rule[] = []
    if(props.column == null)
        return useValidator(...rules)

    // カラムがnullableでも検索条件としては必要
    rules.push(qRequired)

    if(uiDataType.value == "numerics")
        rules.push(qNumber)

    if(uiDataType.value == "floats")
        rules.push(qFloat)

    if(uiDataType.value == "characters"){
        const clengthRule:Validator.Rule = {
            to: props.column.character_maximum_length,
            rule: 'clength',
            message: 'length_to'
        }
        rules.push(clengthRule)
    }

    // TODO floatsとかの実装
    return useValidator(...rules)
})
const emits = defineEmits<{
  (e: 'change', v: any): void;
}>()
const onChange = () => {
    emits("change", input.value)
}

defineExpose({
    validate: () : boolean | Promise<boolean> => {
        const input = componentMap[componentTypeName.value]
        if(input.value == null)
            return true
        if((input.value as any).validate !== undefined)
            return (input.value as any).validate()
        return true
    }
})
</script>