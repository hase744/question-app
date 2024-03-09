class UserState < ApplicationRecord
    after_commit :create_file

    def create_file
        hash = {}
        UserState.all.each do |state|
            hash[state.id] = state.name
        end
        File.open("user_states.json","w") do |text|
            text.puts("#{hash.to_json}")
        end
    end
end
