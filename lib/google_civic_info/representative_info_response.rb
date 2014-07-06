module GoogleCivicInfo
  class RepresentativeInfoResponse
    attr_accessor :divisions

    def initialize(options={})
      self.divisions = options[:divisions]
    end

    def self.from_google_response(response)
      divisions = response['divisions'].map do |ocd_division_id, details|
        division = Division.new(:name=>details['name'], :scope=>details['scope'], :office_ids=>details['officeIds'], :ocd_division_id=>ocd_division_id)
        division.offices = (details['officeIds'] || []).map do |office_id|
          details = response['offices'][office_id]
          office = Office.new :name=>details['name'], :level=>details['level'], :official_ids=>details['officialIds']
          office.officials = details['officialIds'].map do |official_id|
            details   = response['officials'][official_id]
            addresses = (details['address'] ||[]).map{|args| Address.new(:locationName=>args['locationName'], :line1=>args['line1'], :line2=>args['line2'], :line3=>args['line3'], :city=>args['city'], :state=>args['state'], :zip=>args['zip'])}
            channels  = (details['channels']||[]).map{|args| Channel.new(:id=>args['id'], :type=>args['type'])}
            phones    = (details['phones']  ||[]).map{|args| Phone.new(:number=>args['number'])}
            official  = Official.new( :name=>details['name'], :phones=>phones, :emails=>details['emails'], :channels=>channels, :photoUrl=>details['photoUrl'], :urls=>details['urls'], :party=>details['party'],
  :address=>addresses)
          end
          office
        end
        division
      end

      self.new(:divisions=>divisions)
    end

  end
end