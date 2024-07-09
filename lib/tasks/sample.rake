require_relative 'sample_data.rb'
namespace :sample do
  desc "サンプルの生成" 
  task create_users: :environment do
    Sample.create_users
  end

  task create_services: :environment do
    Sample.create_services
  end

  task create_requests: :environment do
    Sample.create_requests
  end

  task create_transactions: :environment do
    Sample.create_transactions
  end

  task create_all: :environment do
    Sample.create_users
    Sample.create_services
    Sample.create_requests
    Sample.create_transactions
  end
end
