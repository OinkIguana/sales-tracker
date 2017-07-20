'use strict';
import * as express from 'express';
import * as bodyParser from 'body-parser';
import * as path from 'path';

import api from './api';

const app = express();
app.listen(process.env.PORT || 8080, () => {
  // tslint:disable-next-line
  console.log('Server is listening on port 8080');
});
app.use(bodyParser.json());
app.use('/api', api);
app.use('/test/', (_, res) => res.sendFile(path.resolve(__dirname, '../web/dist/test.html')));
app.use('/', express.static(path.resolve(__dirname, '../web/dist')));
app.use('/', (_, res) => res.sendFile(path.resolve(__dirname, '../web/dist/index.html')));
