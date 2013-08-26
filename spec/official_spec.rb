require "google_civic_info"
require 'google_civic_info/exceptions'
require "spec_helper"

describe GoogleCivicInfo::Official do

  it "should convert different party strings to a normalized format" do
    
    GoogleCivicInfo::Official.new(:party=>'D').party.should == GoogleCivicInfo::Official::DEMOCRAT
    
  end

end