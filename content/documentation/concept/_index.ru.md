---
title: "Концепты"
weight: 3
---


{{< tabs name="Eviction_example" >}}
{{< tab name="policy/v1" >}}
`policy/v1` Eviction is available in v1.22+. Use `policy/v1beta1` with prior releases.

```json
{
  "apiVersion": "policy/v1",
  "kind": "Eviction",
  "metadata": {
    "name": "quux",
    "namespace": "default"
  }
}
```

{{< /tab >}}
{{< tab name="policy/v1beta1" >}}
{{< alert >}}
Deprecated in v1.22 in favor of `policy/v1`
{{< /alert >}}

test md
<b>test bold</b>

```json
{
  "apiVersion": "policy/v1beta1",
  "kind": "Eviction",
  "metadata": {
    "name": "quux",
    "namespace": "default"
  }
}
```

{{< /tab >}}
{{< /tabs >}}

В данном разделе будет рассмотрено:

- [Модель данных](/documentation/concept/data_models/),
- [Служебные лейблы и метрики](./jobs_instanses/),
- [Типы метрик](./metric_types/).

{{< mermaid >}}
graph TD;
  A-->B;
  A-->C;
  B-->D;
  C-->D;
{{</ mermaid >}}
