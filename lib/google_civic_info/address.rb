module GoogleCivicInfo
  class Address
    attr_accessor :locationName, :line1, :line2, :line3, :city, :state, :zip

    def initialize(options={})
      self.locationName = options[:locationName]
      self.line1 = options[:line1]  
      self.line2 = options[:line2]  
      self.line3 = options[:line3]  
      self.city  = options[:city]   
      self.state = options[:state]  
      self.zip   = options[:zip]    
    end

    def to_s
      "#{line1} #{line2} #{line3} #{city} #{state} #{zip}"
    end
  
    def pretty_print
      "#{line1}\n#{line2}\n#{line3}\n#{city} #{state} #{zip}"
    end
  
  end
end