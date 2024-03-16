module ImageConverter
  #extend ActiveSupport::Concern
  #key = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMGQ4YmZhY2RlZjVmNTg3YzAwMmRmMmVlYzg4YzUyMjBmNWI0YzNhMGFhY2RlMzBmMGIxOTMyMGEwMzU4YTllMjVlMjU5YmMyMDRhZTRmMTkiLCJpYXQiOjE3MDk3MzAwMjMuNzgyMzE4LCJuYmYiOjE3MDk3MzAwMjMuNzgyMzE5LCJleHAiOjQ4NjU0MDM2MjMuNzc3MjU4LCJzdWIiOiI2NzQ3OTU4MiIsInNjb3BlcyI6WyJ1c2VyLnJlYWQiLCJ1c2VyLndyaXRlIiwidGFzay5yZWFkIiwidGFzay53cml0ZSIsIndlYmhvb2sucmVhZCIsIndlYmhvb2sud3JpdGUiLCJwcmVzZXQucmVhZCIsInByZXNldC53cml0ZSJdfQ.btVa6gFzOKaLJnYQf9-TKc55n1NqKrwFFAfDE7wNndxCc-Zhcj7vkGnVkO2SJmnxGqi9WJGofqxzEXur_iS-Nm2HMx3jqPTyldhV9DkMLy4eIDhoz5iILu242mkpu7BmZU8j7C2NfW-j8hmjeDObGjeIfxH0sYW5BMAMe-6xLIkmr8jEdWHu2G3OIn4fPtymxP4EfQx6RcjwTxhabj-wg7AamMNYJMBjNKmkqGTbrMiyp3Cuv-ME-vzCLU6q7YNAQGid3EUy0BpcNoe3sRVsQ0czicCWLCfF1IpeKf-raZWITPI_qdwUJ2f5iMQTxW8u2sZaGJbGF0vBCJmFBgzCtitYKaS41EEuxeZw1t2yW56-2D5Ejkx__03rZPGi-FBIgx2j-t0Y5Dza9xCzW0lrAvjmWq28TxeTxxQANwzkOQcVf5xvofFiTNXKhJidOAuAncEFnoUcgWzp-YwoybxofRqkXP08zkaDxQzdWMECOoErzXAvER_d2irC5_jfBgT1D_BRh5KzH2RRQZCBhvuz8mngctl6UC1bSffbf-PVOdujBtEVVe3B3l8PsOWqGLuY57d1QLTGbKnJ9mJ8VdOYrRm_L90WUWNbbwe4e65jHkv73gsJRHoVIbjU2vAznn22hl-GXROjXqeIZIpswasWMC2WE7SBEIf-LBhGy3PdYeU'
  #cloudconvert = CloudConvert::Client.new(api_key: key, sandbox: false)
  #ACCESS_KEY_ID = Rails.application.credentials.cloud_front[:access_key_id]
  #SECRET_ACCESS_KEY = Rails.application.credentials.cloud_front[:secret_access_key]
  #
  #response = cloudconvert.jobs.create({
  #  tasks: [
  #    {
  #        "name": "import-1",
  #        "operation": "import/s3",
  #        "bucket": "cloud-converter-test",
  #        "region": "eu-west-1",
  #        "access_key_id": ACCESS_KEY_ID,
  #        "secret_access_key": SECRET_ACCESS_KEY,
  #        "key": "index.html"
  #    },
  #    {
  #        "name": "task-1",
  #        "operation": "convert",
  #        "input_format": "html",
  #        "output_format": "png",
  #        "engine": "chrome",
  #        "input": [
  #            "import-1"
  #        ],
  #        "screen_width": 1440,
  #        "wait_until": "load",
  #        "wait_time": 0
  #    },
  #    {
  #        "name": "export-1",
  #        "operation": "export/s3",
  #        "input": [
  #            "task-1"
  #        ],
  #        "bucket": "cloud-converter-test",
  #        "region": "eu-west-1",
  #        "access_key_id": ACCESS_KEY_ID,
  #        "secret_access_key": SECRET_ACCESS_KEY,
  #        "key": "uploads/request_item/file/25/image.png"
  #        #"key": "test/new_image_#{DateTime.now.strftime("%Y年%-m月%-d日 %-H時%-M分%-S秒")}.png"
  #    }
  #  ]
  #})
  #puts(response)
  #puts(response.id)
  #puts(response.tasks.last.status)
end