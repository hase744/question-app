class Role
  include ActiveModel::Model
  include ModelWrapper
  attr_accessor :name, :japanese_name

  def self.all
    [
      Role.new(
        name:"super_admin", 
        japanese_name:"総管理"
      ),
      Role.new(
        name:"assistant_admin", 
        japanese_name: "管理補佐"
      )
    ]
  end
end