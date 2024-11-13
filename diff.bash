diff --git a/app/assets/stylesheets/user/request/show.scss b/app/assets/stylesheets/user/request/show.scss
index dcd1521..4dfbce8 100644
--- a/app/assets/stylesheets/user/request/show.scss
+++ b/app/assets/stylesheets/user/request/show.scss
@@ -1,3 +1,4 @@
+@import "_variables";
 .request_show_zone{
     overflow: hidden;
     .request_area{
@@ -80,20 +81,70 @@
             //        }
             //    }
             //}
-            .request_detail{
-                .request_detail_label{
-                    margin: 0px;
-                    margin-top: 5px;
+            .text_area{
+                position: relative;
+                margin-bottom: 5px;
+                .change_button_area{
+                    text-align: right;
+                    justify-content: flex-end;
+                    display: flex;
                 }
-                .request_detail_content{
-                    margin: 0px 10px;
-                    width: calc(100% - 20px);
-                    line-height: 30px;
-                    .request_detail_text{
-                        margin: 0px;
-                        white-space: pre-line;
+                .change_button{
+                    color: grey;
+                    display: flex;
+                    width: 110px;
+                    //position: absolute;
+                    bottom: -15px;
+                    right: 15px;
+                    background-color: white;
+                    padding: 5px;
+                    border-radius: 10px;
+                    cursor: pointer;
+                    border: 2px solid lightgray;
+                    text-align: right;
+                    justify-content: space-around;
+                    .thumbnail{
+                        width: 20px;
+                        height: 20px;
+                        object-fit: cover;
+                    }
+                    label{
+                        font-size: 15px;
+                        text-align: right;
+                        font-weight: bold;
+                        display: flex;
+                        align-items: center;
                     }
                 }
+                .fa-solid{
+                    font-size: 25px;
+                    display: flex;
+                }
+            }
+            .text_area.image_mode{
+                .request_description_area{
+                    display: none;
+                }
+                .thumbnail{
+                    display: none;
+                }
+            }
+            .text_area.text_mode{
+                .text_image{
+                    display: none;
+                }
+                .fa-solid{
+                    display: none;
+                }
+            }
+            .request_description_area{
+                margin: 0px 10px;
+                width: calc(100% - 20px);
+                line-height: 30px;
+                .request_description{
+                    margin: 0px;
+                    white-space: pre-line;
+                }
             }
             .youtube_video{
                 width: 100%;
diff --git a/app/models/request.rb b/app/models/request.rb
index afd0495..5566d9e 100644
--- a/app/models/request.rb
+++ b/app/models/request.rb
@@ -10,6 +10,7 @@ class Request < ApplicationRecord
   has_many :request_categories, class_name: "RequestCategory", dependent: :destroy
   has_many :supplements, class_name: "RequestSupplement", dependent: :destroy
   has_one :request_category, dependent: :destroy
+  has_one :item, dependent: :destroy, class_name: "RequestItem"
   delegate :category, to: :request_category, allow_nil: true
   has_many :likes, class_name: "RequestLike"
 
diff --git a/app/views/layouts/_head.html.erb b/app/views/layouts/_head.html.erb
index 8f2d3ac..0d1e5dc 100644
--- a/app/views/layouts/_head.html.erb
+++ b/app/views/layouts/_head.html.erb
@@ -20,6 +20,7 @@
     <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
     <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
     <script src="https://cdnjs.cloudflare.com/ajax/libs/jscroll/2.4.1/jquery.jscroll.js"></script>
+    <script src="https://cdnjs.cloudflare.com/ajax/libs/js-cookie/3.0.1/js.cookie.min.js"></script>
     <%= render "user/shared/swiper" %>
     <!-- Development -->
     <%if Rails.env.development?%>
diff --git a/app/views/user/requests/index.html.erb b/app/views/user/requests/index.html.erb
index edbe481..f66f191 100644
--- a/app/views/user/requests/index.html.erb
+++ b/app/views/user/requests/index.html.erb
@@ -25,8 +25,6 @@
 </div>
 <script>
 set_search_detail();
-//content.options[0].selected = false;
-//content.options[1].selected = true;
 </script>
 
 <script>
diff --git a/app/views/user/requests/show.html.erb b/app/views/user/requests/show.html.erb
index 875a01f..7d7f8ce 100644
--- a/app/views/user/requests/show.html.erb
+++ b/app/views/user/requests/show.html.erb
@@ -15,8 +15,27 @@
                 <h3 class="request_title">
                     <%=@request.title%>
                 </h3>
+                <% @request.categories.each do |category| %>
+                    <%= link_to category.japanese_name, user_requests_path(categories: category.name), class:"big_name_tag" %>
+                <% end %>
                 <div>
                 質問者：<%= link_to @request.user.name, user_account_path(@request.user.id) %>
+                    <% if @request.user == current_user%>
+                        <div class="edit_delete_area">
+                            <% if @request.user == current_user && !Transaction.exists?(request_id:params[:id]) %>
+                                <div class="edit_delete_area">
+                                    <%= link_to "削除", user_request_path(@request.id), method: "delete", class:"delete button", data: {confirm: "質問を削除しますか？。"} %>
+                                </div>
+                            <% elsif @request.can_stop_accepting? %>
+                                <div class="edit_delete_area">
+                                    <%= link_to "取り下げ", user_request_stop_accepting_path(@request.id), method: "put", class:"delete button", data: {confirm: "質問を取り下げますか？。\n取り消しできません"} %>
+                                </div>
+                            <% end %>
+                            <%if @request.is_suppliable %>
+                                <%= link_to "補足", new_user_request_supplement_path(request_id: @request.id)%>
+                            <% end %>
+                        </div>
+                    <% end %>
                 </div>
             </div>
             <!--
@@ -44,26 +63,9 @@
                     <% end %>
                 </div>
                 <div class='score_area_right'>
-                    <% if @request.user == current_user%>
-                        <div class="edit_delete_area">
-                            <% if @request.user == current_user && !Transaction.exists?(request_id:params[:id]) %>
-                                <div class="edit_delete_area">
-                                    <%= link_to "削除", user_request_path(@request.id), method: "delete", class:"delete button", data: {confirm: "質問を削除しますか？。"} %>
-                                </div>
-                            <% elsif @request.can_stop_accepting? %>
-                                <div class="edit_delete_area">
-                                    <%= link_to "取り下げ", user_request_stop_accepting_path(@request.id), method: "put", class:"delete button", data: {confirm: "質問を取り下げますか？。\n取り消しできません"} %>
-                                </div>
-                            <% end %>
-                            <%if @request.is_suppliable %>
-                                <%= link_to "補足", new_user_request_supplement_path(request_id: @request.id)%>
-                            <% end %>
-                        </div>
-                    <% else %>
                         <%= link_to(user_request_likes_path(id: @request.id), class: "like_button #{@request.liked_class(current_user)}", id:"like_button", method: :post, remote:true) do%>
                             <span class="fas fa-heart" ></span>&nbsp;いいね　　<span id="like_count"><%=@request.total_likes%></span>&nbsp;
                         <% end %>
-                    <% end %>
                 </div>
             </div>
             <%= render "user/shared/small_label", text:"条件"%>
@@ -105,28 +107,19 @@
                     </td>
                 </tr>
             </table>
-            <div class="request_detail">
+            <div class="text_area">
                 <%= render "user/shared/small_label", text:"本文"%>
-                <div class="request_detail_content" id="request_detail_content">
-                    <p id="request_detail_text" class="request_detail_text"><%=@request.description%></p>
+                <div class="request_description_area" id="request_description_area">
+                    <p id="request_description" class="request_description"><%=@request.description%></p>
                 </div>
-            </div>
-            <% @request.categories.each do |category| %>
-                <%= link_to category.japanese_name, user_requests_path(categories: category.name), class:"big_name_tag" %>
-            <% end %>
-            <div class="item_area">
-                <%if @request.use_youtube%>
-                    <iframe class="youtube_video 16_to_9" src="https://www.youtube.com/embed/<%=@request.youtube_id%>" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
-                <% elsif @request.items.present? %>
-                    <% if @request.request_form_has_image? %>
-                        <% if @request.items.first.is_text_image %>
-                            <%= render 'user/shared/adjustable_image', request: @request%>
-                        <% else %>
-                            <%= render "user/shared/swiper_images", model: @request, use_thumb:false %>
-                        <% end %>
-                    <% elsif @request.request_form.name == "video" %>
-                        <%= video_tag @request.file.url,poster:@request.thumbnail.url, class:"image", controls: true, autobuffer: true%>
-                    <% end %>
+                <% if @request.items.text_image.present? %>
+  	  	            <%= image_tag @request.item.file.url, class:"image text_image" %>
+                    <div class="change_button_area">
+                        <div class="change_button" id="change_button">
+  	  	                    <%= image_tag @request.thumb_with_default, class:"thumbnail" %>
+                            <span class="fa-solid fa-arrow-rotate-right"></span><label>画像を表示</label>
+                        </div>
+                    </div>
                 <% end %>
             </div>
             <%if @request.supplements.present? %>
@@ -206,6 +199,34 @@ $('.main_area').css('padding-bottom','50px');
     </div>
 </div>
 <script>
+$(document).ready(function() {
+    // ページ読み込み時にCookieを確認し、サイドバーの表示状態を設定
+    change_image_and_text();
+    function change_image_and_text(){
+        if (Cookies.get('text_image') === 'show' && $('.change_button_area').length) {
+            $('.text_area').addClass('image_mode');
+            $('.text_area').removeClass('text_mode');
+            $('#change_button label').text('文章を表示');
+        } else {
+            $('.text_area').addClass('text_mode');
+            $('.text_area').removeClass('image_mode');
+            $('#change_button label').text('画像を表示');
+        }
+    }
+
+    // ボタンがクリックされたときの処理
+    $('#change_button').on('click', function() {
+        // 現在の表示状態をCookieに保存
+        if ($('.text_image').is(':visible')) {
+            Cookies.set('text_image', 'hide', { expires: 7 }); // 7日間有効
+        } else {
+            Cookies.set('text_image', 'show', { expires: 7 }); // 7日間有効
+        }
+        change_image_and_text();
+    });
+});
+
+
 over_600_slide_count = <%=@request.items.length.clamp(1, 3) %><%%>
 
 var swiper = new Swiper('.swiper-container', {
diff --git a/public/.DS_Store b/public/.DS_Store
index 3ccc87f..9802337 100644
Binary files a/public/.DS_Store and b/public/.DS_Store differ
diff --git a/.DS_Store b/.DS_Store
index 046dbb7..b0c1639 100644
Binary files a/.DS_Store and b/.DS_Store differ
diff --git a/app/assets/stylesheets/layout/search_layout.scss b/app/assets/stylesheets/layout/search_layout.scss
index 3634cbc..4e6881f 100644
--- a/app/assets/stylesheets/layout/search_layout.scss
+++ b/app/assets/stylesheets/layout/search_layout.scss
@@ -9,6 +9,11 @@
 			max-width: 700px;
 		}
 	}
+	@media (max-width:1000px) {
+		.main_header{
+			margin-top: 0px;
+		}
+	}
 }
 .top_search_form_area{
 	//background-color: white;
@@ -63,6 +68,7 @@
 		z-index: 5;
 		width: 37.5px;
 		height: 37.5px;
+		right: 0px;
 		opacity: 0;
 		cursor: pointer;
 	}
diff --git a/app/assets/stylesheets/user/order/cell.scss b/app/assets/stylesheets/user/order/cell.scss
index 4f42460..e61715b 100644
--- a/app/assets/stylesheets/user/order/cell.scss
+++ b/app/assets/stylesheets/user/order/cell.scss
@@ -16,6 +16,7 @@ $image_width: 80px;
   	width: calc(100% - 20px);
   	display: flex;
   	color: black;
+	height: $image_height;
   	.image_area{
   	    height: $image_height;
   	    width: $image_width;
diff --git a/app/assets/stylesheets/user/request/preview.scss b/app/assets/stylesheets/user/request/preview.scss
index 306c27a..6bca27a 100644
--- a/app/assets/stylesheets/user/request/preview.scss
+++ b/app/assets/stylesheets/user/request/preview.scss
@@ -6,7 +6,6 @@
     line-height:30px;
 }
 .request_preview_zone{
-    position: relative;
 	.change_coupon{
 		margin-top: 0px;
         color: $link_blue;
@@ -30,12 +29,15 @@
     .request_content{
         line-height: 30px;
     }
-    canvas{
-        position: absolute;
-        left: 100vw;
-    }
-    #display_setting{
-        position: absolute;
-        left: 100vw;
-    }
+}
+.text_image_area{
+    position: relative;
+}
+canvas{
+    position: absolute;
+    left: 100vw;
+}
+#display_setting{
+    position: absolute;
+    left: 100vw;
 }
\ No newline at end of file
diff --git a/app/assets/stylesheets/user/request/show.scss b/app/assets/stylesheets/user/request/show.scss
index dcd1521..39868d7 100644
--- a/app/assets/stylesheets/user/request/show.scss
+++ b/app/assets/stylesheets/user/request/show.scss
@@ -1,3 +1,4 @@
+@import "_variables";
 .request_show_zone{
     overflow: hidden;
     .request_area{
@@ -19,8 +20,9 @@
             }
             .request_title_area{
                 .request_title{
-                    margin-top: 5px;
+                    margin-top: 0px;
                     margin-bottom:0px;
+                    font-size: clamp(20px, 3vw, 28px);
                 }
                 border-bottom: solid 2px lightgray;
             }
@@ -80,21 +82,6 @@
             //        }
             //    }
             //}
-            .request_detail{
-                .request_detail_label{
-                    margin: 0px;
-                    margin-top: 5px;
-                }
-                .request_detail_content{
-                    margin: 0px 10px;
-                    width: calc(100% - 20px);
-                    line-height: 30px;
-                    .request_detail_text{
-                        margin: 0px;
-                        white-space: pre-line;
-                    }
-                }
-            }
             .youtube_video{
                 width: 100%;
                 
diff --git a/app/assets/stylesheets/user/service/show.scss b/app/assets/stylesheets/user/service/show.scss
index fe057cc..bb26254 100644
--- a/app/assets/stylesheets/user/service/show.scss
+++ b/app/assets/stylesheets/user/service/show.scss
@@ -19,6 +19,7 @@
                 margin-top: 0px;
                 .service_title{
                     margin: 0px;
+                    font-size: clamp(20px, 3vw, 28px);
                     border-bottom: solid 2px lightgray;
                 }
             }
diff --git a/app/assets/stylesheets/user/transaction/show.scss b/app/assets/stylesheets/user/transaction/show.scss
index b1bcf4d..88d0edc 100644
--- a/app/assets/stylesheets/user/transaction/show.scss
+++ b/app/assets/stylesheets/user/transaction/show.scss
@@ -110,15 +110,6 @@
                 .item_link{
                     width: 100%;
                 }
-                .text_image{
-                    width: 100%;
-                    height: 100px;
-                    //object-fit: cover;
-                    //object-fit: none;
-                    object-position: 50px 50px;
-                    object-position: right top;
-                    opacity: 0.5;
-                }
                 .like_share_area{
                     overflow: hidden;
                     padding-bottom: 5px;
diff --git a/app/controllers/user/services_controller.rb b/app/controllers/user/services_controller.rb
index 010a0a4..bfdd03c 100644
--- a/app/controllers/user/services_controller.rb
+++ b/app/controllers/user/services_controller.rb
@@ -237,6 +237,7 @@ class User::ServicesController < User::Base
 
   def reviews
     transactions = Transaction.solve_n_plus_1
+      .reviewed
       .where(service_id:params[:id])
       .order(id: :DESC)
     @transactions = transactions.page(params[:page]).per(@review_page)
diff --git a/app/models/request.rb b/app/models/request.rb
index afd0495..c2fffbe 100644
--- a/app/models/request.rb
+++ b/app/models/request.rb
@@ -10,6 +10,7 @@ class Request < ApplicationRecord
   has_many :request_categories, class_name: "RequestCategory", dependent: :destroy
   has_many :supplements, class_name: "RequestSupplement", dependent: :destroy
   has_one :request_category, dependent: :destroy
+  has_one :item, dependent: :destroy, class_name: "RequestItem"
   delegate :category, to: :request_category, allow_nil: true
   has_many :likes, class_name: "RequestLike"
 
@@ -47,7 +48,7 @@ class Request < ApplicationRecord
   accepts_nested_attributes_for :request_categories, allow_destroy: true
 
   scope :solve_n_plus_1, -> {
-    includes(:user, :services, :request_categories, :items)
+    includes(:user, :services, :request_categories, :items, :transactions)
   }
 
   scope :suggestable, -> {
@@ -242,6 +243,18 @@ class Request < ApplicationRecord
     self.save
   end
 
+  def has_pure_image
+    self.items.any? { |item| !item.is_text_image } #N+1回避のためwhereを使わない
+  end
+
+  def has_text_image
+    self.items.any? { |item| item.is_text_image } #N+1回避のためwhereを使わない
+  end
+
+  def published_transactions
+    self.transactions.select { |transaction| transaction.is_published } #N+1回避のためwhereを使わない
+  end
+
   def is_suggestable?(user=nil)
     if get_unsuggestable_message(user).present?
       false
@@ -349,6 +362,10 @@ class Request < ApplicationRecord
       end
     end
   end
+
+  def description_length
+    self.description.gsub(/\r\n/, "\n").length
+  end
   
   def status_color
     if self.is_inclusive
@@ -423,7 +440,10 @@ class Request < ApplicationRecord
   end
 
   def need_text_image?
-    self.request_form.name == "text" || (self.request_form.name == "free" && self.items.not_text_image.count < 1)
+    return false if description_length > required_text_image_description_length
+    return true if self.request_form.name == "text"
+    return true if self.request_form.name == "free" && self.items.not_text_image.count < 1
+    false
   end
 
   def validate_item_count
@@ -474,11 +494,12 @@ class Request < ApplicationRecord
     end
 
     #新規の作成 or 作成後に相談室の最大文字数が変更され、最大文字数がひっかかった場合
-    if self.service && (new_record? || self.is_published && will_save_change_to_is_published?)
-      if self.service.request_max_characters && self.service.request_max_characters < self.description.gsub(/(\r\n?|\n)/,"a").length
-        over_character_count = self.description.gsub(/(\r\n?|\n)/,"a").length - self.service.request_max_characters
-        errors.add(:description, "文字数を#{self.service.request_max_characters}字以下にしてください。（#{over_character_count}字オーバー）")
-      end
+    return unless self.service.present? 
+    return if new_record? || self.is_published && will_save_change_to_is_published?
+    return if self.service.request_max_characters.nil?
+    over_character_count = description_length - self.service.request_max_characters
+    if over_character_count > 0
+      errors.add(:description, "文字数を#{self.service.request_max_characters}字以下にしてください。（#{over_character_count}字オーバー）")
     end
   end
 
@@ -486,7 +507,7 @@ class Request < ApplicationRecord
     return unless self.is_published && will_save_change_to_is_published?
     case request_form.name
     when 'text'
-      if self.items.text_image.count != 1
+      if need_text_image? && self.items.text_image.count != 1
         items.destroy_all
         errors.add(:items, "が不適切です")
       end
@@ -500,11 +521,6 @@ class Request < ApplicationRecord
         end
       end
     end
-    if self.items
-      #self.items.first.file_duration = self.file_duration
-    else
-      errors.add(:items, "がありません")
-    end
   end
 
   def validate_is_published
@@ -594,6 +610,10 @@ class Request < ApplicationRecord
     service&.request_max_characters.presence || 20000
   end
 
+  def required_text_image_description_length
+    1000
+  end
+
   def max_price_upper_limit
     10000
   end
diff --git a/app/models/transaction.rb b/app/models/transaction.rb
index af3ab6e..c28e545 100644
--- a/app/models/transaction.rb
+++ b/app/models/transaction.rb
@@ -61,6 +61,7 @@ class Transaction < ApplicationRecord
       :service, 
       :items, 
       :transaction_messages, 
+      {service: :item}, 
       {request: :items}, 
       {transaction_messages: :sender}, 
       {transaction_messages: :receiver}
@@ -462,10 +463,6 @@ class Transaction < ApplicationRecord
     end
   end
 
-  def total_likes
-    self.likes.count
-  end
-
   def validate_title
     if self.title.present?
       errors.add(:title, "を入力して下さい") if self.title.length <= 0 && self.is_published
@@ -541,6 +538,26 @@ class Transaction < ApplicationRecord
     end
   end
 
+  def total_likes
+    self.likes.count
+  end
+
+  def messages_sort_by_later
+    transaction_messages.to_a.sort_by(&:created_at).reverse
+  end
+
+  def messages_sort_by_earlier
+    transaction_messages.to_a.sort_by(&:created_at)
+  end
+
+  def latest_message_body
+    messages_sort_by_later.last.body
+  end
+  
+  def latest_message_created_at
+    messages_sort_by_later.last.created_at
+  end
+
   def suggestion_buyable(user)
     if user.nil?
       false
@@ -571,9 +588,9 @@ class Transaction < ApplicationRecord
     return false unless self.service.allow_pre_purchase_inquiry
     return false if self.is_contracted
     if user == self.seller
-      self.latest_transaction_message&.receiver == user
+      messages_sort_by_later.last&.receiver == user
     elsif user == self.buyer
-      self.latest_transaction_message&.receiver == user || self.transaction_messages.blank?
+      messages_sort_by_later.last&.receiver == user || self.transaction_messages.blank?
     else
       false
     end
diff --git a/app/models/transaction_message.rb b/app/models/transaction_message.rb
index 1239af1..c4ecf89 100644
--- a/app/models/transaction_message.rb
+++ b/app/models/transaction_message.rb
@@ -59,12 +59,4 @@ class TransactionMessage < ApplicationRecord
   def body_max_characters
     #1000
   end
-
-  def self.latest_body
-    sort_by_later&.first&.body
-  end
-  
-  def self.latest_created_at
-    sort_by_later&.first&.created_at
-  end
 end
diff --git a/app/uploaders/file_uploader.rb b/app/uploaders/file_uploader.rb
index 3ef7a59..24e403a 100644
--- a/app/uploaders/file_uploader.rb
+++ b/app/uploaders/file_uploader.rb
@@ -17,7 +17,7 @@ class FileUploader < CarrierWave::Uploader::Base
   end
 
   version :thumb, if: :is_image? do
-    process resize_to_fit: [300, 300]
+    process resize_to_fit: [300, nil]
     process convert: 'jpg'
 
     def full_filename(for_file)
@@ -26,7 +26,7 @@ class FileUploader < CarrierWave::Uploader::Base
   end
 
   version :normal_size, if: :is_image? do
-    process resize_to_fit: [1000, 1000]
+    process resize_to_fit: [1000, nil]
     process convert: 'jpg'
 
     def full_filename(for_file)
diff --git a/app/uploaders/image_uploader.rb b/app/uploaders/image_uploader.rb
index e5b30ec..9f58eb3 100644
--- a/app/uploaders/image_uploader.rb
+++ b/app/uploaders/image_uploader.rb
@@ -18,7 +18,7 @@ class ImageUploader < CarrierWave::Uploader::Base
   end
 
   version :thumb do
-    process resize_to_fit: [300, 300]
+    process resize_to_fit: [300, nil] #高さは無制限
     process convert: 'jpg'
 
     def full_filename(for_file)
@@ -27,7 +27,7 @@ class ImageUploader < CarrierWave::Uploader::Base
   end
 
   version :normal_size do
-    process resize_to_fit: [1000, 1000]
+    process resize_to_fit: [1000, nil] #高さは無制限
     process convert: 'jpg'
 
     def full_filename(for_file)
diff --git a/app/views/layouts/_head.html.erb b/app/views/layouts/_head.html.erb
index 8f2d3ac..0d1e5dc 100644
--- a/app/views/layouts/_head.html.erb
+++ b/app/views/layouts/_head.html.erb
@@ -20,6 +20,7 @@
     <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
     <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
     <script src="https://cdnjs.cloudflare.com/ajax/libs/jscroll/2.4.1/jquery.jscroll.js"></script>
+    <script src="https://cdnjs.cloudflare.com/ajax/libs/js-cookie/3.0.1/js.cookie.min.js"></script>
     <%= render "user/shared/swiper" %>
     <!-- Development -->
     <%if Rails.env.development?%>
diff --git a/app/views/user/images/_description.css.erb b/app/views/user/images/_description.css.erb
index 2424f47..aebf1ef 100644
--- a/app/views/user/images/_description.css.erb
+++ b/app/views/user/images/_description.css.erb
@@ -13,6 +13,10 @@
     /*この要素では幅をせていせず、親要素で幅を設定しないとなぜかうまく表示されない*/
 }
 .title_area{
+display: flex;
+    justify-content: space-between;
+}
+.title{
     color: white; 
     text-align: left;
     margin: 0px;
diff --git a/app/views/user/images/_description.html.erb b/app/views/user/images/_description.html.erb
index fe7795b..70536dc 100644
--- a/app/views/user/images/_description.html.erb
+++ b/app/views/user/images/_description.html.erb
@@ -1,11 +1,14 @@
 
 <div class="" id="display_setting">
-  <div class="answer_zone" id="canvas-box">
-      <div class="answer_area">
-          <div class="message_area" id="message_are">Q.<%= title%>
-          <%= text%>
-          </div>
-      </div>
-      <h1 class="title_area">コレテク　〜稼げるQ&Aサイト〜</h1>
-  </div>
+  	<div class="answer_zone" id="canvas-box">
+  	    <div class="answer_area">
+  	        <div class="message_area" id="message_are">Q.<%= title%>
+  	        <%= text%>
+  	        </div>
+  	    </div>
+  	    <div class="title_area">
+  	      	<h1 class="title">コレテク</h1>
+  	      	<h1 class="title">〜稼げるQ&Aサイト〜</h1>
+  	    </div>
+  	</div>
 </div>
\ No newline at end of file
diff --git a/app/views/user/pre_purchase_inquiries/_modal.html.erb b/app/views/user/pre_purchase_inquiries/_modal.html.erb
index cebaedb..ed0eb68 100644
--- a/app/views/user/pre_purchase_inquiries/_modal.html.erb
+++ b/app/views/user/pre_purchase_inquiries/_modal.html.erb
@@ -19,18 +19,18 @@
 			</div>
 			<% side = transaction.seller == current_user ? 'left' : 'right' %>
 			<div class="message_component">
-				<%= image_tag  transaction.request.user.thumb_with_default, class: "image #{side}_image" %>
+				<%= image_tag  transaction.buyer.thumb_with_default, class: "image #{side}_image" %>
 				<div class="text <%=side%>_text">
 					<h3 class="margin0px">タイトル</h3>
 					<%= transaction.request.title%>
 					<h3 class="margin0px">本文</h3>
 					<%= transaction.request.description%>
-					<% transaction.request.items.not_text_image.each do |item| %>
-						<%= image_tag item.file.normal_size.url, class: "item_image"%>
+					<% transaction.request.items.each do |item| %>
+						<%= image_tag item.file.normal_size.url, class: "item_image" unless item.is_text_image %>
 					<% end %>
 				</div>
 			</div>
-			<% transaction.transaction_messages.solve_n_plus_1.order(created_at: :asc).each do |tm| %>
+			<% transaction.messages_sort_by_earlier.each do |tm| %>
 				<% side = tm.sender == current_user ? 'right' : 'left' %>
 				<%= render "user/pre_purchase_inquiries/cell", 
 					image_url: tm.sender.thumb_with_default,
diff --git a/app/views/user/pre_purchase_inquiries/index.html.erb b/app/views/user/pre_purchase_inquiries/index.html.erb
index f331e6b..416699e 100644
--- a/app/views/user/pre_purchase_inquiries/index.html.erb
+++ b/app/views/user/pre_purchase_inquiries/index.html.erb
@@ -9,9 +9,9 @@
 				<div class="inner_pre_purchase_inquiry_cell">
 					<%=image_tag transaction.opponent_of(current_user).thumb_with_default, class:"image" %>
 					<div class="text_area">
-						<div class="message one_line_text"><%=transaction.transaction_messages.latest_body %></div>
+						<div class="message one_line_text"><%=transaction.latest_message_body %></div>
 						<div class="datetime">
-							<%=	readable_datetime(transaction.transaction_messages.latest_created_at) %>
+							<%=	readable_datetime(transaction.latest_message_created_at) %>
 						</div>
 					</div>
 				</div>
diff --git a/app/views/user/request_likes/show.html.erb b/app/views/user/request_likes/show.html.erb
index 9721989..dd13538 100644
--- a/app/views/user/request_likes/show.html.erb
+++ b/app/views/user/request_likes/show.html.erb
@@ -2,9 +2,11 @@
     <h3 class="list_header"><%= link_to "マイページ", user_configs_path, class:"main_area_top_link"%> > いいねした質問 <%= paginate @requests %></h3>
   	<% @requests.each do |request| %>
         <%= link_to(user_request_path(request.id), class:"order_cell") do %>
+            <% if request.has_pure_image %>
             <div class="image_area">
-                <%= image_tag request.items.first.file.thumb.url, class:"image" %>
+                <%= image_tag request.item.file.thumb.url, class:"image"  %>
             </div>
+            <% end %>
             <div class="text_area">
                 <h4 class="title two_line_text"><%= request.title%></h4>
                 <div class="from_now one_line_text">
diff --git a/app/views/user/requests/_cell.html.erb b/app/views/user/requests/_cell.html.erb
index afef69a..be72eca 100644
--- a/app/views/user/requests/_cell.html.erb
+++ b/app/views/user/requests/_cell.html.erb
@@ -27,14 +27,14 @@
             </span>
             <% end %>
         </div>
-        <%if request.items.first.is_text_image %>
-        <div class="request_condition_area">
-            <div class="request_condition_block"><span class="request_condition_title">予算</span>&nbsp;<span class="content"><%=request.max_price%>円</span>　</div>
-            <div class="request_condition_block"><span class="request_condition_title">提案数</span>&nbsp;<span class="content"><%=request.total_services%>件</span>　</div>
-            <div class="request_condition_block"><span class="request_condition_title"><%=Transaction.human_attribute_name(:delivery_form) %></span>&nbsp;<span class="content"><%=forms_japanese_hash.key(request.delivery_form_name)%></span>　</div>
-        </div>
+        <% if request.has_text_image || request.items.blank? %>
+            <div class="request_condition_area">
+                <div class="request_condition_block"><span class="request_condition_title">予算</span>&nbsp;<span class="content"><%=request.max_price%>円</span>　</div>
+                <div class="request_condition_block"><span class="request_condition_title">提案数</span>&nbsp;<span class="content"><%=request.total_services%>件</span>　</div>
+                <div class="request_condition_block"><span class="request_condition_title"><%=Transaction.human_attribute_name(:delivery_form) %></span>&nbsp;<span class="content"><%=forms_japanese_hash.key(request.delivery_form_name)%></span>　</div>
+            </div>
         <% end %>
-        <% unless request.items.first.is_text_image %>
+        <% if request.has_pure_image %>
             <div class="item_area">
                 <%= render "user/shared/swiper_images", model: request, use_thumb:true %>
             </div>
diff --git a/app/views/user/requests/_form.html.erb b/app/views/user/requests/_form.html.erb
index 44628e3..a7da21c 100644
--- a/app/views/user/requests/_form.html.erb
+++ b/app/views/user/requests/_form.html.erb
@@ -9,6 +9,7 @@
   	<div class="field_area">
   	  	<%= f.label :description, class:"field_label" %><span class="total_characters" length="<%=request.description_max_length(service) %>"></span><br />
   	  	<%= f.text_area :description, autocomplete: "new-password", class:"input_field text_area"%>
+		<div class="annotation">※添付ファイルがなく、本文が<%= request.required_text_image_description_length%>字以下の場合にのみ、文章が質問箱として画像に変換されます</div>
   	</div>
 
   	<div class="field_area">
@@ -68,7 +69,7 @@
   	  	  	  	<% end %>
   	  	  	<% end %>
   	  	  	<%= f.file_field :file, autocomplete: "file", class:"input_field", id:"file_input", accept: accept_image, name: "items[file][]", multiple: true, style:"display:#{request.file_field_display_style}" %>
-				  <span class="annotation">＊添付ファイルの上限数は<%=Request.new.max_items_count%>個です</span>
+				  <span class="annotation">※添付ファイルの上限数は<%=Request.new.max_items_count%>個です</span>
 
   	  	  	<%= f.hidden_field :file_duration, id:"file_duration" %>
   	  	  	<div class="file_discription" id="file_discription"></div>
diff --git a/app/views/user/requests/_question.html.erb b/app/views/user/requests/_question.html.erb
index 509c092..fa5cb1e 100644
--- a/app/views/user/requests/_question.html.erb
+++ b/app/views/user/requests/_question.html.erb
@@ -6,7 +6,7 @@
             <% end %>
             <h5 class="one_line_text user_and_date text">質問者：&nbsp;<%= link_to request.user.name, user_account_path(request.user.id), class: '' %><%= %>　<%= readable_datetime(request.created_at)%></h5>
 			<div class="item_description_area">
-				<% unless request.items.first.is_text_image? %>
+				<% if request.has_pure_image %>
 					<div class='item_area'>
 						<%= image_tag request.items.first.file.thumb.url %>
 					</div>
@@ -15,14 +15,14 @@
             		<span class="three_line_text text description_text"><%= request.description%></span>
 				</div>
 			</div>
-			<% unless request.items.first.is_text_image? %>
+			<% unless request.has_text_image %>
 				<div class='items_area'>
 					<% request.items.each do |item| %>
 						<%= image_tag item.file.thumb.url %>
 					<% end %>
 				</div>
 			<% end %>
-            <% request.transactions.where(is_published: true).each do |transaction| %>
+            <% request.published_transactions.each do |transaction| %>
             	<div class="answer_area">
             	    <div class="seller_container">
             	        <%= link_to(user_account_path(transaction.seller.id), class: 'seller_area') do %>
@@ -53,6 +53,6 @@
     </div>
     <div class='open_text_area'>
 	<div class="smoke"></div>
-        <div class="open_text" id="open_text">&nbsp;<%=request.transactions.where(is_published: true).count%>件の回答<span class='fas fa-angle-down'>&nbsp;</span>&nbsp;</div>
+        <div class="open_text" id="open_text">&nbsp;<%=request.published_transactions.count%>件の回答<span class='fas fa-angle-down'>&nbsp;</span>&nbsp;</div>
     </div>
 </div>
diff --git a/app/views/user/requests/index.html.erb b/app/views/user/requests/index.html.erb
index edbe481..f66f191 100644
--- a/app/views/user/requests/index.html.erb
+++ b/app/views/user/requests/index.html.erb
@@ -25,8 +25,6 @@
 </div>
 <script>
 set_search_detail();
-//content.options[0].selected = false;
-//content.options[1].selected = true;
 </script>
 
 <script>
diff --git a/app/views/user/requests/mine.html.erb b/app/views/user/requests/mine.html.erb
index ccf4453..d3c295c 100644
--- a/app/views/user/requests/mine.html.erb
+++ b/app/views/user/requests/mine.html.erb
@@ -2,9 +2,11 @@
     <h3 class="list_header"><%= link_to "マイページ", user_configs_path, class:"main_area_top_link"%> > 自分の質問 <%= paginate @requests %></h3>
   	<% @requests.each do |request| %>
         <%= link_to(main_path(request), class:"order_cell") do %>
+          	<% if request.has_pure_image %>
             <div class="image_area">
                 <%= image_tag request.thumb_with_default, class:"image" %>
             </div>
+        	<% end %>
             <div class="text_area">
                 <h4 class="title two_line_text"><%= request.title%></h4>
                 <div class="from_now one_line_text">
diff --git a/app/views/user/requests/preview.html.erb b/app/views/user/requests/preview.html.erb
index db83397..87ba65f 100644
--- a/app/views/user/requests/preview.html.erb
+++ b/app/views/user/requests/preview.html.erb
@@ -144,23 +144,23 @@
 	    	<% end %>
 	    </div>
 	</div>
-	<%= render "/user/images/description.html.erb",title: @request.title, text:@request.description, image_width: 500%>
-	<canvas id="canvas"></canvas>
-	<div id="canvas-container"></div>
+<div class="text_image_area">
+	<% if @transaction %>
+		<script>
+			<%= render "user/pre_purchase_inquiries/modal.js.erb" %>
+		</script>
+	<% end %>
+	<%if @request.need_text_image? %>
+		<script src="https://html2canvas.hertzen.com/dist/html2canvas.js"></script>
+		<%= render "/user/images/description.html.erb",title: @request.title, text:@request.description, image_width: 500%>
+		<div id="canvas-container"></div>
+		<script>
+		<%= render 'user/images/description.js.erb',title: @request.title, text: @request.description, image_width: 500, user_name: current_user.name %>
+		</script>
+		<style>
+		<%= render 'user/images/description.css.erb', text: @request.description, image_width: 500, font_size: @request.description_font_size(500) %>
+		</style>
 </div>
-<% if @transaction %>
-<script>
-	<%= render "user/pre_purchase_inquiries/modal.js.erb" %>
-</script>
-<% end %>
-<%if @request.need_text_image? %>
-<script src="https://html2canvas.hertzen.com/dist/html2canvas.js"></script>
-<script>
-<%= render 'user/images/description.js.erb',title: @request.title, text: @request.description, image_width: 500, user_name: current_user.name %>
-</script>
-<style>
-<%= render 'user/images/description.css.erb', text: @request.description, image_width: 500, font_size: @request.description_font_size(500) %>
-</style>
 <script>
 try{
   let isLoaded = false;
@@ -184,14 +184,6 @@ try{
     //service/showからrequest/previeに遷移するWindowのロードに失敗する
     clearTimeout(timeout);
   });
-
-  video_display = document.getElementById("video_display")
-  if(video_display != null){
-    video_display.addEventListener('loadeddata', function() {//フォームに値を代入
-    $("#file_duration").val(Math.floor(this.duration))
-    });
-  }
-
   //create_description_imageでイメージが生成されない時の臨時処理としてリロードする処理
   function reload_description_image(){
       if($("#desctiption_to_image_text").css("display") == "none"){
@@ -207,4 +199,5 @@ try{
   window.location.reload();
 }
 </script>
-<% end %>
\ No newline at end of file
+<% end %>
+</div>
\ No newline at end of file
diff --git a/app/views/user/requests/show.html.erb b/app/views/user/requests/show.html.erb
index 875a01f..12fb5bf 100644
--- a/app/views/user/requests/show.html.erb
+++ b/app/views/user/requests/show.html.erb
@@ -15,8 +15,27 @@
                 <h3 class="request_title">
                     <%=@request.title%>
                 </h3>
+                <% @request.categories.each do |category| %>
+                    <%= link_to category.japanese_name, user_requests_path(categories: category.name), class:"big_name_tag" %>
+                <% end %>
                 <div>
                 質問者：<%= link_to @request.user.name, user_account_path(@request.user.id) %>
+                    <% if @request.user == current_user%>
+                        <div class="edit_delete_area">
+                            <% if @request.user == current_user && !Transaction.exists?(request_id:params[:id]) %>
+                                <div class="edit_delete_area">
+                                    <%= link_to "削除", user_request_path(@request.id), method: "delete", class:"delete button", data: {confirm: "質問を削除しますか？。"} %>
+                                </div>
+                            <% elsif @request.can_stop_accepting? %>
+                                <div class="edit_delete_area">
+                                    <%= link_to "取り下げ", user_request_stop_accepting_path(@request.id), method: "put", class:"delete button", data: {confirm: "質問を取り下げますか？。\n取り消しできません"} %>
+                                </div>
+                            <% end %>
+                            <%if @request.is_suppliable %>
+                                <%= link_to "補足", new_user_request_supplement_path(request_id: @request.id)%>
+                            <% end %>
+                        </div>
+                    <% end %>
                 </div>
             </div>
             <!--
@@ -35,7 +54,7 @@
             -->
             <div class="common_score_area">
                 <div class="score_area_left">
-                    <span class="score_info"><label>状況</label>&nbsp;
+                    <span class="score_info"><label>ステータス</label>&nbsp;
                         <span class='status <%=@request.status_color%>'><%= @request.status %></span>
                     </span>
                     <span class="score_info"><label>投稿</label>&nbsp;<%= readable_datetime(@request.published_at)%></span>
@@ -44,90 +63,51 @@
                     <% end %>
                 </div>
                 <div class='score_area_right'>
-                    <% if @request.user == current_user%>
-                        <div class="edit_delete_area">
-                            <% if @request.user == current_user && !Transaction.exists?(request_id:params[:id]) %>
-                                <div class="edit_delete_area">
-                                    <%= link_to "削除", user_request_path(@request.id), method: "delete", class:"delete button", data: {confirm: "質問を削除しますか？。"} %>
-                                </div>
-                            <% elsif @request.can_stop_accepting? %>
-                                <div class="edit_delete_area">
-                                    <%= link_to "取り下げ", user_request_stop_accepting_path(@request.id), method: "put", class:"delete button", data: {confirm: "質問を取り下げますか？。\n取り消しできません"} %>
-                                </div>
-                            <% end %>
-                            <%if @request.is_suppliable %>
-                                <%= link_to "補足", new_user_request_supplement_path(request_id: @request.id)%>
-                            <% end %>
-                        </div>
-                    <% else %>
                         <%= link_to(user_request_likes_path(id: @request.id), class: "like_button #{@request.liked_class(current_user)}", id:"like_button", method: :post, remote:true) do%>
                             <span class="fas fa-heart" ></span>&nbsp;いいね　　<span id="like_count"><%=@request.total_likes%></span>&nbsp;
                         <% end %>
-                    <% end %>
                 </div>
             </div>
-            <%= render "user/shared/small_label", text:"条件"%>
-            <table class="common_condition_area">
-                <% if @request.is_inclusive %>
-                <tr>
-                    <td class="condition_label">
-                        <span class="condition_name "><%= Request.human_attribute_name(:max_price)%></span>
-                    </td>
-                    <td>
-                        <span class="common_condition"><%=@request.max_price%>円</span>
-                    </td>
-                </tr>
-                <% end %>
-                <% if @request.is_inclusive %>
-                <tr>
-                    <td class="condition_label">
-                        <span class="condition_name "><%= Request.human_attribute_name(:suggestion_deadline) %></span>
-                    </td>
-                    <td>
-                        <span class="common_condition"><%=from_now(@request.suggestion_deadline)%>（<%=@request.suggestion_deadline.strftime("%Y %m/%d %H:%m")%>まで）</span>
-                    </td>
-                </tr>
-                <% end %>
-                <tr>
-                    <td class="condition_label">
-                        <span class="condition_name "><%= Request.human_attribute_name(:request_form) %></span>
-                    </td>
-                    <td>
-                        <span class="common_condition"><%=@request.request_form.japanese_name%></span>
-                    </td>
-                </tr>
-                <tr>
-                    <td class="condition_label">
-                        <span class="condition_name "><%= Request.human_attribute_name(:delivery_form) %></span>
-                    </td>
-                    <td>
-                        <span class="common_condition"><%=@request.delivery_form.japanese_name%></span>
-                    </td>
-                </tr>
-            </table>
-            <div class="request_detail">
-                <%= render "user/shared/small_label", text:"本文"%>
-                <div class="request_detail_content" id="request_detail_content">
-                    <p id="request_detail_text" class="request_detail_text"><%=@request.description%></p>
-                </div>
-            </div>
-            <% @request.categories.each do |category| %>
-                <%= link_to category.japanese_name, user_requests_path(categories: category.name), class:"big_name_tag" %>
+            <% if @request.is_inclusive %>
+                <%= render "user/shared/small_label", text:"条件"%>
+                <table class="common_condition_area">
+                    <tr>
+                        <td class="condition_label">
+                            <span class="condition_name "><%= Request.human_attribute_name(:max_price)%></span>
+                        </td>
+                        <td>
+                            <span class="common_condition"><%=@request.max_price%>円</span>
+                        </td>
+                    </tr>
+                    <tr>
+                        <td class="condition_label">
+                            <span class="condition_name "><%= Request.human_attribute_name(:suggestion_deadline) %></span>
+                        </td>
+                        <td>
+                            <span class="common_condition"><%=from_now(@request.suggestion_deadline)%>（<%=@request.suggestion_deadline.strftime("%Y %m/%d %H:%m")%>まで）</span>
+                        </td>
+                    </tr>
+                    <tr>
+                        <td class="condition_label">
+                            <span class="condition_name "><%= Request.human_attribute_name(:request_form) %></span>
+                        </td>
+                        <td>
+                            <span class="common_condition"><%=@request.request_form.japanese_name%></span>
+                        </td>
+                    </tr>
+                    <tr>
+                        <td class="condition_label">
+                            <span class="condition_name "><%= Request.human_attribute_name(:delivery_form) %></span>
+                        </td>
+                        <td>
+                            <span class="common_condition"><%=@request.delivery_form.japanese_name%></span>
+                        </td>
+                    </tr>
+                </table>
             <% end %>
-            <div class="item_area">
-                <%if @request.use_youtube%>
-                    <iframe class="youtube_video 16_to_9" src="https://www.youtube.com/embed/<%=@request.youtube_id%>" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
-                <% elsif @request.items.present? %>
-                    <% if @request.request_form_has_image? %>
-                        <% if @request.items.first.is_text_image %>
-                            <%= render 'user/shared/adjustable_image', request: @request%>
-                        <% else %>
-                            <%= render "user/shared/swiper_images", model: @request, use_thumb:false %>
-                        <% end %>
-                    <% elsif @request.request_form.name == "video" %>
-                        <%= video_tag @request.file.url,poster:@request.thumbnail.url, class:"image", controls: true, autobuffer: true%>
-                    <% end %>
-                <% end %>
+            <div class="text_area">
+                <%= render "user/shared/small_label", text:"本文"%>
+                <%= render "user/shared/description_text_image", request: @request %>
             </div>
             <%if @request.supplements.present? %>
                 <%= render "user/shared/small_label", text:"補足" %>
@@ -206,6 +186,8 @@ $('.main_area').css('padding-bottom','50px');
     </div>
 </div>
 <script>
+
+
 over_600_slide_count = <%=@request.items.length.clamp(1, 3) %><%%>
 
 var swiper = new Swiper('.swiper-container', {
diff --git a/app/views/user/transactions/show.html.erb b/app/views/user/transactions/show.html.erb
index 46bf9cb..1de0f13 100644
--- a/app/views/user/transactions/show.html.erb
+++ b/app/views/user/transactions/show.html.erb
@@ -18,25 +18,14 @@
                             <p class="buyer_name"><%=@transaction.buyer.name%></p>
                         </div>
                     <% end %>
-                    <div class="description_area"><%= @transaction.request.description%></div>
-
-                    <%if @transaction.request.items.first.is_text_image %>
-                        <%= render 'user/shared/adjustable_image', request: @transaction.request%>
-                    <% else %>
+                    <%= render "user/shared/description_text_image", request: @transaction.request %>
+                    <%if @transaction.request.has_pure_image %>
                         <% @transaction.request.items.each do |item| %>
                             <%= link_to(item.file.url, class: 'item_link') do %>
                                 <%= image_tag item.file.url, class:"image" if item.file.is_image? %>
                             <% end %>
-                            <% if item.use_youtube %>
-                                <div class="item_file_flame 16_to_9" id="item_file_flame">
-                                    <iframe class="item_file 16_to_9"  id="item_file" src="https://www.youtube.com/embed/<%= item.youtube_id %>" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
-                                </div>
-                            <% elsif item.file.is_video? %>
-                                <%= image_tag @transaction.request.file.url, class:"image" %>
-                            <% end %>
                         <% end %>
                     <% end %>
-                    <%##= render "/user/shared/description", text:@transaction.request%>
                 </div>
             </div>
         </div>
@@ -89,13 +78,6 @@
                     <%= link_to(item.file.url, class: 'item_link') do %>
                         <%= image_tag item.file.url, class:"image" if item.file.is_image? %>
                     <% end %>
-                    <% if item.use_youtube %>
-                        <div class="item_file_flame 16_to_9" id="item_file_flame">
-                            <iframe class="item_file 16_to_9"  id="item_file" src="https://www.youtube.com/embed/<%=item.youtube_id%>" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
-                        </div>
-                    <% elsif item.file.is_video? %>
-                        <%= image_tag item.file.url, class:"image" %>
-                    <% end %>
                 <% end %>
                 <div class="like_share_area">
                     <div class="like_area">
@@ -141,57 +123,5 @@
     </div>
 </div>
 <script>
-function open_along_messages(){
-    $('.along_message_area').css('display','none')
-    $('.along_messages').css('display','block')
-}
-
-var item_file_flame = document.getElementById("item_file_flame");
-var item_file = document.getElementById("item_file");
-var transaction_flame = document.getElementById("transaction_flame");
-var like_count = document.getElementById("like_count");
-
-$("#like_button")[0].addEventListener('ajax:success', function(event) {
-  // 成功時の処理
-  var res = event.detail[0];
-  $(".like_button").toggleClass("liked_button");
-  if(res){
-    notify_for_seconds("いいねしました。");
-    like_count.textContent = parseFloat(like_count.textContent) + 1
-  }else{
-    notify_for_seconds("いいねを解除しました。");
-    like_count.textContent = parseFloat(like_count.textContent) - 1
-  }
-  
-});
-
-$("#like_button")[0].addEventListener('ajax:error', function(event) {
-  // 失敗時の処理
-  console.log("いいねできませんでした。")
-  var res = event.detail[0];
-  console.log(res["is_liked"]);
-  $(".like_button").toggleClass("liked_button");
-  notify_for_seconds("いいねできませんでした。");
-  like_count.textContent = parseFloat(like_count.textContent) - 1
-});
-
-<% if @transaction.service.delivery_form.name == "video"%>
-function resize_item_file_flame(){
-    item_file_flame.style.width = "100%"
-    item_file.style.height = "100%"
-    item_file.style.width = "100%"
-    transaction_flame.style.width = "calc(100% - 10px)"
-    let width = transaction_flame.clientWidth
-    item_file_flame.style.height = width/16*9 + "px"
-    //console.log(item_file_flame.style.height)
-    //console.log("resize_item_file_flame")
-    //console.log(item_file_flame.style.height)
-}
-//応急処置
-//setInterval(resize_item_file_flame, 1000);
-<% end %>
-//resize_item_file_flame()
-//window.addEventListener("load",resize_item_file_flame(),false)
-//window.addEventListener("resize", resize_item_file_flame)
-
+<%= render "user/transactions/show.js.erb" %>
 </script>
\ No newline at end of file
diff --git a/public/.DS_Store b/public/.DS_Store
index 3ccc87f..c6b41e9 100644
Binary files a/public/.DS_Store and b/public/.DS_Store differ
