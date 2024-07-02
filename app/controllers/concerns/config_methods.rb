module ConfigMethods
  #"config.jsonのファイルを書き換える"
  def update_config(key:nil, value:nil, sort:nil)
    if File.exist?('config.json')
      begin#configファイルを読み込む
        file = File.read("config.json")
        hash = JSON.parse(file)

        #以下ハッシュを編集
        if sort #ソートがある
          if hash[sort] #ハッシュに既にそのソートがある
            hash[sort][key] = value
          else
            hash[sort] = {key=>value}
          end
        else
          hash[key] = value
        end
      rescue => e#読み込みに失敗した時、引数だけでハッシュを作成
        puts "configファイル読み込みエラー"
        puts e
        if sort
          hash = {sort=>{key=>value}}
        else
          hash = {key=>value}
        end
      end
    else
      puts 'config.jsonファイルは存在しません。'
      if sort
        hash = {sort=>{key=>value}}
      else
        hash = {key=>value}
      end
    end
    File.open("config.json","w") do |text|
      text.puts(hash.to_json)
    end
  end

  #configファイルにあるキーから値を取得
  def config_value(key:nil, sort:nil)
    if File.exist?('config.json')#configファイルが存在する
      begin#configファイルを読み込む
        file = File.read("config.json")
        hash = JSON.parse(file)

        if sort
          value = hash[sort][key]
        else
          value = hash[key]
        end

        begin #DateTimeなどrubyに変換できる元はrubyで返す
          return JSON.parse(value)
        rescue => e #json以外の形式の時
          puts e
          return value
        end
      rescue => e#読み込みに失敗した時、エラーを返す
        puts "キー:#{key} ソート:#{sort}の読み込み失敗"
        puts e
        nil
      end
    else#configファイルが存在しない
      return nil
    end
  end
end