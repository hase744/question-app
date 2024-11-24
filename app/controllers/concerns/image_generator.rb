module ImageGenerator
  extend ActiveSupport::Concern
  included do
    HCTI_API_USER_ID = Rails.application.credentials.hcti[:user_id]
    HCTI_API_KEY = Rails.application.credentials.hcti[:api_key]
  end

  #render_to_stringを使用するためControllerからの呼び出しが必要
  def generate_html_css_from_request(request)
    html_content = render_to_string(
      partial: "user/images/description.html.erb",
      locals: { 
        title: request.title, 
        text: request.description, 
        image_width: 500 }
    )
    css_content = render_to_string(
      partial: "user/images/description.css.erb",
      locals: { 
        text: request.description, 
        image_width: 500, 
        font_size: request.description_font_size(500),
        donwlaod_font: true }
    )
    [html_content, css_content]
  end

  def generate_image_from_content(html_content, css_content)
    response = HTTParty.post(
      "https://hcti.io/v1/image",
      body: { html: html_content, css: css_content },
      basic_auth:  { username: HCTI_API_USER_ID, password: HCTI_API_KEY }
    )
    if response.code == 200
      response.parsed_response["url"]
    else
      raise "Image generation failed: #{response.message}"
    end
  end

  def download_file_from_url(url)
    image_file = URI.open(url)
    image_tempfile = Tempfile.new(["generated_image", File.extname(url)])
    image_tempfile.binmode
    image_tempfile.write(image_file.read)
    image_tempfile.rewind
    image_tempfile
  ensure
    image_file&.close
  end
end
