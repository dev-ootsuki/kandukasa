<template>
    <DialogRegistration :validator="isValid" ref="dialog" mode="register" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete" :small="true">
        <q-field
            borderless
            :model-value="selected"
            lazy-rules
            ref="validateField"
            :rules="validator"
        >
            <q-list>
                <q-item tag="label" v-ripple v-for="column in props.columns">
                    <q-item-section side top>
                        <q-checkbox v-model="selected" :val="column.column_name"/>
                    </q-item-section>
                    <q-item-section>
                        <q-item-label>{{column.column_name}}</q-item-label>
                        <q-item-label caption>{{column.column_type}}</q-item-label>
                    </q-item-section>
                    <q-item-section>
                        <q-item-label caption>{{column.column_comment}}</q-item-label>
                    </q-item-section>
                </q-item>
            </q-list>
        </q-field>
    </DialogRegistration>
</template>

<script lang="ts" setup>
import { DbColumn } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { qRequired } from '~/composables/ValidatorHelper'
import { useValidator } from '~/composables/Validator'
import { QField } from 'quasar'
const props = defineProps<{
    columns:DbColumn[]
}>()
const store = useDbConnectionsStore()
const visible = ref(false)
const mode = ref<Design.DialogEventType>("register")
const dialog = useTemplateRef("dialog")
const selected = ref([])
defineExpose({
    show:() => {
        visible.value = true
    }
})
const emits = defineEmits<{
  (e: 'complete', v:Design.DialogEventType): void,
}>()

const validator = useValidator(qRequired)
const validateField = useTemplateRef<QField>("validateField")
const isValid = () : boolean | Promise<boolean> => {
    return validateField.value!.validate()
}

const onSubmit = () => {
    store
        .createPrimaryKeys(selected.value)
        .then(data => {
            dialog.value!.complete()
        })
}

const onComplete = () => {
    emits("complete", mode.value)
    visible.value = false
}

const onClose = () => {
    visible.value = false
}
</script>