class AboutsController < ApplicationController
  layout :choose_layout

  private def choose_layout
    case action_name
    when 'index'
      'about'
    else
      'how_to_use'
    end
  end

  def index
  end

  def inquiry
  end

  def question
		@question_answer = Faq.available
    if params[:word].present?
      @question_answer = Faq.search(params[:word])
    end
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
