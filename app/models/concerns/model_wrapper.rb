module ModelWrapper
  extend ActiveSupport::Concern

  class_methods do
    def selecter_hash
      all.map { |instance| [instance.japanese_name, instance.name] }.to_h
    end
  end

  def matches_criteria?(criteria)
    criteria.all? do |key, value|
      attribute_value = send(key)
      value.is_a?(Array) ? value.include?(attribute_value) : attribute_value == value
    end
  end
end
