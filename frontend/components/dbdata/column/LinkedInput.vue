<template>
    <!-- datetime / date / time -->
    <q-input 
        filled 
        dense 
        v-model="input" 
        :rules="validator" 
        :class="props.class"
        @update:model-value="onChange" 
        v-if="uiDataType == 'datetime' || uiDataType == 'date' || uiDataType == 'time'" 
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
    
    <!-- characters / text / numerics / giometries / floats / bit /binaries -->
     <q-input 
        v-model="input" 
        dense 
        :rules="validator" 
        :class="props.class"
        @update:model-value="onChange" 
        v-if="uiDataType == 'characters' || uiDataType == 'text' || uiDataType == 'numerics' || uiDataType == 'geometries' || uiDataType == 'floats' || uiDataType == 'bit' || uiDataType == 'binaries'" 
    />

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
      v-if="uiDataType == 'bool'"
    />

    <!-- blob (file) -->
    <q-input 
        type="file" 
        v-model="input" 
        dense
        :rules="validator"
        @update:model-value="onChange"
        :class="props.class"
        v-if="uiDataType == 'blob'"
    />
</template>

<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { DbColumn } from '~/types/Domain.class'
import type { Validator } from '~/types/Types'
import * as DomainClass from '~/types/Domain.class'
const props = defineProps<{
    column:DbColumn,
    value:any,
    class?:string
}>()
const store = useDbConnectionsStore()
const dbDataType = store.selectedDb!.db_instance?.ui_data_types
const emits = defineEmits<{
  (e: 'change', v: any): void;
}>()
const onChange = () => {
    emits("change", input.value)
}
const input = ref(props.value)

const uiDataType = computed<DomainClass.UiDataType>(() => {
    input.value = props.value
    return dbDataType!.findUiDataTypeByDbColumn(props.column)
})

const validator = computed(() => {
    const rules:Validator.Rule[] = []
    if(props.column == null)
        return useValidator(...rules)

    if(!props.column.is_nullable)
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

// TODO 外からvalidate呼べるようにする
defineExpose({
})
</script>