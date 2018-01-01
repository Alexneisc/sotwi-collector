task :deploy do
  knock_file = File.expand_path('../config/deploy/knock.rb', __FILE__)

  if File.exists?(knock_file)
    require knock_file
    sh "knock -d 300 #{KNOCK_IP} #{KNOCK_PORTS}"
    bundle exec 'cap production deploy'
  end
end
