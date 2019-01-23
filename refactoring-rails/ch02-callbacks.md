[🔙 Use REST][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Form Objects 🔜][upcoming-chapter]

# Chapter 2. Callbacks

ActiveRecord Callbacks

A good _smell_ is that when a test requires an object that actually needs to be saved to the
database to test.

```ruby
before_validation :sanitize_phone_number
before_create :generate_token
before_create :update_last_order_for_user
after_save :send_confirmation_email
```

The `:sanitize_phone_number` should be extracted to a service object or helper class.

The `:generate_token` method is simple as its basic and generating a random id.

The `:update_last_order_for_user` updates a column on a different model, which is a bit wierd.

The `:send_confirmation_email` fires off an order email _everytime_ the object is saved, which is
problematic / **bad**.

The first way to address this issue is with a `OrderCreator` service object that handles the saving
_and_ the order email. Another option is a decorator. You can use a `SimpleDelegator`
(a ruby feature) and override the save method.

```ruby
ConfirmingOrder.new(Order.new(order_params))

class ConfirmingOrder < SimpleDelegator
  def save
    if __getobj__.save
      OrderMailer.confirmation(self).deliver
    end
  end
end
```

Pros: API stays the same, and it composes. You can just wrap new behavior if needed.

Cons: subtle/non-obvious, a little fancy. Also, it wraps the orders, so `@order != Order.new`

Pick the one that fits better. Your goal is decomplection.

[🔙 Use REST][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Form Objects 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch01-use-rest.md
[upcoming-chapter]: ch03-form-objects.md
