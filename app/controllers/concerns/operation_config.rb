module OperationConfig
  include ConfigMethods
  # 現在の state をファイルから確認し、必要に応じて更新
  def current_state
    state = config_value(sort:"operation", key:"state")
    change_at = config_value(sort:"operation", key:"change_at")
    change_at ||= DateTime.new(9999, 12, 31, 0, 0, 0)
    #configのoperationgateのchange_atが過ぎていたら更新
    if change_at.nil? || change_at < DateTime.now
      update_operation_config
      state ||= config_value(sort:"operation", key:"state")
    end

    return state
  end

  def latest_description
    config_value(sort:"operation", key:"description")
  end

  def operation_start_at
    config_value(sort:"operation", key:"operation_start_at")
  end

  # operation の設定を更新
  def update_operation_config
    update_config(sort: "operation", key: "description", value: Operation.latest_description)
    update_config(sort: "operation", key: "operation_start_at", value: Operation.first_running_operation&.start_at)
    update_config(sort: "operation", key: "change_at", value: Operation.operation_next_change_at)
    update_config(sort: "operation", key: "state", value: Operation.latest_state)
  end
end