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
        class="pf-color-picker-col"
        :validate="props.validate"
    >
        <q-input 
            ref="innerInput"
            v-model="origin[attr]" 
            :dense="true" 
            class="q-pa-sm pf-color-picker" 
            :rules="validator" 
            lazy-rules 
            :type="props.type !== undefined ? props.type : 'text'"
            :disable="props.readonly === true ? true : false"
        >
            <template v-slot:prepend>
                <q-icon name="colorize" class="cursor-pointer" :style="'color:' + origin[attr] + ';'">
                    <q-popup-proxy cover transition-show="scale" transition-hide="scale">
                        <q-color v-model="origin[attr]" />
                    </q-popup-proxy>
                </q-icon>
            </template>
        </q-input>

        <q-icon :name="props.icon !== undefined ? props.icon : 'star'" :style="'color:' + origin[attr] + ';'" size="3em" class="pf-color-picker-icon" />
        <q-badge color="eins" :style="'color:' + origin[attr] + ';'" >text color</q-badge>
    </pf-element>
</template>