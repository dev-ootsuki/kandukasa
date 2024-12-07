<template>
    <q-breadcrumbs active-color="eins" separator=">" style="font-size: 16px">
        <q-breadcrumbs-el :label="selectedDb?.name" icon="storage" v-if="selectedDb" />
        <q-breadcrumbs-el :label="selectedSchema?.schema_id" icon="schema" v-if="selectedSchema" />
        <q-breadcrumbs-el :label="$t(summaries.label)" :icon="summaries.icon" v-if="summaries.show" />
        <q-breadcrumbs-el :label="selectedTable?.table_id" v-if="selectedTable" />
    </q-breadcrumbs>
</template>

<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
const store = useDbConnectionsStore()
const { selectedDb, selectedSchema, selectedTable, selectedEvent, selectedRoutine, selectedView, selectedTrigger } = storeToRefs(store)
const { t } = useI18n()
const route = useRoute()

const summaries = ref(UiHelper.getSchemaSummary("none"))

const updateSummaries = (mode:any) => {
    if(mode === undefined || mode === null)
        return
    const summary = UiHelper.getSchemaSummary(mode)
    if(summary == null)
        return summaries.value = UiHelper.getSchemaSummary("none")
    summaries.value = summary
}

const updateSummariesChildren = () => {
    if(selectedEvent.value)
        summaries.value = UiHelper.getSchemaSummary("events")
    else if(selectedRoutine.value)
        summaries.value = UiHelper.getSchemaSummary("routines")
    else if(selectedTrigger.value)
        summaries.value = UiHelper.getSchemaSummary("triggers")
    else if(selectedView.value)
        summaries.value = UiHelper.getSchemaSummary("views")
    else if(selectedTable.value)
        summaries.value = UiHelper.getSchemaSummary("tables")
}
updateSummaries(route.query?.show)
updateSummariesChildren()

onBeforeRouteUpdate((to, from, next) => {
  next()
  if(to.query !== undefined)
      updateSummaries(to.query?.show)
})

</script>