module HtmlUploader
  extend ActiveSupport::Concern
  include ConfigMethods
  def get_html(text)
    mini_font_size = 30
    max_font_size = 50
    
    if text.length < 100
      font_size = mini_font_size + ((max_font_size - mini_font_size) / 100) * text_length
    else
      font_size = 30
    end
    view_path = 'user/images/description_image'
    html_content = render_to_string(
      template: view_path, 
      layout: false, 
      locals: { 
        text: text,
        font_size: font_size
      })
  end

  def upload(file_path, file_content)
    s3 = Aws::S3::Resource.new(
      region: 'your-region', # AWSリージョン
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
    )
    obj = s3.bucket("cloud-converter-test").object(File.basename(file_path))
    obj.put(body: file_content, acl: 'public-read') # 'public-read'はアクセス権限の例。必要に応じて変更してください。

    # アップロードが成功したら何かしらの処理を行う（リダイレクトやメッセージ表示など）
  end
end
