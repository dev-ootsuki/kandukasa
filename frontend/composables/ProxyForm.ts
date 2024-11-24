import type { ProxyForm } from '~/types/Types'
import * as ProxyFormClass from '~/types/ProxyForm.class'

export function useProxyForm<T extends ProxyForm.PF>(model: T, refPrefix?: string) : T{
    const prefix = refPrefix === undefined ? typeof model : refPrefix
    const inputRefs = new ProxyFormClass.InputRefsAggregator(model, prefix)
    const handler = new ProxyFormClass.CompositeProxy<T>(model, prefix, inputRefs)
    return new Proxy<T>(model, handler)
}