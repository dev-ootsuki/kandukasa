<template>
    <DialogRegistration :validator="validator" ref="dialog" mode="register" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete" :small="true">
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
    </DialogRegistration>
</template>

<script lang="ts" setup>
import { DbColumn } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore';
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

const validator = () : boolean => {
    let ret = true
    return ret
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