---
title: "Командная строка"
weight: 39

---

Ниже перечислены доступные флаги командной строки Deckhouse Prom++ и их описания.

| Флаг | Описание | Значение по умолчанию                                           |
|------|----------|-----------------------------------------------------------------|
| `-h`, `--help` | Показать контекстно-зависимую справку (также доступны `--help-long` и `--help-man`) |                                                                 |
| `--version` | Показать версию приложения |                                                                 |
| `--config.file` | Путь к файлу конфигурации Deckhouse Prom++ | `prometheus.yml`                                                |
| `--web.listen-address` | Адрес для прослушивания UI, API и телеметрии | `0.0.0.0:9090`                                                  |
| `--auto-gomemlimit.ratio` | Соотношение зарезервированной памяти GOMEMLIMIT к максимальной памяти системы | `0.9`                                                           |
| `--web.config.file` | (**Экспериментальный**) Путь к файлу конфигурации TLS или аутентификации |                                                                 |
| `--web.read-timeout` | Максимальное время ожидания чтения запроса | `5m`                                                            |
| `--web.max-connections` | Максимальное количество одновременных подключений | `512`                                                           |
| `--web.external-url` | Внешний URL-адрес для доступа к Deckhouse Prom++ (через обратный прокси) |                                                                 |
| `--web.route-prefix` | Префикс для внутренних маршрутов веб-интерфейса |                                                                 |
| `--web.user-assets` | Путь к статическим ресурсам (`/user`) |                                                                 |
| `--web.enable-lifecycle` | Разрешить выключение и перезагрузку через HTTP-запросы | `false`                                                         |
| `--web.enable-admin-api` | Включить API для административных действий | `false`                                                         |
| `--web.enable-remote-write-receiver` | Включить API для remote-write-запросов | `false`                                                         |
| `--web.console.templates` | Путь к шаблонам консоли (`/consoles`) | `consoles`                                                      |
| `--web.console.libraries` | Путь к библиотекам консоли | `console_libraries`                                             |
| `--web.page-title` | Заголовок страницы | `Deckhouse Prom++ Time Series Collection and Processing Server` |
| `--web.cors.origin` | Regex для CORS origin |                                                                 |
| `--storage.tsdb.path` | Путь к данным метрик (server mode) | `data/`                                                         |
| `--storage.tsdb.retention` | (**Устаревший**) Время хранения samples |                                                                 |
| `--storage.tsdb.retention.time` | Время хранения samples (переопределяет `retention`) |                                                                 |
| `--storage.tsdb.retention.size` | Макс. объем хранилища (например `512MB`) |                                                                 |
| `--storage.tsdb.no-lockfile` | Не создавать lock-файл | `false`                                                         |
| `--storage.tsdb.head-chunks-write-queue-size` | Размер очереди записи head chunks | `0`                                                             |
| `--storage.agent.path` | Путь к данным (agent mode) | `data-agent/`                                                   |
| `--storage.agent.wal-compression` | Сжимать WAL агента | `true`                                                          |
| `--storage.agent.retention.min-time` | Мин. время хранения samples (agent mode) |                                                                 |
| `--storage.agent.retention.max-time` | Макс. время хранения samples (agent mode) |                                                                 |
| `--storage.agent.no-lockfile` | Не создавать lock-файл (agent mode) | `false`                                                         |
| `--storage.remote.flush-deadline` | Таймаут сброса данных при выключении | `1m`                                                            |
| `--storage.remote.read-sample-limit` | Лимит samples для remote read | `5e7`                                                           |
| `--storage.remote.read-concurrent-limit` | Лимит concurrent remote read | `10`                                                            |
| `--storage.remote.read-max-bytes-in-frame` | Макс. размер фрейма для remote read | `1048576`                                                       |
| `--rules.alert.for-outage-tolerance` | Макс. время простоя для восстановления алертов | `1h`                                                            |
| `--rules.alert.for-grace-period` | Минимальный интервал для алертов | `10m`                                                           |
| `--rules.alert.resend-delay` | Задержка перед повторной отправкой алерта | `1m`                                                            |
| `--rules.max-concurrent-evals` | Лимит параллельных оценок правил | `4`                                                             |
| `--alertmanager.notification-queue-capacity` | Размер очереди уведомлений | `10000`                                                         |
| `--query.lookback-delta` | Макс. lookback для запросов | `5m`                                                            |
| `--query.timeout` | Таймаут выполнения запроса | `2m`                                                            |
| `--query.max-concurrency` | Макс. параллельных запросов | `20`                                                            |
| `--query.max-samples` | Лимит samples на запрос | `50000000`                                                      |
| `--enable-feature` | Включение экспериментальных функций |                                                                 |
| `--log.level` | Уровень логирования (`debug`, `info`, `warn`, `error`) | `info`                                                          |
| `--log.format` | Формат логов (`logfmt`, `json`) | `logfmt`                                                        |
