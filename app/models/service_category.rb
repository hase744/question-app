class ServiceCategory < CategoryBase::Base
  belongs_to :service
  delegate :user, to: :service
  before_validation :check_changed

  def check_changed
    if self.will_save_change_to_category_name?
      self.service.renewed_at = DateTime.now
    end
  end
end
