# Jenkins PostgreSQL Job Databases Plugin

[github.com/lmlima/jenkins-postgresql-job-databases-plugin](https://github.com/lmlima/jenkins-postgresql-job-databases-plugin)

Automatically set up test databases for Jenkins jobs.

## Usage

In the global Jenkins configuration, set up host and port of your
PostgreSQL server and enter credentials of the PostgreSQL user that shall be
used to create databases and grant permissions. Note that this user
needs at least CREATEDB and CREATEROLE options.

Configure a database name in a job. The plugin ensures the database
exists when the job is run. It grants all permissions for the database
to a job specific user and publishes its credentials in the
environment variables $PGSQL_USER and $PGSQL_PASSWORD.

## Contributors

* [Leandro Muniz de Lima](https://github.com/lmlima) (`leandro.m.lima@ufes.br`)

## Contributors of Jenkins MySQL Job Databases Plugin

* [Tim Fischbach](https://github.com/tf) (`tfischbach@codevise.de`)
* [Nicolas Rodriguez](https://github.com/n-rodriguez) (`nrodriguez@jbox-web.com`)

## License

Please fork and improve.

Copyright (c) 2014 Codevise Solutions Ltd. This software is licensed under the MIT License.
