<template>
    <div class="q-pa-md">
      <q-toolbar class="content-header q-pa-sm">
        <databases-breadcrumbs />
      </q-toolbar>
    </div>
  </template>
  
  <script lang="ts" setup>
  import { useDbConnectionsStore } from '@/stores/DbConnectionsStore'
  const store = useDbConnectionsStore()
  const { selectedTable } = storeToRefs(store)
  if(selectedTable?.value == null)
      navigateTo('/')
  </script>