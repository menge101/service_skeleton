# Sequel model for Bones
class Bone < Sequel::Model
  def validate
    super
    errors.add(:name, 'Must have a name.') if name.empty?
  end
end
