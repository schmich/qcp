require 'sinatra'
require 'server'
require 'json'
require 'version'

class QcpApp < Sinatra::Base
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

  get '/registry' do
    { :configured => !@qcp.nil? }.to_json
  end

  post '/registry' do
    if @qcp.nil?
      master = params[:master]
      if !master
        halt 400, { :error => 'Specify master password.' }.to_json
      end

      if master.strip.empty?
        halt 400, { :error => 'Master password must not be empty.' }.to_json
      end

      @qcp = QcpServer.new(master)
    else
      master = params[:master]
      if !master
        halt 400, { :error => 'Specify master password.' }.to_json
      end

      if master != @qcp.master
        halt 403, { :error => 'Incorrect master password.' }.to_json
      end
    end

    { :token => @qcp.new_token }.to_json
  end

  get '/clipboard' do
    configured!
    authenticated!

    { :content => @qcp.content }.to_json
  end

  post '/clipboard' do
    configured!
    authenticated!

    content = params[:content]
    if !content
      halt 400, { :error => 'Specify content to copy.' }.to_json
    end

    @qcp.content = content

    { }.to_json
  end

  delete '/clipboard' do
    configured!
    authenticated!

    @qcp.content = nil

    { }.to_json
  end

private
  def configured!
    if @qcp.nil?
      halt 400, { :error => 'Server not configured.' }.to_json
    end
  end

  def authenticated!
    content_type :json

    @auth ||= Rack::Auth::Basic::Request.new(request.env)

    if !@auth.provided? || !@auth.basic? || !@auth.credentials
      authenticate('Specify credentials.')
    elsif !@qcp.token? @auth.credentials[0]
      authenticate('Incorrect credentials.')
    end
  end

  def authenticate(message)
    response['WWW-Authenticate'] = %(Basic realm="qcp")
    halt 401, { :error => message }.to_json
  end
end
