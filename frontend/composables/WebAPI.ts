import type { UseFetchOptions } from 'nuxt/app'

export function useWebAPI<T>(
  url: string | (() => string),
  options?: UseFetchOptions<T>,
) {
  return useFetch(url, {
    ...options,
    $fetch: useNuxtApp().$webapi as typeof $fetch
  })
}

export function webapi(){
  return useNuxtApp().$webapi as typeof $fetch
}