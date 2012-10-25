Whiplash API V1 - Ruby Client
================================

This library provides a wrapper around the Whiplash Merchandising REST API for use within Ruby apps or via the console.

== Note

**If you are using a Rails app, the advised approach is to use ActiveResource. You can get started or gain inspiration from our example Rails app: https://github.com/ideaoforder/whiplash-rails-example**

== Requirements

- Ruby 1.8.7+
- Rubygems
- JSON
- ActiveResource

A valid API key is required to authenticate requests. You can find your API key on your customer account page.

== Installation

```
gem install whiplash_api 
```

Or if you're using Bundler:

```
gem 'whiplash_api'
```

== Configuration

To use the API client in your Ruby code, provide the required credentials as follows:

```
require 'rubygems'
require 'whiplash_api'

WhiplashApi::Base.api_key = 'XXXXXXXXXXXXX'
```
You'll likely want to start by testing in the Sandbox:

```
 WhiplashApi::Base.test = true
```

== Usage

The API currently gives you access to your Orders, Items, and OrderItems.

```
$ irb
>
> WhiplashApi::Base.api_key = 'XXXXXXXXXXXXX'
>
> items = WhiplashAPI::Item.all
>
> items = WhiplashAPI::Item.sku('SOME-SKU-111')
>
> order = WhiplashAPI::Order.last
>
> orders = WhiplashAPI::Order.all(:params => {:status => 'shipped', :created_at_min => '2008-01-01'})
>
> order_item = WhiplashAPI::OrderItem.originator(ID_IN_YOUR_STORE)
>
```

== Contributing to the Whiplash API Gem
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2012 Whiplash Merchandising/Mark Dickson. See LICENSE.txt for further details.

