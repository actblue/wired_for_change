class SalsaDonation < SalsaObject
  salsa_attribute :Transaction_Date, :amount, :Transaction_Type, :Form_of_Payment
  salsa_attribute :Order_Info, :Status
  salsa_attribute :Email, :First_Name, :Last_Name, :Occupation
  salsa_attribute :Tracking_Code, :Donation_Tracking_Code
  salsa_attribute :Employer, :Employer_Street, :Employer_Street_2
  salsa_attribute :Employer_City, :Employer_State, :Employer_Zip
  salsa_attribute :Tag
end
