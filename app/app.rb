require 'grape'

module Skeleton
  class API < Grape::API
    version 'v0', using: :path
    prefix 'api'
    format :json

    get '/ping' do
      { data: 'pong' }
    end
  end
end