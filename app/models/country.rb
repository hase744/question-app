class Country
  include ActiveModel::Model
  include ModelWrapper
  attr_accessor :id, :name, :japanese_name, :code

  def self.all
    [
      Country.new(
        id:1, japanese_name:"日本", name: "japan", code: "81"
      ),
      Country.new(
        id:2, japanese_name:"アメリカ", name: "america", code: "1"
      ),
    ]
  end
end