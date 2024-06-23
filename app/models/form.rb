class Form
  include ActiveModel::Model
  attr_accessor :id, :name, :japanese_name, :description, :start_at, :end_at

  def self.all
    [
      Form.new(
        id: 1,
        name: 'text',
        japanese_name: '文章',
        start_at: DateTime.new(2024, 1, 1)
      ),
      Form.new(
        id: 2,
        name: 'image',
        japanese_name: '文章＋画像',
        start_at: DateTime.new(2024, 1, 1)
      ),
      #Form.new(
      #  id: 3,
      #  name: 'video',
      #  japanese_name: '動画',
      #  start_at: DateTime.new(2024, 1, 1)
      #),
    ]
  end

  def selecter_hash
    all.map{|f| [f.japanese_name, f.name]}.to_h
  end

  def name_sym
    self.name.to_sym
  end

  def self.where(criteria)
    all.select { |form| form.matches_criteria?(criteria) }
  end
  
  def self.find_by(criteria)
    all.find { |form| form.matches_criteria?(criteria) }
  end

  def matches_criteria?(criteria)
    criteria.all? { |key, value| self.send(key) == value }
  end
end