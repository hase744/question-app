module TemplateConcern
  extend ActiveSupport::Concern
  def set_request_content
    if Rails.env.development?
      self.title ||= "仕事に対するモチベーション"
      self.description ||= "最近、仕事に対するモチベーションが低下しています。やりがいを感じられず、将来への不安が募っています。今の仕事を続けるべきか、それとも新しい道を模索すべきか悩んでいます。同じ環境でのルーティンに疲れ、新しい挑戦を求めていますが、安定感も捨てがたいです。どのようにして自分に合った仕事を見つけ、人生をより充実させることができるでしょうか？仕事と生活のバランスを取りながら、将来の展望を見据えるためのステップは何でしょうか？ご助言いただければ幸いです。"
    end
  end


  def set_service_content
    if Rails.env.development?
      self.title ||= "仕事の悩み相談"
      self.description ||= "専門的なアドバイスや解決策を提供し、悩みや疑問に対してリアルタイムでサポートします。豊富な経験をもとに、仕事に関する様々なテーマに対応可能です。進行中のプロジェクトやキャリアに関する相談から、スキルの向上やキャリアアドバイスまで、あらゆる仕事に関するトピックに対応いたします。プロフェッショナルな助言で仕事に自信を持ち、成功への一歩を踏み出しましょう。安心して相談できるプライベートな空間で、あなたの仕事に関する課題を共有し、解決に導くお手伝いを致します。"
    end
  end
 
  def image_with_default
    self.image&.url.present? ? self.image.url : '/corretech_icon.png'
  end
end