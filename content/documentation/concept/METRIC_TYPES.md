---
title: "Metric types"
weight: 6
---

## Counter

A counter is a cumulative metric that represents a single monotonically increasing counter whose value can only increase or be reset to zero upon restart.
For example, you can use a counter to represent the number of requests served, tasks completed, or errors.

Do not use a counter to represent a value that can decrease.
For example, do not use a counter for the number of currently running processes; use an indicator instead.

## Gauge

A gauge is a metric that represents a single numerical value that can increase or decrease arbitrarily.
Gauges are typically used to measure quantities such as temperature or current memory usage, as well as for “counts” that can increase and decrease, such as the number of concurrent requests.

## Histogram

A histogram records individual measurements (such as request durations or response sizes) and distributes them across customizable ranges called buckets.
It also stores the sum of all recorded values.

A histogram with the base name of the metric `<basename>` exposes several time series when collecting data:

- Cumulative counters for each bucket in the format `<basename>_bucket{le="<upper limit inclusive>"}`
- The sum of all recorded measurements — `<basename>_sum`
- The total number of recorded events — `<basename>_count` (equivalent to the value `<basename>_bucket{le="+Inf"}`, which includes all measurements)

To calculate percentiles based on histograms, you can use the `histogram_quantile()` function.

Histograms are also suitable for calculating the [Apdex index](https://en.wikipedia.org/wiki/Apdex).
When working with buckets, remember that histogram values are [cumulative](https://en.wikipedia.org/wiki/Histogram#Cumulative_histogram).

## Summary

Similar to histogram, summary records individual measurements (e.g., request durations or response sizes).

It stores the total number of events, the sum of all recorded values, and calculates customizable percentile values within a rolling time window.

A summary with the base metric name `<basename>` exposes several time series when collecting data:

- Percentile values φ, calculated on the fly, in the format `<basename>{quantile="<φ>"}`
- The sum of all fixed measurements — `<basename>_sum`
- The total number of recorded events — `<basename>_count`
