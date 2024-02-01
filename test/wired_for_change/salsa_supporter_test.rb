# frozen_string_literal: true

require "test_helper"
require "wired_for_change/salsa_supporter"

describe SalsaSupporter do
  before do
    @supporter =
      SalsaSupporter.new(tag: ["foo", "bar bas"], Email: "foo@bar.com")
  end

  it "encode tags" do
    assert_equal "object=supporter&Email=foo%40bar.com&tag=foo&tag=bar%20bas",
                 @supporter.uri_encoded
  end

  it "should have salsa supporter attributes" do
    _(SalsaSupporter.salsa_attributes.sort).must_equal(
      %i[
        City
        Country
        Email
        First_Name
        Last_Name
        Occupation
        Organization
        Phone
        State
        Street
        Street_2
        Zip
        organization_KEY
        tag
      ]
    )
  end
end
