import { defineStore } from 'pinia'
import en_US from 'quasar/lang/en-US.js'
import ja from 'quasar/lang/ja.js'
import type { Design, System } from '@/types/Types'
import * as DesignClass from '~/types/Design.class'
import * as SystemClass from '~/types/System.class'
import { colors } from 'quasar'
const { getPaletteColor } = colors


export const langs:Design.Lang[] = [{
    value:"en",
    name: "en",
    qName:"en-US",
    qResource:en_US
},{
    value:"ja",
    name: "ja",
    qName:"ja",
    qResource:ja
}]

type State = {
    design:DesignClass.Config
    system:SystemClass.Config
}

const defaultSystem = new SystemClass.Config()
defaultSystem.databaseProducts = [
    {label: "MySQL", value: "MySQL", enable: true},
    {label:"postgreSQL", value: "postgreSQL", enable: false},
    {label: "RDS Aurora MySQL", value:"RDSAuroraMySQL", enable: true},
    {label:"RDS Aurora postgreSQL", value:"RDSAuroraPostgreSQL", enable: false}
]
defaultSystem.dbDataPrimaryKey = "_internal_kandukasa_exchange_id_"
defaultSystem.dbMultiSelectedKeySeparator = "_#_kandukasa_#_#_key_#_#_separator_#_"

const createDefaultDesign = () => {
    const ret = new DesignClass.Config()
    ret.lang = langs[1]
    ret.primary = getPaletteColor("primary")
    ret.secondary = getPaletteColor("secondary")
    ret.accent = getPaletteColor("accent")
    ret.positive = getPaletteColor("positive")
    ret.negative = getPaletteColor("negative")
    ret.info = getPaletteColor("info")
    ret.warning = getPaletteColor("warning")
    ret.textLight = getPaletteColor("light")
    ret.textEins  = getPaletteColor("eins")
    ret.textZwei = getPaletteColor("zwei")
    ret.textDrei = getPaletteColor("drei")
    return ret
}
const defaultDesign:DesignClass.Config = createDefaultDesign()
defaultDesign.before = createDefaultDesign()

export const useSystemStore = defineStore('system', {
    // convert to a function
    state: (): State => ({
        design: defaultDesign,
        system: defaultSystem
    }),
    getters: {
        designSetting(state : State) : DesignClass.Config{
            return state.design
        },
        systemSetting(state: State) : SystemClass.Config{
            return state.system
        }
    },
    actions: {
        revertDesign(i18nLocale:Ref<any>, quasar:any){
            if(!this.design.isTouch())
                return

            this.design = this.design.before!
            if(this.design.before === undefined)
                this.design.before = createDefaultDesign()
            
            i18nLocale.value = this.design.lang?.name!

            quasar.lang = this.design.lang?.qResource
            if(quasar.dark.isActive !== this.design.isDark)
                quasar.dark.toggle()
        },
        saveDesign(newval:DesignClass.Config){
            newval.before = this.design
            this.design = newval
        }
    }
})
