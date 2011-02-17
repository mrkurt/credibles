Fabricator(:page) do
  account Fabricate(:account)
  key { Fabricate.sequence(:key) }
  url 'http://localhost'
end
