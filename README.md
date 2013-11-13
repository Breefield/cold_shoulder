Cold Shoulder
=============

Rails validation gem which ensures no contact information can be passed into a field.
Looks for Twitter handles, email addresses, and phone numbers

Rails 4:
```shell
gem 'cold_shoulder'
```

Rails 3:
Same as above, it _should_ work with major versions of Rails 3, nothing too crazy going on in here.

## Usage Example
```ruby
class Message < ActiveRecord::Base
  validates :body, cold_shoulder: true
end
```

### Validation Options
```ruby
class Message < ActiveRecord::Base
  validates :body, cold_shoulder: {
    ignore_twitter: true, 
    ignore_email: true, 
    ignore_phone: true
  }
end
```

## What can it catch?
Here are some examples, straight out of the Rspec tests!
### Email addresses
```
dustin.hoffman@breefield.com
dustin.hoffman at breefield.com
dustin.hoffman [ a t ] breefield.com
```
### Phone numbers
```
208 871 2069
(208)8712069
+1 (208)871-2069
2 0 8 8 7 1 2 0 6 9
2\n0\n8\n8\n7 lol Rob Ford \n1\n2\n0\n6\n9
```

It won't missfire and catch:
```
$1,000,000,000
```

### Twitter handles
```
@valid_username
```

### Override validation messages
In config/locals/en.yml
```
en:
  errors:
    messages:
      contains_twitter_handle: "contains the twitter handle: %{handles}"
      contains_phone_number: "contains the phone number: %{phone_numbers}"
      contains_email_address: "contains the email address: %{email_addresses}"
```

## Contributing
 
1. Fork the project
2. Make your feature addition or bug fix
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
  * cold_shoulder uses rspec, all tests are in spec/cold_shoulder_spec.rb
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send us a pull request