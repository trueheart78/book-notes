[&lt;&lt; Configuring a Database](ch17-configuring-a-database.md) | [README](README.md) | [Logging &gt;&gt;](ch19-logging.md)

# Chapter 18. Configuring Application Secrets

There is also a `secrets.yml` file found within the `config` folder. This file is
meant to store your app's sensitive data, such as access keys and passwords that
may be req'd for external APIs. At a minimum, Rails requires that `secret_key_base`
is set for each env of your app. This is the property that used to be set in the
`secret_token.rb` initializer in older versions of Rails.


**Kevin Says:** I would strongly advise not storing any production secret values
in nversion control. Use env vars to do this.

A hash of all the secrets defined in `config/secrets.yml` can be access via
`Rails.application.secrets`.

```ruby
Rails.application.secrets
# => {:secret_key_base=>"hashhhh"}
```

An accessor for each secret key is also provided, like `Rails.application.secrets.secret_key_base`.

```ruby
Rails.env
# => "development"
Rails.application.secrets.secret_key_base
# => "hashhhh"
```

## Secret Token

Certain types of hacking involve modifying the contents of cookies without the
server knowing about it. By digitally signing all cookies sent to the browser,
Rails can detect whether they were tampered with. Rails signs cookies using the
value of `secret_key_base`, from `config/secrets.yml`, which is randomly generated
along with your app.

[&lt;&lt; Configuring a Database](ch17-configuring-a-database.md) | [README](README.md) | [Logging &gt;&gt;](ch19-logging.md)
