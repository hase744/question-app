class Operation < ApplicationRecord
  belongs_to :admin_user
  enum state: CommonConcern.operation_states 
  scope :running, -> { where(state: "running") }
  scope :started, -> { where("start_at <= ?", DateTime.now) }
  scope :not_started, -> { where("? < start_at", DateTime.now) }
  scope :ordered_by_start, -> { order(start_at: :asc) }
  after_commit :update_operation_config

  # 次の operation の変更時刻を取得
  def self.operation_next_change_at
    not_started.minimum(:start_at)
  end

  # 最新の state を取得
  def self.latest_state
    started.ordered_by_start&.last&.state
  end

  # 最新の state を取得
  def self.latest_description
    started.ordered_by_start&.last&.description
  end

  # 最初の "running" 状態の operation を取得
  def self.first_running_operation
    running.not_started.ordered_by_start.first
  end
end
