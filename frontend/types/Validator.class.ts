/// <reference path="./Types.d.ts" />
/// <reference types="date-fns" />
import { format } from 'date-fns'
import type { Validator } from '@/types/Types'

export class ValidatorMessageAdapter implements Validator.MessageAdapter{
    settings: Validator.Settings
    constructor(settings: Validator.Settings){
        this.settings = settings
    }
    get(rule:Validator.Rule) : string{
        if(rule.overrideMessage !== undefined)
            return rule.overrideMessage
        
        return this.settings.converter(
            this.settings.messages.get(rule.message),
            rule.format,
            this.ruleToMessageArgs(rule)
        )
    }
    ruleToMessageArgs (rule : Validator.Rule) : any[]{
        const ret:any[] = []
        if(rule.from !== undefined)
            ret.push(rule.from)
        if(rule.to !== undefined){
            if(rule.from != rule.to)
                ret.push(rule.to)
        }
        if(rule.regex !== undefined)
            ret.push(rule.regex)
        return ret
    }
}

export class DefaultSettings implements Validator.Settings{
    defaultDateFormat: string = 'yyyy-MM-dd hh:mm:ss'
    messages: Map<Validator.Message, string> = new Map()
    converter: Validator.MessageConverter = (message: string | null | undefined, _format?: string, ...args:any[]) : string => {
        if(message === null || message === undefined)
            return ''
        if(args === null || args === undefined || args.length == 0)
            return ''

        const result = [];
        for(let i = 0; i < message.length; i++){
            const target = message.charAt(i)
            if(target == '{'){
                const argumentsIndex = [];
                let isIllegalPattern = false;
                i++;

                while(message.charAt(i) !== '}'){
                    const pos = message.charAt(i)
                    if(/^[0-9]{1}$/.test(pos))
                        argumentsIndex.push(pos)
                    else
                        isIllegalPattern = true
                    i++;
                }

                if(isIllegalPattern || argumentsIndex.length == 0)
                    continue
                const argumentsIndexNum = parseInt(argumentsIndex.join(''));
                if(argumentsIndexNum >= args.length)
                    continue

                let embedVal = args[argumentsIndexNum]
                if(embedVal === null || embedVal === undefined)
                    embedVal = ''
                if(embedVal instanceof Date){
                    if(_format !== undefined)
                        embedVal = format(embedVal, _format)
                    else
                        embedVal = format(embedVal, this.defaultDateFormat)
                }
                result.push(embedVal)
            }
            else{
                result.push(target)
            }
        }
        return result.join('')
    }
    constructor(){
        this.messages.set("required","Input is required")
        this.messages.set("numeric", "Please enter numerical values")
        this.messages.set("ascii", "Please use alphanumeric symbols")
        this.messages.set("email", "Please enter email address")
        this.messages.set("hiragana", "Please enter in hiragana")
        this.messages.set("katakana", "Please enter in katakana")
        this.messages.set("zenkaku", "Please enter in zenkaku")
        this.messages.set("length_from_to", "Please enter {0} to {1} characters")
        this.messages.set("length_from", "Please enter at least {0} characters")
        this.messages.set("length_to", "Please enter up to {0} characters")
        this.messages.set("length_exactly", "Please enter exactly {0} characters")
        this.messages.set("range_from_to", "Please enter from {0} to {1}")
        this.messages.set("range_from", "Please enter at least {0}")
        this.messages.set("range_to", "Please enter less than or equal to {0}")
    }
}
export class Executor{
    _validators: Map<Validator.ValidateType,Validator.IsOk> = new Map()
    _regexNumber: RegExp = /^\d+$/
    constructor(){
        this._validators.set("required", (input: string, rangeFrom: number | undefined, rangeTo: number | undefined, regex: RegExp | undefined): boolean => {
            if(input == null || input == "")
                return false
            return true
        })
        this._validators.set("regex", (input: string, rangeFrom: number | undefined, rangeTo: number | undefined, regex: RegExp | undefined): boolean => {
            if(regex === undefined || regex === null)
                return true
            return regex.test(input)
        })
        this._validators.set("clength", (input: string, from: number | undefined, to: number | undefined, regex: RegExp | undefined): boolean => {
            if((input === undefined || input === null) && (from == 0 || from === undefined || from === null))
                return true
            if(input == null)
                return from == 0
            if(from !== null && from !== undefined && from < 0)
                console.warn("ValidatorClass.Executor#clength : legnth from is less than 0.")
            const adjustFrom = from === undefined || from === null ? 0 : from
            if(to === undefined || to === null)
                return input.length >= adjustFrom
            return input.length >= adjustFrom && input.length <= to
        })
        this._validators.set("range", (input: string, from: number | undefined, to: number | undefined, regex: RegExp | undefined): boolean => {
            if((input === undefined || input === null) && (from == 0 || from === undefined || from === null))
                return true
            if(input == null)
                return from == 0
            if(!this._regexNumber.test(input))
                return false
        
            const val = parseInt(input)
            if(from !== null && from !== undefined && from < 0)
                console.warn("ValidatorClass.Executor#range : range from is less than 0.")
            if(val < 0)
                return false
        
            const resultFrom = from === undefined || from === null ? true : from <= val
            const resultTo = to === undefined || to === null ? true : to >= val
            return resultFrom && resultTo
        })
        this._validators.set("rangeIncludeMinus", (input: string, from: number | undefined, to: number | undefined, regex: RegExp | undefined): boolean => {
            if((input === undefined || input === null) && (from == 0 || from === undefined || from === null))
                return true
            if(input == null)
                return from == Number.MIN_VALUE
            if(!this._regexNumber.test(input))
                return false
        
            const val = parseInt(input)
            const resultFrom = from === undefined || from === null ? true : from <= val
            const resultTo = to === undefined || to === null ? true : to >= val
            return resultFrom && resultTo
        })
    }
    createOk(rule: Validator.Rule): Validator.IsOk{
        return (input: string) : boolean => {
            if(!this._validators.has(rule.rule))
                return true
            if(rule.rule == "custom" && rule.custom !== undefined)
                return rule.custom(input)
            return this._validators.get(rule.rule)!(input, rule.from, rule.to, rule.regex)
        }
    }
}
export class I18nPluginSettings implements Validator.Settings{
    defaultDateFormat:string = 'yyyy-MM-dd hh:mm:ss'
    messages: Map<Validator.Message, string>
    converter: Validator.MessageConverter
    constructor(converter: Validator.MessageConverter){
        this.converter = converter
        this.messages = new Map([
            ["required", "validate.required"],
            ["numeric", "validate.numeric"],
            ["ascii", "validate.ascii"],
            ["email", "validate.email"],
            ["hiragana", "validate.hiragana"],
            ["katakana", "validate.katakana"],
            ["zenkaku", "validate.zenkaku"],
            ["length_from_to", "validate.length_from_to"],
            ["length_from", "validate.length_from"],
            ["length_to", "validate.length_to"],
            ["length_exactly", "validate.length_exactly"],
            ["range_from_to", "validate.range_from_to"],
            ["range_from", "validate.range_from"],
            ["range_to", "validate.range_to"]
        ])
    }
}
export class I18nPluginValidator implements Validator.Plugin{
    settings: Validator.Settings
    create: Validator.UseValidator
    constructor(useValidator: Validator.UseValidator, converter: Validator.MessageConverter){
        this.create = useValidator
        this.settings = new I18nPluginSettings(converter)
    }
}
