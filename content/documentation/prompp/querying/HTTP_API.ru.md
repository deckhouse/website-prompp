---
title: "HTTP API"
weight: 17

---

Текущий стабильный HTTP API доступен по адресу /api/v1 на сервере Deckhouse Prom++. Любые обратно совместимые дополнения будут добавляться к этой конечной точке.

## Обзор формата

Формат ответа API — JSON. Каждый успешный запрос к API возвращает код состояния 2xx.

Некорректные запросы, которые достигают обработчиков API, возвращают объект ошибки JSON и один из следующих кодов ответа HTTP:

- 400 Bad Request — когда параметры отсутствуют или некорректны.
- 422 Unprocessable Entity — когда выражение не может быть выполнено (RFC4918).
- 503 Service Unavailable — когда запросы превышают время ожидания или прерываются.
Другие коды, не начинающиеся с 2xx, могут возвращаться для ошибок, возникающих до достижения конечной точки API.

Массив предупреждений может быть возвращен, если есть ошибки, которые не препятствуют выполнению запроса. Все успешно собранные данные будут возвращены в поле `data`.

Формат оболочки JSON-ответа выглядит следующим образом:

```yml
{
  "status": "success" | "error",
  "data": <data>,
  // Устанавливается только если status = "error". Поле data может всё ещё содержать дополнительные данные.
  "errorType": "<string>",
  "error": "<string>",
  // Только если при выполнении запроса возникли предупреждения. Данные всё равно будут в поле data.
  "warnings": ["<string>"]
}
```

## Общие параметры определены следующим образом:

- `<rfc3339 | unix_timestamp>`: Входные метки времени могут быть указаны либо в формате RFC3339, либо как Unix-метка времени в секундах, с необязательными десятичными знаками для точности до долей секунды. Выходные метки времени всегда представлены как Unix-метки времени в секундах.
- `<series_selector>`: Селекторы временных рядов Deckhouse Prom++, например, http_requests_total или http_requests_total{method=~"(GET|POST)"}, которые необходимо кодировать в URL.
- `<duration>`: Строки длительности Deckhouse Prom++. Например, 5m означает длительность в 5 минут.
- `<bool>`: Логические значения (строки true и false).

Примечание: Имена параметров запроса, которые могут повторяться, заканчиваются на [].

## Запросы выражений

Выражения языка запросов могут быть вычислены для одного момента времени или за диапазон времени. В следующих разделах описаны конечные точки API для каждого типа запросов выражений.

## Instant запросы

Следующая конечная точка вычисляет мгновенный запрос в определенный момент времени:

```yml
GET /api/v1/query
POST /api/v1/query
```

Параметры URL-запроса:

```yml
query=<string>: Строка выражения Deckhouse Prom++.
time=<rfc3339 | unix_timestamp>: Метка времени для вычисления. Необязательный.
timeout=<duration>: Таймаут вычисления. Необязательный. По умолчанию и ограничивается значением флага -query.timeout.
```

Текущее время сервера используется, если параметр time не указан.

Вы можете закодировать эти параметры в теле запроса, используя метод POST и заголовок Content-Type: application/x-www-form-urlencoded. Это полезно при указании большого запроса, который может превысить лимиты символов URL на стороне сервера.

Раздел data результата запроса имеет следующий формат:

```yml
{
  "resultType": "matrix" | "vector" | "scalar" | "string",
  "result": <value>
}
```

<value> относится к данным результата запроса, которые имеют различный формат в зависимости от resultType. См. форматы результатов выражений.

Следующий пример вычисляет выражение up на момент времени 2015-07-01T20:10:51.781Z:

```bash
curl 'http://localhost:9090/api/v1/query?query=up&time=2015-07-01T20:10:51.781Z'
```

Пример ответа:

```yml
{
   "status": "success",
   "data": {
      "resultType": "vector",
      "result": [
         {
            "metric": {
               "__name__": "up",
               "job": "Deckhouse Prom++",
               "instance": "localhost:9090"
            },
            "value": [ 1435781451.781, "1" ]
         },
         {
            "metric": {
               "__name__": "up",
               "job": "node",
               "instance": "localhost:9100"
            },
            "value": [ 1435781451.781, "0" ]
         }
      ]
   }
}
```

## Запросы по диапазону

Следующая конечная точка вычисляет выражение за диапазон времени:

```yml
GET /api/v1/query_range
POST /api/v1/query_range
```

Параметры URL-запроса:

- query=<string>: Строка выражения Deckhouse Prom++.
- start=<rfc3339 | unix_timestamp>: Начальная метка времени (включительно).
- end=<rfc3339 | unix_timestamp>: Конечная метка времени (включительно).
- step=<duration | float>: Шаг разрешения запроса в формате длительности или числе секунд с плавающей точкой.
- timeout=<duration>: Таймаут вычисления. Необязательный. По умолчанию и ограничивается значением флага -query.timeout.

Вы можете закодировать эти параметры в теле запроса, используя метод POST и заголовок Content-Type: application/x-www-form-urlencoded. Это полезно при указании большого запроса.

Раздел data результата запроса имеет следующий формат:

```yml
{
  "resultType": "matrix",
  "result": <value>
}
```

Формат заполнителя <value> см. в разделе о формате результата для диапазонных векторов.

Следующий пример вычисляет выражение up за 30-секундный диапазон с шагом 15 секунд:

```bash
curl 'http://localhost:9090/api/v1/query_range?query=up&start=2015-07-01T20:10:30.781Z&end=2015-07-01T20:11:00.781Z&step=15s'
```

Пример ответа:

```yml
{
   "status": "success",
   "data": {
      "resultType": "matrix",
      "result": [
         {
            "metric": {
               "__name__": "up",
               "job": "Deckhouse Prom++",
               "instance": "localhost:9090"
            },
            "values": [
               [ 1435781430.781, "1" ],
               [ 1435781445.781, "1" ],
               [ 1435781460.781, "1" ]
            ]
         },
         {
            "metric": {
               "__name__": "up",
               "job": "node",
               "instance": "localhost:9091"
            },
            "values": [
               [ 1435781430.781, "0" ],
               [ 1435781445.781, "0" ],
               [ 1435781460.781, "1" ]
            ]
         }
      ]
   }
}
```

## Форматирование выражений запросов

Следующая конечная точка форматирует выражение PromQL в удобочитаемом виде:

```yml
GET /api/v1/format_query
POST /api/v1/format_query
```

Параметры URL-запроса:

- query=<string>: Строка выражения Deckhouse Prom++.

Вы можете закодировать эти параметры в теле запроса, используя метод POST и заголовок Content-Type: application/x-www-form-urlencoded.
Раздел data результата запроса — это строка с отформатированным выражением. Примечание: все комментарии удаляются в отформатированной строке.

Следующий пример форматирует выражение foo/bar:

```bash
curl 'http://localhost:9090/api/v1/format_query?query=foo/bar'
```

Пример ответа:

```yml
{
   "status": "success",
   "data": "foo / bar"
}
```

## Запросы метаданных

Deckhouse Prom++ предоставляет набор API-конечных точек для запроса метаданных о рядах и их метках.

ПРИМЕЧАНИЕ: Эти конечные точки могут возвращать метаданные для рядов, для которых нет выборок в выбранном диапазоне времени, и/или для рядов, выборки которых были помечены как удаленные через API удаления. Точный объем дополнительно возвращаемых метаданных рядов является деталью реализации и может измениться в будущем.

## Поиск рядов по селекторам лейблов

Следующая конечная точка возвращает список временных рядов, соответствующих определенному набору лейблов:

```yml
GET /api/v1/series
POST /api/v1/series
```

Параметры URL-запроса:

- match[]=<series_selector>: Повторяющийся аргумент селектора рядов, который выбирает ряды для возврата. Должен быть предоставлен хотя бы один аргумент match[].
- start=<rfc3339 | unix_timestamp>: Начальная метка времени.
- end=<rfc3339 | unix_timestamp>: Конечная метка времени.
- limit=<number>: Максимальное количество возвращаемых рядов. Необязательный.

Раздел data результата запроса состоит из списка объектов, содержащих пары имя/значение метки, которые идентифицируют каждый ряд.

Следующий пример возвращает все ряды, соответствующие селекторам up или process_start_time_seconds{job="Deckhouse Prom++"}:

```bash
curl -g 'http://localhost:9090/api/v1/series?' --data-urlencode 'match[]=up' --data-urlencode 'match[]=process_start_time_seconds{job="Deckhouse Prom++"}'
```

Пример ответа:

```yml
{
   "status": "success",
   "data": [
      {
         "__name__": "up",
         "job": "Deckhouse Prom++",
         "instance": "localhost:9090"
      },
      {
         "__name__": "up",
         "job": "node",
         "instance": "localhost:9091"
      },
      {
         "__name__": "process_start_time_seconds",
         "job": "Deckhouse Prom++",
         "instance": "localhost:9090"
      }
   ]
}
```

## Получение имен лейблов

Следующая конечная точка возвращает список имен лейблов:

```yml
GET /api/v1/labels
POST /api/v1/labels
```

Параметры URL-запроса:

- start=<rfc3339 | unix_timestamp>: Начальная метка времени. Необязательный.
- end=<rfc3339 | unix_timestamp>: Конечная метка времени. Необязательный.
- match[]=<series_selector>: Повторяющийся аргумент селектора рядов, который выбирает ряды, из которых читаются имена лейблов. Необязательный.
- limit=<number>: Максимальное количество возвращаемых рядов. Необязательный.

Раздел data JSON-ответа — это список строковых имен лейблов.

Пример:

```yml
{
    "status": "success",
    "data": [
        "__name__",
        "call",
        "code",
        "config",
        "dialer_name",
        "endpoint",
        "event",
        "goversion",
        "handler",
        "instance",
        "interval",
        "job",
        "le",
        "listener_name",
        "name",
        "quantile",
        "reason",
        "role",
        "scrape_job",
        "slice",
        "version"
    ]
}
```

## Запрос значений лейблов

Следующая конечная точка возвращает список значений лейблов для указанного имени метки:

```yml
GET /api/v1/label/<label_name>/values
```

Параметры URL-запроса:

- start=<rfc3339 | unix_timestamp>: Начальная метка времени. Необязательный.
- end=<rfc3339 | unix_timestamp>: Конечная метка времени. Необязательный.
- match[]=<series_selector>: Повторяющийся аргумент селектора рядов, который выбирает ряды, из которых читаются значения лейблов. Необязательный.
- limit=<number>: Максимальное количество возвращаемых рядов. Необязательный.

Раздел data JSON-ответа — это список строковых значений лейблов.

Этот пример запрашивает все значения метки job:

```bash
curl http://localhost:9090/api/v1/label/job/values
```

```yml
{
   "status": "success",
   "data": [
      "node",
      "Deckhouse Prom++"
   ]
}
```

## Запрос примеров (экземпляров)

Это экспериментальная функция, и она может измениться в будущем. Следующая конечная точка возвращает список примеров для допустимого запроса PromQL за определенный диапазон времени:

```yml
GET /api/v1/query_exemplars
POST /api/v1/query_exemplars
```

Параметры URL-запроса:

- query=<string>: Строка выражения Deckhouse Prom++.
- start=<rfc3339 | unix_timestamp>: Начальная метка времени.
- end=<rfc3339 | unix_timestamp>: Конечная метка времени.

```bash
curl -g 'http://localhost:9090/api/v1/query_exemplars?query=test_exemplar_metric_total&start=2020-09-14T15:22:25.479Z&end=2020-09-14T15:23:25.479Z'
```

Пример ответа:

```yml
{
    "status": "success",
    "data": [
        {
            "seriesLabels": {
                "__name__": "test_exemplar_metric_total",
                "instance": "localhost:8090",
                "job": "Deckhouse Prom++",
                "service": "bar"
            },
            "exemplars": [
                {
                    "labels": {
                        "trace_id": "EpTxMJ40fUus7aGY"
                    },
                    "value": "6",
                    "timestamp": 1600096945.479
                }
            ]
        },
        {
            "seriesLabels": {
                "__name__": "test_exemplar_metric_total",
                "instance": "localhost:8090",
                "job": "Deckhouse Prom++",
                "service": "foo"
            },
            "exemplars": [
                {
                    "labels": {
                        "trace_id": "Olp9XHlq763ccsfa"
                    },
                    "value": "19",
                    "timestamp": 1600096955.479
                },
                {
                    "labels": {
                        "trace_id": "hCtjygkIHwAN9vs4"
                    },
                    "value": "20",
                    "timestamp": 1600096965.489
                }
            ]
        }
    ]
}
```

## Форматы результатов выражений

Запросы выражений могут возвращать следующие значения ответа в свойстве result раздела data. Заполнители <sample_value> представляют числовые значения выборок. JSON не поддерживает специальные значения с плавающей точкой, такие как NaN, Inf и -Inf, поэтому значения выборок передаются как строки JSON в кавычках, а не как сырые числа.

Ключи "histogram" и "histograms" появляются только в ответе, если присутствуют экспериментальные нативные гистограммы. Заполнитель <histogram> подробно объяснен в соответствующем разделе ниже.

## Диапазонные векторы

Диапазонные векторы возвращаются как результат типа matrix. Соответствующее свойство result имеет следующий формат:

```yml
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "values": [ [ <unix_time>, "<sample_value>" ], ... ],
    "histograms": [ [ <unix_time>, <histogram> ], ... ]
  },
  ...
]
```

Каждый ряд может иметь ключ "values", или ключ "histograms", или оба. Для заданной метки времени будет только одна выборка типа float или гистограммы.

Ряды возвращаются отсортированными по метрике. Функции, такие как sort и sort_by_label, не влияют на диапазонные векторы.

## Мгновенные векторы

Мгновенные векторы возвращаются как результат типа vector. Соответствующее свойство result имеет следующий формат:

```yml
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "value": [ <unix_time>, "<sample_value>" ],
    "histogram": [ <unix_time>, <histogram> ]
  },
  ...
]
```

Каждый ряд может иметь ключ "value" или ключ "histogram", но не оба.

Ряды не гарантированно возвращаются в каком-либо определенном порядке, если не используется функция, такая как sort или sort_by_label.

## Скаляры

Скалярные результаты возвращаются как результат типа scalar. Соответствующее свойство result имеет следующий формат:

```yml
[ <unix_time>, "<scalar_value>" ]
```

## Нативные гистограммы

Заполнитель <histogram>, использованный выше, форматируется следующим образом.

Примечание: нативные гистограммы — это экспериментальная функция, и формат ниже может измениться.

```yml
{
  "count": "<count_of_observations>",
  "sum": "<sum_of_observations>",
  "buckets": [ [ <boundary_rule>, "<left_boundary>", "<right_boundary>", "<count_in_bucket>" ], ... ]
}
```

Заполнитель <boundary_rule> — это целое число от 0 до 3 со следующим значением:

- 0: «открыто слева» (левая граница исключается, правая включается)
- 1: «открыто справа» (левая граница включается, правая исключается)
- 2: «открыто с обеих сторон» (обе границы исключаются)
- 3: «закрыто с обеих сторон» (обе границы включаются)

Примечание: В текущих реализованных схемах корзин положительные корзины «открыты слева», отрицательные — «открыты справа», а нулевая корзина (с отрицательной левой и положительной правой границами) — «закрыта с обеих сторон».

## Цели

Следующая конечная точка возвращает обзор текущего состояния обнаружения целей Deckhouse Prom++:

```yml
GET /api/v1/targets
```

Как активные, так и отброшенные цели включены в ответ по умолчанию. Отброшенные цели подчиняются лимиту keep_dropped_targets, если он установлен. Поле labels представляет набор лейблов после применения перемаркировки. Поле discoveredLabels представляет немодифицированные метки, полученные во время обнаружения сервисов до перемаркировки.

```bash
curl http://localhost:9090/api/v1/targets
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9090",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "job": "Deckhouse Prom++"
        },
        "labels": {
          "instance": "127.0.0.1:9090",
          "job": "Deckhouse Prom++"
        },
        "scrapePool": "Deckhouse Prom++",
        "scrapeUrl": "http://127.0.0.1:9090/metrics",
        "globalUrl": "http://example-Deckhouse Prom++:9090/metrics",
        "lastError": "",
        "lastScrape": "2017-01-17T15:07:44.723715405+01:00",
        "lastScrapeDuration": 0.050688943,
        "health": "up",
        "scrapeInterval": "1m",
        "scrapeTimeout": "10s"
      }
    ],
    "droppedTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9100",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "__scrape_interval__": "1m",
          "__scrape_timeout__": "10s",
          "job": "node"
        }
      }
    ]
  }
}
```

Параметр state позволяет фильтровать цели по состоянию (например, state=active, state=dropped, state=any). Пустой массив возвращается для отфильтрованных целей.

```bash
curl 'http://localhost:9090/api/v1/targets?state=active'
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9090",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "job": "Deckhouse Prom++"
        },
        "labels": {
          "instance": "127.0.0.1:9090",
          "job": "Deckhouse Prom++"
        },
        "scrapePool": "Deckhouse Prom++",
        "scrapeUrl": "http://127.0.0.1:9090/metrics",
        "globalUrl": "http://example-Deckhouse Prom++:9090/metrics",
        "lastError": "",
        "lastScrape": "2017-01-17T15:07:44.723715405+01:00",
        "lastScrapeDuration": 50688943,
        "health": "up"
      }
    ],
    "droppedTargets": []
  }
}
```

Параметр scrapePool позволяет фильтровать цели по имени пула.

```bash
curl 'http://localhost:9090/api/v1/targets?scrapePool=node_exporter'
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "activeTargets": [
      {
        "discoveredLabels": {
          "__address__": "127.0.0.1:9091",
          "__metrics_path__": "/metrics",
          "__scheme__": "http",
          "job": "node_exporter"
        },
        "labels": {
          "instance": "127.0.0.1:9091",
          "job": "node_exporter"
        },
        "scrapePool": "node_exporter",
        "scrapeUrl": "http://127.0.0.1:9091/metrics",
        "globalUrl": "http://example-Deckhouse Prom++:9091/metrics",
        "lastError": "",
        "lastScrape": "2017-01-17T15:07:44.723715405+01:00",
        "lastScrapeDuration": 50688943,
        "health": "up"
      }
    ],
    "droppedTargets": []
  }
}
```

## Правила

Конечная точка /rules возвращает список загруженных правил оповещения и записи. Кроме того, она возвращает текущие активные оповещения, сгенерированные каждым правилом оповещения.

Поскольку конечная точка /rules довольно новая, она не имеет таких же гарантий стабильности, как общий API v1.

```yml
GET /api/v1/rules
```

Параметры URL-запроса:

- type=alert|record: Возвращает только правила оповещения (например, type=alert) или правила записи (например, type=record). Если параметр отсутствует или пуст, фильтрация не применяется.
- rule_name[]=<string>: Возвращает только правила с указанным именем. Если параметр повторяется, возвращаются правила с любым из указанных имен. Если все правила группы отфильтрованы, группа не возвращается. Если параметр отсутствует или пуст, фильтрация не применяется.
- rule_group[]=<string>: Возвращает только правила с указанным именем группы. Если параметр повторяется, возвращаются правила с любым из указанных имен групп. Если параметр отсутствует или пуст, фильтрация не применяется.
- file[]=<string>: Возвращает только правила с указанным путем к файлу. Если параметр повторяется, возвращаются правила с любым из указанных путей. Если параметр отсутствует или пуст, фильтрация не применяется.
- exclude_alerts=<bool>: Возвращает только правила, без активных оповещений.

```bash
curl http://localhost:9090/api/v1/rules
```

Пример ответа:

```yml
{
    "data": {
        "groups": [
            {
                "rules": [
                    {
                        "alerts": [
                            {
                                "activeAt": "2018-07-04T20:27:12.60602144+02:00",
                                "annotations": {
                                    "summary": "High request latency"
                                },
                                "labels": {
                                    "alertname": "HighRequestLatency",
                                    "severity": "page"
                                },
                                "state": "firing",
                                "value": "1e+00"
                            }
                        ],
                        "annotations": {
                            "summary": "High request latency"
                        },
                        "duration": 600,
                        "health": "ok",
                        "labels": {
                            "severity": "page"
                        },
                        "name": "HighRequestLatency",
                        "query": "job:request_latency_seconds:mean5m{job=\"myjob\"} > 0.5",
                        "type": "alerting"
                    },
                    {
                        "health": "ok",
                        "name": "job:http_inprogress_requests:sum",
                        "query": "sum by (job) (http_inprogress_requests)",
                        "type": "recording"
                    }
                ],
                "file": "/rules.yaml",
                "interval": 60,
                "limit": 0,
                "name": "example"
            }
        ]
    },
    "status": "success"
}
```

## Оповещения

Конечная точка /alerts возвращает список всех активных оповещений.

Поскольку конечная точка /alerts довольно новая, она не имеет таких же гарантий стабильности, как общий API v1.

```yml
GET /api/v1/alerts
```

```bash
curl http://localhost:9090/api/v1/alerts
```

Пример ответа:

```yml
{
    "data": {
        "alerts": [
            {
                "activeAt": "2018-07-04T20:27:12.60602144+02:00",
                "annotations": {},
                "labels": {
                    "alertname": "my-alert"
                },
                "state": "firing",
                "value": "1e+00"
            }
        ]
    },
    "status": "success"
}
```

## Запрос метаданных целей

Следующая конечная точка возвращает метаданные о метриках, собираемых с целей. Это экспериментальная функция, и она может измениться в будущем.

```yml
GET /api/v1/targets/metadata
```

Параметры URL-запроса:

- match_target=<label_selectors>: Селекторы лейблов, которые сопоставляют цели по их наборам лейблов. Если не указано, выбираются все цели.
- metric=<string>: Имя метрики, для которой запрашиваются метаданные. Если не указано, возвращаются метаданные для всех метрик.
- limit=<number>: Максимальное количество целей для сопоставления.

Раздел data результата запроса состоит из списка объектов, содержащих метаданные метрик и набор лейблов цели.

Следующий пример возвращает все записи метаданных для метрики go_goroutines из первых двух целей с меткой job="Deckhouse Prom++".

```bash
curl -G http://localhost:9091/api/v1/targets/metadata \
    --data-urlencode 'metric=go_goroutines' \
    --data-urlencode 'match_target={job="Deckhouse Prom++"}' \
    --data-urlencode 'limit=2'
```

Пример ответа:

```yml
{
  "status": "success",
  "data": [
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "Deckhouse Prom++"
      },
      "type": "gauge",
      "help": "Number of goroutines that currently exist.",
      "unit": ""
    },
    {
      "target": {
        "instance": "127.0.0.1:9091",
        "job": "Deckhouse Prom++"
      },
      "type": "gauge",
      "help": "Number of goroutines that currently exist.",
      "unit": ""
    }
  ]
}
```

Следующий пример возвращает метаданные для всех метрик всех целей с меткой instance="127.0.0.1:9090".

```bash
curl -G http://localhost:9091/api/v1/targets/metadata \
    --data-urlencode 'match_target={instance="127.0.0.1:9090"}'
```

```yml
{
  "status": "success",
  "data": [
    // ...
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "Deckhouse Prom++"
      },
      "metric": "Deckhouse Prom++_treecache_zookeeper_failures_total",
      "type": "counter",
      "help": "The total number of ZooKeeper failures.",
      "unit": ""
    },
    {
      "target": {
        "instance": "127.0.0.1:9090",
        "job": "Deckhouse Prom++"
      },
      "metric": "Deckhouse Prom++_tsdb_reloads_total",
      "type": "counter",
      "help": "Number of times the database reloaded block data from disk.",
      "unit": ""
    },
    // ...
  ]
}
```

## Запрос метаданных метрик

Она возвращает метаданные о метриках, собираемых с целей. Однако она не предоставляет информации о целях. Это экспериментальная функция, и она может измениться в будущем.

```yml
GET /api/v1/metadata
```

Параметры URL-запроса:

- limit=<number>: Максимальное количество возвращаемых метрик.
- limit_per_metric=<number>: Максимальное количество возвращаемых метаданных для каждой метрики.
- metric=<string>: Имя метрики для фильтрации метаданных. Если не указано, возвращаются метаданные для всех метрик.

Раздел data результата запроса состоит из объекта, где каждый ключ — это имя метрики, а каждое значение — это список уникальных объектов метаданных, предоставленных для этого имени метрики всеми целями.

Следующий пример возвращает две метрики. Обратите внимание, что метрика http_requests_total имеет более одного объекта в списке. По крайней мере, у одной цели есть значение HELP, которое не совпадает с остальными.

```bash
curl -G http://localhost:9090/api/v1/metadata?limit=2
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "cortex_ring_tokens": [
      {
        "type": "gauge",
        "help": "Number of tokens in the ring",
        "unit": ""
      }
    ],
    "http_requests_total": [
      {
        "type": "counter",
        "help": "Number of HTTP requests",
        "unit": ""
      },
      {
        "type": "counter",
        "help": "Amount of HTTP requests",
        "unit": ""
      }
    ]
  }
}
```

Следующий пример возвращает только одну запись метаданных для каждой метрики.

```bash
curl -G http://localhost:9090/api/v1/metadata?limit_per_metric=1
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "cortex_ring_tokens": [
      {
        "type": "gauge",
        "help": "Number of tokens in the ring",
        "unit": ""
      }
    ],
    "http_requests_total": [
      {
        "type": "counter",
        "help": "Number of HTTP requests",
        "unit": ""
      }
    ]
  }
}
```

Следующий пример возвращает метаданные только для метрики http_requests_total

```bash
curl -G http://localhost:9090/api/v1/metadata?metric=http_requests_total
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "http_requests_total": [
      {
        "type": "counter",
        "help": "Number of HTTP requests",
        "unit": ""
      },
      {
        "type": "counter",
        "help": "Amount of HTTP requests",
        "unit": ""
      }
    ]
  }
}
```

## Alertmanagers

Следующая конечная точка возвращает обзор текущего состояния обнаружения Alertmanager в Deckhouse Prom++:

```yml
GET /api/v1/alertmanagers
```

Как активные, так и отброшенные Alertmanager'ы включены в ответ.

```bash
curl http://localhost:9090/api/v1/alertmanagers
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "activeAlertmanagers": [
      {
        "url": "http://127.0.0.1:9090/api/v1/alerts"
      }
    ],
    "droppedAlertmanagers": [
      {
        "url": "http://127.0.0.1:9093/api/v1/alerts"
      }
    ]
  }
}
```

## Состояние

Следующие конечные точки состояния предоставляют текущую конфигурацию Deckhouse Prom++.

## Конфигурация

Следующая конечная точка возвращает текущий загруженный конфигурационный файл:

```yml
GET /api/v1/status/config
```

Конфигурация возвращается как дамп YAML-файла. Из-за ограничений библиотеки YAML комментарии не включаются.

```bash
curl http://localhost:9090/api/v1/status/config
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "yaml": "<содержимое загруженного конфигурационного файла в YAML>"
  }
}
```

## Флаги

Следующая конечная точка возвращает значения флагов, с которыми был настроен Deckhouse Prom++:

```yml
GET /api/v1/status/flags
```

Все значения имеют тип результата string.

```bash
curl http://localhost:9090/api/v1/status/flags
```

Пример ответа:

```yml
{
  "status": "success",
  "data": {
    "alertmanager.notification-queue-capacity": "10000",
    "alertmanager.timeout": "10s",
    "log.level": "info",
    "query.lookback-delta": "5m",
    "query.max-concurrency": "20",
    ...
  }
}
```

## Приемник OTLP

Deckhouse Prom++ можно настроить как приемник для протокола OTLP Metrics. Это не считается эффективным способом приема выборок. Используйте его с осторожностью для конкретных случаев с низким объемом данных. Он не подходит для замены приема через сканирование.

Включите приемник OTLP с помощью флага --enable-feature=otlp-write-receiver. Когда он включен, конечная точка приемника OTLP — /api/v1/otlp/v1/metrics.
