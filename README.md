lita-onewheel-loggly
--------------------

[![Build Status](https://travis-ci.org/onewheelskyward/lita-onewheel-loggly.png?branch=master)](https://travis-ci.org/onewheelskyward/lita-onewheel-loggly)
[![Coverage Status](https://coveralls.io/repos/onewheelskyward/lita-onewheel-loggly/badge.png)](https://coveralls.io/r/onewheelskyward/lita-onewheel-loggly)

TODO: Add a description of the plugin.

Installation
------------
Add lita-onewheel-loggly to your Lita instance's Gemfile:

``` ruby
gem "lita-onewheel-loggly"
```

Configuration
-------------
```
Lita.configure do |config|
  config.handlers.onewheel_loggly.api_key = 'insert key here'
  config.handlers.onewheel_loggly.base_uri = 'eh'
  config.handlers.onewheel_loggly.query = 'medium'
end
```

Usage
-----

Well, firstly, Google's API explorer can be a little trick.


Going Forward
-------------

I'm going to implement postgres and make sure I can track everything I want to track.  Testing the limits of the api calls since I get so few.
