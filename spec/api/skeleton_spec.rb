RSpec.describe Skeleton::API do
  include Rack::Test::Methods
  include_context :bond

  def app
    Skeleton::API
  end

  it 'ping' do
    get '/api/v0/ping'
    bond.spy(status: last_response.status)
    bond.spy(body: last_response.body)
  end
end
