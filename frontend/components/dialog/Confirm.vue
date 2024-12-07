<template>
  <q-dialog v-model="visible" persistent @hide="onHide" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
    <q-card class="bg-eins text-eins">
      <q-bar>
        <div>{{$t(title)}}</div>
      </q-bar>

      <q-space />

      <q-card-section class="row items-center">
        <q-avatar icon="warning" text-color="warning" flat size="6em" />
        <span class="q-ml-sm" v-if="!phaseComplete">{{$t('common.exec_confirm', [$t(title)])}}</span>
        <span class="q-ml-sm" v-if="phaseComplete">{{$t('common.exec_complete', [$t(title)])}}</span>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat :label="$t('common.cancel').toUpperCase()" @click="onCancel" v-if="!phaseComplete" />
        <q-btn flat :label="$t('common.exec').toUpperCase()" @click="onSubmit" v-if="!phaseComplete" />
        <q-btn flat :label="$t('common.close').toUpperCase()" @click="onComplete" v-if="phaseComplete"/>
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script lang="ts" setup>
import { type Design } from '~/types/Types'
import { useErrorStore } from '~/stores/ErrorStore'
const errorStore = useErrorStore()
const props = defineProps<{
    title?: string,
    handler?:Design.MultiDialogHandler
}>()

const visible = ref(false)
const title = computed(() => {
  if(props.title !== undefined)
    return props.title
  return UiHelper.findSystemOperaion(mode.value!).label
})
const { dialog } = storeToRefs(errorStore)
const mode = ref<Design.DialogEventType>("register")
const phaseComplete = ref<boolean>(false)

const emits = defineEmits<{
  (e: 'submit', v:Design.DialogEventType): void,
  (e: 'cancel', v:Design.DialogEventType): void,
  (e: 'complete', v:Design.DialogEventType): void,
}>()


defineExpose({
  show: (m:Design.DialogEventType) : void => {
    mode.value = m
    visible.value = true
  },
  complete: () => {
    showComplete()
  },
  hide: () => {
    onHide()
  }
})

watch(dialog, async (newval:any, oldval:any) => {
  dialog.value = newval
  if(dialog.value)
    onHide()
})
const showComplete = () => {
  phaseComplete.value = true
  visible.value = true
}

const onCancel = () => {
  if(props.handler != null)
    props.handler[mode.value]?.cancel?.()
  emits('cancel', mode.value)
  onHide()
}
const onSubmit = () => {
  if(props.handler != null)
    props.handler[mode.value]?.submit()
      .then(data => {
        showComplete()
      })
      .catch(data => {
        onHide()
      })

  emits('submit', mode.value)
}
const onComplete = () => {
  if(props.handler != null)
    props.handler[mode.value]?.complete?.()
  emits('complete', mode.value)
  onHide()
}
const onHide = () => {
  visible.value = false
  phaseComplete.value = false
}
</script>