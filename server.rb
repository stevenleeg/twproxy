require "sinatra"
require "net/http"
require "uri"
require "bcrypt"

enable :sessions

before do
  accepted_token = BCrypt::Password.create(
    "#{ENV['WIKI_USER']}#{ENV['wiki_pass']}#{ENV['WIKI_AUTH']}"
  )

  # If we're logging in we don't need to authenticate the user
  return if request.path == '/login'

  if !session.include? :auth || !session[:auth] != @accepted_token
    redirect '/login'
    return
  end
end

get '/login' do
  haml :login
end

get '/logout' do
  session[:auth] = ''
  redirect '/login'
end

post '/login' do
  user = params['user'] == ENV['WIKI_USER']
  pass = params['pass'] == ENV['WIKI_PASS']

  if user && pass
    token = BCrypt::Password.create(
      "#{params[:user]}#{params[:pass]}#{ENV['WIKI_AUTH']}"
    )
    session[:auth] = token.to_s

    redirect '/'
  else
    @error = true
    haml :login
  end
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

