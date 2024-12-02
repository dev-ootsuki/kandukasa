<template>
    <q-btn 
        :label="props.mini === true ? undefined : $t(operation.label)" 
        :icon="operation.icon" 
        @click="onClick" 
        :color="color" 
        :class="clazz" 
        :to="props.to" 
        :size="props.mini === true ? '8px' : undefined" 
    />
</template>

<script lang="ts" setup>
import type { Design, Auth } from '~/types/Types'
import { UiHelper } from '~/utils/UiHelper'
const props = defineProps<{
    mode:Design.UIMode,
    color?:string,
    feature:Auth.FunctionsType,
    mini?:boolean,
    class?:string,
    to?:string
}>()
const operation = UiHelper.findSystemOperaion(props.mode)
const color = props.color !== undefined ? props.color : operation.danger ? 'negative' : 'primary'
const clazz = props.class !== undefined ? `${props.class}${props.mini === true ? " btn-inner-tables" : ""}` : props.mini === true ? "btn-inner-tables" : undefined
const emits = defineEmits(["click"])
const onClick = () => {
    emits("click")
}
</script>