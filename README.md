# cap-js-pg-100-columns

@cap-js/postgres issue with more than 100 columns

## Description of erroneous behaviour 

I am running the latest versions of CAP and @cap-js/postgres (see excerpt from `package.json` below)

```json
  "dependencies": {
    "@cap-js-community/odata-v2-adapter": "^1.11.4",
    "@cap-js/postgres": "^1.0.1",
    "@sap/cds": "^7",
    "express": "^4",
    "express-http-proxy": "^1.6.3"
  },
  "devDependencies": {
    "@cap-js/sqlite": "^1",
    "@sap/ux-specification": "^1.108.10"
  },
```

When executing a SELECT I'm hitting a hard limitation in the PostgreSQL function `json_build_object` (100 arguments to a function). This seems to be a hard-coded limitation within the PG client library

```text
[cds] - error: cannot pass more than 100 arguments to a function
    at test1/node_modules/pg/lib/client.js:526:17
    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
    at async Object.all (test1/node_modules/@cap-js/postgres/lib/PostgresService.js:119:26)
    at async PostgresService.onSELECT (test1/node_modules/@cap-js/db-service/lib/SQLService.js:66:16)
    at async next (test1/node_modules/@sap/cds/lib/srv/srv-dispatch.js:79:17)
    at async next (test1/node_modules/@sap/cds/lib/srv/srv-dispatch.js:79:17)
    at async PostgresService.handle (test1/node_modules/@sap/cds/lib/srv/srv-dispatch.js:77:10)
    at async ReportService.<anonymous> (test1/node_modules/@sap/cds/libx/_runtime/common/generic/crud.js:67:16)
    at async next (test1/node_modules/@sap/cds/lib/srv/srv-dispatch.js:79:17)
    at async ReportService.handle (test1/node_modules/@sap/cds/lib/srv/srv-dispatch.js:77:10) {
  length: 118,
  severity: 'ERROR',
  code: '54023',
  detail: undefined,
  hint: undefined,
  position: '8',
  internalPosition: undefined,
  internalQuery: undefined,
  where: undefined,
  schema: undefined,
  table: undefined,
  column: undefined,
  dataType: undefined,
  constraint: undefined,
  file: 'parse_func.c',
  line: '136',
  routine: 'ParseFuncOrColumn',
  sql: `SELECT json_build_object(... not distinct from $1 LIMIT 1) as Xyz\n` +
    ' ^',
  id: '1518066',
  level: 'ERROR',
  timestamp: 1690503126781
}
```
This works fine with SQLite (I truncated the rather lengthy SQL statement above as the contents are irrelevant).  When researching this issue the suggestion came to use multiple calls of `JSONB` and
concatenate the result with `||` as a workaround for this limitation
([see stackexchange](https://stackoverflow.com/questions/53376451/cannot-pass-more-than-100-arguments-to-a-function-to-json-build-object)  and [PostgreSQL JSON Functions and Operators](https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSONB-OP-TABLE))

## Detailed steps to reproduce

The moment you attempt to execute a SELECT with more that 100 arguments it will fail with the above on PostgreSQL but not on SQLite.

## Details about your project

It's a customer business application that uses in this select a couple of tables with >30 columns. The following sample reproduces the same issue.

| test100 | https://github.com/cforkin/cap-js-pg-100-columns |
|:---------------------- | ----------- |
| Node.js                | v18.16.1    |
| @sap/cds               | 7.0.2       |
| @sap/cds-compiler      | 4.0.2       |
| @sap/cds-dk            | 7.0.3  |
| @sap/cds-dk (global)   | 7.0.3       |
| @sap/eslint-plugin-cds | 2.6.3       |
| @sap/cds-mtxs          | 1.9.2       |
