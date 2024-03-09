module Countries
  extend ActiveSupport::Concern
  def countries
    [
      Country.new(name: 'japan')
    ]
  end

  def self.countries
  end
end