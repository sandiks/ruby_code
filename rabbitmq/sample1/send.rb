require 'bunny'


connection = Bunny.new
connection.start

channel = connection.create_channel
queue = channel.queue('hello')

text = "adksjfksd df kolyan"

channel.default_exchange.publish(text, routing_key: queue.name)
puts " [sent] Sent #{text}"
connection.close