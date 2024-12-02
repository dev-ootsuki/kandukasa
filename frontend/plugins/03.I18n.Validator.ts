import type { Validator } from '~/types/Types'
import * as ValidatorClass from '~/types/Validator.class'
import { useValidator } from '~/composables/Validator'
export default defineNuxtPlugin((nuxtApp) : any => {
  let i18n: any = null
  nuxtApp.hook("vue:setup",() => {
    i18n = useNuxtApp().$i18n
  })
  const validator: Validator.Plugin = new ValidatorClass.I18nPluginValidator(useValidator, (message: string | undefined, argFormat?:string, ...args:any[]) : string => {
    if(argFormat === undefined)
        return i18n.t(message, ...args)
      return i18n.t(message, argFormat, ...args)
  })
  return {
    provide: {
      validator
    },
  }
})