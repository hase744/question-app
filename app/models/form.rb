class Form
  include ActiveModel::Model
  include ModelWrapper
  include ModelCollection
  attr_accessor :id, :name, :japanese_name, :description, :start_at, :end_at

  def self.all
    Collection.new([
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
    ])
  end

  def self.for_request
    available.where(name: ['image', 'text'])
  end

  def self.japanese_names_for_request
    for_request.map(&:japanese_name).join('、')
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
end