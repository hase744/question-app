namespace :qa do
    desc "QuestionAnswerをリセット" #desc → description（説明）
    task reset: :environment do #task_nameは自由につけられる
        QuestionAnswer.all.each do |qa|
            qa.destroy
        end

        path = Rails.root.join("db", "seeds", "question_answer.rb")
        if File.exist?(path)
            puts "Creating question_answer...."
            require(path)
        end
    end
end
