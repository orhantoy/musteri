# Müşteri

(*Müşteri* means customer in Turkish.)

A lot of applications deal with importing customers and/or users from other systems, usually by uploading a tabular file like CSV. I made a test assignment for job applicants at a previous job about this specific need. This codebase is an illustration of how I would do it.

## Concepts

- **Space** is the top-level grouping of customers. It is the equivalent of an account.
- **Customer** belongs to a space.
- **User** can have access to multiple customers across spaces with only one set of credentials (email + password).

## Restrictions

- CSV must be delimited with comma `,` and UTF-8 encoded.
- Only CSV is supported.
- CSV file must have a header row with hard-coded column names.

## Improvements

Basically all the listed restrictions should be addressed in an ideal implementation.

## Run

There is nothing special about this Rails app. If you have PostgreSQL installed and have tried running Rails apps before it should be enough to run the following commands

```
./bin/setup

rails test # Tests should be passing
rails server
```
