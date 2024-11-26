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

const props = defineProps<{
    title?: string,
    icon?: string,
    message?:string
}>()

const visible = ref(false)
const title = computed(() => {
  if(props.title !== undefined)
    return props.title
  return UiHelper.uiModeToTitleKey(mode.value!)
})

const callbackSubmit = ref<() => Promise<any>>()
const callbackCancel = ref<Function>()
const callbackComplete = ref<Function>()
const callbackFailed = ref<Function>()
const mode = ref<Design.UIMode>("register")
const phaseComplete = ref<boolean>(false)
const phaseError = ref<boolean>(false)

defineExpose({
  onConfirm: (m:Design.UIMode, submit:() => Promise<any>, complete?: Function, failed?:Function, cancel?:Function) : void => {
    mode.value = m 
    callbackSubmit.value = submit
    callbackCancel.value = cancel
    callbackComplete.value = complete
    callbackFailed.value = failed
    visible.value = true
  }
})

const onCancel = () => {
  callbackCancel.value?.()
  onHide()
}
const onSubmit = () => {
  callbackSubmit.value?.()
  .catch(data => {
    phaseError.value = true
  })
  .finally(() => {
    if(phaseError.value !== true)
      phaseComplete.value = true
    else{
      callbackFailed.value?.()
      onHide()
    }
  })
}
const onComplete = () => {
  callbackComplete.value?.()
  onHide()
}
const onHide = () => {
  visible.value = false
  phaseComplete.value = false
  phaseError.value = false
  callbackSubmit.value = undefined
  callbackCancel.value = undefined
  callbackComplete.value = undefined
  callbackFailed.value = undefined
}
</script>