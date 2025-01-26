<template>
    <DialogRegistration slot-style="min-height:34vh;" :validator="isValid" ref="dialog" mode="register" :visible="visible" @close="onClose" @submit="onSubmit" @complete="onComplete" midium>
        <div class="q-ma-md">
            <div class="row form-row">
                <div class="col-12 col-md-4 text-eins bg-eins">
                    <strong>{{$t('tables.def_columns')}}</strong>
                    <q-badge class="q-ml-sm" color="negative">{{$t('common.required')}}</q-badge>
                </div>
                <div class="col-12 col-md-8 bg-eins text-eins">
                    <q-select ref="inputDefColumn" class="q-ma-md" v-model="defColumn" :rules="validator" :options="props.columns" option-label="column_name" />
                </div>
            </div>

            <div class="row form-row">
                <div class="col-12 col-md-4 text-eins bg-eins">
                    <strong>{{$t('tables.foreignkey_name')}}</strong>
                    <q-badge class="q-ml-sm" color="negative">{{$t('common.required')}}</q-badge>
                </div>
                <div class="col-12 col-md-8 bg-eins text-eins">
                    <q-input ref="inputFkeyName" class="q-ma-md" v-model="fkeyName" :rules="validator" />
                </div>
            </div>

            <div class="row form-row">
                <div class="col-12 col-md-4 text-eins bg-eins">
                    <strong>{{$t('tables.foreignkey')}}</strong>
                    <q-badge class="q-ml-sm" color="negative">{{$t('common.required')}}</q-badge>
                </div>
                <div class="col-12 col-md-8 bg-eins text-eins">
                    <div class="flex-horizon q-ma-md">
                        <q-select class="q-mt-md q-mr-md selected-table-select" v-model="refTable" :options="store.selectedSchema?.tables" option-label="table_name" @update:model-value="onSelectTable" />
                        <q-select :rules="validator" ref="inputRefColumn" class="q-mt-md selected-column-select" v-model="refColumn" :options="refTable?.columns" option-label="column_name" />
                    </div>
                </div>
            </div>

            <div class="row form-row">
                <div class="col-12 col-md-4 text-eins bg-eins">
                    <strong>{{$t('tables.fkey_action_on_references')}}</strong>
                    <q-toggle v-model="actionOnUse" :label="actionOnUse ? $t('common.use') : $t('common.no_use')" />
                </div>
                <div class="col-12 col-md-8 bg-eins text-eins">
                    <div v-if="actionOnUse" class="q-ma-md flex-horizon">
                        <span class="q-ma-md q-mt-lg">{{$t('tables.fkey_action_match_type')}}</span>
                        <q-select :rules="validator" ref="inputMatchType" class="q-mt-md" v-model="actionOnMatchTypeRef" :options="store.selectedDb?.db_instance?.fkey_match_types" />
                    </div>
                    <div v-if="actionOnUse" class="q-ma-md flex-horizon">
                        <span class="q-ma-md q-mt-lg">{{$t('tables.fkey_action_on_create')}}</span>
                        <q-select :rules="validator" ref="inputActionOnCreate" class="q-mt-md q-mr-md selected-table-select" v-model="actionOnCreateRef" :options="actionOnReferences" />
                    </div>
                    <div v-if="actionOnUse" class="q-ma-md flex-horizon">
                        <span class="q-ma-md q-mt-lg">{{$t('tables.fkey_action_on_delete')}}</span>
                        <q-select :rules="validator" ref="inputActionOnDelete" class="q-mt-md q-mr-md selected-table-select" v-model="actionOnDeleteRef" :options="actionOnReferences" />
                    </div>
                </div>
            </div>
        </div>
    </DialogRegistration>
</template>

<style lang="css">
.selected-table-select{
    width: 15vw;
}
.selected-column-select{
    width: 15vw;
}
.flex-horizon{
    display:flex;
}
</style>

<script lang="ts" setup>
import { DbColumn, DbTable } from '~/types/Domain.class'
import type { Design } from '~/types/Types'
import { useDbConnectionsStore } from '~/stores/DbConnectionsStore'
import { qRequired } from '~/composables/ValidatorHelper'
import { useValidator } from '~/composables/Validator'
import { QSelect, QInput } from 'quasar'
const props = defineProps<{
    columns:DbColumn[]
}>()
const actionOnReferences = ["NO ACTION", "RESTRICT", "CASCADE", "SET NULL", "SET DEFAULT"]

const store = useDbConnectionsStore()
const visible = ref(false)
const mode = ref<Design.DialogEventType>("register")
const dialog = useTemplateRef("dialog")

const fkeyName = ref()
const refTable = ref()
const refColumn = ref()
const defColumn = ref()
const actionOnCreateRef = ref()
const actionOnDeleteRef = ref()
const actionOnUse = ref(false)
const actionOnMatchTypeRef = ref()

const inputBases = [useTemplateRef<QSelect>("inputDefColumn"), useTemplateRef<QInput>("inputFkeyName"), useTemplateRef<QSelect>("inputRefColumn")]
const inputExtras = [useTemplateRef<QSelect>("inputMatchType"), useTemplateRef<QSelect>("inputActionOnCreate"), useTemplateRef<QSelect>("inputActionOnDelete")]

defineExpose({
    show:() => {
        visible.value = true
    }
})
const emits = defineEmits<{
  (e: 'complete', v:Design.DialogEventType): void,
}>()

const validator = useValidator(qRequired)
const isValid = () : boolean | Promise<boolean> => {
    if(inputBases.find(e => !e.value!.validate()))
        return false
    if(actionOnUse.value && inputExtras.find(e => !e.value!.validate()))
        return false
    return true
}

const onSelectTable = () => {
    refColumn.value = null
    if(refTable.value.columns == null){
        store
            .getTableInfo(refTable.value.table_name)
            .then(data => {
            })
    }
}

const onSubmit = () => {
    store
        .createForeignKey(fkeyName.value!, defColumn.value, refColumn.value, actionOnUse.value, actionOnMatchTypeRef.value, actionOnCreateRef.value, actionOnDeleteRef.value)
        .then(data => {
            dialog.value!.complete()
        })
}

const onComplete = () => {
    emits("complete", mode.value)
    visible.value = false
    store
        .getTableInfo(store.selectedTable!.table_id!)
        .then(data => {
            onClose()
        })
}

const onClose = () => {
    visible.value = false
    fkeyName.value = null
    refTable.value = null
    refColumn.value = null
    defColumn.value = null
    actionOnUse.value = false
    actionOnCreateRef.value = null
    actionOnDeleteRef.value = null
    actionOnMatchTypeRef.value = null
}
</script>