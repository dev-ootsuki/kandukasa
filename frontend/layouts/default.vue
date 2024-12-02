<template>
  <SystemLoading />
  <DialogError />
  <q-layout view="lHh Lpr lFf" class="bg-eins text-eins">
    <LayoutHeader @onCollapse="collapseLeftmenu" />
    
    <q-drawer
      v-model="leftmenuOpen"
      show-if-above
      class="bg-zwei text-zwei"
      :width="systemStore.design.leftmenuWitdh"
    >
        <LayoutLeftmenu />
    </q-drawer>

    <q-page-container>
      <NuxtPage />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
import { useSystemStore } from '~/stores/SystemStore'
import { useAuthStore } from '~/stores/AuthStore'
import { useQuasar } from 'quasar'
import { useI18n } from 'vue-i18n';

// TODO あとでなおす？
const systemStore = useSystemStore()

const design = systemStore.design
const quasar = useQuasar()
quasar.lang = design.lang?.qResource
useI18n().locale.value = design.lang?.name!
const isDarckActive = quasar.dark.isActive
if(isDarckActive && design.isDark){
  // already darkmode
}
else if(isDarckActive && !design.isDark){
  // darkmode, but settings is not darkmode
  quasar.dark.toggle()
}
else if(!isDarckActive && design.isDark){
  // not darkmode, but settings is darkmode
  quasar.dark.toggle()
}
else{ // !isDarckActive && !design.isDark
  // not darkmode
}

const leftmenuOpen = ref(systemStore.design.leftmenuOpen)
function collapseLeftmenu () {
    leftmenuOpen.value = !leftmenuOpen.value
}
</script>