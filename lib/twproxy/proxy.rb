require "sinatra"
require "net/http"
require "uri"
require "digest/sha1"
require "rotp"

class TWProxy < Sinatra::Base
  ##
  # Authenticate each request before permitting it to access the wiki
  #
  before do
    @accepted_token = Digest::SHA1.hexdigest(
      "#{settings.username}#{settings.password}#{settings.auth}"
    )

    token = request.cookies["auth"]

    if token == @accepted_token
      @authenticated = true
    elsif request.path != "/login"
      redirect "/login"
    end
  end

  ##
  # Authentication handlers
  #
  get "/login" do
    redirect "/" if @authenticated
    haml :login
  end

  post "/login" do
    hashed_pass = Digest::SHA1.hexdigest(params["pass"])
    user = params["user"] == settings.username
    pass = hashed_pass == settings.password

    if settings.auth
      totp = ROTP::TOTP.new(settings.auth)
      auth = totp.verify(params["auth"])
    else
      auth = true
    end

    if !auth
      @error = "Auth code is incorrect"
      haml :login
    elsif user && pass && auth
      token = Digest::SHA1.hexdigest(
        "#{params["user"]}#{hashed_pass}#{settings.auth}"
      )
      response.set_cookie("auth", value: token, 
                                  secure: settings.enable_ssl, 
                                  expires: (Date.today >> 1).to_time,
                                  httponly: true)

      redirect "/"
    else
      @error = "Invalid username/password"
      haml :login
    end
  end

  get "/logout" do
    response.set_cookie("auth", nil)
    redirect "/login"
  end

  ##
  # Wiki proxy
  #
  def get_uri
    capture = URI::decode(params[:captures][0])
    base = settings.url
    if settings.url[-1] != '/'
      base += '/'
    end

    uri = URI.parse("#{base}#{URI::encode(capture)}")
  end

  put /\/(.*)/ do
    uri = get_uri
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Put.new(uri.request_uri, initheader = { "Content-Type" => "application/json"})
    request.body.rewind
    req.body = request.body.read

    resp = http.request(req)

    status resp.code
    headers({"Etag" => resp["Etag"]})
    resp.body
  end

  delete /\/(.*)/ do
    uri = get_uri
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Delete.new(uri.request_uri)
    resp = http.request(req)

    status resp.code
    resp.body
  end

  get /\/(.*)/ do
    uri = get_uri
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.request_uri)

    http.request(req).body
  end
end
