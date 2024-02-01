# frozen_string_literal: true

require "test_helper"
require "wired_for_change/salsa_base"

describe SalsaObject do
  before { @object = SalsaObject.new() }

  describe "#uri_encode" do
    it "should encode a hash" do
      params = { email: "foo@bar.com", tag: ["foo", "bar bas"] }
      assert_equal "email=foo%40bar.com&tag=%5B%22foo%22%2C%20%22bar%20bas%22%5D",
                   @object.uri_encode(params)
    end

    it "should encode an array of two strings" do
      params = %w[email foo@bar.com]
      assert_equal "email=foo%40bar.com", @object.uri_encode(params)
    end

    it "should encode an array of a symbol and a strings" do
      params = [:email, "foo@bar.com"]
      assert_equal "email=foo%40bar.com", @object.uri_encode(params)
    end

    it "should encode an array of pairs" do
      params = [[:email, "foo@bar.com"], [:single_tag, "tag"]]
      assert_equal "email=foo%40bar.com&single_tag=tag",
                   @object.uri_encode(params)
    end

    it "should encode a SalsaObject" do
      class SalsaSubclass < SalsaObject
        salsa_attribute :tag, :Email
      end
      params = SalsaSubclass.new(tag: ["foo", "bar bas"], Email: "foo@bar.com")
      assert_equal "object=subclass&tag=foo&tag=bar%20bas&Email=foo%40bar.com",
                   @object.uri_encode(params)
    end
  end
end
