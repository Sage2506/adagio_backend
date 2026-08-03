# adagio_backend

Adagio backend is a Rails API-only service that powers the backoffice platform.
It handles:

- students and guardians
- plans, disciplines, classrooms, lessons, attendance
- subscriptions, payments, orders, products
- users and token-based authentication

Base API namespace: `/api/v1`

## 1) Onboarding Quick Start (10-15 minutes)

Use this if you are joining the project and want a reliable first boot.

### Prerequisites

- Ruby `3.4.2`
- PostgreSQL running locally
- Bundler
- Rails master key available (for credentials)
- AWS Cognito credentials (required for login/token verification paths)

### Step-by-step

1. Install dependencies

```bash
bundle install
```

2. Configure Rails credentials

```bash
bin/rails credentials:edit
```

Add or verify:

```yml
aws:
  region: us-east-1
  access_key_id: YOUR_ACCESS_KEY_ID
  secret_access_key: YOUR_SECRET_ACCESS_KEY
  cognito_client_id: YOUR_COGNITO_CLIENT_ID
  cognito_client_secret: YOUR_COGNITO_CLIENT_SECRET
  cognito_user_pool_id: YOUR_COGNITO_USER_POOL_ID
```

3. Prepare database

```bash
bin/rails db:prepare
```

4. Boot the app

```bash
bin/setup
```

If you do not want to start the server automatically:

```bash
bin/setup --skip-server
bin/rails server
```

5. Validate health endpoint

```bash
curl http://localhost:3000/up
```

Expected result: HTTP 200.

## 2) First-Day Operational Checklist

Run this checklist in order:

- [ ] Application boots with no errors
- [ ] `bin/rails db:prepare` succeeds
- [ ] `GET /up` returns 200
- [ ] Can authenticate via `POST /api/v1/auth/login`
- [ ] Can call one protected endpoint with `Authorization: Bearer <id_token>`
- [ ] `bin/rails test` runs
- [ ] `bin/rubocop` runs

If any item fails, use the troubleshooting section below.

## 3) Local Development Runbook

### Daily start

```bash
bin/rails server
```

### Common commands

```bash
bin/rails db:prepare
bin/rails test
bin/rubocop
bin/brakeman
```

### Useful reset commands

```bash
bin/rails log:clear tmp:clear
```

## 4) Project Map

- `app/controllers/api/v1`: REST endpoints
- `app/models`: domain models and associations
- `app/services`: service objects and external integrations (Cognito)
- `app/controllers/concerns/authenticable.rb`: token guard logic
- `config/routes.rb`: API routes and custom actions
- `db/schema.rb`: current database shape

## 5) API Conventions

### Authentication

- Public endpoint: `POST /api/v1/auth/login`
- Most endpoints are protected and require:

```http
Authorization: Bearer <id_token>
```

Token verification uses Cognito JWKS via the `CognitoAuth` service.

### Pagination and filtering

Several resources support:

- `Pagy` pagination (response includes `links` and `pages`)
- `Ransack` filters using `q[...]` query params

### CORS

CORS is configured in `config/initializers/cors.rb`.
Allowed origins include local frontend hosts (for example port `5173`) and LAN patterns.

## 6) Main Resources

Available under `/api/v1`:

- `alumns` (includes `PUT /alumns/:id/associate`, `GET /alumns/birthdays_by_month`)
- `guardians` (includes `PUT /guardians/:id/associate`)
- `assistances`, `classrooms`, `disciplines`, `lessons`
- `plans`, `plan_disciplines`, `products`
- `subscriptions` (includes `PUT /subscriptions/:id/rehabilitate`)
- `payments`, `subscription_payments`
- `orders`
- `users`, `user_disciplines`

## 7) Data Domains (DB-Level)

Core tables:

- `alumns`, `guardians`, `alumn_guardians`
- `plans`, `disciplines`, `plan_disciplines`
- `lessons`, `assistances`, `classrooms`
- `subscriptions`, `payments`, `subscription_payments`
- `orders`, `order_products`, `order_payments`
- `users`, `user_disciplines`

## 8) Deployment Notes

- The provided `Dockerfile` targets production usage.
- This repository includes `kamal` for deployment strategy.
- Production uses Solid Queue, Solid Cache, and Solid Cable configuration.

Build image:

```bash
docker build -t adagio_backend .
```

Run image example:

```bash
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=YOUR_MASTER_KEY \
  --name adagio_backend adagio_backend
```

## 9) Troubleshooting

### 401 Invalid token

- Verify `Authorization: Bearer <id_token>` header exists
- Verify Cognito values in Rails credentials
- Confirm token is issued for the expected user pool/client

### Database boot errors

- Ensure PostgreSQL is up
- Run `bin/rails db:prepare`
- Check local DB name/permissions in `config/database.yml`

### CORS blocked requests

- Confirm frontend origin is allowed in `config/initializers/cors.rb`
- Confirm frontend base URL targets this backend correctly

## 10) Frontend Integration

The React backoffice consumes this API via `VITE_API_BASE_URL`.
Use a base URL that points to this service and `/api/v1` routes.
