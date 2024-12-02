import type { ProxyForm } from '~/types/Types'
import type { Reactive } from 'vue'

const _logging = (message:string, ...args:any[]) :void => {
        //console.log(log, args)
}
export class InputRefsAggregator<T extends ProxyForm.PF> implements ProxyForm.InputRefsAggregator<T>{
    props: string[]
    domain: T
    refs: Map<string, Ref> = new Map()
    constructor(domain: T, refIdPrefix: string){
        this.domain = domain
        this.props = Object.getOwnPropertyNames(domain)
        this.props?.forEach(prop => {
            const ref = useTemplateRef(`${refIdPrefix}.${prop}`)
            this.refs.set(prop, ref)
        })
    }
    apply(target: T, thisArg: any, argArray: any[]): any{
        _logging("InputRefsAggregator#apply", target, thisArg, argArray)
    }
    get(target: T, p: string | symbol, receiver: any): any{
        _logging('InputRefsAggregator#get', target, p, receiver)
        const propName = String(p)
        if(!this.props.includes(propName) && !this.has(target, p))
            return undefined
        return this.refs.get(propName)?.value
    }
    set(target: T, p: string | symbol, newValue: any, receiver: any): boolean{
        _logging("InputRefsAggregator#set", target, p, newValue, receiver)
        if(!this.props.includes(String(p)))
            return true // Through !!!! cause InputRefsAggregator is dummy

        const ref = this.refs.get(String(p))
        if(ref !== undefined){
            if(!isReadonly(ref))
                ref.value = newValue
        }
        return true
    }
    has(target: T, p: string | symbol) : boolean{
        _logging('InputRefsAggregator#has', target, p)
        if(this.props.includes(String(p)))
            return true
        return ["isValid", "useModel"].includes(String(p))
    }
    isValid(): boolean {
        _logging("InputRefsAggregator#isValid()")
        let ret = true
        for(const [k, v] of this.refs){
            if(v == null)
                continue;
            if(v.value == null)
                continue;

            if(v.value.validate === undefined)
                continue;
            const validResult = v.value.validate()
            ret &&= validResult
        }
        return ret
    }
    toDomain(): {} {
        return true
    }
    useModel(prop: string) : Ref | undefined{
        return this.refs.get(prop)
    }
    usePrimary(propName: string): string | number | boolean | null | undefined {
        return null
    }
}

export class CompositeProxy<T extends ProxyForm.PF> implements ProxyForm.CompositeProxy<T, Reactive<T>>{
    composites: ProxyForm.PF[]
    primary: Reactive<T>
    props: string[]
    methods : string[] = []
    prefix: string
    constructor(domain: T, prefix:string, ...composites: ProxyForm.PF[]){
        this.props = Object.getOwnPropertyNames(domain)
        this.primary = reactive<T>(domain)
        this.composites = composites
        this.methods = this.getMethodNames()
        this.prefix = prefix
    }
    apply(target: T, thisArg: any, argArray: any[]): any{
        return (this as any)[target].apply(this, ...argArray)
    }
    get(target: T, p: string | symbol, receiver: any): any{
        _logging(`CompositeProxy#get ${p.toString()} : `, arguments)
        const { propName, propValue } = this.toProp(this.primary, p)
        if(this.isSelfMethod(propName)){
            const bindParent = this
            return new Proxy((...args: any[]) => {}, {
                apply(target: any, thisArg: any, argArray: any[]) : any{
                    return (bindParent as any)[propName].apply(bindParent, ...argArray)
                }
            })
        }
        if(this.isMethod(propName)){
            return this.callMethod(target, propName, receiver, arguments)
        }
        if(propValue !== undefined)
            return propValue
        return this.composites.find(composite => {
            const cPropValue = this.getAnyValueByKey(composite, propName)
            if(cPropValue !== undefined)
                return cPropValue
            return false
        })
    }
    set(target: T, p: string | symbol, newValue: any, receiver: any): boolean{
        _logging(`CompositeProxy#set ${p.toString()} : `, arguments)
        const propName = this.toPropName(p)
        let ret = true
        if(Object.hasOwn(this.primary, propName))
            (this.primary as any)[propName] = newValue
        this.composites.map(composite => {
            (composite as any)[propName] = newValue
        })
        return ret
    }
    usePrimary() : Reactive<T>{
        return this.primary
    }
    private isSelfMethod(prop:string) : boolean{
        return ["usePrimary"].includes(prop)
    }
    private toProp(target:any, p : string | symbol) : { propName: string, propValue: any }{
        const propName = this.toPropName(p)
        return { propName: propName, propValue: target[propName] }
    }
    private toPropName(p : string | symbol) : string{
        return String(p)
    }
    private getAnyValueByKey(target: any, p: string) : any{
        return (this.primary as any)[p]
    }
    private getMethodNames() : string[]{
        const _getOwnMethods = (obj: Object) => {
            return Object
            .entries(Object.getOwnPropertyDescriptors(obj))
            .filter(([name, {value}]) => {
                return typeof value === 'function' && name !== 'constructor' && !["get", "set", "has", "apply"].includes(name)
            })
            .map(([name]) => name)
        }
        const _getMethods = (o: object, methods: string[]): string[] => {
            return o === Object.prototype ? methods : _getMethods(Object.getPrototypeOf(o), methods.concat(_getOwnMethods(o)))
        }
        let methodNames : string[] = []
        this.composites?.forEach(e => {
            methodNames = [..._getMethods(e, methodNames)]
        })
        methodNames = [...new Set(_getMethods(this.primary, methodNames))]
        return methodNames
    }
    private isMethod(p : string) : boolean {
        return this.methods.includes(p)
    }
    private callMethod(target: T, p: string, receiver: any, args: any): any{
        const bindParent = this
        return new Proxy((...args: any[]) => {}, {
            apply(target: any, thisArg: any, argArray: any[]) : any{
                let ret = true
                const method = (bindParent.primary as any)[p]
                ret &&= method !== undefined ? method.apply(bindParent.primary, args) : true
                ret &&= bindParent.callCompositeMethod(p, argArray)
                return ret
            }
        })
    }
    private callCompositeMethod(propName:string, ...args: any[]) : any{
        let ret = true
        this.composites?.forEach(e => {
            const compositemethod = (e as any)[propName]
            ret &&= compositemethod !== undefined ? compositemethod.apply(e, args) : true
        })
        return ret
    }
}