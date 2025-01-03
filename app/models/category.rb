class Category
  include ActiveModel::Model
  include ModelWrapper
  include ModelCollection
  attr_accessor :id, :name, :parent_category, :child_categories, :japanese_name, :description, :start_at, :end_at

  def self.all
    all_categories = [
      business = Category.new(
        id: 1,
        parent_category: nil,
        name: 'business',
        japanese_name: 'ビジネス',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: [
        ]
      ),
        new_business = Category.new(
          id: 1001,
          parent_category: business,
          name: 'new_business',
          japanese_name: '起業・副業',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        marketing = Category.new(
          id: 1002,
          parent_category: business,
          name: 'marketing',
          japanese_name: 'マーケティング',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        affiliate = Category.new(
          id: 1003,
          parent_category: business,
          name: 'affiliate',
          japanese_name: 'アフィリエイト',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        social_media = Category.new(
          id: 1004,
          parent_category: business,
          name: 'social_media',
          japanese_name: 'SNS',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        resale = Category.new(
          id: 1005,
          parent_category: business,
          name: 'resale',
          japanese_name: '物販',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
      career = Category.new(
        id: 2,
        parent_category: nil,
        name: 'career',
        japanese_name: 'キャリア',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: [
        ]
      ),
        job_hunting = Category.new(
          id: 2001,
          parent_category: career,
          name: 'job_hunting',
          japanese_name: '就活',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        career_change = Category.new(
          id: 2002,
          parent_category: career,
          name: 'career_change',
          japanese_name: '転職・独立',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        sales_job = Category.new(
          id: 2003,
          parent_category: career,
          name: 'sales_job',
          japanese_name: '営業職',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        technical_job = Category.new(
          id: 2004,
          parent_category: career,
          name: 'technical_job',
          japanese_name: '技術職',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        designer = Category.new(
          id: 2005,
          parent_category: career,
          name: 'designer',
          japanese_name: 'デザイナー',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
      life = Category.new(
        id: 3,
        parent_category: nil,
        name: 'life',
        japanese_name: '人生',
        start_at: DateTime.new(2024, 1, 1),
        child_categories: [
        ]
      ),
        future_path = Category.new(
          id: 3001,
          parent_category: life,
          name: 'future_path',
          japanese_name: '進路',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        living = Category.new(
          id: 3002,
          parent_category: life,
          name: 'living',
          japanese_name: '生き方',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
        marrage = Category.new(
          id: 3003,
          parent_category: life,
          name: 'marrage',
          japanese_name: '結婚',
          start_at: DateTime.new(2024, 1, 1),
          child_categories: []
        ),
    ]
    #all_categories = [business, career, presentation, document_preparation, freelance]
    #business.child_categories = [presentation, document_preparation]
    #career.child_categories = [freelance]

    all_categories.select {|c| c.parent_category != nil}.each do |category|
      category.parent_category.child_categories.push(category)
    end

    Collection.new(all_categories)
  end

  def valid
  end

  def name_sym
    self.name.to_sym
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
