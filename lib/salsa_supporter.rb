class SalsaSupporter < SalsaObject
  salsa_attribute :organization_KEY, :Email, :First_Name, :Last_Name
  salsa_attribute :Street, :Street_2
  salsa_attribute :City, :State, :Country, :Zip
  salsa_attribute :Organization, :Occupation
  salsa_attribute :Tag
end
