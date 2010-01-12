require 'net/http'
require 'erb'

require 'addressable/uri'
require 'xml'

module PennySMSMuncher
  module PennySMS
    class Request
      attr_accessor :api_key, :text, :url, :from_email, :phone_number, :response

      def initialize(api_key, from_email, phone_number, text, api_url=nil)
        self.url = Addressable::URI.parse(api_url || @api_url)
        self.phone_number = phone_number
        self.from_email = from_email
        self.text = text
        self.api_key = api_key
        self.from_email = from_email
      end

      def request
        req = Net::HTTP::Post.new url.path,
          initheader = {'Content-Type' => @content_type}
        req.body = template
        req
      end

      def send_sms
        resp = Net::HTTP.new(url.host).start {|http| http.request(request) }

        if resp.is_a? Net::HTTPSuccess
          self.response = Response.new(resp)
        else
          raise APIError, "PennySMS API changed or busted. Or gem obsolete."
        end
      end
    end

    class Response
      attr_accessor :data, :raw, :status

      def initialize(raw)
        self.raw = raw
        self.data = XML::Parser.string(raw.body).parse # JSON?
        self.set_status
        self
      end

      def success?
        !fault_code
      end

      def set_status
        if fault
          self.status = 'error'
        else
          self.status = data.find('//params//string').first.content
        end
      end

      def fault_code
        fault.find('//i4').first.content if fault
      end

      def fault_name
        fault.find('//string').first.content if fault
      end

      def fault
        return unless data && !data.find('//fault').empty?
        data.find('//fault//member')[0]
      end
    end

    class XMLRequest < Request
      def initialize(*args)
        @api_url = 'http://api.pennysms.com/xmlrpc'
        @rpc_method = 'send'
        @content_type = 'text/xml'
        super
      end

      def template
        ERB.new(%q{<?xml version="1.0"?>
          <methodCall>
          <methodName><%= @rpc_method %></methodName>
          <params>
          <param>
          <value><string><%= api_key %></string></value>
          </param>
          <param>
          <value><string><%= from_email %></string></value>
          </param>
          <param>
          <value><string><%= phone_number %></string></value>
          </param>
          <param>
          <value><string><%= text %></string></value>
          </param>
          </params>
        </methodCall>}.gsub(/^  /, '')).result(binding)
      end
    end

    # DOES NOT WORK 2009-12-22
    class JSONRequest < Request
      def initialize(*args)
        raise NoMethodError, "JSONRequest not working. Figure it out though and let me know"
        @api_url = 'http://api.pennysms.com/jsonrpc'
        @rpc_method = 'send'
        @content_type = 'text/json'
        super
      end

      def template
        {:method => @rpc_method,
          :params => [api_key,from_email,phone_number,text]
        }.to_json
      end
    end

    class APIError < Exception; end
  end
end
