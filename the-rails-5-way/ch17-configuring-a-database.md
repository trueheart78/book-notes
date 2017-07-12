[&lt;&lt; Production Mode](ch16-production-mode.md) | [README](README.md) | [Configuring Application Secrets &gt;&gt;](ch18-configuring-application-secrets.md)

# Chapter 17. Configuring a Database

The file `database.yml` found in `config` specifies all configuration settings
required by Active Record to connect to a database. When a new app is bootstrapped,
Rails automatically generates boilerplate sections for each env.

An old best practice within the Rails community has been not to store `config/database.yml`
in version control. New to Rails 4.1 is the capability to configure Active Record
with an env var `DATABSE_URL`, allowing each dev working on the project to have their
own copy of `config/database.yml` that is not stored in version control.

[&lt;&lt; Production Mode](ch16-production-mode.md) | [README](README.md) | [Configuring Application Secrets &gt;&gt;](ch18-configuring-application-secrets.md)
