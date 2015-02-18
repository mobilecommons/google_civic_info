module GoogleCivicInfo
  class Division
    attr_accessor :name, :scope, :office_ids, :ocd_division_id, :offices

    NATIONAL = "national"
    STATEWIDE = "statewide"
    CONGRESSIONAL = "congressional"
    STATE_UPPER = "stateUpper"
    STATE_LOWER = "stateLower"
    COUNTYWIDE = "countywide"
    JUDICIAL = "judicial"
    SCHOOL_BOARD = "schoolBoard"
    CITY_WIDE = "citywide"
    TOWNSHIP = "township"
    COUNTY_COUNCIL = "countyCouncil"
    CITY_COUNCIL = "cityCouncil"
    WARD = "ward"
    SPECIAL = "special"

    SCOPES = [NATIONAL, STATEWIDE, CONGRESSIONAL, STATE_UPPER, STATE_LOWER,
              COUNTYWIDE, JUDICIAL, SCHOOL_BOARD, CITY_WIDE, TOWNSHIP,
              COUNTY_COUNCIL,CITY_COUNCIL,WARD,SPECIAL]

    def initialize(options={})
      validate_inputs!(options)
      self.ocd_division_id = options[:ocd_division_id]
      self.name = options[:name]
      self.scope = options[:scope]
      self.office_ids = Array(options[:office_ids])
      self.offices = Array(options[:offices])
    end

    private
    def validate_inputs!(options)
      if options[:scope] && !SCOPES.include?(options[:scope])
        raise ArgumentError.new("Scope #{options.inspect} is unsupported. Must be one of #{SCOPES.join(",")}")
      end
    end
  end
end
