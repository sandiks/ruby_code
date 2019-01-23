require 'geoip'
require 'parallel'
require 'time'


def filter
  db = GeoIP::City.new('/usr/share/GeoIP/GeoIPCity.dat')
  #p db.look_up('24.24.24.24')
  lines = File.foreach('wl.log').first(100000)
  res=[]
  lines.each do |addr|
    data = db.look_up(addr.strip)
    next if data.nil?
    res<< "#{addr.strip} city:#{data[:city]}" if data[:country_code] =='RU'

  end

  File.write("ru-1.txt",res.join("\n"))
end

require 'net/ftp'

def scan(file_name,start_indx=0)
 
  p "start"

  end_ind = start_indx+10

  puts lines = File.foreach(file_name).to_a[start_indx..end_ind-1]

  Parallel.each(lines,:in_threads=>5) do |addr|
  #lines.each do |addr|
    #puts "open #{addr}"

    ip = addr.split(' ').first
 
    Timeout::timeout(5) do
      Net::FTP.open(ip, 'anonymous', '') do |ftp|
        #ftp.chdir('pub/')
        ftp.passive = true
        files = ftp.nlst rescue "err"
        puts "------ #{addr}: #{files}" if files.size>0
      end rescue "problem with conn"
    end
 
  end
end

#filter
scan("ru-1.txt",140)
