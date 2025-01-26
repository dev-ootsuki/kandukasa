<template>
    <DialogRegistration slot-style="min-height:34vh;" :validator="isValid" ref="dialog" mode="register" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete" midium>
        <div class="q-ma-md">
            <DbForeignKey :columns="props.columns" ref="fkeyComponent" />
        </div>
    </DialogRegistration>
</template>

<script lang="ts" setup>
import { DbColumn } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
const visible = ref(false)
const mode = ref<Design.DialogEventType>("register")
const dialog = useTemplateRef("dialog")
const props = defineProps<{
    columns:DbColumn[]
}>()

const store = useDbConnectionsStore()
const fkeyComponent = useTemplateRef("fkeyComponent")

defineExpose({
    show:() => {
        visible.value = true
    }
})

const emits = defineEmits<{
  (e: 'complete', v:Design.DialogEventType): void,
}>()

const isValid = () : boolean | Promise<boolean> => {
    return fkeyComponent.value?.validate()!
}

const onSubmit = () => {
    const input = fkeyComponent.value!.get()
    store
        .createForeignKey(input)
        .then(data => {
            dialog.value!.complete()
        })
}

const onComplete = () => {
    emits("complete", mode.value)
    visible.value = false
    store
        .getTableInfo(store.selectedTable!.table_id!)
        .then(data => {
            onClose()
        })
}

const onClose = () => {
    visible.value = false
    fkeyComponent.value!.reset()
}
</script>