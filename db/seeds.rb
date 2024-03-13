# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
include Variables
development_table_names = %w(user payment relationship message)

table_names = %w(state user_state category form announce question_answer role media)

table_names.each do |table_name|
    path = Rails.root.join("db", "seeds", "#{table_name}.rb")
    if File.exist?(path)
        puts "Creating #{table_name}...."
        require(path)
    end
end

development_table_names.each do |table_name|
    path = Rails.root.join("db", "seeds", Rails.env, "#{table_name}.rb")
    if File.exist?(path)
        puts "Creating #{table_name}...."
        require(path)
    end
end


AdminUser.create!(email: ENV["EMAIL1"],name:"hasegawa", password: ENV["PASSWORD"], password_confirmation: ENV["PASSWORD"]) if Rails.env.development?
AdminUserRole.create(admin_user_id: AdminUser.first.id, role: Role.find_by(name:"super_admin")) if Rails.env.development?
