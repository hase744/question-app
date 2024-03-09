class User::ImagesController < User::Base
    def answer
    end

    def show
        @request = Request.find(params[:id])
    end
end
