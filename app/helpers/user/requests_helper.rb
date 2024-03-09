module User::RequestsHelper

    def service_request_form_text
        if @service
            if @service.request_form.name == "text"
                true
            else
                false
            end
        else
            false
        end
    end

    def service_request_text_max_length
        if @service
            if @service.request_form.name == "text"
                @request_max_length
            else
                1000
            end
        else
            1000
        end
    end

    def can_suggest?
        if  @request.is_inclusive &&  user_signed_in?
            if @request.suggestion_deadline > DateTime.now 
                if !@request.services.where(user: current_user).present? && @request.user != current_user
                    true
                else
                    puts "aa"
                    false
                end
            else
                puts "ii"
                false
            end
        else
            puts "uu"
            false
        end 
    end
end
