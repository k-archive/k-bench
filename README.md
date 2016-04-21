# k-bench

A Node.js app for Mongo/Arango comparison.

Usage:

```
git clone https://github.com/k-archive/k-bench.git
cd k-bench
npm install
```

and either start Mongo (the database will be created automatically as `kantele-app`.
```
node server.js mongo
```

or Arango. You will need to create the database beforehand (`kantele-app`).

```
node server.js arango
```

When you get the app running, click "Populate database" and then "Start benchmarking". Let it run a couple of minutes and stop/start benchmarking again to make sure the number will converge to about the same.
