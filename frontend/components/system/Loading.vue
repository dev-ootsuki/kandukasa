<template>
  <div class="loading" v-show="isLoading">
    <div class="loading-overlay" :style="styled">
        <q-spinner-cube color="primary" size="4em" />
    </div>
  </div>
</template>

<style>
.loading {
  display: block;
  position: absolute;
  z-index: 9999;
  left: 0;
  top: 0;
  width: "100%";
  height: "100%";
  overflow: "auto";
  background-color: "#000000";
  background-color: alpha(rgba(128, 128, 128, 0.514), 0.4);
}

.loading-overlay {
  background-color: rgba(0, 0, 0, 0.75);
  position: absolute;
  height: 100vh;
  width: 100vw;
  left: 0;
  top: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>

<script setup lang="ts">
import { useLoadingStore } from '~/stores/LoadingStore'
const store = useLoadingStore()
const { isLoading } = storeToRefs(store)
const styled = reactive({ 
    overlayPosition: {
        top: "0"
    }
})
watch(isLoading, async (newval, oldval) => {
    if(newval){
        styled.overlayPosition.top = window.pageYOffset + "px"
    }
})
</script>