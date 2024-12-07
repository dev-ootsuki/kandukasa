<template>
    <DialogConfirm ref="confirm" @submit="onConfirmSubmit" @complete="onComplete" />
    <q-dialog persistent v-model="visible" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
        <div class="row q-pa-sm data-search-conditions-dialog">
            <q-card>
                <q-bar>
                    <div>
                        <span>{{$t(title)}}</span>
                    </div>
                </q-bar>
        
                <q-space />

                <q-card-section>
                    <slot />
                </q-card-section>

                <q-card-actions align="right">
                    <q-btn flat :label="$t('common.close').toUpperCase()" @click="onClose" />
                    <q-btn flat :label="$t('common.exec').toUpperCase()" @click="onSubmit" />
                </q-card-actions>
            </q-card>
        </div>
    </q-dialog>
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
const props = defineProps<{
    mode: Design.DialogEventType,
    visible:boolean
}>()
const visible = computed(() => props.visible)
const title = computed(() => {
  return UiHelper.findSystemOperaion(props.mode).label
})
const confirm = useTemplateRef("confirm")
const emits = defineEmits<{
  (e: 'submit', v:Design.DialogEventType): void,
  (e: 'close', v:Design.DialogEventType): void,
  (e: 'complete', v:Design.DialogEventType): void,
}>()

defineExpose({
    complete: () => {
        confirm.value!.complete()
    }
})

const onSubmit = () => {
    confirm.value?.show(props.mode)
}
const onConfirmSubmit = () => {
    emits("submit", props.mode)
}
const onComplete = () => {
    emits("complete", props.mode)
}
const onClose = () => {
    emits("close", props.mode)
}
</script>