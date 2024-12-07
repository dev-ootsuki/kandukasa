<template>
    <!-- not taget null operation -->
    <DbdataColumnLinkedInput v-if="!selectNullOperation" :column="props.column" :value="props.value" :class="props.class" @change="onChange" ref="input" />
    <!-- target null operation -->
    <span class="q-pt-sm q-pl-md dbdata-search-condition-value" v-if="selectNullOperation">{{ $t('dbdata.compare.compare_nullable') }}</span>
</template>

<script lang="ts" setup>
import { DbColumn } from '~/types/Domain.class'
import { QInput } from 'quasar'
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
const input = ref<InstanceType<typeof QInput>>()
defineExpose({
    validate: () : boolean | Promise<boolean> => {
        if(input.value != null)
            return input.value.validate()
        return true
    }
})
// TODO between だったら入力2つ出す

// TODO クリア押した時にカラム選択した時だけ1行目のバリデーション聞かない
</script>