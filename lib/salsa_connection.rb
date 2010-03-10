require 'net/http'
require 'rexml/xpath'
require 'rexml/document'

class SalsaConnection
  include UriEncoder
  class AuthenticationError < StandardError; end
  class AuthenticationFailure < StandardError; end
  
  attr_accessor :raw_post_response

  def initialize(opts)
    @email = opts[:email]
    @password = opts[:password]
    @node = opts[:node]
    @use_ssl = opts[:use_ssl]
    @debug_http = opts[:debug_http]
  end
  def post(object)
    connect unless @connected
    self.raw_post_response = @conn.post('/save', uri_encode([[:xml, "xml"]].push(object)), {"Cookie" => @session_cookie})
  end
  def post!(object)
    connect! unless @connected
    self.raw_post_response = @conn.post('/save', uri_encode([[:xml, "xml"]].push(object)), {"Cookie" => @session_cookie})
  end
  def connected?
    @connected == true
  end
  def connect(assertive=false)
    port = @use_ssl ? 443 : 80
    @conn = Net::HTTP.new(@node, port)

    @conn.use_ssl = true if @use_ssl
    @conn.set_debug_output $stderr if @debug_http
    @auth_resp = @conn.post('/api/authenticate.sjs', uri_encode(:email => @email, :password => @password))

    #! This is so wrong! Cheap hack to dodge using something like mechanize -- whk 20100302
    # They return multiple cookies, with complex formatting that seems to get eaten by Net::HTTP
    @session_cookie = @auth_resp["Set-Cookie"] && @auth_resp["Set-Cookie"].split(";").find{|h| h =~ /session/i}

    code = @auth_resp.code
    if code != "200"
      return unless assertive
      raise AuthenticationError, "Unexpected response code #{@auth_resp.code}"
    end

    # Too bad they don't return a distinctive HTTP status (404 maybe?) to indicate login failure
    if err = REXML::XPath.first(REXML::Document.new(@auth_resp.read_body), "//error")
      return unless assertive
      raise AuthenticationFailure, "Authentication error #{err.get_text}"
    end

    @connected = true
  end
  def connect!
    connect(true)
  end    
end
