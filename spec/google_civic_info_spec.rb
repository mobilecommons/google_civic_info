require "google_civic_info"
require "google_civic_info/exceptions"
require "spec_helper"

describe GoogleCivicInfo::Client do

  describe "validation" do
    it "should require an API key" do
      expect{ GoogleCivicInfo::Client.new }.to raise_error(ArgumentError)
    end
  end

  describe "error processing" do
    before do
      @client = GoogleCivicInfo::Client.new(:api_key=>"fakeout")
    end

    it "should raise with a bad API key" do
      @client.stub(:http_request).and_return(bad_api_key_response)
      expect{ @client.lookup("2145 Whisper Way Reston, VA") }.
        to raise_error(GoogleCivicInfo::APIError)
    end

    it "should raise if Google server error" do
      @client.stub(:http_request).and_return(backend_error_response)
      expect{ @client.lookup("2145 Whisper Way Reston, VA") }
        .to raise_error(GoogleCivicInfo::APIError)
    end
  end

  describe "processing Google responses" do
    let(:r) { GoogleCivicInfo::RepresentativeInfoResponse.new(:response=>JSON.parse(successful_json_response_1)) }

    it "should create a proper RepresentativeInfoResponse from Google JSON blob" do
      r.divisions.size.should == 7
      division = r.divisions.find { |division| division.ocd_division_id == "ocd-division/country:us/state:va" }
      division.offices.size.should == 4
      office = division.offices[1]
      office.name.should == "Governor"
      office.levels.first.should == "administrativeArea1"
      office.roles.first.should == "headOfGovernment"
      office.officials.size.should == 1
      official = office.officials.first
      official.name.should == "Terry McAuliffe"
      official.party.should == "Democrat"
      official.urls.should == ["http://www.governor.virginia.gov/"]
      official.channels.map { |c| c.url }.should == ["https://www.facebook.com/profile.php?id=61634046094", "https://twitter.com/GovernorVA"]
      official.addresses.first.to_s.squeeze("  ").should == "1111 east broad street richmond VA 23219"
      official.phones.first.to_s.should == "(804) 786-2211"
    end

    describe "#normalized_input" do
      it "returns lookup input split into its parts" do
        normalized_input = { "line1" => "2145 whisper way",
          "zip" => "20191",
          "city" => "reston",
          "state" => "VA" }

        r.normalized_input.should == normalized_input
      end
    end
  end

  describe "representative lookup, making actual HTTP requests" do
    before do
      unless ENV["GOOGLE_API_KEY"]
        pending "These specs make actual HTTP requests. To call them set environment variable GOOGLE_API_KEY="
      end

      @your_api_key = ENV["GOOGLE_API_KEY"] || "your-api-key"
      @client = GoogleCivicInfo::Client.new(:api_key => @your_api_key)
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

    it "a badly formed address should raise APIError " do
      expect{@client.lookup("&$*!?_")}.to raise_error(GoogleCivicInfo::APIError)
    end

    it "an empty address should raise APIError" do
      expect{@client.lookup("")}.to raise_error(GoogleCivicInfo::APIError)
    end

  end

end

def bad_api_key_response
  { "error" => {
      "message" => "Bad Request",
      "code" => 400,
      "errors" => [{ "message" => "Bad Request",
                     "domain" => "usageLimits",
                     "reason" => "keyInvalid" }]
    }
  }.to_json
end

def backend_error_response
  { "error" =>
    { "code" => 503,
      "errors" => [{ "reason" => "backendError",
                     "domain" => "global",
                     "message"=> "Backend Error" }],
      "message" => "Backend Error"
    }
  }.to_json
end

def successful_json_response_1
  {"kind"=>"civicinfo#representativeInfoResponse",
    "normalizedInput"=>{"line1"=>"2145 whisper way",
      "city"=>"reston",
      "state"=>"VA",
      "zip"=>"20191"},
    "divisions"=>{"ocd-division/country:us/state:va/sldl:36"=>{"name"=>"Virginia State House district 36",
        "officeIndices"=>[4]},
      "ocd-division/country:us/state:va/cd:11"=>{"name"=>"Virginia's 11th congressional district",
        "officeIndices"=>[0]},
      "ocd-division/country:us/state:va/sldu:32"=>{"name"=>"Virginia State Senate district 32",
        "officeIndices"=>[5]},
      "ocd-division/country:us/state:va"=>{"name"=>"Virginia",
        "officeIndices"=>[1, 6, 7, 8]},
      "ocd-division/country:us"=>{"name"=>"United States",
        "officeIndices"=>[2, 3]},
      "ocd-division/country:us/state:va/county:fairfax"=>{"name"=>"Fairfax County",
        "officeIndices"=>[9, 10, 11, 12]},
      "ocd-division/country:us/state:va/county:fairfax/council_district:hunter_mill"=>{"name"=>"Fairfax County VA supervisor Hunter Mill district",
        "officeIndices"=>[13]}},
    "offices"=>[{"name"=>"United States House of Representatives VA-11",
                  "divisionId"=>"ocd-division/country:us/state:va/cd:11",
                  "levels"=>["country"],
                  "roles"=>["legislatorLowerBody"],
                  "officialIndices"=>[0]},
                {"name"=>"United States Senate",
                  "divisionId"=>"ocd-division/country:us/state:va",
                  "levels"=>["country"],
                  "roles"=>["legislatorUpperBody"],
                  "officialIndices"=>[1, 2]},
                {"name"=>"President of the United States",
                  "divisionId"=>"ocd-division/country:us",
                  "levels"=>["country"],
                  "roles"=>["headOfState", "headOfGovernment"],
                  "officialIndices"=>[3]},
                {"name"=>"Vice-President of the United States",
                  "divisionId"=>"ocd-division/country:us",
                  "levels"=>["country"],
                  "roles"=>["deputyHeadOfGovernment"],
                  "officialIndices"=>[4]},
                {"name"=>"VA State House District 36",
                  "divisionId"=>"ocd-division/country:us/state:va/sldl:36",
                  "levels"=>["administrativeArea1"],
                  "roles"=>["legislatorLowerBody"],
                  "officialIndices"=>[5]},
                {"name"=>"VA State Senate District 32",
                  "divisionId"=>"ocd-division/country:us/state:va/sldu:32",
                  "levels"=>["administrativeArea1"],
                  "roles"=>["legislatorUpperBody"],
                  "officialIndices"=>[6]},
                {"name"=>"Governor",
                  "divisionId"=>"ocd-division/country:us/state:va",
                  "levels"=>["administrativeArea1"],
                  "roles"=>["headOfGovernment"],
                  "officialIndices"=>[7]},
                {"name"=>"Attorney General",
                  "divisionId"=>"ocd-division/country:us/state:va",
                  "officialIndices"=>[8]},
                {"name"=>"Lietuenant Governor",
                  "divisionId"=>"ocd-division/country:us/state:va",
                  "officialIndices"=>[9]},
                {"name"=>"Sheriff",
                  "divisionId"=>"ocd-division/country:us/state:va/county:fairfax",
                  "officialIndices"=>[10]},
                {"name"=>"Commonwealth's Attorney",
                  "divisionId"=>"ocd-division/country:us/state:va/county:fairfax",
                  "officialIndices"=>[11]},
                {"name"=>"Clerk of the Circuit Court",
                  "divisionId"=>"ocd-division/country:us/state:va/county:fairfax",
                  "officialIndices"=>[12]},
                {"name"=>"Board of Supervisors, District At-Large",
                  "divisionId"=>"ocd-division/country:us/state:va/county:fairfax",
                  "officialIndices"=>[13]},
                {"name"=>"Board of Supervisors, District Hunter Mill",
                  "divisionId"=>"ocd-division/country:us/state:va/county:fairfax/council_district:hunter_mill",
                  "officialIndices"=>[14]}],
    "officials"=>[{"name"=>"Gerald E. Connolly",
                    "address"=>[{"line1"=>"424 Cannon House Office Building",
                                  "city"=>"washington",
                                  "state"=>"DC",
                                  "zip"=>"20515"}],
                    "party"=>"Democratic",
                    "phones"=>["(202) 225-1492"],
                    "urls"=>["http://connolly.house.gov/"],
                    "photoUrl"=>"http://bioguide.congress.gov/bioguide/photo/C/C001078.jpg",
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"CongressmanGerryConnolly"},
                                 {"type"=>"Twitter",
                                   "id"=>"GerryConnolly"},
                                 {"type"=>"YouTube",
                                   "id"=>"repconnolly"}]},
                  {"name"=>"Mark R. Warner",
                    "address"=>[{"line1"=>"459A Russell Senate Office Building",
                                  "city"=>"washington",
                                  "state"=>"DC",
                                  "zip"=>"20510"}],
                    "party"=>"Democratic",
                    "phones"=>["(202) 224-2023"],
                    "urls"=>["http://warner.senate.gov/"],
                    "photoUrl"=>"http://warner.senate.gov/public/index.cfm?a=Files.Serve&File_id=c72fbb2b-c10a-48c4-a684-419c7595d454",
                    "emails"=>["warner_info@warner.senate.gov"],
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"MarkRWarner"},
                                 {"type"=>"Twitter",
                                   "id"=>"MarkWarner"},
                                 {"type"=>"YouTube",
                                   "id"=>"SenatorMarkWarner"}]},
                  {"name"=>"Tim Kaine",
                    "address"=>[{"line1"=>"B40C Dirksen Senate Office Building",
                                  "city"=>"washington",
                                  "state"=>"DC",
                                  "zip"=>"20510"}],
                    "party"=>"Democratic",
                    "phones"=>["(202) 224-4024"],
                    "urls"=>["http://kaine.senate.gov/"],
                    "photoUrl"=>"http://www.kaine.senate.gov/imo/media/image/kaine_official_high_res_photo_thumb.jpg",
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"SenatorKaine"},
                                 {"type"=>"Twitter",
                                   "id"=>"SenKaineOffice"},
                                 {"type"=>"YouTube",
                                   "id"=>"SenatorTimKaine"}]},
                  {"name"=>"Barack Obama",
                    "address"=>[{"line1"=>"The White House",
                                  "line2"=>"1600 pennsylvania avenue nw",
                                  "city"=>"washington",
                                  "state"=>"DC",
                                  "zip"=>"20500"}],
                    "party"=>"Democratic",
                    "phones"=>["(202) 456-1111"],
                    "urls"=>["http://www.whitehouse.gov/"],
                    "photoUrl"=>"http://www.whitehouse.gov/sites/default/files/imagecache/admin_official_lowres/administration-official/ao_image/president_official_portrait_hires.jpg",
                    "channels"=>[{"type"=>"GooglePlus",
                                   "id"=>"+whitehouse"},
                                 {"type"=>"Facebook",
                                   "id"=>"whitehouse"},
                                 {"type"=>"Twitter",
                                   "id"=>"whitehouse"},
                                 {"type"=>"YouTube",
                                   "id"=>"barackobama"}]},
                  {"name"=>"Joseph R. Biden",
                    "address"=>[{"line1"=>"The White House",
                                  "line2"=>"1600 pennsylvania avenue nw",
                                  "city"=>"washington",
                                  "state"=>"DC",
                                  "zip"=>"20500"}],
                    "party"=>"Democratic",
                    "phones"=>["(202) 456-1111"],
                    "urls"=>["http://www.whitehouse.gov/"],
                    "photoUrl"=>"http://www.whitehouse.gov/sites/default/files/imagecache/admin_official_lowres/administration-official/ao_image/vp_portrait.jpeg",
                    "channels"=>[{"type"=>"GooglePlus",
                                   "id"=>"+whitehouse"},
                                 {"type"=>"Facebook",
                                   "id"=>"whitehouse"},
                                 {"type"=>"Twitter",
                                   "id"=>"whitehouse"}]},
                  {"name"=>"Kenneth R. Plum",
                    "address"=>[{"line1"=>"2073 cobblestone lane",
                                  "city"=>"reston",
                                  "state"=>"VA",
                                  "zip"=>"20191"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 758-9733"],
                    "urls"=>["http://leg6.state.va.us/cgi-bin/legp604.exe?141+mbr+H76"],
                    "photoUrl"=>"http://virginiageneralassembly.gov/house/members/photos/36.jpg",
                    "emails"=>["DelKPlum@house.virginia.gov"],
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"kenneth.plum"}]},
                  {"name"=>"Janet D. Howell",
                    "address"=>[{"line1"=>"P.O. Box 2608",
                                  "city"=>"reston",
                                  "state"=>"VA",
                                  "zip"=>"20195"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 709-8283"],
                    "urls"=>["http://apps.lis.virginia.gov/sfb1/Senate/senatorwebprofile.aspx?id=270"],
                    "photoUrl"=>"http://apps.lis.virginia.gov/senatepics/Howell32.jpg",
                    "emails"=>["district32@senate.virginia.gov"],
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"senatorhowell"}]},
                  {"name"=>"Terry McAuliffe",
                    "address"=>[{"line1"=>"1111 east broad street",
                                  "city"=>"richmond",
                                  "state"=>"VA",
                                  "zip"=>"23219"}],
                    "party"=>"Democratic",
                    "phones"=>["(804) 786-2211"],
                    "urls"=>["http://www.governor.virginia.gov/"],
                    "photoUrl"=>"https://governor.virginia.gov/media/2125/Governor-McAuliffe.jpg",
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"61634046094"},
                                 {"type"=>"Twitter",
                                   "id"=>"GovernorVA"}]},
                  {"name"=>"Mark R. Herring",
                    "address"=>[{"line1"=>"900 E. Main St.",
                                  "line2"=>"6th Floor",
                                  "city"=>"richmond",
                                  "state"=>"VA",
                                  "zip"=>"23219"}],
                    "party"=>"Democratic",
                    "phones"=>["(804) 786-2071"]},
                  {"name"=>"Ralph S. Northam",
                    "address"=>[{"line1"=>"102 governor street",
                                  "city"=>"richmond",
                                  "state"=>"VA",
                                  "zip"=>"23219"}],
                    "party"=>"Democratic",
                    "phones"=>["(804) 692-0007"],
                    "urls"=>["http://www.ltgov.virginia.gov/"],
                    "emails"=>["ltgov@ltgov.virginia.gov"]},
                  {"name"=>"Mark Sites",
                    "address"=>[{"line1"=>"4110 chain bridge road",
                                  "city"=>"fairfax",
                                  "state"=>"VA",
                                  "zip"=>"22030"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 691-2131"],
                    "urls"=>["http://www.fairfaxcounty.gov/sheriff/"],
                    "emails"=>["sheriff@fairfaxcounty.gov"],
                    "channels"=>[{"type"=>"Facebook",
                                   "id"=>"fairfaxcountysheriff"}]},
                  {"name"=>"Raymond F. Morrogh",
                    "address"=>[{"line1"=>"4110 chain bridge road",
                                  "city"=>"fairfax",
                                  "state"=>"VA",
                                  "zip"=>"22030"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 246-2776"],
                    "urls"=>["http://www.fairfaxcounty.gov/contact/AgencyDetail.aspx?agId=82"]},
                  {"name"=>"John T. Frey",
                    "address"=>[{"line1"=>"4110 chain bridge road",
                                  "city"=>"fairfax",
                                  "state"=>"VA",
                                  "zip"=>"22030"}],
                    "party"=>"Unknown",
                    "phones"=>["(703) 246-4111"],
                    "urls"=>["http://www.fairfaxcounty.gov/courts/circuit"]},
                  {"name"=>"Sharon Bulova",
                    "address"=>[{"line1"=>"12000",
                                  "line2"=>"#530 government center pkwy",
                                  "city"=>"fairfax",
                                  "state"=>"VA",
                                  "zip"=>"22035"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 324-2321"],
                    "urls"=>["http://www.fairfaxcounty.gov/chairman"],
                    "emails"=>["chairman@fairfaxcounty.gov"]},
                  {"name"=>"Catherine M. Hudgins",
                    "address"=>[{"line1"=>"12000 bowman towne drive",
                                  "city"=>"reston",
                                  "state"=>"VA",
                                  "zip"=>"20190"}],
                    "party"=>"Democratic",
                    "phones"=>["(703) 478-0283"],
                    "urls"=>["http://www.fairfaxcounty.gov/huntermill"],
                    "emails"=>["hntrmill@fairfaxcounty.gov"]
                  }
                 ]
  }.to_json
end
