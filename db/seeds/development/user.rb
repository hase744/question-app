require 'open-uri'


uri = "https://img2.lancers.jp/userprofile/2317369/2817270/a390fa007d8011e926aa8a0ed08f1e457690e92d150974436753e5edba824d13/30517800_150_0.png"
image_uri = URI.parse(uri) # uriを直接openするとセキュリティ的に問題があるためURI.parseする
res = OpenURI.open_uri(image_uri, "Referer" => "https://img2.lancers.jp/userprofile/2317369/2817270/a390fa007d8011e926aa8a0ed08f1e457690e92d150974436753e5edba824d13/30517800_150_0.png")
file = CarrierWave::SanitizedFile.new(tempfile: res, filename: res.base_uri.to_s, content_type: res.content_type)

uri = "https://knsoza1.com/wp-content/uploads/2020/07/fd6ab37249a8470d2d5e0f9cdd987192.png"
image_uri = URI.parse(uri) # uriを直接openするとセキュリティ的に問題があるためURI.parseする
res = OpenURI.open_uri(image_uri, "Referer" => "https://knsoza1.com/wp-content/uploads/2020/07/fd6ab37249a8470d2d5e0f9cdd987192.png")
file2 = CarrierWave::SanitizedFile.new(tempfile: res, filename: res.base_uri.to_s, content_type: res.content_type)

user = User.new(
    email: ENV["EMAIL1"],
    name: "ハセ",
    password: ENV["PASSWORD"],
    password_confirmation: ENV["PASSWORD"],
    #image: file,
    confirmed_at: Time.now,
    is_seller: true,
    youtube_id: "",
    is_dammy: true,
    #categories: "business",
    phone_number: ENV["PHONE_NUMBER"],
    stripe_account_id: ENV["STRIPE_ACCOUNT_ID"],
    phone_confirmed_at: Time.now,
    description:"ここにユーザーの自己紹介を表示させる。例えば特技、暦何年かなどを自由に記入できる。",
    last_login_at:DateTime.now
)
user.process_image_upload = true
#user.assign_attributes(image:file)
user.image = file
user.save

user = User.new(
    email: ENV["EMAIL2"],
    name: "ハセ２",
    password: ENV["PASSWORD"],
    password_confirmation: ENV["PASSWORD"],
    #image: file2,
    confirmed_at: Time.now,
    is_seller: true,
    youtube_id: "",
    is_dammy: true,
    #categories: "business",
    stripe_customer_id:ENV["STRIPE_CUSTOMER_ID"],
    stripe_card_id: ENV["STRIPE_CARD_ID"],
    description:"ここにユーザーの自己紹介を表示させる。例えば特技、暦何年かなどを自由に記入できる。",
    last_login_at:DateTime.now
)
user.process_image_upload = true
#user.assign_attributes(image:file2)
user.image = file2
user.save

