## Errata

Page 38, references the items to be learned on page 40

```ruby
def initialize(options = {}, &block)
  options.each { |k,v| send("#{k}=", v) }
  instance_eval(&block) if block_given?  #instance_eval has not yet been covered
end
```
