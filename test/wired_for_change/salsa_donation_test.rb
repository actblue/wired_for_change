require 'test_helper'
require 'wired_for_change/salsa_donation'

describe SalsaDonation do
  before do
    time = Time.parse('2010-01-01 10:01:11 -08:00')
    @donation = SalsaDonation.new(:Transaction_Date => time, :Email => "foo@bar.com", :amount => 12.34)
  end
  it 'initializes a donation' do
    @donation.wont_be_nil
  end
  it 'should encode tags' do
    @donation.uri_encoded.must_equal "object=donation&Email=foo%40bar.com&amount=12.34&Transaction_Date=2010-01-01T10%3A01%3A11-08%3A00"
  end
  it 'should have salsa donation attributes' do
    SalsaDonation.salsa_attributes.sort.must_equal(
      [:Donation_Tracking_Code, :Email, :Employer, :Employer_City, :Employer_State, :Employer_Street,
       :Employer_Street_2, :Employer_Zip, :First_Name, :Form_Of_Payment, :Last_Name, :Occupation,
       :Order_Info, :RESULT, :Status, :Tracking_Code, :Transaction_Date, :Transaction_Type, :amount, :tag]
    )
  end
end
