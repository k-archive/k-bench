#!/bin/sh

arangosh --javascript.execute arango-cluster-start.js
arangosh --javascript.execute --server.endpoint tcp://127.0.0.1:8530 arango-cluster-create-db.js
node bench.js arango-sharding populate
node bench.js arango-sharding populate
node bench.js arango-sharding populate
node bench.js arango-sharding populate
