class MockUploader < UploaderBase
  # CarrierWaveでローカルファイルシステムを使用
  storage :file

  # ファイルを保存するディレクトリを変更
  def store_dir
    "uploads/tmp/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # 不要な画像処理をスキップする設定
  def cache_dir
    "#{Rails.root}/public/uploads/tmp/"
  end

  # 必要に応じて、画像処理を無効化
  def process?(*args)
    false
  end
end
