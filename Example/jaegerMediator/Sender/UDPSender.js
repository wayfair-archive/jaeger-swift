var Thrift = require('thriftrw').Thrift;
var dgram = require('dgram');
var fs = require('fs');
var path = require('path');

// Get Agent/Collector configuration
const configuration = require('../configuration.json');
const host = configuration.collector.udp.host;
const port = configuration.collector.udp.port;
const bufferSize = configuration.collector.udp.bufferSize;
const agentVersion = configuration.agent.version;
const agentId = configuration.agent.id;

const agentThrift = new Thrift({
  entryPoint: path.join(__dirname, '../Thrift/agent.thrift'),
  allowOptionalArguments: true,
  allowFilesystemAccess: true
});

const jaegerThrift = new Thrift({
  source: fs.readFileSync(path.join(__dirname, '../Thrift/jaeger.thrift'), 'ascii'),
  allowOptionalArguments: true,
});

const client = dgram.createSocket('udp4');
client.on('error', err => {
  console.log(`error sending spans over UDP: ${err}`);
});

var prunedSpans = function(spans) {
  while (JSON.stringify(spans).length > bufferSize) {
    spans.pop()
  }
  return spans
}

var emittableBatch = function(process, spans) {
  return new agentThrift.Agent.emitBatch.ArgumentsMessage({
    version: agentVersion,
    id: agentId,
    body: {
      batch: new jaegerThrift.Batch({
        process: process,
        spans: spans,
      }),
    }
  });
}

var send = function(buffer) {
  client.send(buffer, 0, buffer.length, port, host, (err, sent) => {
    if (err) {
      console.log(err);
    }
  });
}

module.exports = {

  reportBatch: function(batch) {

    // Get the spans
    let spansToSend = []

    // First, let's truncate the payload if it is above 60 KB
    let truncatedSpans = prunedSpans(batch.spans)

    truncatedSpans.forEach(function(spanJson){
      spansToSend.push(new jaegerThrift.Span(spanJson))
    })

    // Creating a batch to report to collector
    let data = emittableBatch(batch.process, spansToSend);

    const thriftBuffer = Buffer.alloc(JSON.stringify(data).length);
    const writeResult = agentThrift.Agent.emitBatch.argumentsMessageRW.writeInto(data, thriftBuffer, 0);

    if (writeResult.err) {
      return;
    }

    // Send over UDP
    send(thriftBuffer);
  }
}
