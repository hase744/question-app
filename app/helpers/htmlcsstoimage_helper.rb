require "htmlcsstoimage"
module HtmlcsstoimageHelper
  extend ActiveSupport::Concern
  CRITERIA_WIDTH = 500
  USER_ID = "c7ba598c-c1c2-491a-b711-d07fe644c762"
  API_KEY = "1eef72eb-2617-4aaf-bf77-948a1e001652"
  class << self
    def get_html(text)
      mini_font_size = CRITERIA_WIDTH*0.03
      max_font_size = CRITERIA_WIDTH*0.05

      if text.length < CRITERIA_WIDTH*0.1
        font_size = mini_font_size + ((max_font_size - mini_font_size) / CRITERIA_WIDTH*0.1) * text_length
      else
        font_size = CRITERIA_WIDTH*0.03
      end
      view_path = 'user/images/description_image.html.erb'
      ac = ApplicationController.new
      html_content = ac.render_to_string(
        template: view_path, 
        layout: false, 
        locals: { 
          text: text,
          font_size: font_size,
          criteria_width: CRITERIA_WIDTH
        }
      )
      return html_content
    end

    def get_image(text)
      begin
      file_content = get_html(text)
      puts file_content
      client = HTMLCSSToImage.new(user_id: USER_ID, api_key: API_KEY)
      image = client.create_image("<div>Hello, world</div>",
                                css: "",
                                google_fonts: "")
      puts "ユーアールエル"
      puts image.url
      rescue => e
        puts e
      end
      return image.url
    end
  end
end