import type { System } from '~/types/Types'

export class Config{
    databaseProducts:System.DbProduct[] = []
    dbDataPrimaryKey?:string
    dbMultiSelectedKeySeparator?:string
}