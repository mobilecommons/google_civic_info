# GoogleCivicInfo

Ruby client for Google Civic Information API https://developers.google.com/civic-information/

## Installation

Add this line to your application's Gemfile:

    gem 'google_civic_info'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_civic_info

## Usage

    your_google_api_key = 'swordfish'
    client = GoogleCivicInfo::Client.new(:api_key => your_google_api_key)
    result = client.lookup("2145 Whisper Way Reston, VA")

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
