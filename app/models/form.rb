class Form
  include ActiveModel::Model
  attr_accessor :id, :name, :japanese_name, :description, :start_at, :end_at

  def self.all
    [
      Form.new(
        id: 1,
        name: 'text',
        japanese_name: '文章のみ',
        start_at: DateTime.new(2024, 1, 1)
      ),
      Form.new(
        id: 2,
        name: 'image',
        japanese_name: '文章＋画像',
        start_at: DateTime.new(2024, 1, 1)
      ),
      Form.new(
        id: 3,
        name: 'free',
        japanese_name: '自由',
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

  def self.available
    all.select { |form| form.start_at < DateTime.now }
  end

  def self.japanese_names
    available.map(&:japanese_name).join('、')
  end

  def selecter_hash
    available.map{|f| [f.japanese_name, f.name]}.to_h
  end

  def name_sym
    self.name.to_sym
  end

  def names
    where()
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