class PotentialSeller < ApplicationRecord
    #require 'open-uri'
    #require 'nokogiri'
    #require 'open_uri_redirections'
    before_validation :get_info_from_url
    belongs_to :proposer, class_name:"AdminUser", foreign_key: "proposer_id", optional:true
    belongs_to :inviter, class_name:"AdminUser", foreign_key: "inviter_id", optional:true
    belongs_to :user, optional:true
    belongs_to :category, optional:true
    validates :url, uniqueness: true

    def get_info_from_url
        #twitterのスクレイピングに失敗
    end
end
