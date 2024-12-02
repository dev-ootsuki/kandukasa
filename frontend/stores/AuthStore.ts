import { defineStore } from 'pinia'
import type { Auth } from '~/types/Types'
import * as AuthClass from '~/types/Auth.class'

type State = {
    roleId: number,
}

const authorizer = new AuthClass.Authorizer()

export const useAuthStore = defineStore('auth', {
    // convert to a function
    state: (): State => ({
        roleId:0
    }),
    getters: {
    },
    actions: {
        hasAuth(roleId:number, func:Auth.FunctionsType, perm: Auth.PermissionType) : boolean{
            return authorizer.getRole(roleId).has(func, perm)
        }
    }
})
