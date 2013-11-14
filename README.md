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
    ignore_twitter: true, # Don't add errors when twitter handles are detected
    ignore_email: true,   # Don't add errors email addresses are detected
    ignore_phone: true,   # Don't add errors when phones are detected
    ignore_link: true,    # Don't add errors when links are detected
    remove_links: true,   # Strip any found links from the actual saved value, setting to true will ignore links
    ignore_number_words: true # Don't count 'zero, one, two' as '0, 1, 2' etc this is used to catch phone numbers as words
    message: 'Use this to override all the specific messages'
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
two oh eight 8 7 one 2 oh six 9
two zero eight eight seven one two oh six nine
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
      contains_twitter: "contains the twitter handle: %{handles}"
      contains_phone: "contains the phone number: %{phone_numbers}"
      contains_email: "contains the email address: %{email_addresses}"
      contains_link: "contains the link: %{detected}"
```

## Contributing
 
1. Fork the project
2. Make your feature addition or bug fix
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
  * cold_shoulder uses rspec, all tests are in spec/cold_shoulder_spec.rb
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send us a pull request