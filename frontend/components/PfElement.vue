<script setup lang="ts">
import type { Validator } from '~/types/Types'

const props = defineProps<{
    label: string,
    icon?: string,
    class?: string,
    validate?:Validator.Rule[]
}>()
const isRequired = props.validate?.find(e => e.rule == "required")
</script>

<template>
    <div class="row form-row" :class="props.class">
        <div class="col-12 col-md-4 text-eins bg-eins">
            <strong>{{label}}</strong>
            <q-badge class="q-ml-sm" color="negative" v-if="isRequired">{{$t('common.required')}}</q-badge>
        </div>
        <div class="col-12 col-md-7 bg-eins text-eins">
            <slot />
        </div>
        <div class="col-12 col-md-1">
            <q-space />
        </div>
    </div>
</template>