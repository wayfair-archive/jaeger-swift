const configuration = require('./configuration.json');
const samplePayload = require('./samplePayload.json');
const express = require('express');
var http = require('http');
const sender = require('./Sender/UDPSender');

var app = express();

app.set('port', process.env.PORT || configuration.port);
app.set('host', process.env.HOST || configuration.host);
app.use(express.json({limit: configuration.payloadLimit}));
app.use(express.urlencoded({limit: configuration.payloadLimit}));

// API: Get the current configuration of the mediator
app.get('/', (req, res) => {
    res.json(configuration);
});

// API: Get the structure of the span accepted by the /spans endpoint
app.get('/sampleBatch', (req, res) => {
    res.json(samplePayload);
});

// API: Report spans to a Jaeger Collector
app.post('/batch', function (req, res) {
  sender.reportBatch(req.body)
  res.status(200).send({
    error: null,
    message: "Success"
  });
});

http.createServer(app).listen(app.get('port'), app.get('host'), function(){
  console.log("Jaeger Mediator server listening on port " + app.get('port'));
  console.log("** Use the /batch endpoint to report your Jaeger Spans to a Jaeger collector. **");
  console.log("** The collector and agent can be configured in configuration.json **");
  console.log("** To see an example of the accepted structure for reporting spans, make a GET to /sampleBatch **");
});

module.exports = app;
