<template>
  <q-dialog persistent v-model="dialog" @hide="onHide" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
    <q-card class="bg-eins text-eins error-dialog">
      <q-bar>
        <div>{{$t('common.encount_error')}} : {{last?.detail?.message}}</div>
      </q-bar>

      <q-space />

      <q-card-section class="row items-center">
        <q-avatar icon="error" text-color="negative" flat size="6em" />
        <span class="q-ml-sm text-negative text-h2 text-weight-bolder">{{last?.status}}</span>
        <span class="q-ml-md text-h5">[{{last?.method}}]</span>
        <span class="q-ml-sm text-h5">{{last?.url}}</span>
      </q-card-section>

      <q-expansion-item
        dense
        dense-toggle
        expand-separator
        icon="message"
        :label="last?.detail?.stackMessage"
        v-if="last?.detail?.stackTrace"
      >
        <q-card-section class="row q-pt-none">
          <span class="q-ml-sm" v-for="trace in last?.detail?.stackTrace">
            {{ trace }}
          </span>
        </q-card-section>
      </q-expansion-item>

      <q-card-actions align="right">
        <q-btn flat :label="$t('common.close').toUpperCase()" v-close-popup @click="onClose" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>
  
<script lang="ts" setup>
import { useErrorStore } from '~/stores/ErrorStore'

const emits = defineEmits(["close"])

const store = useErrorStore()
const { dialog, last } = storeToRefs(store)
const onClose = () => {
    emits('close')
}
const onHide = () => {
    dialog.value = false
}
</script>