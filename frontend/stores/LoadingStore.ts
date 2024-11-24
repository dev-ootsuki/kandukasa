import { defineStore } from 'pinia'

type State = {
    loading: boolean,
}

export const useLoadingStore = defineStore('loading', {
    // convert to a function
    state: (): State => ({
        loading:false
    }),
    getters: {
        isLoading(state: State){
            return state.loading
        }
    },
    actions: {
        show(){
            this.loading = true
        },
        hide(){
            this.loading = false
        },
        clear(){
            this.loading = false
        }
    }
})
