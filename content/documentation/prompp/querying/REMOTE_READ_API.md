---
title: "Remote read API"
weight: 16

---

Deckhouse Prom++ provides an API for remote read, accessible via the endpoint `/api/v1/read`. This interface expects compression using the Snappy algorithm. For more information about the API, visit the [Prom++ repository](https://github.com/deckhouse/prompp/blob/main/prompb/remote.proto).

> **Note:** This API is currently not considered stable and may change even between minor versions of Deckhouse Prom++.

## Samples

This endpoint returns a message containing a list of raw samples matching the requested query.

## Streamed Chunks

Streamed chunks use an XOR algorithm inspired by Gorilla compression to encode chunks. However, it provides millisecond resolution instead of second resolution.
