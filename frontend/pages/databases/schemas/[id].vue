<template>
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <LayoutBreadcrumbsDatabase />
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <q-card v-if="selectedSchema">
        <q-tabs
          v-model="tab"
          dense
          inline-label
          align="left"
          indicator-color="text-eins"
          class="bg-secondary text-white shadow-2"
          :breakpoint="0"
        >
        <q-tab name="info" :label="$t('schemas.info')" icon="info" v-if="mode == 'all'"/>
        <q-tab name="tables" :label="$t('leftmenu.tables')" icon="newspaper" v-if="mode == 'all' || mode == 'tables'"/>
        <q-tab name="query" :label="$t('schemas.query')" icon="edit_note" v-if="mode == 'all'"/>
        <q-tab name="maintenance" :label="$t('schemas.maintenance')" icon="build_circle" v-if="mode == 'all'"/>
        <q-tab name="views" :label="$t('leftmenu.views')" icon="perm_media" v-if="mode == 'all' || mode == 'views'"/>
        <q-tab name="triggers" :label="$t('leftmenu.triggers')" icon="local_fire_department" v-if="mode == 'all' || mode == 'triggers'"/>
        <q-tab name="routines" :label="$t('leftmenu.routines')" icon="functions" v-if="mode == 'all' || mode == 'routines'"/>
        <q-tab name="events" :label="$t('leftmenu.events')" icon="calendar_month" v-if="mode == 'all' || mode == 'events'"/>
      </q-tabs>

      <q-tab-panels v-model="tab" animated>
        <q-tab-panel name="info">
          <!-- schema name -->
          <LayoutRowLabelValue :label="$t('metadata.schema_name')" :value="selectedSchema?.schema_name" />
          <!-- catalog name -->
          <LayoutRowLabelValue :label="$t('metadata.system_catalog')" :value="selectedSchema?.system_catalog" />
          <!-- default character set -->
          <LayoutRowLabelValue :label="$t('metadata.default_character_set_name')" :value="selectedSchema?.default_character_set_name" />
          <!-- default_collation_name -->
          <LayoutRowLabelValue :label="$t('metadata.default_collation_name')" :value="selectedSchema?.default_collation_name" />
          <!-- default_encryption -->
          <LayoutRowLabelValue :label="$t('metadata.default_encryption')" :value="selectedSchema?.default_encryption" />
          <!-- grantee -->
          <LayoutRowLabelValue :label="$t('metadata.grantee')" :value="schemaGrantee" />
          <!-- table size -->
          <LayoutRowLabelValue :label="$t('schemas.table_total')" :value="tablesTotal" />
          <!-- index size -->
          <LayoutRowLabelValue :label="$t('schemas.index_total')" :value="indexesTotal" />
          <!-- count of tables -->
          <LayoutRowLabelValue :label="$t('schemas.num_of_tables')" :value="schema?.tables?.length || 0" />
          <!-- count of views -->
          <LayoutRowLabelValue :label="$t('schemas.num_of_views')" :value="schema?.views?.length || 0" />
          <!-- count of triggers -->
          <LayoutRowLabelValue :label="$t('schemas.num_of_triggers')" :value="schema?.triggers?.length || 0" />
          <!-- count of routines -->
          <LayoutRowLabelValue :label="$t('schemas.num_of_routines')" :value="schema?.routines?.length || 0" />
          <!-- count of events -->
          <LayoutRowLabelValue :label="$t('schemas.num_of_events')" :value="schema?.events?.length || 0" />
          <!-- engines -->
          <LayoutRowLabelValue :label="$t('schemas.engines')" :value="engines" />
          
        </q-tab-panel>

        <q-tab-panel name="tables" v-if="mode == 'all' || mode == 'tables'">
          <tables :connection="selectedSchema.id!" :schema="selectedSchema.schema_id!" />
        </q-tab-panel>

        <q-tab-panel name="query" v-if="mode == 'all'">
          <query />
        </q-tab-panel>

        <q-tab-panel name="maintenance" v-if="mode == 'all'">
          <maintenance />
        </q-tab-panel>
  
        <q-tab-panel name="views" v-if="mode == 'all' || mode == 'views'">
          <views />
        </q-tab-panel>

        <q-tab-panel name="triggers" v-if="mode == 'all' || mode == 'triggers'">
          <triggers />
        </q-tab-panel>

        <q-tab-panel name="routines" v-if="mode == 'all' || mode == 'routines'">
          <routines />
        </q-tab-panel>

        <q-tab-panel name="events" v-if="mode == 'all' || mode == 'events'">
          <events />
        </q-tab-panel>
      </q-tab-panels>

      </q-card>
    </div>
  </div>
</template>
  
<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { UiHelper } from '~/utils/UiHelper'
import { byteToLargeUnit } from '~/composables/UnitConverter'

// sub pages
import Maintenance from '~/pages/databases/schemas/maintenance.vue'
import Query from '~/pages/databases/schemas/query.vue'
import Tables from '~/pages/databases/schemas/tables.vue'
import Views from '~/pages/databases/schemas/views.vue'
import Events from '~/pages/databases/schemas/events.vue'
import Routines from '~/pages/databases/schemas/routines.vue'
import Triggers from '~/pages/databases/schemas/triggers.vue'

const dbStore = useDbConnectionsStore()
const { selectedSchema } = storeToRefs(dbStore)
if(selectedSchema.value == null)
  navigateTo(`/databases/${dbStore?.selectedDb?.id}`)
const schema = selectedSchema.value!
const route = useRoute()

const mode = ref<string>(UiHelper.getSchemaSummary("none").mode)
const tab = ref<string>('info')

// schema info
const schemaGrantee = schema?.grantee ? schema?.grantee : dbStore.selectedDb?.db_instance?.privileges.filter((e:any) => {
  return e.table_schema == "*" || e.table_schema == schema.schema_name
})?.map((e:any) => e?.grantee)

const tablesTotal = schema.tables == null || schema.tables.length == 0 ? 0 : byteToLargeUnit(schema.tables.map(e => e.data_length)?.reduce((acc, current) => {return acc + current}))
const indexesTotal = schema.tables == null || schema.tables.length == 0 ? 0 : byteToLargeUnit(schema.tables.map(e => e.index_length)?.reduce((acc, current) => {return acc + current}))
const engines = Array.from(new Set(schema?.tables?.map(e => e.engine)))?.join(", ")

const render = (show:any) => {
  if(show === undefined || show === null)
      return
  const newmode = UiHelper.getSchemaSummary(show).mode
  if(newmode == null)
      mode.value = UiHelper.getSchemaSummary("none").mode
  else
    mode.value = newmode

  if(mode.value != "all")
    tab.value = mode.value
}

render(route.query?.show)
onBeforeRouteUpdate((to, from, next) => {
  next()
  if(to.query !== undefined){
    render(to.query?.show)
  }
})

</script>