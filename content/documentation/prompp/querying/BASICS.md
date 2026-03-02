---
title: "Basics"
weight: 12
---

Deckhouse Prom++ provides a functional query language called PromQL (Prometheus Query Language) that lets the user select and aggregate time series data in real time. The expression result can be represented as a graph, viewed as spreadsheet data in the Deckhouse Prom++ expression browser, or used by external systems via the HTTP API.

## Examples

This page is a PromQL basic language reference. For learning, it may be easier to start with a couple of [examples](../examples/).

## Expression language data types

In Deckhouse Prom++ expression language, an expression or sub-expression can evaluate to one of four types:

- **Instant vector**: A set of time series containing a single sample for each time series, all sharing the same timestamp.
- **Range vector**: A set of time series containing a range of data points over time for each time series.
- **Scalar**: A simple numeric floating point value.
- **String**: A simple string value; currently unused.

Depending on the use case (for example, when building a graph or displaying the output of an expression), only some of these types are allowed as the result of an expression. For instant, an expression that evaluates to an instant vector is the only type that can be used on a graph.

## Literals

### String literals

String literals are designated by single quotes (`'`), double quotes (`"`) or backticks (`` ` ``).

PromQL follows the same escaping rules as Go. For string literals in single or double quotes, a backslash begins an escape sequence, which may be followed by `a`, `b`, `f`, `n`, `r`, `t`, `v`, or `\`. Specific characters can be provided using octal (`\nnn`) or hexadecimal (`\xnn`, `\unnnn`, and `\Unnnnnnnn`) notations.

Conversely, escape characters are not parsed in string literals designated by backticks. It is important to note that, unlike Go, Deckhouse Prom++ does not discard newlines inside backticks.

Examples:

```yml
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

### Number literals

Scalar float values can be written as literal integer or floating-point numbers in the following format (whitespace only included for better readability):

```yml
[-+]?(
      [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
    | 0[xX][0-9a-fA-F]+
    | [nN][aA][nN]
    | [iI][nN][fF]
)
```

Examples:

```yml
23
-2.43
3.4e-9
0x8f
-Inf
NaN
```

## Time series selectors

Time series selectors are responsible for selecting time series and their corresponding raw or computed values and time labels.

Time series selectors should not be confused with the higher-level concepts of instant and range queries that may execute these selectors. An instant query evaluates a given selector at a single point in time, whereas a range query evaluates the selector at multiple points in time between the start and end timestamps at regular intervals.

### Instant vector selectors

Instant vector selectors allow the selection of a set of time series and a single sample value for each at a given timestamp (point in time). In the simplest form, only a metric name is specified, which results in an instant vector containing elements for all time series that have this metric name.

This example selects all time series that have the `http_requests_total` metric name:

```yml
http_requests_total
```

It is possible to filter these time series further by appending a comma-separated list of label matchers in curly braces (`{}`).

This example selects only those time series with the `http_requests_total` metric name that also have the `job` label set to `Deckhouse Prom++` and their `group` label set to `canary`:

```yml
http_requests_total{job="Deckhouse Prom++",group="canary"}
```

It is also possible to negatively match a label value, or to match label values against regular expressions. The following label matching operators exist:

- `=`: Select labels that are exactly equal to the provided string.
- `!=`: Select labels that are not equal to the provided string.
- `=~`: Select labels that regex-match the provided string.
- `!~`: Select labels that do not regex-match the provided string.

Regex matches are fully anchored. A match of `env=~"foo"` is treated as `env=~"^foo$"`.

For example, this selects all `http_requests_total` time series for `staging`, `testing`, and `development` environments and HTTP methods other than `GET`.

```yml
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

### Range vector selectors

Range vector literals work like instant vector literals, except that they select a range of samples back from the current instant. Syntactically, a float literal is appended in square brackets (`[]`) at the end of a vector selector to specify for how many seconds back in time values should be fetched for each resulting range vector element. The range is a enclosed interval, meaning samples with timestamps coinciding with the range boundaries are still included in the selection.

In this example, we select all the values recorded over the last 5 minutes for all time series that have the metric name `http_requests_total` and a `job` label set to `Deckhouse Prom++`:

```yml
http_requests_total{job="Deckhouse Prom++"}[5m]
```

### Time durations

Time durations are specified as a number immediately followed by one of the following units:

- `ms`: Milliseconds
- `s`: Seconds
- `m`: Minutes
- `h`: Hours
- `d`: Days (a day is always assumed to be 24 hours)
- `w`: Weeks (a week is always assumed to be 7 days)
- `y`: Years (a year is always assumed to be 365 days)

{{< alert level="info" >}}
Leap days are ignored when calculating years, and leap seconds are ignored when calculating minutes.
{{< /alert >}}

Time durations can be combined by concatenation. Units must be ordered from the longest to the shortest. Each unit may appear only once within a single time duration.

Below are some examples of valid time durations:

```yml
5h
1h30m
5m
10s
```

## Query modifiers

### Offset modifier

The `offset` modifier allows changing the time offset for individual instant and range vectors in a query.

For example, the following expression returns the value of `http_requests_total` 5 minutes in the past relative to the current query evaluation time:

```yml
http_requests_total offset 5m
```

{{< alert level="warning" >}}

The `offset` modifier always needs to follow the selector immediately, meaning the following would be correct:

```yml
sum(http_requests_total{method="GET"} offset 5m) // VALID
```

The following would be incorrect:

```yml
sum(http_requests_total{method="GET"}) offset 5m // INVALID
```

{{< /alert >}}

The same works for range vectors. This returns the 5-minute `rate` that `http_requests_total` had a week ago:

```yml
rate(http_requests_total[5m] offset 1w)
```

When querying for samples in the past, a negative offset will enable temporal comparisons forward in time:

```yml
rate(http_requests_total[5m] offset -1w)
```

{{< alert level="info" >}}
This allows a query to look ahead of its evaluation time.
{{< /alert >}}

### @ modifier

The `@` modifier allows changing the evaluation time for individual instant and range vectors in a query. The time supplied to the `@` modifier is a Unix timestamp and described with a float literal.

For example, the following expression returns the value of `http_requests_total` at `2021-01-04T07:40:00+00:00`:

```yml
http_requests_total @ 1609746000
```

{{< alert level="warning" >}}

The `@` modifier always needs to follow the selector immediately, meaning the following would be correct:

```yml
sum(http_requests_total{method="GET"} @ 1609746000) // VALID
```

The following would be incorrect:

```yml
sum(http_requests_total{method="GET"}) @ 1609746000 // INVALID
```

{{< /alert >}}

The same works for range vectors. This returns the 5-minute `rate` that `http_requests_total` had at `2021-01-04T07:40:00+00:00`:

```yml
rate(http_requests_total[5m] @ 1609746000)
```

The `@` modifier supports all representations of numeric literals described above. It works with the `offset` modifier where the offset is applied relative to the `@` modifier time. The results are the same irrespective of the order of the modifiers.

For example, these two queries will produce the same result:

```yml
# offset after @
http_requests_total @ 1609746000 offset 5m
# offset before @
http_requests_total offset 5m @ 1609746000
```

Additionally, `start()` and `end()` can also be used as values for the `@` modifier as special values.

For a range query, they resolve to the start and end of the range query respectively and remain the same for all steps.

For an instant query, `start()` and `end()` both resolve to the evaluation time.

Examples:

```yml
http_requests_total @ start()
rate(http_requests_total[5m] @ end())
```

{{< alert level="info" >}}
The `@` modifier allows a query to look ahead of its evaluation time.
{{< /alert >}}

## Subqueries

A subquery allows you to run an instant query for a given range and resolution. The result of a subquery is a range vector.

Syntax:

```yml
<instant_query> '[' <range> ':' [<resolution>] ']' [ @ <float_literal> ] [ offset <duration> ]
```

where:

- <resolution> is optional. Default is the global evaluation interval.

## Operators

Deckhouse Prom++ supports many binary and aggregation operators. These are described in detail in [PromQL operators](../operators_promql/).

## Functions

Deckhouse Prom++ supports several functions to operate on data. These are described in detail in the expression language functions page.

## Comments

PromQL supports inline comments that start with `#`. Example:

```yml
# This is a comment.
   metric{label="value"} # This is another comment.
```

## Gotchas

### Staleness

The timestamps at which to sample data, during a query, are selected independently of the actual present time series data. This is mainly to support cases like aggregation (`sum`, `avg`, and so on), where multiple aggregated time series do not precisely align in time. Because of their independence, Deckhouse Prom++ needs to assign a value at those timestamps for each relevant time series. It does so by taking the newest sample that is less than the lookback period ago. The lookback period is 5 minutes by default.

If a target scrape or rule evaluation no longer returns a sample for a time series that was previously present, this time series will be marked as stale. If a target is removed, the previously retrieved time series will be marked as stale soon after removal.

If a query is evaluated at a sampling timestamp after a time series is marked as stale, then no value is returned for that time series. If new samples are subsequently ingested for that time series, they will be returned as expected.

A time series will go stale when it is no longer exported, or the target no longer exists. Such time series will disappear from graphs at the times of their latest collected sample, and they will not be returned in queries after they are marked stale.

Some exporters, which put their own timestamps on samples, get a different behaviour: series that stop being exported take the last value for 5 minutes (by default) before disappearing. The `track_timestamps_staleness` setting can change this.

### Avoiding slow queries and overloads

If a query needs to operate on a substantial amount of data, graphing it might time out or overload the server or browser. Thus, when constructing queries over unknown data, always start building the query in the tabular view of Deckhouse Prom++ expression browser until the result set seems reasonable (hundreds, not thousands, of time series at most). Only when you have filtered or aggregated your data sufficiently, switch to graph mode. If the expression still takes too long to graph ad-hoc, pre-record it via a [recording rule](../../configuration/recording_rules/).

This is especially relevant for Deckhouse Prom++ query language, where a bare metric name selector like `api_http_requests_total` could expand to thousands of time series with different labels. Also, keep in mind that expressions that aggregate over many time series will generate load on the server even if the output is only a small number of time series. This is similar to how it would be slow to sum all values of a column in a relational database, even if the output value is only a single number.
