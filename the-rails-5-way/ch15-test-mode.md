[&lt;&lt; Development Mode](ch14-development-mode.md) | [README](README.md) | [Production Mode &gt;&gt;](ch16-production-mode.md)

# Chapter 15. Test Mode

Whenever you run Rails in test mode, that is, the value of the `RAILS_ENV`
environment is `test`, then the settings in `config/environments/test.rb`
are in effect.

Most people get by without ever needing to modify their test environment
settings.

**Custom Environments:** if necessary, you can create add'l envs for your Rails
app to run by cloning one of the existing environment files in the
`config/environments` directory. This allows you to easily create production-like
servers for staging purposes.

[&lt;&lt; Development Mode](ch14-development-mode.md) | [README](README.md) | [Production Mode &gt;&gt;](ch16-production-mode.md)
