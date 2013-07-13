require 'passgen'
require 'set'

class QcpServer
  def initialize()
    @master_password = nil
    @content = nil
    @tokens = Set.new
  end

  attr_accessor :master_password
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

  def revoke_token(token)
    tokens.delete(token)
  end
end
