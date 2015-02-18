module GoogleCivicInfo
  class Channel
    attr_accessor :id, :type
    FACEBOOK = "Facebook"
    GOOGLE_PLUS = "GooglePlus"
    TWITTER = "Twitter"
    YOU_TUBE = "YouTube"
    TYPES = [FACEBOOK, GOOGLE_PLUS, TWITTER, YOU_TUBE]

    def initialize(options={})
      validate_inputs!(options)
      self.id = options[:id]
      self.type = options[:type]
    end

    def url
      case type
      when TWITTER
        "https://twitter.com/#{id}"
      when FACEBOOK
        "https://www.facebook.com/profile.php?id=#{id}"
      when GOOGLE_PLUS
        "https://plus.google.com/#{id}"
      when YOU_TUBE
        "http://www.youtube.com/#{id}"
      end
    end

    private
    def validate_inputs!(options)
      if options[:type] && !TYPES.include?(options[:type])
        raise ArgumentError.new("Type #{options.inspect} is unsupported. Must be one of #{TYPES.join(",")}")
      end
    end
  end
end
