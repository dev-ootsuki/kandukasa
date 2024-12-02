import { useLoadingStore } from '~/stores/LoadingStore'
import { useErrorStore } from '~/stores/ErrorStore'

export default defineNuxtPlugin((nuxtApp) => {
    const apiKey = ""
    const webapi = $fetch.create({
      baseURL: '/api',
      onRequest({ request, options, error }) {
        options.headers.set('Authorization', `Bearer ${apiKey}`)
        useLoadingStore().show()
      },
      onResponse({ request, options, response }) {
        useLoadingStore().hide()
      },
      async onResponseError({ response, options }) {
        useErrorStore().addError({
          data: response._data,
          status: response.status,
          method: options.method === undefined ? "GET" : options.method,
          url:response.url,
          detail: {
            message: response._data.error,
            stackMessage: response?._data?.exception,
            stackTrace: response?._data?.traces?.["Framework Trace"]?.map((e:any) => e?.trace)
          }
        })
        .showDialog()
      },
    })
    return {
      provide: {
        webapi,
      },
    }
})

export type WebAPIFailed<T> = {
  data: T,
  status: string,
  errors: WebAPIError
}

export type WebAPIError = {
  message: string
}