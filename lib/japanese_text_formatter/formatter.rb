require "charwidth"

module JapaneseTextFormatter
  class Formatter
    LATIN_WORD_CHARACTER = Regexp.escape("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    CHARACTER_REQUIRES_PRECEDING_SPACE = Regexp.escape(",.;:!?")
    WRAPPER_DOES_NOT_INCLUDE_SPACE = [
      '()',
      '‘’',
      '“”',
      '"',
      '`',
      "'",
    ]
    CHARACTER_INCLUDES_PRECEDING_SPACE = Regexp.escape("「")
    CHARACTER_INCLUDES_TRAILING_SPACE = Regexp.escape("、。」")
    CHARACTER_INCLUDES_SPACE =
      CHARACTER_INCLUDES_PRECEDING_SPACE +
      CHARACTER_INCLUDES_TRAILING_SPACE
    CHARACTER_DOES_NOT_REQUIRES_PRECEDING_SPACE_AFTER_WRAPPER =
      CHARACTER_REQUIRES_PRECEDING_SPACE +
      CHARACTER_INCLUDES_SPACE
    CHARACTER_DOES_NOT_REQUIRE_SPACE_BEFORE_LATIN_WORD_CHARACTER =
      LATIN_WORD_CHARACTER +
      CHARACTER_INCLUDES_SPACE +
      Regexp.escape(WRAPPER_DOES_NOT_INCLUDE_SPACE.join)
    CHARACTER_DOES_NOT_REQUIRE_SPACE_AFTER_LATIN_WORD_CHARACTER =
      CHARACTER_DOES_NOT_REQUIRE_SPACE_BEFORE_LATIN_WORD_CHARACTER +
      CHARACTER_REQUIRES_PRECEDING_SPACE

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
      # add space after , etc.
      text.gsub!(Regexp.compile('([' + CHARACTER_REQUIRES_PRECEDING_SPACE + '])([^\s])', '\1 \2'))
      # add spaces around () etc.
      WRAPPER_DOES_NOT_INCLUDE_SPACE.each do |wrapper|
        add_space_around_wrapper(text, wrapper)
      end
      # strip unnecessary spaces
      text.gsub!(/  +/, " ")
      # strip trailing spaces
      text.gsub!(/ +$/, "")
      text
    end

    def add_space_between_japanese_and_latin!(text)
      text.gsub!(Regexp.compile('([^\s' + CHARACTER_DOES_NOT_REQUIRE_SPACE_BEFORE_LATIN_WORD_CHARACTER + '])([' + LATIN_WORD_CHARACTER + '])'), '\1 \2')
      text.gsub!(Regexp.compile('(['+ LATIN_WORD_CHARACTER + '])([^\s' + CHARACTER_DOES_NOT_REQUIRE_SPACE_AFTER_LATIN_WORD_CHARACTER + '])'), '\1 \2')
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
        # '" .' -> '".'
        text.gsub!(Regexp.compile(w + ' ([' + CHARACTER_DOES_NOT_REQUIRES_PRECEDING_SPACE_AFTER_WRAPPER + '])'), w + '\1')
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

        text.gsub!(Regexp.compile(pattern), ' \k<wrap> ')
        # ') .' -> ').'
        text.gsub!(Regexp.compile(Regexp.escape(e) + ' ([' + CHARACTER_DOES_NOT_REQUIRES_PRECEDING_SPACE_AFTER_WRAPPER + '])'), e + '\1')
        text
      else
        raise ArgumentError
      end
    end
  end
end
