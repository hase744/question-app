# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
include Variables
development_table_names = %w(user payment payout)

table_names = %w(user)

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

admin_user = AdminUser.create!(email: Rails.application.credentials.admin_user[:email],name: Rails.application.credentials.admin_user[:name], password: Rails.application.credentials.admin_user[:password], password_confirmation: Rails.application.credentials.admin_user[:password])
#AdminUser.create!(email: ENV["EMAIL1"],name:"hasegawa", password: ENV["PASSWORD"], password_confirmation: ENV["PASSWORD"]) #if Rails.env.development?
AdminUserRole.create(admin_user_id: AdminUser.first.id, role_name: Role.find_by(name:"super_admin").name) #if Rails.env.development?
Operation.create(
    admin_user: admin_user, 
    start_at: DateTime.now,
    state: 'running'
    )
