require 'active_record'
require 'faker'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  
  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "company_id"
  end
end

def add_contact_associations_to(ar_base_subclass)
  ar_base_subclass.send :has_many, :phone_numbers
  ar_base_subclass.send :has_many, :email_addresses
end

class Company < ActiveRecord::Base
  add_contact_associations_to self

  has_many :people
end

class Person < ActiveRecord::Base
  #add_contact_associations_to self

  belongs_to :company
  def name
    [last_name, first_name].join
  end
end


cc = Company.new(name: 'company1')

pp = 10.times.map do  
 Person.new(first_name: Faker::Name.first_name , last_name: Faker::Name.last_name )
end

cc.people = pp
cc.save
p cc.people[0..3]
