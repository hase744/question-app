class MessageRecord
  include ActiveModel::Model
  attr_reader :records, :order, :only_answer, :page_number, :per_page, :all_records

  def initialize(request_id:, order: 'asc', only_answer: true, page: nil, per: nil, records: nil)
    @request_id = request_id
    @order = order
    @records = records || fetch_records
    @all_records = @records.dup
    @only_answer = only_answer
    @page_number = page_number
    @per_page = per_page
  end

  def where(only_answer: true, order: 'published_at')
    only_answer = true if only_answer == '1'
    only_answer = false if only_answer == '0'
    filtered_records = @records
    if only_answer
      filtered_records = filtered_records.select { |record| record.is_a?(Transaction) }
    end

    if order == 'published_at'
      filtered_records.reverse!
    end
    self.class.new(
      request_id: @request_id,
      order: @order,
      only_answer: only_answer,
      page: @page_number,
      per: @per_page,
      records: filtered_records
    )
  end

  def self.all(condition)
    new(
      request_id: condition[:request_id], 
      order: 'asc',
      only_answer: 'asc'
      )
  end

  def fetch_records
    request = Request.find(@request_id)
    
    # SQLクエリの構築
    transaction_sql = <<-SQL
    SELECT 'Transaction' AS record_type, id, created_at, published_at 
    FROM transactions
    WHERE request_id = #{ActiveRecord::Base.connection.quote(request.id)}
      AND is_published = true
    SQL

    if request.transactions.exists?
      transaction_message_sql = <<-SQL
        SELECT 'TransactionMessage' AS record_type, id, created_at, published_at 
        FROM transaction_messages
        WHERE transaction_id IN (#{request.transactions.pluck(:id).join(',')})
      SQL
    end

    # 動的に最終SQLを組み立てる
    final_sql_parts = []
    final_sql_parts << "(#{transaction_sql})"
    final_sql_parts << "(#{transaction_message_sql})" if request.transactions.exists?
    
    # UNION ALLで結合し、ORDER BYとLIMITを追加
    final_sql = <<-SQL
      #{final_sql_parts.join(" UNION ALL ")}
      ORDER BY published_at #{order}
    SQL

    # SQL実行
    records = ActiveRecord::Base.connection.execute(final_sql)

    # IDを分類してN+1解決のfind
    transaction_ids = records.map { |row| row['id'] if row['record_type'] == 'Transaction' }.compact
    transaction_message_ids = records.map { |row| row['id'] if row['record_type'] == 'TransactionMessage' }.compact

    transactions = Transaction.solve_n_plus_1.find(transaction_ids).to_a
    transaction_messages = TransactionMessage.solve_n_plus_1.find(transaction_message_ids).to_a

    # レコードをActiveRecordモデルに変換
    records.to_a.map do |row|
      case row['record_type']
      when 'Transaction'
        transactions.find { |model| model.id == row['id'] }
      when 'TransactionMessage'
        transaction_messages.find { |model| model.id == row['id'] }
      end
    end
  end

  def page(number)
    @page_number = number.to_i
    self
  end

  def per(number)
    @per_page = number.to_i
    start_index = (@page_number - 1) * @per_page
    @records = @records.slice(start_index, @per_page) || []
    self
  end

  def total_pages 
    (@all_records.length.to_f/@per_page).ceil 
  end

  def current_page
    @page_number
  end

  def limit_value
    10
  end
end
