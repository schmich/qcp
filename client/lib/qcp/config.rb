require 'json'

module Qcp
  class Config
    def initialize(filename = nil)
      @filename = filename

      if !File.exists? filename
        @server = nil
        @token = nil
      else
        contents = JSON.load(open(@filename))
        @server = contents['server']
        @token = contents['token']
      end
    end

    def server
      @server
    end

    def server=(server)
      @server = server
    end

    def token
      @token
    end

    def token=(token)
      @token = token
    end

    def save!
      File.open(@filename, 'w') do |file|
        file.write({
          :server => @server,
          :token => @token
        }.to_json)
      end
    end

    attr_accessor :filename
  end
end
