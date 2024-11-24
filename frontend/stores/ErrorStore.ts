import { defineStore } from 'pinia'
import { type WebAPI } from '~/types/Types'

type State = {
    errors: WebAPI.WebAPIFailed[],
    dialog:boolean
}

export const useErrorStore = defineStore('error', {
    // convert to a function
    state: (): State => ({
        errors:[],
        dialog:false
    }),
    getters: {
        last(state: State) : WebAPI.WebAPIFailed | undefined{
            return state.errors.findLast(e => e)
        },
        all(state: State) : WebAPI.WebAPIFailed[]{
            return state.errors
        }
    },
    actions: {
        addError(error: WebAPI.WebAPIFailed){
            this.errors.push(error)
            return this
        },
        showDialog(){
            this.dialog = true
        },
        hideDialog(){
            this.dialog = false
        }
    }
})
