require 'sinatra'
require 'server'
require 'json'
require 'version'

class QcpApp < Sinatra::Base
  def initialize
    @qcp = QcpServer.new
    super
  end

  not_found do
    '' # No content.
  end

  error do
    '' # No content.
  end

  before do
    headers 'qcp-version' => $version
    content_type :json
  end

  get '/version' do
    { :version => $version }.to_json
  end

  get '/master' do
    { :initialized => !@qcp.master_password.nil? }.to_json
  end

  put '/master' do
    if !@qcp.master_password.nil?
      token_authenticated!
    end

    password = params[:password]
    if !password
      halt 400, { :error => 'Specify master password.' }.to_json
    end

    if password.strip.empty?
      halt 400, { :error => 'Master password must not be empty.' }.to_json
    end

    @qcp.master_password = password

    { :initialized => true }.to_json
  end

  post '/tokens' do
    configured!
    master_password_authenticated!
    status 201
    token = @qcp.new_token
    headers 'Location' => server_url("/tokens/#{URI.encode(token)}")
    { :token => token }.to_json
  end

  get '/clipboard' do
    configured!
    token_authenticated!

    { :content => @qcp.content }.to_json
  end

  post '/clipboard' do
    configured!
    token_authenticated!

    content = params[:content]
    if !content
      halt 400, { :error => 'Specify content to copy.' }.to_json
    end

    @qcp.content = content

    { }.to_json
  end

  delete '/clipboard' do
    configured!
    token_authenticated!

    @qcp.content = nil

    { }.to_json
  end

private
  def configured!
    if @qcp.master_password.nil?
      halt 400, { :error => 'Server not configured.' }.to_json
    end
  end

  def server_url(path)
    @server_url ||= URI.parse("#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}")
    (@server_url + path).to_s
  end

  def master_password_authenticated!
    content_type :json

    auth ||= Rack::Auth::Basic::Request.new(request.env)

    if !auth.provided? || !auth.basic? || !auth.credentials
      authenticate('Specify master password.')
    elsif @qcp.master_password != auth.credentials[0]
      authenticate('Incorrect master password.')
    end
  end

  def token_authenticated!
    content_type :json

    auth ||= Rack::Auth::Basic::Request.new(request.env)

    if !auth.provided? || !auth.basic? || !auth.credentials
      authenticate('Specify authentication token.')
    elsif !@qcp.token? auth.credentials[0]
      authenticate('Incorrect authentication token.')
    end
  end

  def authenticate(message)
    response['WWW-Authenticate'] = %(Basic realm="qcp")
    halt 401, { :error => message }.to_json
  end
end
