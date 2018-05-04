/* @flow */
import * as React from 'react'
import moment from 'moment'

import Map from '../../util/default-map'
import { List } from '../../common/list'
import { Font } from '../../common/font'
import { Item } from '../../common/list/item'
import { model } from '../../model'
import { l } from '../../localization'
import { SecondaryCard } from '../card-view/secondary-card'
import type { Record } from '../../model/record'
import type { Product } from '../../model/product'
import type { ProductType } from '../../model/product-type'
import S from './info.css'

export type Props = {
  record: Record,
  // $FlowIgnore
  anchor: React.Ref<HTMLElement>,
}

function format(date: Date): string {
  return moment(date).format(l`h:mma`)
}

export function RecordInfo({ record, anchor }: Props) {
  const { products, productTypes } = model.getValue()

  const productInfo: [ProductType, Product[]][] = [...record.products
    .map(id => products.find(product => product.id === id))
    // $FlowIgnore
    .reduce((acc, product) => acc.set(product.typeId, [...acc.get(product.typeId), product]), new Map([], []))]
    // $FlowIgnore
    .map(([typeId, products]) => [productTypes.find(type => type.id === typeId), products])

  return (
    <SecondaryCard title={l`Sale`} anchor={anchor}>
      <List>
        <Item className={S.info}>
          <Font smallCaps semibold>{l`Price`}</Font>
          { record.price.toString() }
        </Item>
        <Item className={S.info}>
          <Font smallCaps semibold>{l`Time`}</Font>
          { format(record.time) }
        </Item>
      </List>
      <div className={S.info}>
        <Font smallCaps semibold>{l`Products`}</Font>
        <div className={S.rule}/>
      </div>
      <div className={S.note}>
        { productInfo.map(([type, products]) =>
          <div className={S.type} key={`type_${type.id}`}>
            <div>{type.name}</div>
            {/* $FlowIgnore */}
            <div className={S.products}>{ products.map(({ name }, i) => <span className={S.product} key={`product_${i}`}>{name}</span>) }</div>
          </div>
        ) }
      </div>
      <div className={S.info}>
        <Font smallCaps semibold>{l`Note`}</Font>
        <div className={S.rule}/>
      </div>
      <div className={S.note}>{ record.info }</div>
    </SecondaryCard>
  )
}