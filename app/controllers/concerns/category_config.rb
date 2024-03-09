module CategoryConfig
    extend ActiveSupport::Concern
    include ConfigMethods
    def latest_tree
        hash = {}
        #開始時刻を過ぎているカテゴリー
        categories = Category.where("start_at < ?", DateTime.now)
        #終了時刻を過ぎていない、もしくは終了時刻が未定
        categories = categories.where("? < end_at", DateTime.now).or(categories.where(end_at:nil))
        parent_categories = categories.where(parent_category_id:nil)

        parent_categories.includes(:parent_category).each do |c|
            child_categories = categories.where(parent_category_id: c.id).pluck(:name)
            hash[c.name] = child_categories
        end
        hash
    end
    
    def latest_category_e_to_j
        hash = {}
        #開始時刻を過ぎているカテゴリー
        categories = Category.where("start_at < ?", DateTime.now)
        #終了時刻を過ぎていない、もしくは終了時刻が未定
        categories = categories.where("? < end_at", DateTime.now).or(categories.where(end_at:nil))
        categories.all.each do |c|
            hash[c.name]=c.japanese_name
        end
        hash
    end

    def latest_category_e_to_id
        hash = {}
        #開始時刻を過ぎているカテゴリー
        categories = Category.where("start_at < ?", DateTime.now)
        #終了時刻を過ぎていない、もしくは終了時刻が未定
        categories = categories.where("? < end_at", DateTime.now).or(categories.where(end_at:nil))
        categories.all.each do |c|
            hash[c.name]=c.id
        end
        hash
    end

    def category_e_to_j(name=nil)
        hash = config_value(sort:"category", key:"english:japanese")
        if name
            hash[name]
        else
            hash
        end
    end

    def category_e_to_id(name=nil)
        hash = config_value(sort:"category", key:"english:id")
        if name
            hash[name]
        else
            hash
        end
    end

    def update_category_config
        update_config(sort:"category", key:"change_at", value: category_next_change_at)
        update_config(sort:"category", key:"tree", value: latest_tree)
        update_config(sort:"category", key:"list", value: latest_category_list)
        update_config(sort:"category", key:"english:japanese", value: latest_category_e_to_j)
        update_config(sort:"category", key:"english:id", value: latest_category_e_to_id)
    end

    def category_tree
        tree = config_value(sort:"category", key:"tree")
        change_at = config_value(sort:"category", key:"change_at")
        #変更時刻を過ぎていたら更新
        if change_at.present? && change_at < DateTime.now 
            update_category_config
        end

        if !tree.present?
            update_category_config
            tree = config_value(sort:"category", key:"tree")
        end
        return tree
    end

    def category_child_to_parent
        child_to_parent = {}
        category_tree.keys.each do |parent|
            category_tree[parent].each do |child|
                child_to_parent[child] = parent
            end
        end
        child_to_parent
    end

    def category_list
        list = config_value(sort:"category", key:"list")
        change_at = config_value(sort:"category", key:"change_at")
        #変更時刻を過ぎていたら更新
        if change_at.present? && change_at < DateTime.now 
            update_category_config
        end

        if !list.present?
            update_category_config
            list = config_value(sort:"category", key:"list")
        end
        return list
    end

    def latest_category_list
        #開始時刻を過ぎているカテゴリー
        categories = Category.where("start_at < ?", DateTime.now)
        #終了時刻を過ぎていない、もしくは終了時刻が未定
        categories = categories.where("? < end_at", DateTime.now).or(categories.where(end_at:nil))
        #以下なぜか上手くいかない
        #categories = categories.left_joins(:parent_category)
        #categories = categories.where(parent_category:nil).or(categories.where(parent_categories:{id: categories.pluck(:id)}))
        #return categories.pluck(:name)
        array = []
        categories.where(parent_category:nil).each do |pc|
            array.push(pc.name)
            pc.child_categories.each do |cc|
                array.push(cc.name)
            end
        end
        array
    end

    def category_next_change_at
        start_at = Category.where("? < start_at",DateTime.now).minimum(:start_at) #未来に始まるカテゴリーの中で開始時刻が最小
        end_at = Category.where("? < end_at",DateTime.now).minimum(:end_at) #未来に終わるカテゴリーの中で開始時刻が最小
        changes = []
        changes.push(start_at) if start_at.present?
        changes.push(end_at) if end_at.present? #一番最近の未来にカテゴリーに変化が生じる時刻
        change_at = changes.min #未来に変化するカテゴリーの中で、最も最近の値
        return change_at
    end
end