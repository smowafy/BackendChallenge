module Messaging
    class Publisher
      class << self

        def publish(args)
          connection = Bunny.new(:host => "amqp://tkkblsfz:4AgK4ahZeghkPriKyDtSL0fyQzkSUFTM@orangutan.rmq.cloudamqp.com/tkkblsfz", :vhost => "tkkblsfz", :user => "tkkblsfz", :password => "  4AgK4ahZeghkPriKyDtSL0fyQzkSUFTM")
          connection.start
          channel = connection.create_channel
          queue_name = "job_queue"
          queue = channel.queue(queue_name, durable: true)
          channel.default_exchange.publish(args[args.keys.first].to_json, :routing_key => queue.name)
          puts "in #{self}.#{__method__}, [x] Sent #{args}!"
          connection.close
        end

      end
    end
  end