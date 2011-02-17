Fabricator(:account) do
  editors [Fabricate.sequence(:email) { |i| "test-#{i}@example.com" }]
end
