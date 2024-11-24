<template>
  <app-loading />
  <error-dialog />
  <q-layout view="lHh Lpr lFf" class="bg-eins text-eins">
    <Header @onCollapse="collapseLeftmenu" />
    
    <q-drawer
      v-model="leftmenuOpen"
      show-if-above
      class="bg-zwei text-zwei"
      :width="systemStore.design.leftmenuWitdh"
    >
        <leftmenu />
    </q-drawer>

    <q-page-container>
      <NuxtPage />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { useSystemStore } from '~/stores/SystemStore'
import { useAuthStore } from '~/stores/AuthStore'
// TODO あとでなおす？
const systemStore = useSystemStore()
const leftmenuOpen = ref(systemStore.design.leftmenuOpen)
function collapseLeftmenu () {
    leftmenuOpen.value = !leftmenuOpen.value
}
</script>