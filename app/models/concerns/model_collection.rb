module ModelCollection
  extend ActiveSupport::Concern

  included do
    def self.collection
      Collection.new(all)
    end

    def self.where(criteria)
      collection.where(criteria)
    end

    def self.find_by(criteria)
      collection.find_by(criteria)
    end
    
    def self.available
      all.select { |form| form.start_at < DateTime.now }
    end
  end

  class Collection
    include Enumerable

    def initialize(records)
      @records = records
    end

    def where(criteria)
      self.class.new(@records.select { |record| record.matches_criteria?(criteria) })
    end

    def find_by(criteria)
      @records.find { |record| record.matches_criteria?(criteria) }
    end

    def map(&block)
      @records.map(&block)
    end

    def select(&block)
      self.class.new(@records.select(&block))
    end

    def each(&block)
      @records.each(&block)
    end

    def length
      @records.length
    end

    def to_a
      @records
    end
  end
end
