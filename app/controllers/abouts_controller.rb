class AboutsController < ApplicationController
    layout "about"
    before_action :layout
    def index
    end

    def inquiry
        @question_answer = QuestionAnswer.all
    end

    def question
        @question_answer = QuestionAnswer.all
    end

    def announce
        #@announces = Announce.page(params[:page]).per(1)
        @announces = Announce.where("disclosed_at < ?", DateTime.now)
        @announces = @announces.order(disclosed_at: "DESC")
        @announces = @announces.page(params[:page]).per(10)
    end

    def layout
    end

    def how_to_sell
    end
end
