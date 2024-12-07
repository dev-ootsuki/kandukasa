<template>
  <q-dialog persistent v-model="visible" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
    <div class="row q-pa-sm data-search-conditions-dialog">
      <q-card>
        <q-bar>
          <div>
            <span>{{$t('common.search_conditions')}}</span>
          </div>
        </q-bar>

        <q-space />

        <q-card-section class="row items-center">
          <q-avatar icon="rule" text-color="primary" flat size="6em" />
          <span class="q-ml-sm">{{$t('common.search_conditions_description')}}</span>
          <span>{{$t('dbdata.compare.and_or_description_start') }}</span>
            <q-toggle
            v-model="searchConditions.andor"
            :false-value="'OR'"
            :true-value="'AND'"
            :label="searchConditions.andor"
          />
          <span>{{$t('dbdata.compare.and_or_description_end') }}</span>
        </q-card-section>

        <q-card-section class="scroll" style="max-height: 50vh">
          <div class="row search-conditions-card" v-for="condition in searchConditions.conditions">
            <DbdataSearchConditionElement :condition-size="searchConditions.conditions.length" :columns="columns" :condition="condition" :ref="`condition_${condition.key}`" :refs="condition.refs"/>
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
const searchConditions = ref<{conditions: Design.SearchCondition[], andor:string}>({conditions:[], andor:"AND"})
const createSearchConditionDefault = () => {
  return {column:null,input:[null],key:0,refs:[]}
}
const props = defineProps<{
    columns:DbColumn[]
}>()
const onRemoveSearchConditionsAt = (key:number) => {
  searchConditions.value.conditions.splice(key, 1)
  // key = indexなので振り直す
  searchConditions.value.conditions.forEach((e, idx) => {
    e.key = idx
  })
  // 0件なら初回表示用に戻す
  if(searchConditions.value.conditions.length == 0)
  searchConditions.value.conditions.push(createSearchConditionDefault())
}
const onAppendSearchConditions = () => {
  const appendElement = createSearchConditionDefault()
  appendElement.key = searchConditions.value.conditions.length
  searchConditions.value.conditions.push(appendElement)
}
const onClearSearchConditions = () => {
  searchConditions.value.conditions.splice(0, searchConditions.value.conditions.length)
  searchConditions.value.conditions.push(createSearchConditionDefault())
}

const emits = defineEmits<{
  (e: 'close', v: { conditions: Design.SearchCondition[], andor: string}): void;
}>()

const onClose = () => {
  const promised:Promise<boolean>[] = []
  let result = true
  searchConditions.value.conditions.forEach(e => {
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
    emits("close", searchConditions.value)
    visible.value = false
  }
  else{
    Promise.all(promised)
    .then(data => {
      const error = data.find(e => {
        return !e
      })
      if(error === null){
        emits("close", searchConditions.value)
        visible.value = false
      }
    })
    .catch(data => {
    })
  }
}

defineExpose({
  show: (args: { conditions: Design.SearchCondition[], andor:string}) => {
    searchConditions.value = args
    visible.value = true
    if(searchConditions.value.conditions.length == 0)
    searchConditions.value.conditions.push(createSearchConditionDefault())
  }
})
</script>