FactoryBot.define do
  factory :apicasso_key do
    scope { { manage: { object: true } } }
    scope_type { nil }
    request_limiting { nil }
    token { 'tokenbacanacomuuid123' }
    deleted_at { nil }
  end
end
