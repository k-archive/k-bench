# k-bench

A Node.js app for Mongo/Arango comparison.

Usage:

```
git clone https://github.com/k-archive/k-bench.git
cd k-bench
npm install
```

and either start the app as configured for Mongo (the database will be created automatically as `kantele-app`.
```
node server.js mongo
```

...or for Arango. You will need to create the database beforehand (`kantele-app`).

```
node server.js arango
```

When you get the app running, point your browser to `http://127.0.0.1:3000` and click "Populate database" and then "Start benchmarking". Let it run a couple of minutes and stop/start benchmarking again to make sure the number will converge to about the same.

## What should happen?

I'm consistently seeing higher number with Arango. Populating the database a "couple of times" may be a good idea. It adds 100 documents into the database when clicking the populate button. 200 documents may be a good number to test with.
