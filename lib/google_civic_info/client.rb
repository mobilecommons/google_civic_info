require "net/https"
require "zlib"
require "json"

module GoogleCivicInfo
  class Client
    attr_accessor :api_key

    CIVIC_INFO_BASE_URL = "https://www.googleapis.com/civicinfo/v2"
    REPRESENTATIVES_URL = "#{CIVIC_INFO_BASE_URL}/representatives"
    ELECTION_URL = "#{CIVIC_INFO_BASE_URL}/elections"
    VOTER_INFO_URL = "#{CIVIC_INFO_BASE_URL}/voterinfo"

    def initialize(options={})
      @api_key = options[:api_key] ||
        raise(ArgumentError.new("You must provide a Google API key"))
    end

    # TODO :includeOffices=>true/false
    def lookup(address, options={})
      response = JSON.parse(http_request(address, options))

      if response["error"]
        process_error_response!(response)
      else
        GoogleCivicInfo::RepresentativeInfoResponse.new(:response => response)
      end
    end

    private
    def request_from(address)
      url = "#{REPRESENTATIVES_URL}?key=#{api_key}&address=#{CGI.escape(address)}"
      headers = { "Accept-Encoding" => "gzip",
        "User-Agent" => "GoogleCivicInfo.rb (gzip)" }

      Net::HTTP::Get.new(url, headers)
    end

    def http
      http = Net::HTTP.new("www.googleapis.com", 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def http_request(address, options={})
      http.start do |get|
        response = get.request(request_from(address))
        if response["Content-Encoding"] == "gzip"
          Zlib::GzipReader.new(StringIO.new(response.body)).read
        else
          response.body
        end
      end
    end

    def process_error_response!(response)
      message = String.new

      # chances are there is only one error, but we handle multiples anyway
      response["error"]["errors"].each do |error|
        message << "Code: #{response["error"]["code"]} "
        message << "Reason: #{error["reason"]} "
        message << "Message: #{error["message"]}\n"
      end

      raise APIError, message
    end
  end
end
