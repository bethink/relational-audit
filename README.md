# Relational::Audit

Audit for entities not for table.
Entity consists of information from multiple related tables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relational-audit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install relational-audit

## Usage


    Class User
         has_many :addresses
         has_one :profile
         relational_audit :only => [:firstname, :lastname, :dob], :ignore => [:id, :created_at, :updated_at]
    end

    Class Address
         belongs_to :user
         belongs_to_audit :user
    end

    Class Profile
         belongs_to :user
         belongs_to_audit :user
    end

    @user.audits # Returns the changes in key/value pair =>  [{{:changes_by=>"Jon", :changes=>{"customers"=>["google", "facebook"], "updated_at"=>[2017-06-28 07:29:43 UTC, 2017-06-28 07:38:27 UTC]}}}, ...]

    @user.raw_audits # Returns audit objects => #<ActiveRecord::Relation [#<RelationalAudit::Audit, ... 

#### For polymorphic association

Assume that 'Address' is a polymporphic enity for User.

    Class User
         has_many :addresses, :as => :entity
         relational_audit
    end

    Class Address
         belongs_to :entity, :polymorphic => true
         belongs_to_audit :entity
    end


## Contributing

1. Fork it ( https://github.com/[my-github-username]/relational-audit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
