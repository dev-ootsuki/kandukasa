import { useNuxtApp } from 'nuxt/app'
import type { Validator } from '~/types/Types'
import * as ValidatorClass from '~/types/Validator.class'

let settings:Validator.Settings | null = null
let executor:ValidatorClass.Executor | null = null

const getExecutor = () : ValidatorClass.Executor => {
    if(executor != null)
        return executor
    executor = new ValidatorClass.Executor()
    return executor
}

const getSettings = () : Validator.Settings => {
    if(settings != null)
        return settings
    const { $validator } = useNuxtApp()
    const defaultSettings = new ValidatorClass.DefaultSettings()
    if($validator !== undefined){
        settings = {...defaultSettings, ...($validator as Validator.Plugin).settings}
    }
    else{
        settings = defaultSettings
    }
    return settings!
}

const createMechanizmByRules = (rules : Validator.Rule[]) : Validator.Mechanizm[] => {
    return rules.map(e => {
        const isOk = getExecutor().createOk(e)
        return { isOk: isOk, rule: e } as Validator.Mechanizm
    })
}

export const useValidator = (...rules: Validator.Rule[]) : Validator.Validation[] => {
    if(rules == null || rules.length == 0)
        return [(input:string) : boolean | string => {
            return true
        }]
    const adapter = new ValidatorClass.ValidatorMessageAdapter(getSettings())
    return createMechanizmByRules(rules).map(e => {
        return (input: string) : boolean | string => {
            return e.isOk(input) || adapter.get(e.rule)
        }
    })
}

