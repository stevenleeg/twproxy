require "sinatra"
require "net/http"
require "uri"

put /\/(.*)/ do
  uri = URI.parse("http://localhost:8080/#{URI::encode(params[:captures][0])}")
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
  uri = URI.parse("http://localhost:8080/#{URI::encode(params[:captures][0])}")
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Delete.new(uri.request_uri)
  resp = http.request(req)

  status resp.code
  resp.body
end

get /\/(.*)/ do
  uri = URI.parse("http://localhost:8080/#{params[:captures][0]}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Get.new(uri.request_uri)

  http.request(req).body
end

