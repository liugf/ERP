# -*- encoding : utf-8 -*-
require "net/ftp"
require 'fileutils'
require 'yaml'

rails_root = File.expand_path('../../../', __FILE__)
Settings = YAML.load_file(rails_root + '/config/settings.yml')

#发送报文
puts 'start send' + Time.new.strftime(" %Y-%m-%d, %H:%M:%S")
begin
  ftp = Net::FTP.new()  
  ftp.connect(Settings['ftp_info']['host'])
  ftp.login(Settings['ftp_info']['username'], Settings['ftp_info']['password'].to_s) 
  ftp.chdir('/TCS/UploadTemp')
rescue    SystemCallError => e
  puts "vpn not connected"
  File.open(rails_root + '/log/ftp.log', 'a') do |file|
    file.puts "time: #{Time.now} error:#{$!} at:#{$@}"
    file.puts "vpn not connected"
  end
  reconnect_vpn_result = system('C:\Program Files\Sangfor\SSL\SangforCSClient\SangforCSClient.exe',' /ShortCutAutoLogin')
  puts "reconnecting vpn : #{reconnect_vpn_result}"
end

Dir.new(Settings['dispatch_paths']['upload_temp']).each do |file_name|
  if file_name != '.' and file_name != '..'
    message_file = File.new(Settings['dispatch_paths']['upload_temp'] + '/' + file_name)
    begin
      puts 'uploading:' + file_name  
      ftp.puttextfile(message_file.path) 
      ftp.rename(file_name, '/TCS/Upload/' + file_name) 
      message_file.close
      FileUtils.mv message_file, Settings["dispatch_paths"]["upload"] + "/" + File.basename(message_file)
    rescue
     message_file.close
     File.open(rails_root + '/log/ftp.log', 'a') do |file|
       file.puts "time: #{Time.now} error:#{$!} at:#{$@}"
     end
   end        
 end
end

ftp.close
puts 'end send'



#接收报文
puts 'start receive'  + Time.new.strftime(" %Y-%m-%d, %H:%M:%S")
begin
  ftp = Net::FTP.new()  
  ftp.connect(Settings['ftp_info']['host'])
  ftp.login(Settings['ftp_info']['username'], Settings['ftp_info']['password'].to_s) 
rescue  SystemCallError => e
  puts "vpn not connected"
  File.open(rails_root + '/log/ftp.log', 'a') do |file|
    file.puts "time: #{Time.now} error:#{$!} at:#{$@}"
    file.puts "vpn not connected"
  end
  reconnect_vpn_result = system('C:\Program Files\Sangfor\SSL\SangforCSClient\SangforCSClient.exe',' /ShortCutAutoLogin')
  puts "reconnecting vpn : #{reconnect_vpn_result}"
end 

ftp.nlst('/TCS/Download').each do |file|
  puts 'downloading:' + file
  temp_file = Settings['dispatch_paths']['temp'] + '/' + file
  ftp.get('/TCS/Download/' + file, temp_file)
  FileUtils.mv temp_file, Settings["dispatch_paths"]["download_temp"] + "/" + File.basename(file)
  ftp.delete('/TCS/Download/' + file)
end
ftp.close

puts 'end receive'