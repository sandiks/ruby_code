require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
queue = channel.queue('hello')

begin
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [receive] Received #{body}"
    # imitate some work
    sleep body.count('.').to_i
    puts ' [x] Done'    
  end
rescue Interrupt => _
  connection.close

  exit(0)
end