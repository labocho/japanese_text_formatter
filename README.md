# JapaneseTextFormatter

Formats Japanese plain text (includes languages that use Latin alphabets).

## Installation


    $ git clone https://github.com/labocho/japanese_text_formatter
    $ cd japanese_text_formatter
    $ rake install

## Usage

    $ echo '英文混じりの文章（ｔｅｘｔ）を､いい感じにformatします｡' | japanese-text-formatter
    英文混じりの文章 (text) を、いい感じに format します。

## Features

- Convert half-width Japanese characters to full-width.
- Convert full-width Latin characters to half-width.
- Add spaces after period, comma etc.
- Add spaces around parentheses, quotes etc.
- Add spaces between Japanese and Latin alphabet words.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/japanese_text_formatter.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

