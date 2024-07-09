class Category
  include ActiveModel::Model
  attr_accessor :id, :name, :parent_category, :child_categories, :japanese_name, :description, :start_at, :end_at

  def self.all
    all_categories = [
      business = Category.new(
        id: 1,
        parent_category: nil,
        name: 'business',
        japanese_name: 'ビジネス',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      carrier = Category.new(
        id: 2,
        parent_category: nil,
        name: 'carrier',
        japanese_name: 'キャリア',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      presentation = Category.new(
        id: 3,
        parent_category: business,
        name: 'presentation',
        japanese_name: 'プレゼン',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      document_preparation = Category.new(
        id: 4,
        parent_category: business,
        name: 'document_preparation',
        japanese_name: '資料作成',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      accounting = Category.new(
        id: 5,
        parent_category: business,
        name: 'accounting',
        japanese_name: '会計・経理',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      job_application = Category.new(
        id: 6,
        parent_category: carrier,
        name: 'job_application',
        japanese_name: '面接・ES',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      sales_job = Category.new(
        id: 7,
        parent_category: carrier,
        name: 'sales_job',
        japanese_name: '営業職',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      technical_job = Category.new(
        id: 8,
        parent_category: carrier,
        name: 'technical_job',
        japanese_name: '技術職',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      clerical_job = Category.new(
        id: 9,
        parent_category: carrier,
        name: 'clerical_job',
        japanese_name: '事務職',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      manager_job = Category.new(
        id: 10,
        parent_category: carrier,
        name: 'manager_job',
        japanese_name: '管理職',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      financial_job = Category.new(
        id: 11,
        parent_category: carrier,
        name: 'financial_job',
        japanese_name: '経理職',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      freelance = Category.new(
        id: 12,
        parent_category: carrier,
        name: 'freelance',
        japanese_name: '独立・副業',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
      sales = Category.new(
        id: 13,
        parent_category: business,
        name: 'sales',
        japanese_name: '営業',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: []
      ),
    ]
    #all_categories = [business, carrier, presentation, document_preparation, freelance]
    #business.child_categories = [presentation, document_preparation]
    #carrier.child_categories = [freelance]

    all_categories.select {|c| c.parent_category != nil}.each do |category|
      category.parent_category.child_categories.push(category)
    end

    all_categories
  end

  def valid
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
  
  def self.not_where(criteria)
    all.reject { |form| form.matches_criteria?(criteria) }
  end

  def self.find_by(criteria)
    all.find { |form| form.matches_criteria?(criteria) }
  end

  def matches_criteria?(criteria)
    criteria.all? do |key, value|
      attribute_value = self.send(key)
      value.is_a?(Array) ? value.include?(attribute_value) : attribute_value == value
    end
  end

  def self.first
    all[0]
  end

  def hash
    {
      id: id,
      name: name,
      japanese_name: japanese_name,
      child_categories: child_categories.map(&:hash)
    }
  end

  def self.hash_tree
    roots = where(parent_category: nil)
    {
      categories: roots.map(&:hash)
    }
  end
end
