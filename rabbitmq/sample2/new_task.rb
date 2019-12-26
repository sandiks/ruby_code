require 'bunny'


connection = Bunny.new
connection.start

channel = connection.create_channel
queue = channel.queue('hello')

message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

queue.publish(message, persistent: true)
puts " [new_task] Sent #{message}"