require 'net/https'
require 'zlib'
require 'json'
module GoogleCivicInfo
  class Client
    attr_accessor :api_key

    CIVIC_INFO_BASE_URL = "https://www.googleapis.com/civicinfo/us_v1"
    REPRESENTATIVES_URL = "#{CIVIC_INFO_BASE_URL}/representatives"
    ELECTION_URL        = "#{CIVIC_INFO_BASE_URL}/elections"
    VOTER_INFO_URL      = "#{CIVIC_INFO_BASE_URL}/voterinfo"

    def initialize(options={})
      @api_key = options[:api_key] || raise(ArgumentError.new("You must provide a Google API key"))
    end

    #TODO :includeOffices=>true/false
    def lookup(address, options={})
      response = JSON.parse( http_request(address, options) )
      if response['status'] == SUCCESS
        GoogleCivicInfo::RepresentativeInfoResponse.from_google_response(response)
      else
        process_error_response!(response)
      end
    end

  private

    def http_request(address, options={})
      request  = Net::HTTP::Post.new("#{REPRESENTATIVES_URL}/lookup?key=#{@api_key}", {"Accept-Encoding" => "gzip", "User-Agent"=>'GoogleCivicInfo.rb (gzip)'})
       request['Content-Type'] = "application/json"
       request.body = {'address'=>address}.to_json

       http = Net::HTTP.new('www.googleapis.com', 443)
       http.use_ssl     = true
       http.verify_mode = OpenSSL::SSL::VERIFY_NONE
       http.start do |post|
         response = post.request(request)
         if response['Content-Encoding'] == 'gzip'
           Zlib::GzipReader.new( StringIO.new( response.body ) ).read
         else
           response.body
         end
       end
    end

    SUCCESS                        = 'success'
    ADDRESS_UNPARSEABLE            = 'addressUnparseable'
    NO_ADDRESS_PARAMETER           = 'noAddressParameter'
    INTERNAL_LOOKUP_FAILURE        = 'internalLookupFailure'
    NO_STREET_SEGMENT_FOUND        = 'noStreetSegmentFound'
    MULTIPLE_STREET_SEGMENTS_FOUND = 'multipleStreetSegmentsFound'
    KEY_INVALID                    = 'keyInvalid'
    BACKEND_ERROR                  = 'backendError'

    def process_error_response!(response)
      if response['error']
        case response['error']['errors'].first["reason"]
        when KEY_INVALID   then raise InvalidApiKey.new(response['error']['errors'].inspect)
        else raise "Unknown Google error: #{response['error'].inspect}"
        end
      elsif response['code'] #503
        case response['errors'].first["reason"]
        when BACKEND_ERROR then raise BackendError.new(response['errors'].inspect)
        else raise "Unknown Google reason: #{response.inspect}"
        end
      else
        case response['status']
        when SUCCESS #noop
        when NO_ADDRESS_PARAMETER           then raise NoAddressParameter.new
        when NO_STREET_SEGMENT_FOUND        then raise NoStreetSegmentFoundException.new
        when ADDRESS_UNPARSEABLE            then raise AddressUnparseableException.new
        when MULTIPLE_STREET_SEGMENTS_FOUND then raise MultipleStreetSegmentsFoundException.new
        when INTERNAL_LOOKUP_FAILURE        then raise InternalLookupFailureException.new
        else raise "Unknown Google status: #{response['status']}"
        end
      end
    end
  end
end

