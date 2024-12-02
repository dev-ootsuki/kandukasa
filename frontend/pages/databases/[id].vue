<template>
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <LayoutBreadcrumbsDatabase />
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <q-card class="bg-eins text-eins" v-if="selected?.db_instance">
        <!-- base info -->
        <q-expansion-item
          dense-toggle
          default-opened
          expand-separator
          icon="info"
          class="text-weight-bold"
          :label="$t('db_instance.info_title')"
        >
          <q-card-section>
            <!-- name -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.name')" :value="selected?.name" />
            <!-- db_type -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.db_type')" :value="selected?.db_type" />
            <!-- host -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.host')" :value="selected?.host" />
            <!-- port -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.port')" :value="selected?.port" />
            <!-- login user -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.login_name')" :value="selected?.login_name" />
            <!-- descriptions -->
            <LayoutRowLabelValue :label="$t('settings.db_connections.description')" :value="selected?.description" />
            <!-- // TODO あとで権限とか認証方法を追加する？ -->

            <q-space />
          </q-card-section>
        </q-expansion-item>

        <q-space />

        <!-- schemas sets -->
        <q-expansion-item
          dense-toggle
          default-opened
          expand-separator
          icon="workspaces"
          class="text-weight-bold"
          :label="$t('db_instance.schemas_title')"
        >
          <q-card-section class="row items-left">
            <q-table
              flat bordered dense
              :rows="selected?.db_instance?.schemas!"
              :columns="UiHelper.convertColumn(selected?.db_instance?.schemas.at(0), $t)"
              row-key="name"
              virtual-scroll
              hide-bottom
              class="db_instance_info_tables sticky-header-table min-sticky-header-table"
              v-model:pagination="defaultPagination"
            />
          </q-card-section>
        </q-expansion-item>        

        <q-space />

        <!-- privileges info -->
        <q-expansion-item
          dense-toggle
          expand-separator
          icon="verified"
          class="text-weight-bold"
          :label="$t('db_instance.privilege_title')"
        >
          <q-card-section class="row items-left">
            <q-table
              flat bordered dense
              :rows="selected?.db_instance?.privileges!"
              :columns="UiHelper.convertColumn(selected?.db_instance?.privileges?.at(0), $t)"
              row-key="name"
              virtual-scroll
              hide-bottom
              class="db_instance_info_tables sticky-header-table min-sticky-header-table"
              v-model:pagination="defaultPagination"
            />
          </q-card-section>
        </q-expansion-item>

        <q-space />
        <!-- engine info -->
        <q-expansion-item
          v-if="selected?.db_instance?.engines.length > 0"
          dense-toggle
          expand-separator
          icon="storage"
          class="text-weight-bold"
          :label="$t('db_instance.engine_title')"
        >
          <q-card-section class="row items-left">
            <q-table
              flat bordered dense
              :rows="selected?.db_instance?.engines!"
              :columns="UiHelper.convertColumn(selected?.db_instance?.engines?.at(0),$t)"
              row-key="name"
              virtual-scroll
              hide-bottom
              class="db_instance_info_tables sticky-header-table min-sticky-header-table"
              v-model:pagination="defaultPagination"
            />
          </q-card-section>
        </q-expansion-item>

        <q-space />
        <!-- character sets -->
        <q-expansion-item
          dense-toggle
          expand-separator
          icon="g_translate"
          class="text-weight-bold"
          :label="$t('db_instance.character_sets_title')"
        >
          <q-card-section class="row items-left">
            <q-table
              flat bordered dense
              :rows="selected?.db_instance?.characters!"
              :columns="UiHelper.convertColumn(selected?.db_instance?.characters?.at(0),$t)"
              row-key="name"
              virtual-scroll
              hide-bottom
              class="db_instance_info_tables sticky-header-table min-sticky-header-table"
              v-model:pagination="defaultPagination"
            />
          </q-card-section>
        </q-expansion-item>

        <!-- collations -->
        <q-expansion-item
          dense-toggle
          expand-separator
          icon="swap_vert"
          class="text-weight-bold"
          :label="$t('db_instance.collations_title')"
        >
          <q-card-section class="row items-left">
            <q-table
              flat bordered dense
              :rows="selected?.db_instance?.collations!"
              :columns="UiHelper.convertColumn(selected?.db_instance?.collations?.at(0),$t)"
              row-key="name"
              virtual-scroll
              hide-bottom
              class="db_instance_info_tables sticky-header-table min-sticky-header-table"
              v-model:pagination="defaultPagination"
            />
          </q-card-section>
        </q-expansion-item>

        <q-space />
      </q-card>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { useSystemStore } from '~/stores/SystemStore'
import { UiHelper } from '~/utils/UiHelper'
const store = useDbConnectionsStore()
const design = useSystemStore().designSetting
const { selected } = storeToRefs(store)

const defaultPagination = ref({ rowsPerPage: design.defaultPageSize })

if(selected?.value == null)
    navigateTo('/')
</script>