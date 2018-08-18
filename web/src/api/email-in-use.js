/* @flow */
import { of } from 'rxjs'
import { tap } from 'rxjs/operators'
import type { Observable } from 'rxjs'

import { GetRequest } from './index'
import type { Response, APIError } from './index'

export class EmailInUseRequest extends GetRequest<string, boolean> {
  cache: Map<string, boolean>

  constructor() {
    super('/api/account/exists')
    this.cache = new Map()
  }

  send(params: string): Observable<Response<boolean, APIError>> {
    if (this.cache.has(params)) {
      return of({ state: 'retrieved', value: this.cache.get(params) })
    }
    return super.send(params)
      .pipe(
        tap(response => {
          if (response.state === 'retrieved') {
            this.cache.set(params, response.value)
          }
        })
      )
  }
}
