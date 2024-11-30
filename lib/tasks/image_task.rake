require "./app/helpers/image_helper.rb"
namespace :image_task do
    desc "image作成"
    task :make_image do
         # 生成した画像のFileClassを取得
        ImageHelper.build('何かしらの文字列を合成してみる').tempfile.open.read
        # 生成した画像の書き出し
        ImageHelper.write('何かしらの文字列を合成してみる')
    end

    desc "image変換"
    task :convert_image => :environment do
        @text = '実は世界のディズニーパークの中で、東京以外はすべてディズニー社による直営のパークです。では、どうして東京だけが、ディズニー直営ではないのでしょうか。
 
        今回の記事では、ディズニー社と、東京ディズニーリゾートを運営するオリエンタルランドとの関係について、見ていくことにしましょう。
         
        そもそも、どうして直営じゃないの？
        日本へのディズニーランド誘致を発案したのは、当時京成電鉄の社長を務めていた川崎千春氏でした。彼は三井不動産と共同で千葉県の浦安沖を埋め立て、その土地に新しい鉄道路線と、ディズニーランドを建設する構想を持っていました。
         
        実はオリエンタルランドはもともと、浦安沖の埋め立て事業のために作られた会社だったのです。その後、漁民との補償交渉がまとまり、オリエンタルランドは千葉県と共同で埋め立て工事に取り掛かります。
         
        親会社の京成や三井の意向を受けて、オリエンタルランドはディズニーに対して、日本でのディズニーランド建設を働きかけます。しかし、当時のディズニー社は、日本への進出に消極的でした。実業家だった松尾國三氏が、アナハイムのディズニーランドを稚拙に模倣した「奈良ドリームランド」を開園させ、ディズニー社は日本に対して強い不信感を持っていたのです。'
        @name = 'World'
        erb = File.read('./app/views/user/images/answer.html.erb')
        #send_data IMGKit.new(get_html("aaaaaa"), quality: 20, width: 800).to_img(:png), type: 'image/png', disposition: 'inline'
        kit = IMGKit.new(File.new('./app/views/user/images/answer.html'))
        img = kit.to_img
        request = Request.find_by(request_form: "text")
        name = SecureRandom.hex
        request.file = kit.to_file("./app/assets/images/#{name}.png")
        File.delete("./app/assets/images/#{name}.png")
        request.save
        #file = kit.to_file("./app/assets/images/#{SecureRandom.hex}.png")
    end 
end
