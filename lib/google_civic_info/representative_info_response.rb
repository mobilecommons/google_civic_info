module GoogleCivicInfo
  class RepresentativeInfoResponse
    attr_accessor :divisions, :response, :normalized_input

    def initialize(options={})
      self.response = options[:response]
      self.divisions = options[:divisions] || divisions_from_google
    end

    def normalized_input
      response["normalizedInput"] if response
    end

    private
    def divisions_from_google
      return unless response

      divisions = response["divisions"].map do |ocd_division_id, details|
        division = division_from(ocd_division_id, details)

        division.office_indices.each do |office_index|
          division.offices << office_from(response["offices"][office_index])
        end

        division
      end
    end

    def division_from(ocd_division_id, attributes)
      attributes[:ocd_division_id] = ocd_division_id
      attributes[:office_indices] = attributes.delete("officeIndices")
      new_attributes = {}
      attributes.each_pair { |k, v| new_attributes[k.to_sym] = v }

      Division.new new_attributes
    end

    def office_from(data)
      office = Office.new(:name =>data["name"],
                          :level => data["level"],
                          :levels => data["levels"],
                          :roles => data["roles"],
                          :official_indices => data["officialIndices"])

      office.official_indices.each do |official_index|
        office.officials << official_from(response["officials"][official_index])
      end

      office
    end

    def official_from(data)
      Official.new(:name => data["name"],
                   :emails => data["emails"],
                   :photoUrl => data["photoUrl"],
                   :urls => data["urls"],
                   :party => data["party"],
                   :addresses => addresses_from(data),
                   :channels => channels_from(data),
                   :phones => phones_from(data))
    end

    def addresses_from(data)
      (data["address"] || []).map do |args|
        Address.new(:locationName => args["locationName"],
                    :line1 => args["line1"],
                    :line2 => args["line2"],
                    :line3 => args["line3"],
                    :city => args["city"],
                    :state => args["state"],
                    :zip => args["zip"])
      end
    end

    def channels_from(data)
      (data["channels"] || []).map do |args|
        Channel.new(:id => args["id"], :type => args["type"])
      end
    end

    def phones_from(data)
      Array(data["phones"]).map { |number| Phone.new(:number => number) }
    end
  end
end
