# n8n on Railway - pinned, tested, 3.0-ready (template, unofficial)

One-click n8n in **queue mode** (main + worker + PostgreSQL + Redis), pinned to a release we tested, with the n8n 3.0 defaults
already set - so the n8n 3.0 release does not land on you by surprise.

**Deploy on Railway:** <TEMPLATE LINK - added when published>
New to Railway? Sign up with our **referral link**: https://railway.com?referralCode=j8As-k - you get USD 20 of credit, and we get a
share of your Railway usage. That is how this free template is paid for.

## Why this template
- **Pinned version.** Most n8n templates run `n8nio/n8n` without a version, so a redeploy can jump to n8n 3.0 (October 2026) on
  its own. This one runs `n8nio/n8n:2.42.3` (pinned by digest, tested 2026-10-06). You upgrade when YOU decide - see "Updating".
- **No open setup page.** A fresh n8n lets the first visitor create the owner account. Here the owner is created from your variables
  at start (n8n's own `N8N_INSTANCE_OWNER_*` feature): you set `N8N_OWNER_EMAIL`, the password is generated.
- **Encryption key set once.** `N8N_ENCRYPTION_KEY` is generated and shared by main and worker - the credentials stay readable after
  redeploys and moves (the classic "Credentials could not be decrypted" problem).
- **n8n 3.0 defaults already on:** `N8N_RUNNERS_TASK_TIMEOUT=60` (Code steps get 60 s) and `N8N_UNVERIFIED_PACKAGES_ENABLED=false`
  (unverified community packages off). Change them if you need the old behaviour.

## What it deploys
| service | what |
|---|---|
| `n8n` | main process (editor, API, webhooks), public HTTPS domain, volume `/home/node/.n8n` |
| `n8n-worker` | runs the executions (queue mode); same image, start command `worker` |
| `Postgres` | Railway PostgreSQL (workflows, credentials - encrypted, executions, binary data) |
| `Redis` | Railway Redis (the job queue) |

## Variables
| variable | set by | |
|---|---|---|
| `N8N_OWNER_EMAIL` | **you** | your login e-mail |
| `N8N_OWNER_PASSWORD` | generated | your login password - copy it from the Railway variables of `n8n` |
| `N8N_ENCRYPTION_KEY` | generated | **back it up** (password manager) - without it no credential can be decrypted |
| `DB_POSTGRESDB_*`, `QUEUE_BULL_REDIS_*` | Railway references | |
| `EXECUTIONS_MODE=queue`, `N8N_DEFAULT_BINARY_DATA_MODE=database` | template | binary data in the database so main and worker share it |
| `N8N_RUNNERS_TASK_TIMEOUT=60`, `N8N_UNVERIFIED_PACKAGES_ENABLED=false` | template | the n8n 3.0 defaults |
| `N8N_PROXY_HOPS=1`, `N8N_DIAGNOSTICS_ENABLED=false` | template | behind Railway's proxy; no telemetry |

## Updating (and n8n 3.0)
1. Back up the database (Railway PostgreSQL backups) and note your `N8N_ENCRYPTION_KEY`.
2. Read n8n's release notes; for 3.0 also the official breaking-changes page (Function nodes are removed - use Code nodes).
3. Change the version in the `FROM` line of the Dockerfile in YOUR copy (or wait for our tested update here), redeploy `n8n` and
   `n8n-worker` together.
4. Going back: n8n can migrate its database on a new version - restore the backup together with the old version, not only the old image.
Guide: https://localhavenstore.github.io/guides/ (n8n on Railway and 3.0) · tested update verdicts: https://localhavenstore.github.io/update-watch/

## How it was tested
A Railway-like stack (the same variables, PostgreSQL 17, Redis with a password, main + worker in queue mode) on a fresh throw-away
Ubuntu 24.04 VM: health, setup page closed, owner login works (a wrong password does not), a webhook workflow runs through the
worker, login survives a restart, the plain password is not in the n8n process. Result: `VM_TEST_RESULT.txt`.

Made with AI assistance and tested by us (Localhaven, https://localhavenstore.github.io). Not affiliated with Railway or n8n GmbH.
