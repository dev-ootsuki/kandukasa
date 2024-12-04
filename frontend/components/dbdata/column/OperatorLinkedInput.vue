<template>
    <!-- not taget null operation -->
    <DbdataColumnLinkedInput v-if="!selectNullOperation" :column="props.column" :value="props.value" :class="props.class" @change="onChange" />
    <!-- target null operation -->
    <span class="q-pt-sm dbdata-search-condition-value" v-if="selectNullOperation">{{ $t('dbdata.compare.compare_nullable') }}</span>
</template>

<script lang="ts" setup>
import { DbColumn } from '~/types/Domain.class'
const props = defineProps<{
    column:DbColumn,
    operator?:number,
    value:any,
    class?:string
}>()
const selectNullOperation = computed(() => {
    return NullableOnlyOperatorTypes.find(e => e.id == props.operator) != null
})
const emits = defineEmits<{
  (e: 'change', v: any): void;
}>()
const onChange = (v:any) => {
    emits("change", v)
}

// TODO between だったら入力2つ出す
</script>