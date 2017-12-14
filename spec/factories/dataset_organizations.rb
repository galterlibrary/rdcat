FactoryGirl.define do
  factory :dataset_organization do
    association :dataset, factory: :dataset
    association :organization, factory: :organization
  end
end
