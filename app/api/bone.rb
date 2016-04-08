require_relative('../models/bone')
require_relative('../entities/bone')

module Skeleton
  # Bone API
  class Bones < Grape::API
    format :json
    version 'v0', using: :path
    local_name = name

    resource :bones do
      desc 'Bone index', params: Skeleton::Entities::Bone.documentation
      get do
        StatsD.measure(Skeleton.stats_string(local_name, 'index')) do
          @bones = Bone.all
          present @bones, with: Skeleton::Entities::Bone
        end
      end

      desc 'Bone lookup', params: Skeleton::Entities::Bone.documentation
      get ':id' do
        StatsD.measure(Skeleton.stats_string(local_name, 'lookup')) do
          @bone = Bone[id: params[:id]]
          present @bone, with: Skeleton::Entities::Bone
        end
      end

      desc 'Bone update', params: Skeleton::Entities::Bone.documentation
      put ':id' do
        StatsD.measure(Skeleton.stats_string(local_name, 'update')) do
          @bone = Bone[id: params[:id]]
          @bone.name = params[:name] if params[:name]
          @bone.save

          present @bone, with: Skeleton::Entities::Bone
        end
      end

      desc 'Bone create', params: Skeleton::Entities::Bone.documentation
      post do
        StatsD.measure(Skeleton.stats_string(local_name, 'create')) do
          @bone = Bone.new
          @bone.name = params[:name] if params[:name]
          @bone.save

          present @bone, with: Skeleton::Entities::Bone
        end
      end

      desc 'Bone remove', params: Skeleton::Entities::Bone.documentation
      delete ':id' do
        StatsD.measure(Skeleton.stats_string(local_name, 'delete')) do
          Bone[params[:id].to_i].destroy
        end
      end
    end
  end
end
