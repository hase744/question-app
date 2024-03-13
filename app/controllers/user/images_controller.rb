class User::ImagesController < User::Base
    def answer
    end

    def show
        text = params[:text]
        criteria_width = params[:criteria_width].to_i
        mini_font_size = criteria_width*0.03
        max_font_size = criteria_width*0.05
  
        if text.length < criteria_width*0.1
          font_size = mini_font_size + ((max_font_size - mini_font_size) / criteria_width*0.1) * text.length
        else
          font_size = criteria_width*0.03
        end
        render 'user/images/description_image.html.erb', layout: false, locals: { 
            text: text,
            font_size: font_size,
            criteria_width: criteria_width
          }
    end
end
