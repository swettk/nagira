require 'spec_helper'

#
# Specs for implemetned API endpoints. Only check response: OK or 404.
#

shared_examples_for :fail_on_random_url do |base|  
  RANDOM.each do |url|
    ep = "#{base}/#{url}"
    it "fails on '#{ep}' string" do
      get ep
      last_response.status.should be 404
    end
  end
end

shared_examples_for :respond_to_valid_url do |base, urls, custom_regex|

  case urls
    when Array
    urls.each do |url|
      ep = "#{base}/#{url}"
      it "responds to #{ep}" do
        get ep
        last_response.should be_ok
      end
    end
    when nil
      ep = "#{base}"
      it "responds to #{ep}" do
        get ep
        last_response.should be_ok
      end
  end
end

shared_examples_for :fail_on_bad_url do |url|
  before {  get url }
  it "fails on #{url}" do 
    last_response.status.should be 404
  end
end

describe Nagira do 
  
  set :environment, :test       # This should run only in test mode as it uses hardcoded host names
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end
  
  context "API endpoints" do
    
    host   = IMPLEMENTED[:hosts].first 
    spaces = "host%20with%20space"


    context :top do 
      it_should_behave_like :respond_to_valid_url,  '', IMPLEMENTED[:top]
      it_should_behave_like :fail_on_random_url,    ''
    end
      

    context "/_status" do
      it_should_behave_like :respond_to_valid_url,  "/_status", IMPLEMENTED[:hosts]
      it_should_behave_like :respond_to_valid_url,  "/_status", IMPLEMENTED[:output] + ["_hosts"]
      it_should_behave_like :fail_on_random_url, '/_status'
    end

    context "/_status/:host" do
      it_should_behave_like :respond_to_valid_url,  "/_status/#{host}", IMPLEMENTED[:status]
      it_should_behave_like :fail_on_random_url,    "/_status/#{host}"

      context "hostname with space" do
        it_should_behave_like :fail_on_bad_url,  "/_status/#{spaces}"
      end

      context :unknown_host do
        it_should_behave_like :fail_on_bad_url,       '/_status/unknown_host'
        it_should_behave_like :fail_on_random_url,    "/_status/unknown_host"
      end
    end                         # /_status/:host

    context "/_status/:host/_services" do 
      it_should_behave_like :respond_to_valid_url,  "/_status/#{host}/_services"
      it_should_behave_like :respond_to_valid_url,  "/_status/#{host}/_services", ["SSH", "PING"]

      context "hostname with space" do
        it_should_behave_like :fail_on_bad_url,  "/_status/#{spaces}/_services"
      end
    end


    context "custom hostname regex - host with spaces" do
        
      it { pending "Need to figure out how to change hostname regex on the fly" }
        #it_should_behave_like :respond_to_valid_url,  "/_status/#{spaces}", nil, '\w[(%20)\w\-\.]+'
        #it_should_behave_like :respond_to_valid_url,  "/_status/#{spaces}/_services"
    end                         # custom hostname regex
    
  end                           # API endpoints
    
end
