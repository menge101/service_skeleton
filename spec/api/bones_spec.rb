RSpec.describe Skeleton::Bones do
  include Rack::Test::Methods
  include_context :bond

  def app
    Skeleton::API
  end

  it 'creates' do
    post 'api/v0/bones/', { name: 'create_test'}.to_json, "CONTENT_TYPE" => "application/json"
    bond.spy(last_response.status)
    bond.spy(Bone.first.name)
  end

  it 'indexes' do
    Bone.create({ name: 'index1' })
    Bone.create({ name: 'index2' })
    get 'api/v0/bones/'
    bond.spy(last_response.status)
    bond.spy(JSON.parse(last_response.body))
  end

  it 'performs a lookup' do
    Bone.create({ name: 'lookup' })
    id = Bone.first.id
    get "api/v0/bones/#{id}"
    bond.spy(last_response.status)
    bond.spy(JSON.parse(last_response.body))
  end

  it 'updates' do
    Bone.create({ name: 'not_updated'})
    id = Bone.first.id
    put "api/v0/bones/#{id}", { name: 'updated' }.to_json, "CONTENT_TYPE" => "application/json"
    bond.spy(last_response.status)
    bond.spy(Bone.first.name)
  end

  it 'deletes' do
    Bone.create({ name: 'not_deleted'})
    id = Bone.first.id
    delete "api/v0/bones/#{id}"
    bond.spy(last_response.status)
    bond.spy(Bone.count)
  end

end