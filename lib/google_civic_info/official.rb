module GoogleCivicInfo
  class Official
    attr_accessor :name, :phones, :emails, :channels, :photoUrl, :urls, :party, :addresses

    DEMOCRAT    = 'Democrat'
    REPUBLICAN  = 'Republican'
    INDEPENDENT = 'Independent'
    UNKNOWN     = 'Unknown'

    PARTIES = [
      DEMOCRAT, REPUBLICAN, INDEPENDENT, UNKNOWN
    ]

    DEMOCRAT_STRINGS   = %w[Democrat Democratic D Democrat/Working\ Families]
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

    def validate_inputs(options)
      Array(options[:addresses]).each do |address|
        raise ArgumentError.new("Address expected. Got #{address.class}: #{address.inspect}") unless address.is_a?(Address)
      end
      Array(options[:channels]).each do |channel|
        raise ArgumentError.new("Channel expected. Got #{channel.class}: #{channel.inspect}") unless channel.is_a?(Channel)
      end
      Array(options[:phones]).each do |phone|
        raise ArgumentError.new("Phone expected. Got #{phone.class}: #{phone.inspect}") unless phone.is_a?(Phone)
      end
      Array(options[:urls]).each do |url|
        raise ArgumentError.new("Invalid URL format #{url.inspect}") unless url =~ URI::ABS_URI
      end
      
      if options[:party] && !PARTIES.include?(normalize_party(options[:party]))
        puts "WARNING: Unknown party: '#{options.inspect}'. Continuing"
        # raise ArgumentError.new("Party #{options.inspect} is unsupported. Must be one of #{PARTIES.join(',')}")
      end
    end
    
    def normalize_party(str)
      case str
      when *REPUBLICAN_STRINGS then REPUBLICAN
      when *DEMOCRAT_STRINGS   then DEMOCRAT
      else str
      end
    end

  end
end