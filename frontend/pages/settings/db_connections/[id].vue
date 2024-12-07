<template>
  <DialogConfirm ref="dialog" @submit="onSubmit" @complete="onComplete" />
  <div class="q-pa-md">
    <q-toolbar class="content-header q-pa-sm">
      <span class="content-title text-eins bg-eins">{{$t('settings.db_connections.title_'+mode)}}</span>
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <q-form autocorrect="off" autocapitalize="off" autocomplete="off">
        <div>
          <!--id -->
          <PfElement :label="$t('settings.db_connections.id')" v-if="mode == 'update'">
            <strong>{{input.id}}</strong>
          </PfElement>
          <!-- name -->
          <PfInput icon="label" :label="$t('settings.db_connections.name')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.name" />
          <!-- db_type -->
          <PfSelect require icon="settings_applications" :label="$t('settings.db_connections.db_type')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.db_type" :options="system.databaseProducts.filter(e => e.enable)"/>
          <!-- host -->
          <PfInput icon="dns" :label="$t('settings.db_connections.host')" :validate="[qRequired, qLengthTo128]" :model="input" ref="input.host" />
          <!-- port -->
          <PfInput icon="lan" :label="$t('settings.db_connections.port')" :validate="[qRequired, qNumber, qRangeTo99999]" :model="input" ref="input.port" />
          <!-- default database name -->
          <PfInput icon="lan" :label="$t('settings.db_connections.default_database_name')" :validate="[qRequired, qLengthTo64]" :model="input" ref="input.default_database_name" />
          <!-- login_name -->
          <PfInput icon="person" :label="$t('settings.db_connections.login_name')" :validate="[qRequired, qLengthTo32]" :model="input" ref="input.login_name" />
          <!-- password -->
          <PfInput icon="key" :label="$t('settings.db_connections.password')" :validate="[qLengthTo32]" :model="input" ref="input.password" type="password" />
          <!-- timeout -->
          <PfInput icon="wifi_off" :label="$t('settings.db_connections.timeout')" :validate="[qRequired, qNumber, qRangeTo99999]" :model="input" ref="input.timeout" />
          <!-- description -->
          <PfInput :label="$t('settings.db_connections.description')" type="textarea" :validate="[qLengthTo500]" :model="input" ref="input.description" />
        </div>
        <div class="q-pa-md">
          <SystemBtnOperation :mode="mode" @click="onRegistration" feature="dbconnections" />
        </div>
      </q-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { useSystemStore } from '~/stores/SystemStore'
import { UiHelper } from '~/utils/UiHelper'
import { qRequired, qNumber, qRangeTo99999, qLengthTo500, qLengthTo128 } from '~/composables/ValidatorHelper' 
import * as Domain from '~/types/Domain.class'
import { useProxyForm } from '~/composables/ProxyForm'
import type { Design } from '~/types/Types'
const store = useDbConnectionsStore()
const route = useRoute()
const system = useSystemStore().systemSetting

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
  if(input.isValid())
    dialog.value!.show(mode)
}
const onSubmit = () : Promise<any> => {
  if(mode == "register")
    return store.saveDbConnection(input)
  return store.modifyDbConnection(input)
}
const onComplete = () => {
  navigateTo('/settings/db_connections/')
}
</script>
