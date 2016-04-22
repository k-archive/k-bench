# k-bench

A Node.js app for Mongo/Arango comparison.

# Requirements

- Arangodb
- Mongodb 3.0.x (3.2 not yet supported)


# Install

```
git clone https://github.com/k-archive/k-bench.git
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

## What should happen?

I'm consistently seeing higher number with Arango. 

