<template>
    <DialogRegistration :validator="validator" ref="dialog" :mode="mode" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete">
        <div v-for="column in props.columns" class="row form-row">
            <div class="col-12 col-md-3 text-eins bg-eins">
                <strong class="q-pr-sm">{{column.column_name}}</strong>
                <q-badge class="q-mr-sm" color="negative" v-if="!column.is_nullable">{{$t('common.required')}}</q-badge>
            </div>
            <div class="col-12 col-md-4 bg-eins text-eins" ref="inputRoot">
                <template v-if="column.extra != 'auto_increment'">
                    <DbdataColumnLinkedInput :required="!column.is_nullable" class="q-pt-md" :column="column" :multiple="false" :value="data![column.column_name!]" @change="(v:any) => {data![column.column_name!] = v}" />
                </template>
                <template v-else>
                    <div class="q-pt-lg q-pl-sm">{{mode == "register" ? $t('dbdata.registration.auto_increment') : data![column.column_name!]}}</div>
                </template>
            </div>
            <div class="col-12 col-md-3 text-eins bg-eins">
                <div class="q-pt-md q-pl-sm">{{column.column_type}}</div>
                <div class="q-pl-sm">{{ column.extra }}</div>
            </div>
            <div class="col-12 col-md-2 text-eins bg-eins">
                <div>{{ column.column_comment }}</div>
            </div>
        </div>
    </DialogRegistration>
</template>

<script lang="ts" setup>
import { DbColumn, DbData } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore';
const props = defineProps<{
    columns:DbColumn[]
}>()
const store = useDbConnectionsStore()
const visible = ref(false)
const mode = ref<Design.DialogEventType>("register")
const dialog = useTemplateRef("dialog")
let data = reactive<DbData>({})
defineExpose({
    show:(argMode: Design.DialogEventType, argData: DbData) => {
        mode.value = argMode
        visible.value = true
        data = reactive(argData)
    }
})
const emits = defineEmits<{
  (e: 'complete', v:Design.DialogEventType): void,
}>()

const inputRoot = useTemplateRef("inputRoot")
const validator = () : boolean => {
    let ret = true
    props.columns.forEach((e,i) => {
        if(e.extra != 'auto_increment'){
            const root:any = inputRoot.value!
            const cret = root[i].__vnode.children[0].component.exposed.validate()
            ret &&= cret
        }
        ret &&= true
    })
    return ret
}

const onSubmit = () => {
    let promise:Promise<any> | null = null
    if(mode.value == "register"){
        promise = store.createTableData(data)
    }
    else{
        promise = new Promise<any>((resolve) => resolve(true))
    }
    promise!.then(data => {
        dialog.value!.complete()
    })
}

const onComplete = () => {
    emits("complete", mode.value)
    visible.value = false
}

const onClose = () => {
    visible.value = false
}
</script>