require "google_civic_info"
require 'google_civic_info/exceptions'
require "spec_helper"

describe GoogleCivicInfo::Client do

  describe "validation" do
    it "should require an API key" do
      expect{ GoogleCivicInfo::Client.new }.to raise_error(ArgumentError)
    end
  end

  describe "error processing" do
    before do
      @client = GoogleCivicInfo::Client.new(:api_key=>'fakeout')
    end
  
    it "should raise with a bad API key" do
      @client.stub(:http_request).and_return(bad_api_key_response)
      expect{ @client.lookup("2145 Whisper Way Reston, VA") }.to raise_error(GoogleCivicInfo::InvalidApiKey)
    end

    it "should raise with a bad API key" do
      @client.stub(:http_request).and_return(no_address_parameter_response)
      expect{ @client.lookup("") }.to raise_error(GoogleCivicInfo::NoAddressParameter)
    end
    
    it "should raise if Google server error" do
      @client.stub(:http_request).and_return(backend_error_response)
      expect{ @client.lookup("2145 Whisper Way Reston, VA") }.to raise_error(GoogleCivicInfo::BackendError)
    end
    
  end
  
  describe "processing Google responses" do
    it "should create a proper RepresentativeInfoResponse from Google JSON blob" do
      r = GoogleCivicInfo::RepresentativeInfoResponse.from_google_response(JSON.parse(successful_json_response_1))
      r.divisions.size.should == 7
      division = r.divisions.find{|division| division.ocd_division_id == "ocd-division/country:us/state:va"}
      division.offices.size.should == 5
      office = division.offices.first
      office.name.should == "Governor"
      office.officials.size.should == 1
      official = office.officials.first
      official.name.should == "Robert F. McDonnell"
      official.urls.should == ["http://www.governor.virginia.gov/"]
      official.channels.map{|c|c.url}.should == ["https://www.facebook.com/profile.php?id=61634046094", "https://twitter.com/GovernorVA"]
    end
  end
  
  describe "representative lookup, making actual HTTP requests" do
    before do
      pending "These specs make actual HTTP requests. To call them, comment this line out and set environment variable GOOGLE_API_KEY="
      @your_api_key = ENV['GOOGLE_API_KEY'] || "your-api-key"
      @client = GoogleCivicInfo::Client.new(:api_key=>@your_api_key)
    end
    
    it "should return a correct result" do
      result = @client.lookup("2145 Whisper Way Reston, VA")
      result.should be_a(GoogleCivicInfo::RepresentativeInfoResponse)
      result.divisions.size.should == 7
    end
    
    ADDRESSES = [
    #   "3300 Rivermont Ave, Lynchburg, VA 24503",
    #   "211 E 3rd St, Farmville, VA 23901",
    #   "4707 Valley View Blvd NW, Roanoke, VA 24012",
    #   "7015 Old Keene Mill Rd, Springfield, VA 22150",
    #   "700J N Main St, Blacksburg, VA 24060",
    #   "8190 Meadowbridge Rd, Mechanicsville, VA 23116",
    #   "975 Hilton Heights Rd, Charlottesville, VA 22901",
    #   "12805 Fair Lakes Pkwy, Fairfax, VA 22033",
    #   "21100 Dulles Town Cir Ste 186, Sterling, VA 20166",
    #   "11620 Monument Dr, Fairfax, VA 22030"
    ]
    ADDRESSES.each do |address|
      it "should return for #{address}" do
        result = @client.lookup(address)
        puts result.inspect
      end
    end
    
    it "should raise AddressUnparseableException" do
      expect{@client.lookup('rocklobster')}.to raise_error(GoogleCivicInfo::AddressUnparseableException) 
    end

    it "should raise AddressUnparseableException" do
      expect{@client.lookup('')}.to raise_error(GoogleCivicInfo::NoAddressParameter) 
    end
    
  end
  
end

def bad_api_key_response
  {"error"=>{"message"=>"Bad Request", "code"=>400, "errors"=>[{"message"=>"Bad Request", "domain"=>"usageLimits", "reason"=>"keyInvalid"}]}}.to_json
end

def no_address_parameter_response
  {"status"=>"noAddressParameter", "kind"=>"civicinfo#representativeInfoResponse"}.to_json
end

def backend_error_response
  {"code"=>503, "errors"=>[{"reason"=>"backendError", "domain"=>"global", "message"=>"Backend Error"}], "message"=>"Backend Error"}.to_json
end

def successful_json_response_1
  {"offices"=>
    {"O0"=>
      {"name"=>"VA State House of Delegates - District 036",
       "level"=>"state",
       "officialIds"=>["P0"]},
     "O1"=>
      {"name"=>"VA State Senate - District 32",
       "level"=>"state",
       "officialIds"=>["P1"]},
     "O2"=>
      {"name"=>"United States House of Representatives - District 11",
       "level"=>"federal",
       "officialIds"=>["P2"]},
     "O3"=>{"name"=>"Governor", "level"=>"state", "officialIds"=>["P3"]},
     "O4"=>
      {"name"=>"Lietuenant Governor", "level"=>"state", "officialIds"=>["P4"]},
     "O5"=>{"name"=>"Attorney General", "level"=>"state", "officialIds"=>["P5"]},
     "O6"=>
      {"name"=>"United States Senate",
       "level"=>"federal",
       "officialIds"=>["P6"]},
     "O7"=>
      {"name"=>"United States Senate",
       "level"=>"federal",
       "officialIds"=>["P7"]},
     "O8"=>{"name"=>"President", "level"=>"federal", "officialIds"=>["P8"]},
     "O9"=>{"name"=>"Vice President", "level"=>"federal", "officialIds"=>["P9"]},
     "Oa"=>
      {"name"=>"Clerk of the Circuit Court",
       "level"=>"county",
       "officialIds"=>["P10"]},
     "Ob"=>
      {"name"=>"Supervisor, District At-Large",
       "level"=>"county",
       "officialIds"=>["P11"]},
     "Oc"=>
      {"name"=>"Commonwealth's Attorney",
       "level"=>"county",
       "officialIds"=>["P12"]},
     "Od"=>{"name"=>"Sheriff", "level"=>"county", "officialIds"=>["P13"]},
     "Oe"=>
      {"name"=>"Supervisor, District Hunter Mill",
       "level"=>"county",
       "officialIds"=>["P14"]}},
   "status"=>"success",
   "kind"=>"civicinfo#representativeInfoResponse",
   "divisions"=>
    {"ocd-division/country:us/state:va"=>
      {"scope"=>"statewide",
       "name"=>"Virginia",
       "officeIds"=>["O3", "O4", "O5", "O6", "O7"]},
     "ocd-division/country:us/state:va/county:fairfax"=>
      {"scope"=>"countywide",
       "name"=>"Fairfax County",
       "officeIds"=>["Oa", "Ob", "Oc", "Od"]},
     "ocd-division/country:us/state:va/sldl:36"=>
      {"scope"=>"stateLower",
       "name"=>"Virginia House of Delegates district 36",
       "officeIds"=>["O0"]},
     "ocd-division/country:us/state:va/cd:11"=>
      {"scope"=>"congressional",
       "name"=>"Virginia's 11th congressional district",
       "officeIds"=>["O2"]},
     "ocd-division/country:us/state:va/county:fairfax/council_district:hunter_mill"=>
      {"name"=>"Fairfax County VA supervisor Hunter Mill district",
       "officeIds"=>["Oe"]},
     "ocd-division/country:us"=>
      {"scope"=>"national", "name"=>"United States", "officeIds"=>["O8", "O9"]},
     "ocd-division/country:us/state:va/sldu:32"=>
      {"scope"=>"stateUpper",
       "name"=>"Virginia State Senate district 32",
       "officeIds"=>["O1"]}},
   "normalizedInput"=>
    {"line1"=>"2145 Whisper Way",
     "zip"=>"20191",
     "city"=>"Reston",
     "state"=>"VA"},
   "officials"=>
    {"P10"=>
      {"name"=>"John T. Frey", "phones"=>["(703) 246-4111"], "party"=>"Unknown"},
     "P11"=>
      {"emails"=>["chairman@fairfaxcounty.gov"],
       "name"=>"Sharon Bulova",
       "urls"=>["http://www.fairfaxcounty.gov/chairman"],
       "phones"=>["(703) 324-2321"],
       "party"=>"Democratic"},
     "P12"=>
      {"name"=>"Raymond F. Morrogh",
       "urls"=>
        ["http://www.fairfaxcounty.gov/contact/AgencyDetail.aspx?agId=82"],
       "phones"=>["(703) 246-2776"],
       "party"=>"Democratic"},
     "P13"=>
      {"emails"=>["sheriff@fairfaxcounty.gov"],
       "name"=>"S. G. Barry",
       "channels"=>[{"id"=>"fairfaxcountysheriff", "type"=>"Facebook"}],
       "urls"=>["http://www.fairfaxcounty.gov/sheriff/"],
       "phones"=>["(703) 691-2131"],
       "party"=>"Democratic"},
     "P14"=>
      {"emails"=>["hntrmill@fairfaxcounty.gov"],
       "name"=>"Catherine M. Hudgins",
       "urls"=>["http://www.fairfaxcounty.gov/huntermill"],
       "phones"=>["(703) 478-0283"],
       "party"=>"Democratic"},
     "P0"=>
      {"emails"=>["DelKPlum@house.virginia.gov"],
       "name"=>"Kenneth R. Plum",
       "channels"=>[{"id"=>"kenneth.plum", "type"=>"Facebook"}],
       "urls"=>
        ["http://dela.state.va.us/dela/MemBios.nsf/a7b082ef6ed01eac85256c0d00515644/a224f842f65c497a85257b64004568f9?OpenDocument"],
       "phones"=>["(703) 758-9733"],
       "party"=>"Democratic"},
     "P1"=>
      {"emails"=>["district32@senate.virginia.gov"],
       "name"=>"Janet D. Howell",
       "channels"=>[{"id"=>"senatorhowell", "type"=>"Facebook"}],
       "urls"=>
        ["http://apps.lis.virginia.gov/sfb1/Senate/senatorwebprofile.aspx?id=270"],
       "phones"=>["(703) 709-8283"],
       "party"=>"Democratic"},
     "P2"=>
      {"name"=>"Gerald E. \"Gerry\" Connolly",
       "channels"=>
        [{"id"=>"CongressmanGerryConnolly", "type"=>"Facebook"},
         {"id"=>"GerryConnolly", "type"=>"Twitter"}],
       "urls"=>["http://connolly.house.gov/"],
       "phones"=>["(202) 225-1492"],
       "party"=>"Democratic"},
     "P3"=>
      {"name"=>"Robert F. McDonnell",
       "channels"=>
        [{"id"=>"61634046094", "type"=>"Facebook"},
         {"id"=>"GovernorVA", "type"=>"Twitter"}],
       "urls"=>["http://www.governor.virginia.gov/"],
       "phones"=>["(804) 786-2211"],
       "party"=>"Republican"},
     "P4"=>
      {"emails"=>["tgov@ltgov.virginia.gov"],
       "name"=>"William T. Bolling",
       "channels"=>
        [{"id"=>"bollingva", "type"=>"Facebook"},
         {"id"=>"lgbillbolling", "type"=>"Twitter"}],
       "urls"=>["http://www.ltgov.virginia.gov/"],
       "phones"=>["(804) 692-0007"],
       "party"=>"Republican"},
     "P5"=>
      {"name"=>"Kenneth T. Cuccinelli II",
       "channels"=>
        [{"id"=>"AGVirginia", "type"=>"Facebook"},
         {"id"=>"AGCuccinelli", "type"=>"Twitter"}],
       "urls"=>["http://www.vaag.virginia.gov"],
       "phones"=>["(804) 786-2071"],
       "party"=>"Republican"},
     "P6"=>
      {"name"=>"Mark R. Warner",
       "channels"=>
        [{"id"=>"MarkRWarner", "type"=>"Facebook"},
         {"id"=>"MarkWarner", "type"=>"Twitter"}],
       "urls"=>["http://warner.senate.gov/"],
       "phones"=>["(202) 224-2023"],
       "party"=>"Democratic"},
     "P7"=>
      {"name"=>"Tim Kaine",
       "channels"=>
        [{"id"=>"SenatorKaine", "type"=>"Facebook"},
         {"id"=>"SenKaineOffice", "type"=>"Twitter"}],
       "urls"=>["http://kaine.senate.gov/"],
       "phones"=>["(202) 224-4024"],
       "party"=>"Democratic"},
     "P8"=>
      {"name"=>"Barack Hussein Obama II",
       "address"=>
        [{"line1"=>"The White House",
          "line2"=>"1600 Pennsylvania Avenue NW",
          "line3"=>"",
          "zip"=>"20500",
          "city"=>"Washington",
          "state"=>"DC"}],
       "channels"=>
        [{"id"=>"barackobama", "type"=>"Facebook"},
         {"id"=>"barackobama", "type"=>"YouTube"},
         {"id"=>"barackobama", "type"=>"Twitter"},
         {"id"=>"110031535020051778989", "type"=>"GooglePlus"}],
       "photoUrl"=>
        "http://www.whitehouse.gov/sites/default/files/imagecache/admin_official_lowres/administration-official/ao_image/president_official_portrait_hires.jpg",
       "urls"=>
        ["http://www.whitehouse.gov/administration/president_obama/",
         "http://www.barackobama.com/index.php"],
       "phones"=>["(202) 456-1111", "(202) 456-1414"],
       "party"=>"Democrat"},
     "P9"=>
      {"name"=>"Joseph (Joe) Robinette Biden Jr.",
       "address"=>
        [{"line1"=>"The White House",
          "line2"=>"1600 Pennsylvania Avenue NW",
          "line3"=>"",
          "zip"=>"20500",
          "city"=>"Washington",
          "state"=>"DC"}],
       "channels"=>
        [{"id"=>"JoeBiden", "type"=>"Twitter"},
         {"id"=>"joebiden", "type"=>"Facebook"},
         {"id"=>"VP", "type"=>"Twitter"}],
       "photoUrl"=>
        "http://www.whitehouse.gov/sites/default/files/imagecache/admin_official_lowres/administration-official/ao_image/vp_portrait.jpeg",
       "urls"=>["http://www.whitehouse.gov/administration/vice-president-biden"],
       "party"=>"Democrat"}}}.to_json
  end