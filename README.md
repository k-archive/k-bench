# k-bench

A Node.js app for Mongo/Arango comparison.

# Requirements

- Arangodb
- Mongodb 3.0.x (3.2 not yet supported)


# Install

```
git clone https://github.com/k-archive/k-bench.git
cd k-bench
npm install
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

Note: you can use **arango-sharding** and **mongo-sharding** in place of **arango**/**mongo**. See mongo-cluster-start.txt for an example how a Mongo sharding cluster can be created.

## What should happen?

I'm consistently seeing higher number with Arango.

## Example output

```
got 200  Average: 60     Now: 61         Min: 40         Max: 244
got 200  Average: 60     Now: 54         Min: 40         Max: 244
got 200  Average: 60     Now: 70         Min: 40         Max: 244
got 200  Average: 60     Now: 65         Min: 40         Max: 244
got 200  Average: 60     Now: 44         Min: 40         Max: 244
got 200  Average: 60     Now: 48         Min: 40         Max: 244
got 200  Average: 60     Now: 61         Min: 40         Max: 244
got 200  Average: 60     Now: 47         Min: 40         Max: 244
got 200  Average: 60     Now: 70         Min: 40         Max: 244
```
