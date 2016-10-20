require "charwidth"

module JapaneseTextFormatter
  class Formatter
    attr_reader :options

    def self.default_options
      { normalize_charwidth: true,
        format_latin_text: true,
        add_space_between_japanese_and_latin: true,
      }
    end

    def initialize(options = {})
      @options = self.class.default_options.merge(options)
    end

    def format(text)
      text = text.dup

      normalize_charwidth!(text) if options[:normalize_charwidth]
      format_latin_text!(text) if options[:format_latin_text]
      add_space_between_japanese_and_latin!(text) if options[:add_space_between_japanese_and_latin]

      text
    end

    private
    def normalize_charwidth!(text)
      Charwidth.normalize!(text)
    end

    def format_latin_text!(text)
      text.gsub!(/([,\.;:\!\?」])([^\s])/, '\1 \2') # add space after , etc.
      add_space_around_wrapper(text, '()')
      add_space_around_wrapper(text, '‘’')
      add_space_around_wrapper(text, '“”')
      add_space_around_wrapper(text, '"')
      add_space_around_wrapper(text, '`')
      text.gsub!(/  +/, " ")
      text.gsub!(/ +$/, "")
      text
    end

    def add_space_between_japanese_and_latin!(text)
      text.gsub!(/([^\sa-zA-Z0-9\(、。「」])([a-zA-Z0-9])/, '\1 \2')
      text.gsub!(/([a-zA-Z0-9])([^\sa-zA-Z0-9\)、。「」,\.\!\?:;])/, '\1 \2')
      text
    end

    def add_space_around_wrapper(text, wrapper)
      case wrapper.length
      when 1
        w = Regexp.escape(wrapper)
        pattern = [
          w,
          '[^' + w + ']*?',
          w,
        ].join

        text.gsub!(Regexp.compile(pattern), ' \0 ')
        text
      when 2
        s, e = wrapper.each_char.to_a

        pattern = [
          '(?<wrap>',
            Regexp.escape(s),
              '(?:',
                '[^' + [s, e].uniq.join + ']',
                '|',
                '\g<wrap>',
              ')*',
            Regexp.escape(e),
          ')',
        ].join

        text.gsub!(Regexp.compile(pattern), ' \k<wrap>')
        text
      else
        raise ArgumentError
      end
    end
  end
end
