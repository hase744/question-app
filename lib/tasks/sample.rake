require_relative 'sample_data.rb'
namespace :sample do
  desc "サンプルの生成" 
  task create_users: :environment do
    SampleData.create_users
  end

  task create_services: :environment do
    SampleData.create_services
  end

  task create_requests: :environment do
    SampleData.create_requests
  end

  task create_transactions: :environment do
    SampleData.create_transactions
  end

  task create_all: :environment do
    SampleData.create_users
    SampleData.create_services
    SampleData.create_requests
    SampleData.create_transactions
  end
end
