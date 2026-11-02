# infra-monitoring-project

Учебный проект для мониторинга доступности API и анализа логов.

## Запуск

Требуются Docker и Docker Compose. Из корня проекта:

```bash
docker compose up -d
docker compose ps
curl http://localhost:80
```

Ожидаемый ответ: `Monitoring Service Active`.

Nginx принимает запросы на локальном порту 80 и передаёт их сервису `api:8080`
по сети Docker `monitoring`. Порт API доступен только внутри сети контейнеров.

Остановка:

```bash
docker compose down
```
