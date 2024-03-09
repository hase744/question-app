class Country
  include ActiveModel::Model
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

  def self.where(criteria)
    all.select { |country| country.matches_criteria?(criteria) }
  end
  
  def self.find_by(criteria)
    all.find { |country| country.matches_criteria?(criteria) }
  end

  def matches_criteria?(criteria)
    criteria.all? { |key, value| self.send(key) == value }
  end
end