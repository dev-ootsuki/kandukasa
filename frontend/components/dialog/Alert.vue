<template>
    <q-dialog persistent v-model="visible" @hide="onHide" transition-show="flip-down" transition-hide="flip-up" backdrop-filter="blur(4px) saturate(150%)">
        <q-card class="bg-eins text-eins alert-dialog">
        <q-bar>
            <div>{{$t('common.alert')}}</div>
        </q-bar>

        <q-space />

        <q-card-section class="row items-center">
            <q-avatar icon="warning" text-color="warning" flat size="6em" />
            <span v-for="message in messages">
                {{ message }}
            </span>
        </q-card-section>

        <q-card-actions align="right">
            <q-btn flat :label="$t('common.close').toUpperCase()" @click="onHide" />
        </q-card-actions>
        </q-card>
    </q-dialog>
</template>

<script lang="ts" setup>
const visible = ref(false)
const messages = ref<string[]>([])

defineExpose({
    show: (...args:string[]) => {
        messages.value = args
        visible.value = true
    }
})

const onHide = () => {
    visible.value = false
    messages.value = []
}
</script>