// arangosh --javascript.execute arango-cluster-start.js

var Planner = require("org/arangodb/cluster").Planner;
var p = new Planner({numberOfDBservers:3, numberOfCoordinators:2});
var Kickstarter = require("org/arangodb/cluster").Kickstarter;
k = new Kickstarter(p.getPlan());
k.launch();

// arangosh --server.endpoint tcp://127.0.0.1:8530 --javascript.execute arango-cluster-create-db.js
