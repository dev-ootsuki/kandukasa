<template>
    <q-btn :label="settings.label" :icon="settings.icon" @click="onClick" />
</template>

<script lang="ts" setup>
import { type Design } from '~/types/Types'
import { useI18n } from 'vue-i18n';
const props = defineProps<{
    mode:Design.UIMode
}>()
const { t } = useI18n()
const settings = props.mode == "register" ? 
    { label: t('common.new_registration_exec'), icon:"add_circle"} : 
    { label: t('common.update_exec'), icon:"edit"}

const emits = defineEmits(["click"])
const onClick = () => {
    emits("click")
}
</script>