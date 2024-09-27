module OperationConfig
  include ConfigMethods
  extend ActiveSupport::Concern
  def latest_state
    operation = Operation.where("start_at <= ?", DateTime.now).last
    operation.state
  end

  def update_operation_config
    update_config(sort:"operation", key:"change_at", value: operation_next_change_at)
    update_config(sort:"operation", key:"state", value: latest_state)
  end

  #現在のstateをファイルから確認、変更時期を過ぎていたらdbを参照して更新
  def current_state
    puts "状態"
    state = config_value(sort:"operation", key:"state")
    change_at = config_value(sort:"operation", key:"change_at")
    #configのoperationのchange_atが過ぎていたら更新
    if change_at.present? && change_at < DateTime.now
      update_operation_config
    end

    if !state.present?
      update_operation_config
      state = config_value(sort:"operation", key:"state")
    end
    return state
  end

  def operation_next_change_at
    changes = []
    operations = Operation.where("? < start_at",DateTime.now)
    start_at = operations.minimum(:start_at) #未来に始まるオペレーションの中で開始時刻が最小
    change_at = start_at
    return change_at
  end

  def first_running_operation
    operations = Operation.where(state:State.find_by(name:"running"))
    operations = operations.where("? < start_at",DateTime.now)
    operations = operations.order(start_at: "ASC")
    operations.first
  end
end