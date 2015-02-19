module GoogleCivicInfo
  class Office
    attr_accessor :name, :level, :official_indices, :officials

    COUNTY = "county"
    FEDERAL = "federal"
    STATE = "state"
    CITY = "city"
    OTHER = "other"
    LEVELS = [FEDERAL, STATE, CITY, COUNTY, OTHER]

    def initialize(options={})
      validate_inputs!(options)
      self.name  = options[:name]
      self.level = options[:level]
      self.official_indices = Array(options[:official_indices])
      self.officials = Array(options[:officials])
    end

    private
    def validate_inputs!(options)
      if options[:level] && !LEVELS.include?(options[:level])
        raise ArgumentError.new("Level #{options.inspect} is unsupported. Must be one of #{LEVELS.join(",")}")
      end
    end
  end
end
