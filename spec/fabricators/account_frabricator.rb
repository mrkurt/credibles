Fabricate.sequence(:account_seq)
Fabricator(:account) do
  editors [Fabricate.sequence(:name) { |i| "test-#{i}@example.com" }]
end
