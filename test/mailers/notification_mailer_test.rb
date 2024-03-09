require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "transaction" do
    mail = NotificationMailer.transaction
    assert_equal "Transaction", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "message" do
    mail = NotificationMailer.message
    assert_equal "Message", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "service" do
    mail = NotificationMailer.service
    assert_equal "Service", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
