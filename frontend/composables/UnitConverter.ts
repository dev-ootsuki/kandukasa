import * as DomainClass from '~/types/Domain.class'

const TeraByteUnit = new DomainClass.ByteUnit("TB", Math.pow(1024,4), Math.pow(1024,5),2)
const GigaByteUnit = new DomainClass.ByteUnit("GB", Math.pow(1024,3), Math.pow(1024,4),2)
const MegaByteUnit = new DomainClass.ByteUnit("MB", Math.pow(1024,2), Math.pow(1024,3),2)
const KiroByteUnit = new DomainClass.ByteUnit("MB",          1024,    Math.pow(1024,2),2)
const ByteUnit = new DomainClass.ByteUnit(    "B" ,             0,             1024   ,2)
const ByteUnits = [ByteUnit, KiroByteUnit, MegaByteUnit, GigaByteUnit, TeraByteUnit]

export const byteToLargeUnit = (val:number) : string => {
    const unit = ByteUnits.find(e => e.inRange(val))
    if(unit == null)
        return `${val}`
    return unit.exchangeToString(val)
}