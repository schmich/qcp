require 'web'
require 'test/unit'
require 'rack/test'
require 'json'

set :environment, :test

class QcpServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    QcpApp
  end

  def setup
  end

  def teardown
  end

  def test_no_index
    get '/'
    assert_equal 404, last_response.status
  end

  def test_version
    get '/version'
    obj = assert_json_response
    assert !obj['version'].nil?
  end

  def assert_json_response
    assert last_response.ok?
    assert last_response.content_type =~ /application\/json/
    return JSON.parse(last_response.body)
  end
end
