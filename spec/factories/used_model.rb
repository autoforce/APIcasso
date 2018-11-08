FactoryBot.define do
  factory :used_model do
    active { Faker::Boolean.boolean }
    account_id { Faker::Number.number(1) }
    unit_id { Faker::Number.number(1) }
    brand { Faker::Vehicle.make }
    name { Faker::Vehicle.make_and_model }
    model { Faker::Vehicle.model }
    version { Faker::Number.decimal(1, 1) }
    model_year { Faker::Vehicle.year }
    production_year { Faker::Vehicle.year }
    kind { 'car' }
    new_vehicle { Faker::Boolean.boolean }
    old_price { Faker::Number.decimal(4, 2) }.to_s
    price_value { Faker::Number.decimal(4, 2) }
    price { Faker::Number.decimal(4, 2) }.to_s
    category { Faker::Vehicle.car_type }
    transmission { Faker::Vehicle.transmission }
    km_value { Faker::Number.number(8) }
    km { Faker::Number.number(8) }
    plate { Faker::Number.number(4) }
    color { Faker::Vehicle.color }
    doors { Faker::Number.number(1) }
    fuel  { Faker::Number.number(1) }
    fuel_text { Faker::Vehicle.fuel_type }
    shielded { Faker::Boolean.boolean }
  end
end
