# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :school do
    name { "Basic School" }
    country { "US" }
    city { "Berkeley" }
    state { "CA" }
    grade_level { 4 }
    school_type { 0 }
    website { "https://www.school.edu" }
  end

  factory :admin do
    first_name { "Admin" }
    last_name  { "User" }
    email { "admin@berkeley.edu" }
  end
end
