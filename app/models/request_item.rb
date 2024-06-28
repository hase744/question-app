class RequestItem < ApplicationRecord
    belongs_to :request, optional: true
    attr_accessor :use_youtube
    attr_accessor :service
    attr_accessor :file_duration
    attr_accessor :duration
    attr_accessor :youtube_id_valid
    mount_uploader :file, FileUploader
    before_validation :set_default_values
  
    validate :validate_youtube_id
    validate :validate_file
    #validate :validate_thumbnail
    validate :validatable_duration
  
    after_initialize do
      puts "ここ！"
      if self.youtube_id.present?
        self.use_youtube = true
      else
        self.use_youtube = false
      end
    end

    def request_form
      self.request.request_form
    end

  
    def is_published
      self.request.is_published
    end
  
    def set_default_values
      request = self.request

      case self.use_youtube
      when "1" then
        self.use_youtube = true
      when "0" then
        self.use_youtube = false
      end
  
      transaction = Transaction.find_by(request:self.request)
      if transaction.present? #transaction作成済み
        self.service = transaction.service
      end

      if request.service_id #依頼をcreateの時
        self.service = Service.find(request.service_id)
      end
  
      case request_form.name
      when "text" then
        self.youtube_id = nil
      when "image" then
        #self.thumbnail = self.file
        #self.youtube_id = nil
      when "video" then
        if self.use_youtube
          self.thumbnail = nil
          self.file = nil
        else
          self.youtube_id = nil
        end
      end

      if request_form.name == "video"
        #MediaInfoが本番環境では使えないため self.file.present?
        if self.file.present?
          self.duration = self.file_duration
        end
        if self.use_youtube
          self.duration = get_video_second
        end
      end

    end
    
    def validate_youtube_id
      if self.will_save_change_to_youtube_id?
        if  self.request_form.name == "text"
          errors.add(:youtube_id, "が適切ではありません") if self.youtube_id.present?
        elsif self.request_form.name == "image"
          errors.add(:youtube_id, "が適切ではありません") if self.youtube_id.present?
        elsif self.request_form.name == "video"
          if self.use_youtube && !is_youtube_id_valid?
            errors.add(:youtube_id, "が適切ではありません")
          end
        end
      end
    end

    def validatable_duration
      if self.request_form.name == "video"
        if self.service.present? && self.service.request_max_duration
          if !self.duration.present?
            errors.add(:duration, "がありません")
          elsif self.duration.to_i > self.service.request_max_duration
            errors.add(:duration, "は最大#{self.service.request_max_duration}秒です")
          end
        end
      end
    end
  
    def validate_file
      if  self.request_form.name == "text" && self.is_published
        errors.add(:file, "をアップロードして下さい") if !self.file.present? #&& self.validate_published
        #errors.add(:file, "のフォーマットが正しくありません") if !is_image_extension #&& self.validate_published
      elsif self.request_form.name == "image"
        errors.add(:file, "をアップロードして下さい") if !self.file.present? #&& self.validate_published
      elsif self.request_form.name == "video"
        if !self.use_youtube
          errors.add(:file, "のフォーマットが正しくありません") if !is_video_extension #&& self.validate_published
          errors.add(:file, "をアップロードして下さい") if !self.file.present? #&& self.validate_published
        end
      end
    end
  
    def validate_thumbnail
      if  self.request_form.name == "text"
        #errors.add(:thumbnail, "が不正な値です") if !self.thumbnail.url.present?
      elsif self.request_form.name == "image"
        errors.add(:thumbnail, "が不正な値です") if !self.thumbnail.url.present?
      elsif self.request_form.name == "video"
        if !self.use_youtube
          errors.add(:thumbnail, "が不正な値です") if !self.thumbnail.url.present? #&& self.validate_published
        end
      end
    end
  
  
    def is_video_extension
      if self.file.present?
        file_extension = File.extname(self.file.path).delete(".")
        if FileUploader.new.extension_allowlist.include?(file_extension) && !ImageUploader.new.extension_allowlist.include?(file_extension)
          true
        else
          false
        end
      else
        false
      end
    end
  
    def is_image_extension
      if self.file.present?
        file_extension = File.extname(self.file.path).delete(".")
        if ImageUploader.new.extension_allowlist.include?(file_extension)
          true
        else
          false
        end
      else
        false
      end
    end
  
    def get_video_second
      if self.use_youtube
        self.youtube_id_valid = false
        begin
          require 'google/apis/youtube_v3'
          youtube = Google::Apis::YoutubeV3::YouTubeService.new
          youtube.key = ENV["YOUTUBE_V3_KEY"]
          
          response = youtube.list_videos("contentDetails", id:self.youtube_id)
          
          pt = response.items[0].content_details.duration
          if pt.to_s.include?("M") #1分以下の時PT○○M○○Sの形
            video_length = /PT(?<min>\d+)M(?<sec>\d+)S/.match(pt)
            min = video_length["min"].to_i
            sec = video_length["sec"].to_i
            video_second = min*60 + sec
          else #1分以下の時PT○○Sの形
            video_length = /PT(?<sec>\d+)S/.match(pt)
            sec = video_length["sec"].to_i
            video_second = sec
          end
          self.youtube_id_valid = true if video_second.present?
          video_second
        rescue => e
          false
        end
      elsif self.file.present?
        #Mediainfoが本番環境で使えないので下は使われていない
        url = self.file.url
        metadata = MediaInfo.from(url)
        duration = metadata.video.duration/1000
        duration
      end
    end
  
    private def is_youtube_id_valid?
      self.youtube_id_valid
    end
end
