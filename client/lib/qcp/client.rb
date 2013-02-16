require 'rest-client'
require 'addressable/uri'
require 'json'

module Qcp
  class ServerError < RuntimeError
  end

  class Client
    def initialize(server, token = nil)
      @server = Addressable::URI.parse(server)
      @token = token
    end

    attr_accessor :token

    def configured?
      begin
        response = RestClient.get url('/registry')
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end

      result = JSON.parse(response)
      return result['configured']
    end

    def register(master)
      begin
        response = RestClient.post url('/registry'), :master => master
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end

      result = JSON.parse(response)
      @token = result['token']
      return @token
    end

    def copy(content)
      begin
        response = RestClient::Request.new(
          :method => :post,
          :url => url('/clipboard'),
          :user => @token,
          :payload => {
            :content => content
          },
        ).execute
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end
    end

    def paste
      begin
        response = RestClient::Request.new(
          :method => :get,
          :url => url('/clipboard'),
          :user => @token
        ).execute
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end

      result = JSON.parse(response.to_s)
      return result['content']
    end

    def clear
      begin
        response = RestClient::Request.new(
          :method => :delete,
          :url => url('/clipboard'),
          :user => @token
        ).execute
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end
    end

    def version
      begin
        response = RestClient.get url('/version')
      rescue RestClient::Exception => e
        result = JSON.parse(e.response)
        raise ServerError, result['error']
      rescue => e
        raise
      end

      result = JSON.parse(response)
      return result['version']
    end

  private
    def url(relative_path)
      @server.join(relative_path).to_s
    end
  end
end
