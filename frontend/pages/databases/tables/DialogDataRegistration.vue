<template>
    <DialogRegistration ref="dialog" :mode="mode" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete">
        <div v-for="column in props.columns">
            {{ column.column_name }}
        </div>
    </DialogRegistration>
</template>

<script lang="ts" setup>
import { DbColumn, DbData } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
const visible = ref(false)
const mode = ref<Design.DialogEventType>("register")
const props = defineProps<{
    columns:DbColumn[]
}>()
const dialog = useTemplateRef("dialog")
defineExpose({
    show:(arg: Design.DialogEventType, data: DbData) => {
        mode.value = arg
        visible.value = true
    }
})
const emits = defineEmits<{
  (e: 'complete', v:Design.DialogEventType): void,
}>()


const onSubmit = () => {
    let promise:Promise<any> | null = null
    if(mode.value == "register"){
        promise = new Promise<any>((resolve) => resolve(true))
    }
    else{
        promise = new Promise<any>((resolve) => resolve(true))
    }
    promise!.then(data => {
        dialog.value!.complete()
    })
}

const onComplete = () => {
    emits("complete", mode.value)
}

const onClose = () => {
    visible.value = false
}
</script>