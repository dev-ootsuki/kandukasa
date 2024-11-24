<template>
    <q-header elevated class="bg-drei text-drei">
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          @click="onClickMenu"
          aria-label="Menu"
          icon="menu"
        />
        <q-toolbar-title class="text-drei bg-drei">
          {{$t('app_name')}}
        </q-toolbar-title>
        <q-btn round flat icon="home" to="/" />
        <q-btn round flat icon="settings" to="/settings/" />
      </q-toolbar>
    </q-header>
</template>

<script lang="ts" setup>
const emits = defineEmits<{
  (e: 'onCollapse', v: null): void;
}>()
function onClickMenu () {
  emits("onCollapse", null)
}
</script>