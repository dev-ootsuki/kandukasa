<template>
	<div class="content-main">
		<!-- header -->
		<div class="q-pa-md">
			<q-toolbar class="content-header q-pa-sm">
		      <span class="content-title text-eins bg-eins">{{$t('settings.design.title')}}</span>
		    </q-toolbar>
		</div>
		<!-- main -->
		<div class="q-pa-md">
			<!-- lang -->
			<PfElement :label="$t('settings.design.lang')">
				<q-select class="q-pa-sm" filled v-model="langModel" :options="langOptions" :label="$t('settings.design.lang')" />
			</PfElement>
			<!-- dark mode -->
			<PfElement :label="$t('settings.design.dark_mode')">
				<q-toggle
					class="q-pa-sm"
					v-model="$q.dark.mode"
					:label="$t('settings.design.dark_mode')"
					:leftLabel="true"
					:dark="$q.dark.isActive ? true : false"
					@click="changeDarkMode"
					color="primary"
				/>
			</PfElement>
			<!-- primary color -->
			<PfColorPicker :model="input" ref="conf.primary" :label="$t('settings.design.primary_color')" :validate="colorVlidate"/>
			<!-- secondary color -->
			<PfColorPicker :model="input" ref="conf.secondary" :label="$t('settings.design.secondary_color')" :validate="colorVlidate"/>
			<!-- accent color -->
			<PfColorPicker :model="input" ref="conf.accent" :label="$t('settings.design.accent_color')" :validate="colorVlidate"/>
			<!-- positive color -->
			<PfColorPicker :model="input" ref="conf.positive" :label="$t('settings.design.positive_color')" :validate="colorVlidate"/>
			<!-- negative color -->
			<PfColorPicker :model="input" ref="conf.negative" :label="$t('settings.design.negative_color')" :validate="colorVlidate"/>
			<!-- info color -->
			<PfColorPicker :model="input" ref="conf.info" :label="$t('settings.design.info_color')" :validate="colorVlidate"/>
			<!-- warning color -->
			<PfColorPicker :model="input" ref="conf.warning" :label="$t('settings.design.warning_color')" :validate="colorVlidate"/>
			<!-- light color -->
			<PfColorPicker :model="input" ref="conf.textLight" :label="$t('settings.design.light_color')" :validate="colorVlidate"/>
			<!-- main1 color -->
			<PfColorPicker :model="input" ref="conf.textEins" :label="$t('settings.design.main1_color')" :validate="colorVlidate"/>
			<!-- main2 color -->
			<PfColorPicker :model="input" ref="conf.textZwei" :label="$t('settings.design.main2_color')" :validate="colorVlidate"/>
			<!-- main3 color -->
			<PfColorPicker :model="input" ref="conf.textDrei" :label="$t('settings.design.main3_color')" :validate="colorVlidate"/>
		</div>
		<!-- footer -->
		<div class="q-pa-md">
			<q-btn icon="home" label="REVERT" @click="onRevert" />
			<q-btn icon="home" label="SAVE" @click="onSave" />
		</div>
	</div>
</template>

<script setup lang="ts">
import { useI18n } from "vue-i18n"
import { useSystemStore, langs } from "~/stores/SystemStore"
import { qRequired } from '~/composables/ValidatorHelper'
import { useProxyForm } from '~/composables/ProxyForm'
import * as DesignClass from "~/types/Design.class"

const store = useSystemStore()
const input = useProxyForm<DesignClass.Config>(
  store.designSetting, 
  "conf"
)

const colorVlidate = [qRequired]

const quasar = useQuasar()
const changeDarkMode = () => {
	input.touch()
	quasar.dark.toggle()
}

const { locale, t } = useI18n({ useScope: "global" });
const langModel = ref(input.lang)
const langOptions = langs.map(e => {
	e.label = t(`langs.${e.name}`)
	return e
})

watch(langModel, async() => {
	locale.value = langModel.value?.name!
	quasar.lang = langModel.value?.qResource
	langs.forEach(e => e.label =  t(`langs.${e.name}`))
	input.touch()
})

const onRevert = () => {
	store.revertDesign(locale, quasar)
}
const onSave = () => {
	store.saveDesign(input)
}
//onBeforeRouteLeave
</script>
