#!/usr/bin/env ruby
# Encoding: utf-8
#
# Author:: api.dklimkin@gmail.com (Danial Klimkin)
#
# Copyright:: Copyright 2011, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example gets suggested ad units that have more than 50 requests. The
# statement retrieves up to the maximum page size limit of 500.
#
# This feature is only available to DFP premium solution networks.
#
# Tags: SuggestedAdUnitService.getSuggestedAdUnitsByStatement

require 'dfp_api'

API_VERSION = :v201211
NUMBER_OF_REQUESTS = 50

def get_suggested_ad_units_by_statement()
  # Get DfpApi instance and load configuration from ~/dfp_api.yml.
  dfp = DfpApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # dfp.logger = Logger.new('dfp_xml.log')

  # Get the SuggestedAdUnitService.
  suggested_ad_unit_service = dfp.service(:SuggestedAdUnitService, API_VERSION)

  # Create a statement to only select suggested ad units with more than 50
  # requests (with maximum limit of 500).
  statement = {
     :query => 'WHERE numRequests > :num_requests LIMIT 500',
     :values => [
         {:key => 'num_requests',
          :value => {:value => NUMBER_OF_REQUESTS,
                     :xsi_type => 'NumberValue'}}
     ]
  }

  # Get ad units by statement.
  page =
      suggested_ad_unit_service.get_suggested_ad_units_by_statement(statement)

  if page[:results]
    # Print details about each suggested ad unit in results.
    page[:results].each_with_index do |ad_unit, index|
      puts "%d) Suggested ad unit ID: '%s', number of requests: %d" %
          [index, ad_unit[:id], ad_unit[:num_requests]]
    end
  end

  # Print a footer.
  if page.include?(:total_result_set_size)
    puts "Total number of suggested ad units: %d" % page[:total_result_set_size]
  end
end

if __FILE__ == $0
  begin
    get_suggested_ad_units_by_statement()

  # HTTP errors.
  rescue AdsCommon::Errors::HttpError => e
    puts "HTTP Error: %s" % e

  # API errors.
  rescue DfpApi::Errors::ApiException => e
    puts "Message: %s" % e.message
    puts 'Errors:'
    e.errors.each_with_index do |error, index|
      puts "\tError [%d]:" % (index + 1)
      error.each do |field, value|
        puts "\t\t%s: %s" % [field, value]
      end
    end
  end
end
