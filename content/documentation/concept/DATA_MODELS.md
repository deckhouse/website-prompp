---
title: "Data model"
weight: 4
---

Deckhouse Prom++ stores all data as time series: streams of timestamped values belonging to a single metric and a single set of labels. In addition to stored time series, Deckhouse Prom++ can generate derived time series as a result of query execution.

## Metric names and labels

Each time series is uniquely identified by its metric name and optional key-value pairs called labels.

### Metric names

- **Description**: Specifies the general characteristics of the system being measured (for example, `http_requests_total` — the total number of HTTP requests received).
- **Naming rules**:
  - Metric names can contain ASCII letters, numbers, underscores, and colons.
  - Must match the following regular expression: `[a-zA-Z_:][a-zA-Z0-9_:]*`.
  
  > **Warning.** Colons are reserved for user-defined rules. They should not be used in exporters or direct instrumentation.

### Labels

- **Description**: Allow the Deckhouse Prom++ data model to identify any combination of labels for a single metric. They define the specific dimensional implementation of that metric (for example, all HTTP requests that used the `POST` method for the `/api/tracks` handler). The query language allows you to filter and aggregate data based on these dimensions.
- **Naming rules**:
  - Labels can contain ASCII letters, numbers, and underscores. They must match the following regular expression: `[a-zA-Z_][a-zA-Z0-9_]*`.
  - Label names beginning with `__` (two underscores) are reserved for internal use.
  - Label values can contain any Unicode characters.
  - Labels with an empty value are considered equivalent to no label.
- **Changing labels**: Any change to a label value, including adding or removing labels, creates a new time series.

## Samples

Samples form the actual data of time series. Each sample includes:

- **Values**: Floating point number (`float64`).
- **Timestamps**: Accuracy up to milliseconds.

{{< alert level="info" >}}
Starting with Deckhouse Prom++ v2.40, experimental support for native histograms has been added. Instead of a simple `float64` value, a sample can now represent a complete histogram.
{{< /alert >}}

## Metric representation format

The following format is used to identify time series:

```text
<metric name>{<label name>=<label value>, ...}
```

For example, a time series with the metric name `api_http_requests_total` and labels `method=“POST”` and `handler=“/messages”` can be written as follows:

```text
api_http_requests_total{method=“POST”, handler="/messages"}
```
