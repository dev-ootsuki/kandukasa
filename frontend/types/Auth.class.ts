import type { Auth } from '@/types/Types'

class Role implements Auth.Role{
    availableFunctions:Auth.UserRoleMapping []  = []
    constructor(...mappings: Auth.UserRoleMapping[]){
        this.availableFunctions
    }
    has(func:Auth.FunctionsType, perm: Auth.PermissionType) : boolean{
        const ret = this
            .availableFunctions
            .find(e => e.func == func)?.perm.find(e => e == "all" ? true : e == perm)
        return ret !== undefined
    }
}
class MasterRole extends Role{
    override has(func:Auth.FunctionsType, perm: Auth.PermissionType) : boolean{
        return true
    }
}

const admin: Role = new MasterRole()
const NoRole: Role = new Role()
const view: Role = new Role(
    { func: "connections", perm:["read"] },
    { func: "schemas", perm:["read", "bulk_read"] },
    { func: "tables", perm:["read", "bulk_read", "readtable"] },
    { func: "columns", perm:["read", "bulk_read"] },
)
const maintenance: Role = new Role(
    { func: "users", perm:["read", "bulk_read"] },
    { func: "connections", perm:["read"] },
    { func: "schemas", perm:["all"] },
    { func: "tables", perm:["all"] },
    { func: "views", perm:["all"] },
    { func: "events", perm:["all"] },
    { func: "triggers", perm:["all"] },
    { func: "routines", perm:["all"] },
    { func: "columns", perm:["all"] },
)

const RoleMap = [admin, maintenance, view]

export class Authorizer{
    getRole(roleId: number): Auth.Role{
        return RoleMap[roleId]
    }
}

