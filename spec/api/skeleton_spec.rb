RSpec.describe Skeleton::API do
  include Rack::Test::Methods

  def app
    Skeleton::API
  end

  it 'ping' do
    get '/api/v0/ping'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({ data: 'pong' }.to_json)
  end
end