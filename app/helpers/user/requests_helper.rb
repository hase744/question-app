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
end
