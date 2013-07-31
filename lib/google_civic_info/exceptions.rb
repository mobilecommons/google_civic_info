module GoogleCivicInfo
  class Exception < StandardError; end
  class InvalidApiKey < Exception; end
  class AddressUnparseableException < Exception; end
  class NoStreetSegmentFoundException < Exception; end
  class MultipleStreetSegmentsFoundException < Exception; end
  class InternalLookupFailureException < Exception; end
  class NoAddressParameter < Exception; end
  class BackendError < Exception; end
end