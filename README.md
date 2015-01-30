# Lifft

This is just a little helper for extracting Xliff files from an Xcode project and uploding them to the GetLocalization translation service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lifft'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lifft

## Usage

    $ lifft update <the name of you GetLocalization project> --project <your.xcodeproj> -u <username> [-n (if it's new)]

    $ lifft fetch <the name of you GetLocalization project> --project <your.xcodeproj> -u <username>

## Contributing

1. Fork it ( https://github.com/BenjaminBriggs/lifft/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
