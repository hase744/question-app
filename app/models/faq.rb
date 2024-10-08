class Faq
  include ActiveModel::Model
  attr_accessor :question, :answer, :is_published, :words

  def self.all
    json_url = 'https://raw.githubusercontent.com/hase744/question-app-faq-json/refs/heads/main/version-1/faq.json'
    data = JSON.parse(URI.open(json_url).read)
    
    # Map each JSON object to a new Faq instance
    data.map do |faq|
      new(
        question: faq['question'],
        answer: faq['answer'],
        is_published: faq['is_published'],
        words: faq['words']
      )
    end
  end

  def selecter_hash
    available.map{|f| [f.japanese_name, f.name]}.to_h
  end

  def self.available
    all.select { |faq| faq.is_published }
  end

  def name_sym
    self.name.to_sym
  end

  def names
    where()
  end

  def self.where(criteria)
    all.select { |faq| faq.matches_criteria?(criteria) }
  end
  
  def self.find_by(criteria)
    all.find { |faq| faq.matches_criteria?(criteria) }
  end

  def matches_criteria?(criteria)
    criteria.all? { |key, value| self.send(key) == value }
  end

  def self.search(word)
    available.select do |faq|
      faq.question.include?(word) || (faq.words && faq.words.include?(word))
    end
  end
end