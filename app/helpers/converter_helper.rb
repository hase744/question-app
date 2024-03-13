#require 'cloudconvert'
module ConverterHelper
  extend ActiveSupport::Concern
  CRITERIA_WIDTH = 500
  KEY = Rails.application.credentials.cloud_front[:key]
  ACCESS_KEY_ID = Rails.application.credentials.cloud_front[:access_key_id]
  SECRET_ACCESS_KEY = Rails.application.credentials.cloud_front[:secret_access_key]
  FORMAT = 'jpg'
  class << self
    def get_html(text, file_name)
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
      file_path = Rails.root.join('public', 'uploads', "#{file_name}.html")
      File.open(file_path, 'w') { |file| file.write(html_content) }
      return file_path.to_s
    end

    def upload(local_path, remote_key)
      file_array = remote_key.split('/')
      file_array = file_array.take(file_array.length - 1)
      file_path = file_array.join('/')
      file_path = "#{file_path}/index.html"
      s3 = Aws::S3::Resource.new(
        region: 'eu-west-1',
        access_key_id: ACCESS_KEY_ID,
        secret_access_key: SECRET_ACCESS_KEY,
      )
      s3.bucket('cloud-converter-test').object(file_path).upload_file(local_path)
      #obj = s3.bucket('cloud-converter-test').object(File.basename(file_path))
      #obj.put(body: file_content)
    end

    def convert(item)
      puts "ファイル"
      puts item.file.path
      file_key = item.file_html_path
      cloudconvert = CloudConvert::Client.new(
        api_key: KEY, 
        sandbox: false
        )
      begin
        response = cloudconvert.jobs.create({
          tasks: [
            {
              "name": "import-1",
              "operation": "import/s3",
              "bucket": "cloud-converter-test",
              "region": "eu-west-1",
              "access_key_id": ACCESS_KEY_ID,
              "secret_access_key": SECRET_ACCESS_KEY,
              "key": file_key
            },
            {
              "name": "task-1",
              "operation": "convert",
              "input_format": "html",
              "output_format": FORMAT,
              "engine": "chrome",
              "input": [
                  "import-1"
                ],
              "screen_width": CRITERIA_WIDTH,
              #"screen_width": 600,
              #"screen_height": 400,
              "wait_until": "load",
              "wait_time": 0
            },
            {
              "name": "export-1",
              "operation": "export/s3",
              "input": [
                  "task-1"
                ],
              "bucket": "cloud-converter-test",
              "region": "eu-west-1",
              "access_key_id": ACCESS_KEY_ID,
              "secret_access_key": SECRET_ACCESS_KEY,
              "key": item.file.path
            }
          ]
        })
        publish(item.file.path)
        return true
      rescue => e
        return false
      end
    end

    def publish(path)
      sleep(5)
      s3 = Aws::S3::Resource.new(
        region: 'eu-west-1',
        access_key_id: ACCESS_KEY_ID,
        secret_access_key: SECRET_ACCESS_KEY,
      )
      
      bucket_name = "cloud-converter-test" 
      object_key = path
      
      # バケットポリシーを更新してオブジェクトをpublicに設定
      bucket = s3.bucket(bucket_name)
      object = bucket.object(object_key)
      
      object_acl = object.acl
      object.acl.put(acl: 'public-read')
    end
  end
end