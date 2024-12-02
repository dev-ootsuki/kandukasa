<template>
  <div class="q-pa-md">
    <DialogConfirm ref="dialog" />
    <q-toolbar class="content-header q-pa-sm">
      <span class="content-title text-eins bg-eins">{{$t('settings.db_connections.title')}}</span>
      <SystemBtnOperation to="/settings/db_connections/0" class="absolute-right" mode="register" feature="dbconnections" />
    </q-toolbar>
    <div class="content-main q-pa-sm">
      <span v-if="store.dbConnections?.length == 0">
        <q-icon name="warning" color="warning" size="2em" />
        {{$t('common.no_record')}}
      </span>
      <q-markup-table separator="cell" flat bordered v-if="store.dbConnections?.length > 0">
        <thead>
          <tr>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.name')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.db_type')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.host')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.port')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.login_name')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('settings.db_connections.use_ssl')}}</th>
            <th class="text-right bg-secondary text-white">{{$t('common.operation')}}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="con in store.dbConnections">
            <td class="text-right">{{con.name}}</td>
            <td class="text-right">{{con.db_type}}</td>
            <td class="text-right">{{con.host}}</td>
            <td class="text-right">{{con.port}}</td>
            <td class="text-right">{{con.login_name}}</td>
            <td class="text-right">{{con.use_ssl ? $t('common.yes') : $t('common.no')}}</td>
            <td class="text-right">
              <SystemBtnOperation mode="update" feature="dbconnections" class="q-mr-md" mini :to="''+con.id" />
              <SystemBtnOperation mode="delete" feature="dbconnections" mini @click="onDelete(con.id!)" />
            </td>
          </tr>
        </tbody>
      </q-markup-table>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
  const store = useDbConnectionsStore()
  await store.findDbConnectionsAll()

  const dialog = useTemplateRef<any>("dialog")

  const onDelete = (id:number) => {
    dialog.value!.onConfirm("delete", () => {
      return store.deleteDbConnection(id)
    }, () => {
      location.reload()
    })
  }
</script>
