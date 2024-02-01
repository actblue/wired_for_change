# frozen_string_literal: true

class SalsaSupporter < SalsaObject
  salsa_attribute :organization_KEY, :Email, :First_Name, :Last_Name, :Phone
  salsa_attribute :Street, :Street_2
  salsa_attribute :City, :State, :Country, :Zip
  salsa_attribute :Organization, :Occupation
  salsa_attribute :tag
end
