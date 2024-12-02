<script setup lang="ts">
import { UiHelper } from '~/utils/UiHelper'
import { qRequired  } from '~/composables/ValidatorHelper'
const props = defineProps<{
    label: string,
    model: any,
    options:{
        label:string, 
        value:any, 
        category?:number
        disable?:boolean
    }[]
    require?:boolean,
    readonly?: boolean
    icon?:string
}>()
const validator = props.require === true ? useValidator(qRequired) : []
const empty = [{ label: '', value: null }]
const mergeOps = [...(props.require !== true ? [empty] : []), ...props.options]
const attr = UiHelper.getRefId()
const origin = props.model.usePrimary()
const innerInput = useTemplateRef("innerInput")

const validate = () : boolean => {
    const val:any = innerInput.value
    if(val.validate !== undefined)
        return val.validate()
    return true
}
defineExpose({
    validate
})
const selected = ref(origin[attr])
watch(selected, (valnew,valold) => {
    if(valnew != null){
        selected.value = valnew
        origin[attr] = selected.value.value
    }
})
</script>

<template>
    <pf-element 
        :label="props.label" 
        :icon="props.icon" 
        :validate="props.require === true ? [qRequired] : undefined">
        <q-select 
            ref="innerInput"
            :options="mergeOps" 
            v-model="selected"
            dense
            class="q-pa-sm" 
            :rules="validator" 
            filled
            :disable="props.readonly === true ? true : false"
        />
    </pf-element>
</template>