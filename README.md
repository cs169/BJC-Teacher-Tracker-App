# BJC Teacher Tracker

Sp24 Badges:

[![Bluejay Dashboard](https://img.shields.io/badge/Bluejay-Dashboard_BJC%20Teacher%20Tracker-blue.svg)](http://dashboard.bluejay.governify.io/dashboard/script/dashboardLoader.js?dashboardURL=https://reporter.bluejay.governify.io/api/v4/dashboards/tpa-CS169L-23-GH-cs169_BJC-Teacher-Tracker/main) •
[![All Specs](https://github.com/cs169/BJC-Teacher-Tracker-App/actions/workflows/specs.yml/badge.svg)](https://github.com/cs169/BJC-Teacher-Tracker-App/actions/workflows/specs.yml) •
[![RuboCop](https://github.com/cs169/BJC-Teacher-Tracker-App/actions/workflows/rubocop.yml/badge.svg)](https://github.com/cs169/BJC-Teacher-Tracker-App/actions/workflows/rubocop.yml) •
[![Maintainability](https://api.codeclimate.com/v1/badges/9bedc69e2aa0c0b704cd/maintainability)](https://codeclimate.com/github/cs169/BJC-Teacher-Tracker/maintainability) •
[![Test Coverage](https://api.codeclimate.com/v1/badges/9bedc69e2aa0c0b704cd/test_coverage)](https://codeclimate.com/github/cs169/BJC-Teacher-Tracker/test_coverage) •
[![Pivotal Tracker](https://user-images.githubusercontent.com/67244883/154180887-f803124e-0156-4322-899d-ba475139d60d.png)](https://www.pivotaltracker.com/n/projects/2406982)


Sp23 Badges:

[![Bluejay Dashboard](https://img.shields.io/badge/Bluejay-Dashboard_BJC%20Teacher%20Tracker-blue.svg)](http://dashboard.bluejay.governify.io/dashboard/script/dashboardLoader.js?dashboardURL=https://reporter.bluejay.governify.io/api/v4/dashboards/tpa-CS169L-23-GH-cs169_BJC-Teacher-Tracker/main) •
[![Build & Rspec & Cucumber](https://github.com/cs169/BJC-Teacher-Tracker/actions/workflows/specs.yml/badge.svg)](https://github.com/cs169/BJC-Teacher-Tracker) •
[![Robocop](https://github.com/cs169/BJC-Teacher-Tracker/actions/workflows/rubocop.yml/badge.svg)](https://github.com/cs169/BJC-Teacher-Tracker) •
[![Maintainability](https://api.codeclimate.com/v1/badges/9bedc69e2aa0c0b704cd/maintainability)](https://codeclimate.com/github/cs169/BJC-Teacher-Tracker/maintainability) •
[![Test Coverage](https://api.codeclimate.com/v1/badges/9bedc69e2aa0c0b704cd/test_coverage)](https://codeclimate.com/github/cs169/BJC-Teacher-Tracker/test_coverage) •
[![Pivotal Tracker](https://user-images.githubusercontent.com/67244883/154180887-f803124e-0156-4322-899d-ba475139d60d.png)](https://www.pivotaltracker.com/n/projects/2406982)

---

Previous Badges:

![Specs Status](https://github.com/beautyjoy/BJC-Teacher-Tracker/actions/workflows/specs.yml/badge.svg) •
[![codecov](https://codecov.io/gh/beautyjoy/BJC-Teacher-Tracker/branch/master/graph/badge.svg?token=96PyjKKVzi)](https://codecov.io/gh/beautyjoy/BJC-Teacher-Tracker) • ![Rubocop Status](https://github.com/beautyjoy/BJC-Teacher-Tracker/actions/workflows/rubocop.yml/badge.svg)

---

## Description

The Beauty and Joy of Computing (BJC) is an introductory computer science curriculum developed at UC Berkeley meant for high school freshmen up to college freshmen. The program has a teacher guide and a newly generated password that is to be given to any teacher who signs up for the program as a volunteer educator in the Bay Area - there are plans to expand the program to other states in late 2020. This pilot application is designed as a dashboard to track the workflow of teachers who run the program and provide high-level, descriptive statistics on the courses taught and participating schools. The BJC Teacher Tracker is a NEW project started in Fall 2019 by a group of 5 student developers in UC Berkeley's CS 169: Software Engineering.

## Key Features and Functionality

We have worked on the adding following core features and functionality:

- Feature: A application form for prospective teachers to request access to the platform
- Functionality: Administrators are immediately notified of new applications via email
- Feature: Administrators can validate or deny applicants with a button click
- Functionality: An email is automatically sent to successful applicants notifying them of their acceptance to the teaching program
- Feature: A separate administrators' view that uses Google OAuth to allow logins from UC Berkeley-registered users (@berkeley.edu)
- Functionality: Administrators can login to the dashboard to view unvalidated applications, statistics on validated applicants, and a list of current teachers
- Feature: The administrators' view contains a main page with
  - buttons to delete or validate newly submitted forms
  - tables for statistics about the schools and the courses current teachers are teaching
  - a map with the locations of all the schools that teachers are a part of
  - a separate page with all the validated teachers and their information

## Installation:

### Environmental Variable
* We are not using `application.yml` (rails env framework). Instead, we use a `.env` file at directory root to load all env vars. Use `.env.example` as a reference for env format.
* Use tools like [overmind](https://github.com/DarthSim/overmind) or [foreman](https://github.com/ddollar/foreman) to load in the env vars.
* You probably need to configure your own oauth keys and database name/passwords.

### Postgres Installation

#### MacOS:
* `brew install postgresql chromedriver`
* Start postgres if necessary. `brew services start postgresql`

#### Linux/WSL:
* `sudo apt install postgresql`
* Create a postgres user.
  * `sudo su - postgres` (to get into postgres shell)
  * `createuser --interactive --pwprompt` (in postgres shell)
  * Save `DB_USER` and `DB_PASSWORD` fields in the `.env` file.
* Start postgres if necessary. `pg_ctlcluster 12 main start`
  * Note: if you are using WSL2 on windows, the command to start postgres is `sudo service postgresql start`

### Framework/Gem Installation
* `rvm use 3.2.2` # Double-check `.ruby-version`
* `bundle`
* `bin/rails db:setup` (Run this after setting up Postgres)
* `nvm install 14` Node v14 is needed
* `yarn install` Yarn is needed

### Spin Up Server
* Use tools like [overmind](https://github.com/DarthSim/overmind) or [foreman](https://github.com/ddollar/foreman) to boot up server with env vars loaded.
* If you are using `overmind`, you can simply `npm run dev`.

### Available Commands
- For RSpec tests run `bundle exec rspec`
- For Cucumber tests run `bundle exec cucumber`
- For Rubocop check run `bundle exec rubocop` (Autocorrect all with `bundle exec rubocop -a`)
- To make someone an admin use db console access
  - Using psql
    - First run `heroku pg:psql` (for Heroku) or `psql bjc_teachers_dev` (for local) to get into psql
    - Alternatively, you can use `rails db` to get into psql
    - Then
      ```
      UPDATE teachers
      SET admin = true
      WHERE Email LIKE '%@berkeley.edu%'
      ;
      ```
      Of course, you can swap in the email of your choice.
  - Using rails console
    - First run `heroku run rails console` (for Heroku) or `rails console` (for local) to get into rails console
    - Then
      ```
      Teacher.where("email LIKE '%@berkeley.edu%'").update_all(admin: true)
      ```

## JavaScript and CSS with Webpack

* `stylesheet_pack_tag` doesn't work. :(
* Use `import '*.scss' in a _JavaScript file, and webpack will compile correctly
* If you need a new CSS-only import, make a new CSS *and* a new JS file.

## Deployed Site:

- https://teachers.bjc.berkeley.edu

## Steps to Deploying on Heroku

- ... create a heroku app
- `heroku stack:set heroku-20` (Ruby 3.2.2 is not supported on latest stack heroku-22. Double check your Ruby version though)
- `heroku buildpacks:set heroku/nodejs` # this must be the first buildpack.
- `heroku buildpacks:add --index 2 heroku/ruby`
- `git remote set-url heroku https://git.heroku.com/bjc-teachers.git` (or whatever your heroku deployment repository is)
- Make your local changes and start the commit process
- `git add .`
- `git commit -m "<Message>"`
- `git push heroku master` (If this fails, try commenting the release command in `Procfile` for this first deployment only and go on to the next step. After you are done with the deployment, uncomment back the release command again. For more information, see [this PR](https://github.com/cs169/BJC-Teacher-Tracker/pull/15).)

If bundler install runs successfully, continue with the following commands to correctly setup the PostgreSQL database on Heroku:
- `heroku addons:create heroku-postgresql` (or, create and attach a new postgresql database on Heroku dashboard manually)
- `heroku run bin/rails db:drop` (if this fails, you can skip this step)
- `heroku run bin/rails db:schema:load`
- `heroku run bin/rails db:seed`
- `figaro heroku:set -e production` (or `staging`, depending on the your needs)
- `heroku open`



### CodeClimate Local Test

TODO: Link to download CodeClimate binaries for macOS.

```
https://codeclimate.com/downloads/test-reporter/test-reporter-latest-darwin-amd64
```
