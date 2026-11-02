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

## Передача на удалённый сервер

В примерах замените `deploy@example.com` на пользователя и адрес своего сервера.
На сервере должны быть установлены Docker и Docker Compose, пользователь должен
иметь доступ к Docker, а локальный порт 80 должен быть свободен.

### SSH-ключ

Создайте отдельную пару ключей и задайте парольную фразу при запросе:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/infra_monitoring_ed25519 \
  -C "infra-monitoring-deploy"
```

Если файл ключа уже существует, используйте другое имя, чтобы не перезаписать его.
Закрытый ключ остаётся на вашей машине. На сервер копируется только публичный
ключ с расширением `.pub`:

```bash
ssh-copy-id -i ~/.ssh/infra_monitoring_ed25519.pub deploy@example.com
```

При первом подключении сверьте отпечаток ключа сервера с данными администратора.
Для установки публичного ключа потребуется существующий доступ к серверу,
например по паролю.

### Архив и развёртывание

Из корня проекта соберите архив с файлами проекта. Логи, локальные настройки
и каталог `.git` в него не включаются. Архив сохраняется рядом с проектом:

```bash
COPYFILE_DISABLE=1 tar -czf ../infra-monitoring-project.tar.gz \
  README.md .gitignore check_api.sh analyze_logs.sh \
  docker-compose.yml nginx .github

ssh -i ~/.ssh/infra_monitoring_ed25519 deploy@example.com \
  'mkdir -p ~/infra-monitoring-project'

scp -i ~/.ssh/infra_monitoring_ed25519 \
  ../infra-monitoring-project.tar.gz \
  deploy@example.com:~/infra-monitoring-project/
```

Распакуйте архив и запустите стек через SSH:

```bash
ssh -i ~/.ssh/infra_monitoring_ed25519 deploy@example.com '
  cd ~/infra-monitoring-project &&
  tar -xzf infra-monitoring-project.tar.gz &&
  docker compose up -d &&
  docker compose ps &&
  curl --fail http://localhost:80
'
```

Ожидаемый ответ: `Monitoring Service Active`. Проверка выполняется на сервере:
порт 80 опубликован только на его локальном интерфейсе.
