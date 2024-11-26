namespace :uploads do
  desc "Delete old folders from public/uploads/tmp"
  task cleanup_tmp: :environment do
    tmp_dir = Rails.root.join('public', 'uploads', 'tmp')

    Dir.glob(tmp_dir.join('*')).each do |folder|
      if File.directory?(folder)
        FileUtils.rm_rf(folder) # フォルダごと削除
      end
    end

    puts "Cleanup completed for #{tmp_dir}"
  end
end
