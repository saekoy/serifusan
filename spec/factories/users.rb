FactoryBot.define do
  factory :user do
    firebase_uid { 'MyString' }
    email { 'MyString' }
    display_name { 'MyString' }
    photo_url { 'MyString' }
    provider { 'MyString' }
  end
end
