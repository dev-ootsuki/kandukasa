<script setup lang="ts">
import { useValidator } from '~/composables/Validator'
import type { Validator } from '~/types/Types'

const props = defineProps<{
    validate?: Validator.Rule[]
    label: string,
    model: any,
    type?: "password" | "text" | "time" | "date" | "textarea"
    readonly?: true | false
    icon?:string
}>()
const validatorArgs = props.validate
const validator = props.validate !== undefined ? useValidator(...validatorArgs!) : undefined
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
</script>

<template>
    <pf-element 
        :label="props.label" 
        :icon="props.icon" 
        :class="props.type === 'textarea' ? 'form-row-textarea' : undefined"
        :validate="props.validate"
    >
        <q-input 
            ref="innerInput"
            v-model="origin[attr]" 
            dense
            class="q-pa-sm" 
            :rules="validator" 
            lazy-rules 
            :type="props.type !== undefined ? props.type : 'text'"
            :disable="props.readonly === true ? true : false"
        >
            <template v-slot:prepend>
                <q-icon :name="props.icon" v-if="props.icon !== undefined" color="positive" />
            </template>
        </q-input>
    </pf-element>
</template>