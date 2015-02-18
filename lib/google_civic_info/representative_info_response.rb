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

        division.office_ids.each do |office_id|
          division.offices << office_from(response["offices"][office_id])
        end

        division
      end
    end

    def division_from(ocd_division_id, attributes)
      attributes[:ocd_division_id] = ocd_division_id
      attributes[:office_ids] = attributes.delete("officeIds")
      new_attributes = {}
      attributes.each_pair { |k, v| new_attributes[k.to_sym] = v }

      Division.new new_attributes
    end

    def office_from(data)
      office = Office.new(:name =>data["name"],
                          :level => data["level"],
                          :official_ids => data["officialIds"])

      office.official_ids.each do |official_id|
        office.officials << official_from(response["officials"][official_id])
      end

      office
    end

    def official_from(data)
      Official.new(:name => data["name"],
                   :emails => data["emails"],
                   :photoUrl => data["photoUrl"],
                   :urls => data["urls"],
                   :party => data["party"],
                   :address => addresses_from(data),
                   :channels => channels_from(data),
                   :nphones => phones_from(data))
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
      (data["phones"] || []).map{|args| Phone.new(:number => args["number"])}
    end
  end
end
