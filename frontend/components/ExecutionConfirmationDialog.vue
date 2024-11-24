<template>
  <q-dialog v-model="model" persistent @hide="onHide" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
    <q-card class="bg-eins text-eins">
      <q-bar>
        <div>{{$t(title)}}</div>
      </q-bar>

      <q-space />

      <q-card-section class="row items-center">
        <q-avatar icon="warning" text-color="warning" flat size="6em" />
        <span class="q-ml-sm">{{$t('common.exec_confirm', [$t(title)])}}</span>
      </q-card-section>

      <q-card-actions align="right">
        <q-btn flat :label="$t('common.cancel').toUpperCase()" v-close-popup @click="onCancel" />
        <q-btn flat :label="$t('common.exec').toUpperCase()" v-close-popup @click="onSubmit" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script lang="ts" setup>
import { type Design } from '~/types/Types'

const props = defineProps<{
    title?: string,
    icon?: string,
    message?:string,
    mode: Design.UIMode
}>()
const title = computed(() => {
  if(props.title !== undefined)
    return props.title
  return UiHelper.uiModeToTitleKey(props.mode)
})

const model = defineModel<boolean>()
const emits = defineEmits(["cancel", "submit"])

const onCancel = () => {
    emits('cancel')
}
const onSubmit = () => {
    emits('submit')
}
const onHide = () => {
    model.value = false
}
</script>