# Maybe someday this'll warrant a test_helper.rb
# require File.join(File.dirname(__FILE__), 'test_helper')
# in the mean time:<-END_TEST_HELPER
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require File.dirname(__FILE__) + '/../init.rb'
require 'shoulda'
require 'mocha'
require 'ruby-debug' # uncomment this to use the debugger
require 'time'
begin; require 'turn'; rescue LoadError; end # Use Test::Unit Report formatting (New) if the gem is installed
#END_TEST_HELPER content

class WiredForChangeTest < Test::Unit::TestCase
  context 'supporter' do
    setup do
      @supporter = SalsaSupporter.new(:tag => ['foo', 'bar bas'], :Email => "foo@bar.com")
    end
    should 'encode tags' do
      @supporter.uri_encoded.should == "object=supporter&Email=foo%40bar.com&tag=foo&tag=bar%20bas"
    end
  end
  context 'donation' do
    setup do
      @donation = SalsaDonation.new(:Transaction_Date => Time.parse('2010-01-01 10:01:11'),
                                    :Email => "foo@bar.com", :amount => 12.34)
    end
    should 'encode' do
      @donation.uri_encoded.should == "object=donation&Email=foo%40bar.com&amount=12.34&Transaction_Date=2010-01-01T10%3A01%3A11-05%3A00"
    end
  end
  context 'combo encoding' do
    setup do
      @supporter = SalsaSupporter.new(:tag => ['foo', 'bar bas'], :Email => "foo@bar.com")
      @donation = SalsaDonation.new(:Email => "foo@bar.com", :amount => 12.34)
    end
    should 'work' do
      encoded = SalsaConnection.new({}).uri_encode([[:xml, "xml"], @supporter, @donation])
      encoded.should == "xml=xml&object=supporter&Email=foo%40bar.com&tag=foo&tag=bar%20bas&object=donation&Email=foo%40bar.com&amount=12.34"
    end
  end
  context 'connection' do
    SAMPLE_NODE = 'test-salsa.example.com'
    SESSION_KEY = 'JSESSIONID=DECAFBAD666EA7A7BADCAFEBADF00DU2'
    setup do
      assert_nothing_raised do
        Net::HTTP.expects(:new).never
        args = {
          :node => SAMPLE_NODE, :use_ssl => true,
          :email => "foo@example.com", :password => "supersekrit"
        }
        @connection = SalsaConnection.new(args)
      end
    end
    should 'produce an object' do
      @connection.is_a?(SalsaConnection).should.be true
    end
    context 'mocking connection' do
      setup do
        @auth_response = mock('Net::HTTPResponse')
        @auth_response.stubs(:code => "200")
        @auth_response.stubs(:[]).with("Set-Cookie").returns("#{SESSION_KEY}; Path=/")
  
        @http_connection = mock('Net::HTTP')
        @http_connection.expects(:use_ssl=).with(true)
        @http_connection.stubs(:post).with('/api/authenticate.sjs', "email=foo%40example.com&password=supersekrit").returns(@auth_response)
  
        Net::HTTP.expects(:new).with(SAMPLE_NODE, 443).returns(@http_connection)
      end
      context 'good creds' do
        setup do
          response_xml = <<-EOXML
            <?xml version="1.0"?>
            <data organization_KEY="1245">
              <message>Successful Login</message>
            </data>
          EOXML
          @auth_response.stubs(:read_body).returns(response_xml)
        end          
        context 'assertive' do
          setup { assert_nothing_raised{ @connection.connect! } }
          should 'set auth_resp' do
            @connection.instance_variable_get(:@auth_resp).should.not.be nil
          end
          should 'set session_cookie' do
            @connection.instance_variable_get(:@session_cookie).should == SESSION_KEY
          end
        end
        context 'post a supporter assertive' do
          setup do
            supporter = SalsaSupporter.new(:Email => 'foo@example.com')
            @response_xml = <<-EOXML
              <?xml version="1.0"?>
              <data>
                <success object="supporter" key="31513133">Modified entry 31513133</success>
                <success object="donation" key="11713849">Modified entry 11713849</success>
              </data>
            EOXML
            @http_response = mock()
            @http_response.stubs(:code).returns("200")
            @http_response.stubs(:read_body).returns(@response_xml)
            @http_connection.stubs(:post).with('/save', 
                                               "xml=xml&object=supporter&Email=foo%40example.com",
                                               {'Cookie' => SESSION_KEY}).returns(@http_response)
            assert_nothing_raised { @connection.post!(supporter) }
          end
          should 'be connected' do @connection.should.be.connected end
          should 'leave raw_post_response' do
            @connection.raw_post_response.should == @response_xml
          end
          should 'leave raw_post_request' do
            @connection.raw_post_request.should == 'xml=xml&object=supporter&Email=foo%40example.com'
          end
        end
      end
      context 'bad creds' do
        setup do
          response_xml = <<-EOXML
            <?xml version="1.0"?>
            <data>
              <error>Invalid login, please try again.</error>
            </data>
          EOXML
          @auth_response.stubs(:read_body).returns(response_xml)
        end
        context 'connect assertive' do
          setup do
            assert_raise SalsaConnection::AuthenticationFailure do
              @connection.connect!
            end
          end
          should 'not be connected' do @connection.should.not.be.connected end
        end
        context 'connect passive' do
          setup do
            assert_nothing_raised { @connection.connect }
          end
          should 'not be connected' do @connection.should.not.be.connected end
        end
        context 'post a supporter assertive' do
          setup do
            supporter = SalsaSupporter.new(:Email => 'foo@example.com')
            assert_raise SalsaConnection::AuthenticationFailure do
              @connection.post!(supporter)
            end
          end
          should 'not be connected' do @connection.should.not.be.connected end
        end
      end
    end
  end
end