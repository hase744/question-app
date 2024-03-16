module CommonConcern
  extend ActiveSupport::Concern
  def all_models_valid?(models)
    begin
      if models.instance_of?(Array) #配列である
        models.each do |model|
          if model.present? && model.invalid? #保存不可
            return false
          end
        end
      else
        return false if models.invalid? #保存不可
      end
      return true
    rescue
      return false
    end
  end
  
  def get_invalid_models(models)
    invalid_models = []
    begin
      if models.instance_of?(Array) #配列である
        models.each do |model|
          if model.invalid? #保存不可
            invalid_models.push(model)
          end
        end
      else
        models_valid = false if models.invalid? #保存不可
      end
      invalid_models
    rescue
        alse
    end
  end
  
  def detect_models_errors(models)
    begin
      if models.instance_of?(Array) #配列である
        models.each do |model|
          if model.invalid? #保存不可
            model.save
          end
        end
      else
          models_valid = false if models.invalid? #保存不可
      end
    rescue
    end
  end

  def file_html_path
    file_array = self.file.path.split('/')
    file_array = file_array.take(file_array.length - 1)
    file_path = file_array.join('/')
    file_key = "#{file_path}/index.html"
  end

  def file_html_path
    file_array = self.file.path.split('/')
    file_array = file_array.take(file_array.length - 1)
    file_path = file_array.join('/')
    file_key = "#{file_path}/index.html"
  end

  def self.user_states
    [:normal, :suspended, :register, :browse, :deleted]
  end

  def self.operation_states
    [:running, :suspended, :register, :browse]
  end

  def is_normal
    self.state == 'normal'
  end

  def is_running
    self.state == 'running'
  end

  def is_suspended
    self.state == "suspended"
  end

  def is_register
    self.state == "register"
  end

  def is_browse
    self.state == "browse"
  end

  def is_deleted
    self.state == "deleted"
  end
end