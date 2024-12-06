class Role
  include ActiveModel::Model
  include ModelWrapper
  include ModelCollection
  attr_accessor :name, :japanese_name

  def self.all
    Collection.new([
      Role.new(
        name:"super_admin", 
        japanese_name:"総管理"
      ),
      Role.new(
        name:"assistant_admin", 
        japanese_name: "管理補佐"
      )
    ])
  end
end