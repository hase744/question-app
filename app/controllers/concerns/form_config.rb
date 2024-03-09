module FormConfig
    extend ActiveSupport::Concern
    include ConfigMethods
    #formの{日本語名：ID}をformのnameを引数にして返す
    def forms_japanese_hash(form=nil)#引数のformは最初にhashの順番で最初に入れるもの
        hash = config_value(sort:"form", key:"japanese:id")
        change_at = config_value(sort:"form", key:"change_at")
        if change_at.present? && change_at < DateTime.now
            update_form_config
        end

        if !hash.present?
            update_form_config
            hash = config_value(sort:"form", key:"japanese:id")
        end

        if form.present? 
            form_japanese = Form.find_by(name:form).japanese_name #先頭にしたいformの日本語名を取得
            first_hash = hash.slice(form_japanese) #先頭にしたいformのハッシュ
            if first_hash.present?
                hash.delete(form_japanese)#先頭にしたいformのハッシュを全体から削除
                hash = first_hash.merge(hash)#先頭にしたいformのハッシュを先頭に追加
            end
        end
        return hash
    end

    def update_form_config
        update_config(sort:"form", key:"change_at", value: form_next_change_at)
        update_config(sort:"form", key:"japanese:id", value: latest_forms)
    end
    
    def latest_forms#引数に指定されたフォームを先頭にしてformの {日本語名：ID} のハッシュを生成
        forms_hash = {}
        forms = Form.where("start_at < ?", DateTime.now)
        forms = forms.where("? < end_at", DateTime.now).or(forms.where(end_at:nil))
        forms.each do |f|
            forms_hash.store(f.japanese_name, f.id)
        end
        return forms_hash
    end

    def form_next_change_at
        start_at = Form.where("? < start_at",DateTime.now).minimum(:start_at)
        end_at = Form.where("? < end_at",DateTime.now).minimum(:end_at)
        changes = []
        changes.push(start_at) if start_at.present?
        changes.push(end_at) if end_at.present?
        #未来に変化するカテゴリーの中で、最も最近の値
        change_at = changes.min
        return change_at
    end
end