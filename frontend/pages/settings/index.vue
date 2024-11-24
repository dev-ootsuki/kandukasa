<template>
    <div class="q-pa-md">
        <q-toolbar class="content-header q-pa-sm">
            <span class="content-title text-eins bg-eins">{{$t('settings.summary')}}</span>
        </q-toolbar>
        <div class="content-main q-pa-sm">
            <q-card class="bg-eins text-eins">
                <q-card-section>
                    <!-- design -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.design.title')" icon="palette" to="designs/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_design')}}</strong>
                        </div>
                    </div>
                    <!-- connections -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.db_connections.title')" icon="storage" to="db_connections/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_db_connections')}}</strong>
                        </div>
                    </div>
                    <!-- watch point -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.watch_points.title')" icon="visibility" to="watch_points/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_watch_points')}}</strong>
                        </div>
                    </div>
                    <!-- authority -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.authority.title')" icon="task_alt" to="authority/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_authority')}}</strong>
                        </div>
                    </div>
                    <!-- users -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.users.title')" icon="person" to="users/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_users')}}</strong>
                        </div>
                    </div>
                    <!-- configurations -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.configurations.title')" icon="settings" to="configurations/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_configurations')}}</strong>
                        </div>
                    </div>
                    <!-- external services -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.external_services.title')" icon="share" to="external_services/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_external_services')}}</strong>
                        </div>
                    </div>
                    <!-- management queries -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.queries.title')" icon="shortcut" to="queries/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_queries')}}</strong>
                        </div>
                    </div>
                    <!-- dashboard -->
                    <div class="row q-pa-sm bg-intensity text-intensity row-label-value">
                        <div class="col-12 col-md-5">
                            <q-btn class="btn-settings-anchor" color="primary" :label="$t('settings.dashboard.title')" icon="dashboard" to="dashboard/" />
                        </div>
                        <div class="col-12 col-md-7">
                            <strong>{{$t('settings.summary_of_dashboard')}}</strong>
                        </div>
                    </div>
                </q-card-section>
            </q-card>
        </div>
    </div>
</template>

<script setup lang="ts">
</script>