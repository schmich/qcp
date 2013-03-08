require 'passgen'

class QcpServer
  def initialize(master)
    @master = master
    @content = nil
    @tokens = []
  end

  attr_accessor :master
  attr_accessor :tokens
  attr_accessor :content

  def token?(token)
    tokens.include? token
  end

  def new_token
    token = Passgen::generate while (!token || tokens.include?(token))
    tokens << token
    token
  end
end
