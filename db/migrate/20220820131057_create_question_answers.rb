class CreateQuestionAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :question_answers do |t|
      t.string :sort
      t.text :question
      t.text :answer
      t.references :admin_user

      t.timestamps
    end
  end
end
