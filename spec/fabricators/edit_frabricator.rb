Fabricator(:edit) do
  page Fabricate(:page)
  email { Fabricate.sequence(:email) { |i| "test-user-#{i}@example.com" } }
  ip_address '127.0.0.1'
  url 'http://localhost'
  comments 'do it now'
  suggestions [Edit::Suggestion.new(:element_path => '#id > p:eq(0)', :original => 'a serious test', :proposed => 'a serious best')]
end
