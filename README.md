[![Build Status](https://travis-ci.org/InclusiveClassrooms/skills-wheel.svg?branch=master)](https://travis-ci.org/InclusiveClassrooms/skills-wheel)
[![codecov](https://codecov.io/gh/InclusiveClassrooms/skills-wheel/branch/master/graph/badge.svg)](https://codecov.io/gh/InclusiveClassrooms/skills-wheel)

# Skillswheel

This project uses:
[Elixir version 1.4.x](http://elixir-lang.org/)
[PostgreSQL version 9.5.x](https://www.postgresql.org/)

## Quick Start

* Ensure you have the above dependencies installed
* Ensure you have the following environment variables in your path:
```bash
export POSTGRES_USERNAME=<psql_username>
export POSTGRES_PASSWORD=<psql_password>
```
* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Install Node.js dependencies with `npm install`
* Start your phoenix server with `mix phoenix.server`
* Now visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing

* To run the tests locally ensure you have run the above quick start steps
* Run the test script with `mix test`
* You can check test coverage with `mix coveralls`
* You can generate a coverage report with `mix coveralls.html`

## Routes

Check the application routes with `mix pheonix.routes`

