module Skeleton
  module Entities
    # Bone Entity class
    class Bone < Grape::Entity
      root 'bones', 'bone'
      expose :name, documentation: { type: :string, desc: 'Bone name' }
    end
  end
end
