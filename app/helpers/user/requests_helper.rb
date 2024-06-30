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
end
