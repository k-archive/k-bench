# k-bench

A Node.js app for Mongo/Arango comparison.

# Requirements

- Arangodb
- Mongodb 3.0.x (3.2 not yet supported)


# Install

```
npm install k-bench
cd k-bench
```
You need to create the database for Arango manually. Database name: **kantele-app**. Mongo database will be created automatically.

#Usage

Populate db (add 100 documents):
```
- node bench.js arango populate
- node bench.js mongo populate
```

Clear db:
```
- node bench.js arango clear
- node bench.js mongo clear
```

Benchmark:
```
- node bench.js arango
- node bench.js mongo
```

Note: you can use `arango-sharding` and `mongo-sharding` too in place of arango/mongo. See mongo-cluster-start.txt for an example how a Mongo sharding can be created.

## What should happen?

I'm consistently seeing higher number with Arango.

