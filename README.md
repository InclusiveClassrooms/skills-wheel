[![Build Status](https://travis-ci.org/InclusiveClassrooms/skills-wheel.svg?branch=master)](https://travis-ci.org/InclusiveClassrooms/skills-wheel)
[![codecov](https://codecov.io/gh/InclusiveClassrooms/skills-wheel/branch/master/graph/badge.svg)](https://codecov.io/gh/InclusiveClassrooms/skills-wheel)

# Skillswheel

This project uses:
[Elixir version 1.4.x](http://elixir-lang.org/)
[PostgreSQL version 9.5.x](https://www.postgresql.org/)
[Node version 6.10.x](https://nodejs.org/)
[Redis version 3.2.4](https://redis.io/)

## Quick Start

* Ensure you have the above dependencies installed
* Ensure you have the following environment variables in your path:
```bash
export POSTGRES_USERNAME=<psql_username>
export POSTGRES_PASSWORD=<psql_password>
export SMTP_USERNAME=AKIAJTAJDKM4LEZYXFUA
export SMTP_PASSWORD=As1PNrgowukauAigSvNBFXgHuqGShjcC9PRV7zzW3XJr
export SES_SERVER=email-smtp.eu-west-1.amazonaws.com
export SES_PORT=25
export ADMIN_EMAIL=inclusiveclassroomstest@gmail.com
export ADMIN_PASSWORD=inclusiveclassrooms123
export REDIS_URL=redis://localhost:6379
export SECRET_KEY_BASE=RoBmHpD9fll4Z+i9J/yort8U3AEelmCaphcUmQBHlimDvAeGmdzxYuVrL7BbsczP
```
* Start a postgres server in a seperate terminal with:
```
$ postgres -D /usr/local/var/postgres
```
* Start a redis server in a seperate terminal with:
```
$ redis-server
```
* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Install Node.js dependencies with `npm install`
* Start your phoenix server with `mix phoenix.server`
* Now visit [`localhost:4000`](http://localhost:4000) from your browser.

**NOTE:** If you are experiencing errors when trying to run the project then it
might be because of the following:

* `.env` file isn't sourced. Quick fix: type `source .env` into the command line
at the root of your project
* `psql` isn't running. Quick fix: start a `psql` server in your terminal

## Testing

* To run the tests locally ensure you have run the above quick start steps
* Run the test script with `mix test`
* You can check test coverage with `mix coveralls`
* You can generate a coverage report with `mix coveralls.html`

## Routes

Check the application routes with `mix pheonix.routes`
