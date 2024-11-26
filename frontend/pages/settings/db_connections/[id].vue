<template>
  <confirmation-dialog ref="dialog" />
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <span class="content-title text-eins bg-eins">{{$t('settings.db_connections.title_'+mode)}}</span>
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <q-form autocorrect="off" autocapitalize="off" autocomplete="off">
        <div>

          <!--id -->
          <pf-element :label="$t('settings.db_connections.id')" v-if="mode == 'update'">
            <strong>{{input.id}}</strong>
          </pf-element>
          <!-- name -->
          <pf-input icon="label" :label="$t('settings.db_connections.name')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.name" />
          <!-- db_type -->
          <pf-select require icon="settings_applications" :label="$t('settings.db_connections.db_type')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.db_type" :options="Domain.DatabaseProducts.filter(e => e.enable)"/>
          <!-- host -->
          <pf-input icon="dns" :label="$t('settings.db_connections.host')" :validate="[qRequired, qLengthTo128]" :model="input" ref="input.host" />
          <!-- port -->
          <pf-input icon="lan" :label="$t('settings.db_connections.port')" :validate="[qRequired, qNumber, qRangeTo99999]" :model="input" ref="input.port" />
          <!-- default database name -->
          <pf-input icon="lan" :label="$t('settings.db_connections.default_database_name')" :validate="[qRequired, qLengthTo64]" :model="input" ref="input.default_database_name" />
          <!-- login_name -->
          <pf-input icon="person" :label="$t('settings.db_connections.login_name')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.login_name" />
          <!-- password -->
          <pf-input icon="key" :label="$t('settings.db_connections.password')" :validate="[qLengthTo32]" :model="input" ref="input.password" type="password" />
          <!-- timeout -->
          <pf-input icon="wifi_off" :label="$t('settings.db_connections.timeout')" :validate="[qRequired, qNumber, qRangeTo99999]" :model="input" ref="input.timeout" />
          <!-- description -->
          <pf-input :label="$t('settings.db_connections.description')" type="textarea" :validate="[qLengthTo500]" :model="input" ref="input.description" />
        </div>
        <div class="q-pa-md">
          <btn-registration :mode="mode" @click="onRegistration" />
        </div>
      </q-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { UiHelper } from '~/utils/UiHelper'
import { qRequired, qNumber, qRangeTo99999, qLengthTo500, qLengthTo128 } from '~/composables/ValidatorHelper' 
import * as Domain from '~/types/Domain.class'
import { useProxyForm } from '~/composables/ProxyForm'
import type { Design } from '@/types/Types'
const store = useDbConnectionsStore()
const route = useRoute()

if(!UiHelper.isNumberRouteId(route.params.id))
  await navigateTo('/')

const id = UiHelper.toNumberRouteId(route.params.id)
const input = useProxyForm<Domain.DbConnection>(
  await store.getDbConnectionById(id), 
  "input"
)
const mode:Design.UIMode = input.id !== undefined && input.id > 0 ? "update" : "register"
const dialog = useTemplateRef<any>("dialog")

const onRegistration = () => {
  if(input.isValid()){
    dialog.value!.onConfirm(mode, () => {
      if(mode == "register")
        return store.saveDbConnection(input)
      return store.modifyDbConnection(input)
    }, () => {
      navigateTo('/settings/db_connections/')
    })
  }
}
</script>
