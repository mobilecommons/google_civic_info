module GoogleCivicInfo
  class Official
    attr_accessor :name, :phones, :emails, :channels, :photoUrl, :urls, :party, :addresses

    DEMOCRAT = "Democrat"
    REPUBLICAN = "Republican"
    INDEPENDENT = "Independent"
    NONPARTISAN = "Nonpartisan"
    UNKNOWN = "Unknown"

    PARTIES = [DEMOCRAT, REPUBLICAN, INDEPENDENT, NONPARTISAN, UNKNOWN]

    DEMOCRAT_STRINGS = %w[Democrat Democratic D Democrat/Working\ Families]
    REPUBLICAN_STRINGS = %w[Republican R]

    def initialize(options={})
      validate_inputs(options)

      self.name      = options[:name]
      self.phones    = Array(options[:phones])
      self.emails    = Array(options[:emails])
      self.channels  = Array(options[:channels])
      self.photoUrl  = options[:photoUrl]
      self.urls      = Array(options[:urls])
      self.addresses = Array(options[:addresses])
      self.party     = normalize_party(options[:party])
    end

    private
    def raise_error_for(type, argument)
      message = "#{type} expected. Got #{argument.class}: #{argument.inspect}"
      raise ArgumentError.new(message)
    end

    def check_valid_argument(klass, argument)
      raise_error_for(klass.name, argument) unless argument.is_a?(klass)
    end

    def validate_for(klass, collection)
      collection.each { |c| check_valid_argument(klass, c) }
    end

    def validate_inputs(options)
      validate_for(Address, Array(options[:addresses]))
      validate_for(Channel, Array(options[:channels]))
      validate_for(Phone, Array(options[:phones]))

      Array(options[:urls]).each do |url|
        message = "Invalid URL format #{url.inspect}"
        raise ArgumentError.new(message) unless url =~ URI::ABS_URI
      end

      if options[:party] &&
          !PARTIES.include?(normalize_party(options[:party]))

        puts "WARNING: Unknown party: '#{options.inspect}'. Continuing"
      end
    end

    def normalize_party(str)
      case str
      when *REPUBLICAN_STRINGS
        REPUBLICAN
      when *DEMOCRAT_STRINGS
        DEMOCRAT
      else
        str
      end
    end
  end
end
