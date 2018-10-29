/* @flow */
import { model } from '../model'
import { exportProducts, exportRecords } from '../model/dialog/export'
import { importProducts } from '../model/dialog/import'

import type { Convention } from '../model/convention'

export function closeDialog() {
  model.next({
    ...model.getValue(),
    dialog: null,
  })
}

export function showExportProductsDialog() {
  model.next({
    ...model.getValue(),
    dialog: exportProducts,
  })
}

export function showExportRecordsDialog(convention: Convention) {
  model.next({
    ...model.getValue(),
    dialog: exportRecords(convention),
  })
}

export function showImportProductsDialog() {
  model.next({
    ...model.getValue(),
    dialog: importProducts,
  })
}
