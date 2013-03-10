require 'web'
require 'test/unit'
require 'rack/test'
require 'json'

set :environment, :test

class Test::Unit::TestCase
  include Rack::Test::Methods

  def assert_auth_error
    assert_json_error(401)
  end

  def assert_json_error(status_code = 400)
    r = assert_json_response(status_code)
    error = r['error']
    assert !error.nil?
  end

  def assert_json_response(status_code = 200)
    assert_equal status_code, last_response.status
    assert last_response.content_type =~ /application\/json/
    return JSON.parse(last_response.body)
  end
end

class QcpSimpleAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    QcpApp.new!
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
    r = assert_json_response
    assert !r['version'].nil?
  end

  def test_master_not_init
    get '/master'
    r = assert_json_response
    init = r['initialized']
    assert_not_nil init
    assert_equal false, init
  end

  def test_master_require_password
    put '/master'
    assert_json_error
  end

  def test_master_require_non_empty_password
    put '/master', :password => ''
    assert_json_error
  end

  def test_master_init
    put '/master', :password => 'foo'
    r = assert_json_response
    init = r['initialized']
    assert_not_nil init
    assert_equal true, init
  end

  def test_tokens_no_master
    post '/tokens'
    assert_json_error
  end

  def test_tokens_no_auth
    put '/master', :password => 'foo'
    post '/tokens'
    assert_auth_error
  end
end

class QcpInitializedTest < Test::Unit::TestCase
  def app
    QcpApp.new!
  end

  def setup
    put '/master', :password => 'foo'
  end

  def teardown
  end

  def test_token_create
    authenticate
    post '/tokens'
    r = assert_json_response(201)
    token = r['token']
    assert_not_nil token
    assert !token.strip.empty?
  end

  def test_token_unique
    authenticate
    post '/tokens'
    r = assert_json_response(201)
    token1 = r['token']
    post '/tokens'
    r = assert_json_response(201)
    token2 = r['token']
    assert_not_equal token1, token2
  end

  def authenticate
    authorize 'foo', ''
  end
end
