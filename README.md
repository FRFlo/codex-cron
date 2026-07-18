# codex-cron

Image Docker minimale qui réplique la logique du billet [Codex cron quota wakeup](https://jhuang.netlify.app/blog/2026-05-08-codex-cron-quota-wakeup/) : un cron lance périodiquement `codex exec ... "hi"` pour ouvrir des fenêtres de quota Codex.

## How to build the image locally

```bash
docker build -t codex-cron .
```

## How to run the container

Le cron est piloté par `CODEX_CRON_SCHEDULE`, une expression cron standard à 5 champs. Les heures multiples sont supportées nativement via une liste séparée par des virgules.

```bash
docker run -d \
  --name codex-cron \
  -e CODEX_CRON_SCHEDULE="0 0,5,10,15,20 * * *" \
  -e TZ="Europe/Paris" \
  -v codex-cron-home:/home/codex \
  -v codex-cron-workspace:/workspace \
  codex-cron
```

- `CODEX_CRON_SCHEDULE` : planification cron complète.
- `TZ` : fuseau horaire utilisé par le cron dans le conteneur.
- `codex-cron-home` : volume persistant pour la session et l'authentification.
- `codex-cron-workspace` : répertoire dans lequel le job exécute `codex exec`.

Par défaut, l'image utilise `0 0,5,10,15,20 * * *`.

## How to authenticate Codex

L'authentification est volontairement manuelle via `docker exec`.

```bash
docker exec -it -u codex -e HOME=/home/codex codex-cron codex login
```

Les fichiers d'authentification et de session restent persistants car ils vivent sous `/home/codex`, monté sur un volume Docker.

## How to inspect logs

```bash
docker logs -f codex-cron
```

## How to use the published image from GHCR

Le workflow GitHub Actions publie automatiquement l'image sur GHCR à chaque `push`.

```bash
docker pull ghcr.io/<owner>/codex-cron:latest
```

Remplace `<owner>` par le propriétaire du dépôt GitHub.

## Reference behavior reproduced

Le script planifié exécute l'équivalent de :

```bash
codex exec \
  --model gpt-5.4-mini \
  -c 'model_reasoning_effort="low"' \
  --skip-git-repo-check \
  --ephemeral \
  "hi"
```

avec journalisation des timestamps de début et fin, comme dans le billet d'origine.

## Reference: GitHub Actions publication

Le workflow `.github/workflows/docker-publish.yml` :

- build l'image à chaque `push`
- publie sur `ghcr.io/<owner>/codex-cron`
- publie des tags de branche et de commit
- publie `latest` sur la branche par défaut
