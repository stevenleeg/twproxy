require "sinatra"
require "net/http"
require "uri"
require 'digest/sha1'

set :bind, '0.0.0.0'

before do
  @accepted_token = Digest::SHA1.hexdigest(
    "#{ENV['WIKI_USER']}#{ENV['WIKI_PASS']}#{ENV['WIKI_AUTH']}"
  )

  token = request.cookies['auth']

  if token == @accepted_token
    @authenticated = true
  elsif request.path != '/login'
    redirect '/login'
  end
end

get '/login' do
  redirect '/' if @authenticated
  haml :login
end

post '/login' do
  hashed_pass = Digest::SHA1.hexdigest(params['pass'])
  user = params['user'] == ENV['WIKI_USER']
  pass = hashed_pass == ENV['WIKI_PASS']

  if user && pass
    token = Digest::SHA1.hexdigest(
      "#{params['user']}#{hashed_pass}#{ENV['WIKI_AUTH']}"
    )
    response.set_cookie('auth', value: token, secure: true, httponly: true)

    redirect '/'
  else
    @error = true
    haml :login
  end
end

get '/logout' do
  session[:auth] = ''
  redirect '/login'
end

put /\/(.*)/ do
  uri = URI.parse("#{ENV['WIKI_URL']}#{URI::encode(params[:captures][0])}")
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Put.new(uri.request_uri, initheader = { 'Content-Type' => 'application/json'})
  request.body.rewind
  req.body = request.body.read

  resp = http.request(req)

  status resp.code
  headers({"Etag" => resp['Etag']})
  resp.body
end

delete /\/(.*)/ do
  uri = URI.parse("#{ENV['WIKI_URL']}#{URI::encode(params[:captures][0])}")
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Delete.new(uri.request_uri)
  resp = http.request(req)

  status resp.code
  resp.body
end

get /\/(.*)/ do
  uri = URI.parse("#{ENV['WIKI_URL']}#{params[:captures][0]}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Get.new(uri.request_uri)

  http.request(req).body
end

