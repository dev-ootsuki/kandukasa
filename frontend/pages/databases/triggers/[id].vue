<template>
    <div class="q-pa-md">
      <q-toolbar class="content-header q-pa-sm">
        <LayoutBreadcrumbsDatabase />
      </q-toolbar>
      <div class="content-main q-pa-sm">
        <q-card class="bg-eins text-eins">
          <q-tabs
            v-model="tab"
            dense
            inline-label
            align="left"
            indicator-color="text-eins"
            class="bg-secondary text-white shadow-2"
            :breakpoint="0"
          >
            <q-tab name="info" :label="$t('routines.info')" icon="info" />
          </q-tabs>
  
          <q-tab-panels v-model="tab" animated>
            <q-tab-panel name="info">
            </q-tab-panel>
          </q-tab-panels>
  
        </q-card>
      </div>
    </div>
  </template>
    
  <script lang="ts" setup>
  import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
  const store = useDbConnectionsStore()
  const { selectedTrigger } = storeToRefs(store)
  const tab = ref('info')
  if(selectedTrigger?.value == null)
      navigateTo('/')
  </script>