require 'test_helper'
require 'wired_for_change/salsa_connection'

describe SalsaConnection do
  it 'should initialize a connection' do
    SalsaConnection.new({}).wont_be_nil
  end

  describe 'new' do
    SAMPLE_NODE = 'test-salsa.example.com'
    SESSION_KEY = 'JSESSIONID=DECAFBAD666EA7A7BADCAFEBADF00DU2'
    before do
      args = {
          :node => SAMPLE_NODE, :use_ssl => true,
          :email => "foo@example.com", :password => "supersekrit"
      }
      @connection = SalsaConnection.new(args)
    end
    it 'should produce a SalsaConnection object' do
      @connection.must_be_instance_of SalsaConnection
    end

    describe 'mocking connection' do
      before do
        @auth_response = mock('Net::HTTPResponse')
        @auth_response.stubs(:code => "200")
        @auth_response.stubs(:[]).with("Set-Cookie").returns("#{SESSION_KEY}; Path=/")

        @http_connection = mock('Net::HTTP')
        @http_connection.expects(:use_ssl=).with(true)
        @http_connection.stubs(:post).with('/api/authenticate.sjs', "email=foo%40example.com&password=supersekrit").returns(@auth_response)

        Net::HTTP.expects(:new).with(SAMPLE_NODE, 443).returns(@http_connection)
      end

      describe 'good creds' do
        before do
          response_xml = <<-EOXML
              <?xml version="1.0"?>
              <data organization_KEY="1245">
                <message>Successful Login</message>
              </data>
          EOXML
          @auth_response.stubs(:read_body).returns(response_xml)
        end
        describe 'assertive' do
          before { @connection.connect! }
          it 'should set auth_resp' do
            @connection.instance_variable_get(:@auth_resp).wont_be_nil
          end
          it 'should set session_cookie' do
            @connection.instance_variable_get(:@session_cookie).must_equal SESSION_KEY
          end
        end
        describe 'post a supporter assertive' do
          before do
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
            @connection.post!(supporter)
          end
          it 'should be connected' do
            @connection.connected?.must_equal true
          end
          it 'should leave raw_post_response' do
            @connection.raw_post_response.must_equal @response_xml
          end
          it 'should leave raw_post_request' do
            @connection.raw_post_request.must_equal 'xml=xml&object=supporter&Email=foo%40example.com'
          end
        end
      end

      describe 'bad creds' do
        before do
          response_xml = <<-EOXML
            <?xml version="1.0"?>
            <data>
              <error>Invalid login, please try again.</error>
            </data>
          EOXML
          @auth_response.stubs(:read_body).returns(response_xml)
        end
        describe 'connect assertive' do
          before do
            lambda { @connection.connect! }.must_raise SalsaConnection::AuthenticationFailure
          end
          it 'should not be connected' do
            @connection.connected?.must_equal false
          end
        end
        describe 'connect passive' do
          before do
            @connection.connect
          end
          it 'should not be connected' do
            @connection.connected?.must_equal false
          end
        end
        describe 'post a supporter assertive' do
          before do
            supporter = SalsaSupporter.new(:Email => 'foo@example.com')
            lambda { @connection.post!(supporter) }.must_raise SalsaConnection::AuthenticationFailure
          end
          it 'should not be connected' do
            @connection.connected?.must_equal false
          end
        end
      end
    end
  end

  describe 'combo encoding' do
    before do
      @supporter = SalsaSupporter.new(:tag => ['foo', 'bar bas'], :Email => "foo@bar.com")
      @donation = SalsaDonation.new(:Email => "foo@bar.com", :amount => 12.34)
    end
    it 'should encode an array' do
      encoded = SalsaConnection.new({}).uri_encode([[:xml, "xml"], @supporter, @donation])
      assert_equal "xml=xml&object=supporter&Email=foo%40bar.com&tag=foo&tag=bar%20bas&object=donation&Email=foo%40bar.com&amount=12.34", encoded
    end
  end
end
