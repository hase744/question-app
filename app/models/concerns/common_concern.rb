module CommonConcern
    extend ActiveSupport::Concern
    def all_models_valid?(models)
        models_valid = true
        begin
            if models.instance_of?(Array) #配列である
                models.each do |model|
                    if model.invalid? #保存不可
                        models_valid = false
                        break
                    end
                end
            else
                models_valid = false if models.invalid? #保存不可
            end
            models_valid
        rescue
            false
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
            false
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
    
end