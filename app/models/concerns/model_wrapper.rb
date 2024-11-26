# app/models/concerns/model_wrapper.rb
module ModelWrapper
  extend ActiveSupport::Concern

  class_methods do
    def selecter_hash
      all.map { |instance| [instance.japanese_name, instance.name] }.to_h
    end

    def where(criteria)
      all.select { |instance| instance.matches_criteria?(criteria) }
    end

    def not_where(criteria)
      all.reject { |instance| instance.matches_criteria?(criteria) }
    end

    def find_by(criteria)
      all.find { |instance| instance.matches_criteria?(criteria) }
    end

    def first
      all[0]
    end
  end

  def matches_criteria?(criteria)
    criteria.all? do |key, value|
      attribute_value = send(key)
      value.is_a?(Array) ? value.include?(attribute_value) : attribute_value == value
    end
  end
end
