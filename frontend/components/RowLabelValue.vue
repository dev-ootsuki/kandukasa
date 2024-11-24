<template>
    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
        <div class="col-10 col-md-3">
            <strong>{{props.label}}</strong>
        </div>
        <div class="col-10 col-md-7">
            <strong v-if="!Array.isArray(props.value)">{{props.value}}</strong>
            <div v-for="each in props.value" v-if="Array.isArray(props.value)">
                <strong>{{each}}</strong>
            </div>
        </div>
    </div>
</template>
<script lang="ts" setup>
const props = defineProps<{
    label: string,
    value: any | any[]
}>()
</script>