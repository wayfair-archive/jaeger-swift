# Jaeger-Swift

[![Build Status](https://travis-ci.org/wayfair/jaeger-swift.svg?branch=master)](https://travis-ci.org/wayfair/jaeger-swift)

Jaeger-Swift is a distributed tracing client for Uber's [Jaeger](https://www.jaegertracing.io/) platform written completely in Swift. It follows the official [Opentracing specification](https://github.com/opentracing/specification/blob/master/specification.md).

## Installation

This section has quick setup steps for getting a simple proof of concept up and running. For a more comprehensive understanding of this project, Check out our [API reference](https://wayfair.github.io/jaeger-swift). A complete Opentracing solution consists of a client, an agent and a collector. The following steps will show you how to configure this project to report to a locally hosted Jaeger collector.

#### Step 1 - Spin up a Jaeger collector

If you already have a Jaeger collector up and running, you can skip this step. If not, you can run the Jaeger all-in-one docker image published to DockerHub by running the following command in Terminal. Once this step is completed, you should have a working Jaeger collector running locally.

```
$ docker run -d --name jaeger \
-e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
-p 5775:5775/udp \
-p 6831:6831/udp \
-p 6832:6832/udp \
-p 5778:5778 \
-p 16686:16686 \
-p 14268:14268 \
-p 9411:9411 \
jaegertracing/all-in-one:1.11
```

Now, if you open your browser and type [http://localhost:16686](http://localhost:16686), you should see the Jaeger web interface that displays trace information. Of course, there won't be any traces from our client there.

#### Step 2 - Setup a mediator service
The Jaeger collector only accepts data that is encoded in `Thrift` format. We have a mediator service that the client can report to. This mediator service accepts JSON spans from the Swift client, encodes this data to `Thrift Binary` format and reports it to the Jaeger collector over UDP.

* Download [our Jaeger mediator service](./Example/jaegerMediator).
* By default, this mediator service reports spans to the locally hosted collector. If you already have a remote collector setup, you can specify the location in `configuration.json`.
* Open Terminal. Run `npm ci` and then run `npm start`. You should now have the mediator service running on `http://localhost:3000`. You should see this message printed in the console:

```
Jaeger Mediator server listening on port 3000
** Use the /batch endpoint to report your Jaeger Spans to a Jaeger collector. **
** The collector and agent can be configured in configuration.json **
** To see an example of the accepted structure for reporting spans, make a GET to /sampleBatch **
```

* This step is optional. Most machines have a limit on the payload size for UDP packets. This limit is usually `9216 bytes`. At times, this can throttle our payload if we report a larger number of spans to the collector. Therefore, if you anticipate that you will be reporting a lot of spans over short durations, you can update this threshold to a preferred size for UDP payloads using this command. The maximum supported size for UDP packets is 65 KB.

```
sudo sysctl net.inet.udp.maxdgram=65536
```

#### Step 3 - Setup the client library in your XCode project

##### Versions

* For `Swift 4.2` use `Jaeger-swift 3.0.0`.
* `Jaeger-swift 4.0.0` is targeting `Swift 5`.

##### Carthage

* Add `github "wayfair/jaeger-swift" == 4.0.0` to your `Cartfile`.
* Run `carthage bootstrap` to download and generate the Jaeger Framework.
* Drag `Jaeger.framework` from the appropriate platform directory in `Carthage/Build/` to the “Linked Frameworks and Libraries” section of your Xcode project’s “General” settings.


## What is Distributed Tracing?

Based on the official [Opentracing documentation](https://opentracing.io/docs/overview/what-is-tracing/), Distributed tracing, also called distributed request tracing, is a method used to profile and monitor applications, especially those built using a microservices architecture. Distributed tracing helps pinpoint where failures occur and what causes poor performance. In essence, distributed tracing is basically a way to aggregate and report a collection of spans. Spans and Traces are described in more detail below:

![jaeger overview](https://user-images.githubusercontent.com/2333426/49960014-1d716b80-fedd-11e8-8acd-c0be92337cc6.png)

#### What is a Span?

A measurable unit of work in the distributed tracing world is referred to as a `Span`. For example, the round trip time associated with a single endpoint request from an app, or, the time it takes for a single view to load can be a `Span`. A span needs to be related to other spans in the span hierarchy unless it is a root span. Spans can be aggregated under a `Trace`. We can think of a trace as an aggregation of spans. By aggregating enough spans, we can get a detailed idea of performance bottlenecks, relationships between different tasks. A distributed tracing client facilitates applications to send a collection of spans to a span collector service.

Spans can be related to each other through two kinds of relationships:

* Parent-Child relationship
* Follows-from relationship

A parent-child relationship can be used to group one or more spans that may be dependent on a specific span. Consider an API request that fetches data from the database and returns a JSON to the client. A parent span can encompass the entire duration of the request/response lifecycle. A child span can now be started when the middleware validates the request from the client, and another child span can be started when the middleware fetches the data from the server. These two child spans happen within the context of the parent span because the parent span can be completed only after the response has been sent to the client and for that to happen, the validation and the record-fetch will need to happen. There is a timing-dependency between the parent span and these 2 child spans, meaning, the child spans will need to be started before the parent span (associated with the API request) is finished.

A follows-from relationship is a little different from a parent-child relationship. In this case, there is still an association between two or more spans. However, there isn't a timing dependency between the spans. Consider this scenario - you have an app that fetches images from a server and renders the content on the UI. In this case, you will need to fetch the images from the server which is span A, and, render the images after the images are fetched which is span B, so, one operation follows the other. There is a contextual dependency between the spans because span B cannot start until span A has finished. However, span B doesn't start until span A has already finished, so span B doesn't fall under the time umbrella of span A. Therefore, this type of relationship is best expressed as a follows-from relationship.

###### Structure of a Span

Each span has the following components:

* A span context which has some data to uniquely identify that span. Specifically, it has a span ID and a trace ID. The span ID is a UUID which is unique to the span and the trace ID links the span with the trace that encompasses the span.
* A list of span references which denote how the span is related to other spans.

#### What is a Trace?

A trace is a collection of spans. Think of a trace as an aggregation of all the spans over a certain duration. For example, all the spans we measure in a single app session can be aggregated in a trace.

## Parts of a Distributed Tracing Client

A distributed tracing client is made up of the following components:
* Tracer
* Agent
* Collector

#### Tracer
A tracer is an object that manages traces. A tracer's responsibility involves starting and stopping spans and sending the spans to an agent.

#### Agent

An agent is responsible for sending the collected spans to a span collector. An agent may optionally also have logic to cache the spans and batch send them if needed.

#### Collector

A collector is a service that ingests spans sent by an agent. Two of the most popular tracing services at the moment are [Zipkin](https://zipkin.io/) and [Jaeger](https://www.jaegertracing.io/).

#### Mediating Jaeger Spans

One of the challenges we ran into while building this project is that the Jaeger collector we report to only accepts data encoded in `Thrift`. We made an engineering decision not to perform this encoding on the client as it required an extra dependency. Therefore, we built a mediator service that takes in spans from the client, encodes this data to `Thrift Binary` format, and reports it to a sender.

## Fitting everything together

![jaeger sequence](https://user-images.githubusercontent.com/2333426/49960015-1d716b80-fedd-11e8-98b8-48727f34414d.png)

When we create an instance of the Jaeger client, we specify two time intervals, a queuing time interval and a reporting time interval. When the app starts a new span, the span stores the timestamp at the exact moment. Once the span is finished, the span is queued in memory for the duration of the queuing time interval. Once this timer is invalidated, the agent picks up the spans and persists that data to disk. Now the second reporting timer picks up the spans from disk, reports the spans through the sender and then flushes the cache.

## Usage

* A simple app with just one view controller is shown below.

```swift
import UIKit
import Jaeger

class ViewController: UIViewController {

  let jaegerClient: JaegerCoreDataClient = {
    let mediatorEndpoint = URL(string: "http://localhost:3000/batch")!
    let configuration = CoreDataAgentConfiguration(averageMaximumSpansPerSecond: 5, savingInterval: 5, sendingInterval: 10, coreDataFolderURL: nil)!
    let process = JaegerBatchProcess(serviceName: "Demo App", tags: [])
    let sender = JaegerJSONSender(endPoint: mediatorEndpoint, process: process)
    return JaegerCoreDataClient(config: configuration, sender: sender)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
```

In the snippet shown above, we use the pre-built `JaegerCoreDataClient` which implements the `Agent` protocol and `JaegerJSONSender`, which, implements the `SpanSender` protocol. The sender accepts an array of type `SpanConvertible` which is a customizable representation of a span. Now, if you need to implement a strategy to report to a different collector like Zipkin, you can implement the `SpanConvertible` protocol to convert a `Span` into the appropriate format accepted by Zipkin. If you need a reference, we have done the same with `JaegerSpan`. The `Agent` and `SpanSender` being protocols are also customizable. If you need more information on this topic, you can refer our [API Documentation](https://wayfair.github.io/jaeger-swift).

Now if you need to create a simple root span, you can just do this.

```swift
let rootSpan = jaegerClient.tracer.startRootSpan(operationName: "A simple root span")
//Do something here
rootSpan.finish()
```

The above example describes a simple root span that is not related to any other span. If you have a scenario where you need to break down the measurement of a larger operation into smaller sub-operations, you can create child spans. In the following example, we have one big operation that takes 5 seconds to finish and a smaller operation that is started before the bigger operation ends which takes 3 seconds to finish. This type of scenario can be captured through a `parent-child` relationship.

```swift
func doWork(executionTime: Double, done: @escaping () -> ()) {
  DispatchQueue.main.asyncAfter(deadline: .now() + executionTime, execute: done)
}

func performOperations() {
  let rootSpan = jaegerClient.tracer.startRootSpan(operationName: "A simple root span")

  //Start the big operation
  doWork(executionTime: 5) {
    //Big operation finishes
    rootSpan.finish()
  }

  let childSpan = jaegerClient.tracer.startSpan(operationName: "A simple child span", childOf: rootSpan.spanRef, tags: [Tag(key: "childMeasurement", tagType: .string("a child operation"))])

  //Start a smaller operation that starts before the big operation ends
  doWork(executionTime: 2) {
    //Stop this span once the small operation finishes
    childSpan.finish()
  }
}
```

When building a new feature, in many cases, we might have a series of operations that will need to happen before a user can interact with the UI. For example, if we have a table view that is dynamically populated based on the response from an endpoint, we may need to A) fetch the data from the server, B) parse and validate what we received, C) reload our table view section(s) with the new data. In such a case, there are multiple operations that follow one another. This scenario can be captured through a `follows-from` relationship. Shown below, is an example where we grab an image from a URL and update a `UImageView`.

```swift
func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
  URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}

func updateView(with data: Data) {
  myCustomView.image = UIImage(data: data)
}

func updateImage() {
  let imageURLString = "http://www.website.com/image1.png"

  guard let imageURL = URL(string: imageURLString) else {
    return
  }

  //Start a new span to record image download time
  let imageDownloadSpan = jaegerClient.tracer.startSpan(operationName: "Image download span", referencing: nil, startTime: Date(), tags: [Tag(key: "downloadURL", tagType: .string(imageURLString))])

  getData(from: imageURL) { [weak self] (data, response, error) in

    //Finish this span once the image downloads
    imageDownloadSpan.finish()
    guard let strongSelf = self else {
      return
    }

    //Start a new span to update a UI component
    let imageRenderSpan = strongSelf.jaegerClient.tracer.startSpan(operationName: "Image render span", followsFrom: imageDownloadSpan.spanRef, tags: [Tag(key: "uiComponent", tagType: .string("myCustomView"))])

    strongSelf.updateView(with: data)

    //Finish image rendering span
    imageRenderSpan.finish()
  }
}
```

###### Observe your traces

If you have completed the steps above, you can now see your traces in your Jaeger collector. If you are using the all-in-one docker image specified in [step 1](#step-1---spin-up-a-jaeger-collector), you can just open [http://localhost:16686/](http://localhost:16686/) to see your traces.The name of the process reporting the spans will be `Jaeger iOS App`. This name can be configured in the mediator.

## Check out our Demo app

For a more comprehensive understanding of this project, you can check out our demo app [here](./Example). You can configure the demo app to send traces to our Jaeger mediator.

## Documentation

For a full understanding of this project, check out our [API reference](https://wayfair.github.io/jaeger-swift). We also welcome contributions!
