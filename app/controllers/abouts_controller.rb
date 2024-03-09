class AboutsController < ApplicationController
    layout "about"
    before_action :layout
    def index
        puts gon.layout
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
        gon.layout = "about"
    end

    def how_to_sell
        @categories = ""
        category_list.each do |category|
            @categories += "、#{category_e_to_j(category)}"
        end
        @forms = ""
        forms_japanese_hash.keys.each do |f|
            @forms += f
            if f != forms_japanese_hash.keys.last
                @forms += "、"
            end
        end
    end
end
