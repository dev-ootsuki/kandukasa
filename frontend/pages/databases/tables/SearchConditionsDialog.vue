<template>
  <q-dialog v-model="visible">
    <div class="row q-pa-sm row-label-value data-search-conditions-dialog">
      <q-card>
        <q-bar>
          <div>{{$t('common.search_conditions')}}</div>
        </q-bar>

        <q-space />

        <q-card-section class="row items-center">
          <q-avatar icon="rule" text-color="primary" flat size="6em" />
          <span class="q-ml-sm">{{$t('common.search_conditions_description')}}</span>
        </q-card-section>

        <q-card-section class="scroll" style="max-height: 50vh">
          <div class="row search-conditions-card" v-for="condition in conditions">
            <DbdataSearchConditionElement :condition-size="conditions.length" :columns="columns" :condition="condition" :ref="`condition_${condition.key}`" :refs="condition.refs"/>
            <q-btn flat round icon="remove" color="negative" @click="onRemoveSearchConditionsAt(condition.key)" />
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat round icon="add" color="accent" @click="onAppendSearchConditions" class="q-mr-sm" />
        </q-card-actions>

        <q-card-actions align="right">
          <q-btn flat :label="$t('common.clear')" @click="onClearSearchConditions" />
          <q-btn flat :label="$t('common.close')" @click="onClose" />
        </q-card-actions>
      </q-card>
    </div>
  </q-dialog>
</template>

<script lang="ts" setup>
import type { Design } from '~/types/Types'
import { DbColumn } from '~/types/Domain.class'
import DbdataSearchConditionElement from '~/components/dbdata/SearchConditionElement.vue'
// 検索条件
const visible = ref<boolean>(false)
const conditions = ref<Design.SearchCondition[]>([])
const createSearchConditionDefault = () => {
  return {column:null,input:null,key:0,refs:[]}
}
const props = defineProps<{
    columns:DbColumn[]
}>()
const onRemoveSearchConditionsAt = (key:number) => {
    conditions.value.splice(key, 1)
  // key = indexなので振り直す
    conditions.value.forEach((e, idx) => {
    e.key = idx
  })
  // 0件なら初回表示用に戻す
  if(conditions.value.length == 0)
    conditions.value.push(createSearchConditionDefault())
}
const onAppendSearchConditions = () => {
  const appendElement = createSearchConditionDefault()
  appendElement.key = conditions.value.length
  conditions.value.push(appendElement)
}
const onClearSearchConditions = () => {
  conditions.value.splice(0, conditions.value.length)
  conditions.value.push(createSearchConditionDefault())
}

const emits = defineEmits<{
  (e: 'close', v: Design.SearchCondition[]): void;
}>()

const onClose = () => {
  const promised:Promise<boolean>[] = []
  let result = true
  conditions.value.forEach(e => {
    if(e.refs[0] == null || e.refs[0].exposed === undefined)
      return true
    const ret = e.refs[0].exposed.validate()
    if(ret instanceof Promise){
      promised.push(ret)
      return true
    }
    result = result && ret
  })
  if(promised.length == 0 && result){
    emits("close", conditions.value)
    visible.value = false
  }
  else{
    Promise.all(promised)
    .then(data => {
      const error = data.find(e => {
        return !e
      })
      if(error === null){
        emits("close", conditions.value)
        visible.value = false
      }
    })
    .catch(data => {

    })
  }
}

defineExpose({
  show: (args: Design.SearchCondition[]) => {
    conditions.value = args
    visible.value = true
    if(conditions.value.length == 0)
      conditions.value.push(createSearchConditionDefault())
  }
})
</script>