require 'active_record'

namespace :db do
  desc "Dumps the database"
  task backup: [:environment, :load_config] do

    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    db_server = "localhost"
    db_esc_path = ENV['backup_path'] # ファイルのバックアップ先のパス
    timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    backup_file = "#{db_esc_path}/#{timestamp}.dump"

    cmd = nil
    cmd = "MYSQL_PWD=#{configuration['password']} mysqldump -h #{db_server} -u #{configuration['username']} #{configuration['database']} > #{backup_file}"

    puts cmd
    exec cmd
  end
end
