require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__)) + "/../lib/penny_sms.rb"
include PennySMSMuncher


module PennySMSHelper
  def failing_sms
    @phone = '5555555555'
    @email = 'mouse house'
    @message = "Mouse is in the house!"
    @req = PennySMS::XMLRequest.new('api_key', @email, @phone,@message)
  end

  def fault_body
    '<?xml version="1.0" ?><methodResponse><fault><value><struct><member><name>faultCode</name><value><i4>500</i4></value></member><member><name>faultString</name><value><string>Error: unsupported cell number</string></value></member></struct></value></fault></methodResponse>'
  end
  
  def success_body
    '<?xml version="1.0" ?><methodResponse><params><param><value><string>OK</string></value></param></params></methodResponse>'
  end
end


describe "PennySMSMuncher::PennySms" do
  include PennySMSHelper

  describe 'creating' do

    describe 'XMLRequest' do
      it 'should set the url' do
        req = PennySMS::XMLRequest.new('api_key', nil, nil,nil)
        req.url.path.should match(/xml/)
      end
    end

    describe 'JSONRequest' do
      it 'should set the url'
    end
  end

  describe 'template' do
    describe 'XMLRequest' do
      before(:each) do
        failing_sms
      end

      it 'should include the phone_number' do
        @req.template.should match(@phone)
      end
      it 'should include the email' do
        @req.template.should match(@email)
      end
      it 'should include the message'  do
        @req.template.should match(@message)
      end
      it 'should include the api_key'    do
        @req.template.should match('api_key')
      end

    end
    describe 'JSONRequest' do
      it 'should include the phone_number'
      it 'should include the email'
      it 'should include the message'
      it 'should include the api_key'
    end
  end

  describe 'making the API call' do
    describe 'fails' do
      it 'should raise an error if the API call fails' do
        failing_sms
        Net::HTTP.any_instance.stubs(:start).returns "bogus"
        lambda{@req.send_sms}.should raise_error(PennySMS::APIError)
      end
    end

    describe 'succeeds' do
      describe 'with errors' do
        before(:each) do
          failing_sms
          http_mock = mock('Net::HTTPSuccess')
          http_mock.stubs( :code => '200',
            :message => "OK",
            :content_type => "text/xml",
            :body => fault_body,
            :is_a? => Net::HTTPSuccess)
          Net::HTTP.any_instance.stubs(:start).returns http_mock
          @response = @req.send_sms
        end

        it "should return a response object"  do
          @response.class.should == PennySMS::Response
        end

        it 'should set the status' do
          @response.status.should == 'error'
        end

        it 'should not be successful' do
          @response.should_not be_success
        end

        it 'should set the fault_code' do
          @response.fault_code.should == '500'
        end

        it 'should set the fault_name' do
          @response.fault_name.should match(/unsupported cell/)
        end
      end

      describe 'with no errors' do
        before(:each) do
          failing_sms
          http_mock = mock('Net::HTTPSuccess')
          http_mock.stubs( :code => '200',
            :message => "OK",
            :content_type => "text/xml",
            :body => success_body,
            :is_a? => Net::HTTPSuccess)
          Net::HTTP.any_instance.stubs(:start).returns http_mock
          @response = @req.send_sms
        end

        it "should return a response object"  do
          @response.class.should == PennySMS::Response
        end

        it 'should set the status' do
          @response.status.downcase.should == 'ok'
        end

        it 'should be successful' do
          @response.should be_success
        end

        it 'should not set the fault_code' do
          @response.fault_code.should be_nil
        end

        it 'should not set the fault_name' do
          @response.fault_name.should be_nil
        end
      end
    end
  end
end
