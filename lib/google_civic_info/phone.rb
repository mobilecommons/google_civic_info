module GoogleCivicInfo
  class Phone
    # just store the formatted string they give us.
    # alternatively, extract and store raw number and pretty print output
    attr_accessor :number

    def initialize(options={})
      self.number = options[:number] || options["number"]
    end

    def to_s
      number
    end

    def digits
      number.gsub(/[^\d]/,"")
    end
  end
end
