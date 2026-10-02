# Adagio Backend

## Project description

Adagio Backend is an API-only service for the Adagio backoffice. It provides the
REST API used to manage students and guardians, classes and attendance, plans
and subscriptions, payments and orders, products, and staff users. API routes
are namespaced under `/api/v1`. User authentication is integrated with AWS
Cognito.

## Tech stack

- Ruby 3.4.2 and Rails 8.1.3.1
- PostgreSQL and Puma
- AWS Cognito for authentication; JWTs are verified against Cognito JWKS
- Solid Queue, Solid Cache, and Solid Cable for background jobs, caching, and
  Action Cable
- Pagy and Ransack for pagination and filtering
- Minitest, RuboCop, and Brakeman for tests, style, and security analysis
- Docker and Kamal configuration for production deployment

## Run locally

### Requirements

- Ruby 3.4.2 (see `.ruby-version`)
- Bundler
- PostgreSQL running locally, with permission to create databases
- The Rails credentials master key
- AWS Cognito credentials for login and protected API requests

### Setup and start

1. Install Ruby 3.4.2 and start PostgreSQL.
2. From the project root, install the gems:

   ```bash
   bundle install
   ```

3. Make Rails credentials available. Obtain the project's master key through
   the team's approved secret-sharing channel, then either place it in
   `config/master.key` or export it as `RAILS_MASTER_KEY`. Do not commit or
   share the key in source control.
4. Check that the encrypted Rails credentials include these AWS settings:

   ```yaml
   aws:
     region: YOUR_AWS_REGION
     access_key_id: YOUR_AWS_ACCESS_KEY_ID
     secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
     cognito_client_id: YOUR_COGNITO_CLIENT_ID
     cognito_client_secret: YOUR_COGNITO_CLIENT_SECRET
     cognito_user_pool_id: YOUR_COGNITO_USER_POOL_ID
   ```

   To edit credentials locally, run `bin/rails credentials:edit`; the master
   key is required. Never commit plaintext credentials.
5. Create or update the development database:

   ```bash
   bin/rails db:prepare
   ```

   The database is named `adagio_backend_development` and uses the local
   PostgreSQL defaults in `config/database.yml`.
6. Start the API:

   ```bash
   bin/rails server
   ```

   The server listens on `http://localhost:3000` by default. Alternatively,
   `bin/setup` installs dependencies, prepares the database, and starts the
   development server. Use `bin/setup --skip-server` to prepare everything
   without starting the server.
7. Check that Rails is responding:

   ```bash
   curl --fail http://localhost:3000/up
   ```

   A successful health check returns HTTP 200. A valid Cognito user and working
   AWS credentials are needed to test login and protected endpoints.

### Common development commands

```bash
bin/rails db:prepare
bin/rails test
bin/rubocop
bin/brakeman
bin/rails log:clear tmp:clear
```

If database setup fails, confirm PostgreSQL is running and that your local
PostgreSQL role can create the database specified in `config/database.yml`.

## Operational checklist

Run this checklist in order:

- [ ] Application boots with no errors
- [ ] `bin/rails db:prepare` succeeds
- [ ] `GET /up` returns 200
- [ ] Can authenticate via `POST /api/v1/auth/login`
- [ ] Can call a protected endpoint after logging in with Cognito
- [ ] `bin/rails test` runs
- [ ] `bin/rubocop` runs

If any item fails, use the troubleshooting section below.

## Project map

- `app/controllers/api/v1`: REST endpoints
- `app/models`: domain models and associations
- `app/services`: service objects and external integrations (Cognito)
- `app/controllers/concerns/authenticable.rb`: token guard logic
- `config/routes.rb`: API routes and custom actions
- `db/schema.rb`: current database shape

## API conventions

### Authentication

- Public endpoint: `POST /api/v1/auth/login`
- Protected endpoints authenticate using the HTTP-only JWT cookie set at login.

Token verification uses Cognito JWKS via the `CognitoAuth` service.

### Pagination and filtering

Several resources support:

- `Pagy` pagination (response includes `links` and `pages`)
- `Ransack` filters using `q[...]` query params

### CORS

CORS is configured in `config/initializers/cors.rb`.
Allowed origins include local frontend hosts (for example port `5173`) and the
production frontend origin.

## Main resources

Available under `/api/v1`:

- `alumns` (includes `PUT /alumns/:id/associate`, `GET /alumns/birthdays_by_month`)
- `guardians` (includes `PUT /guardians/:id/associate`)
- `assistances`, `classrooms`, `disciplines`, `lessons`
- `plans`, `plan_disciplines`, `products`
- `subscriptions` (includes `PUT /subscriptions/:id/rehabilitate`)
- `payments`, `subscription_payments`
- `orders`
- `users`, `user_disciplines`

## Data domains

Core tables:

- `alumns`, `guardians`, `alumn_guardians`
- `plans`, `disciplines`, `plan_disciplines`
- `lessons`, `assistances`, `classrooms`
- `subscriptions`, `payments`, `subscription_payments`
- `orders`, `order_products`, `order_payments`
- `users`, `user_disciplines`

## Deployment notes

- The provided `Dockerfile` targets production usage.
- This repository includes `kamal` for deployment strategy.
- Production uses Solid Queue, Solid Cache, and Solid Cable configuration.

## Troubleshooting

### Authentication errors

- Verify AWS and Cognito values in Rails credentials
- Confirm the user and token belong to the configured Cognito user pool/client
- For protected routes, log in through the API so the JWT cookie is set

### Database boot errors

- Ensure PostgreSQL is up
- Run `bin/rails db:prepare`
- Check local DB name/permissions in `config/database.yml`

### CORS blocked requests

- Confirm frontend origin is allowed in `config/initializers/cors.rb`
- Confirm frontend base URL targets this backend correctly

## Frontend integration

The React backoffice consumes this API via `VITE_API_BASE_URL`.
Use a base URL that points to this service and `/api/v1` routes.
