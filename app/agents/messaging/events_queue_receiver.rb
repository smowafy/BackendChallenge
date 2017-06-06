  #require_dependency "#{Rails.root.join('app','agents','messaging','events_agent')}"
  require 'uri'
  require 'net/http'

  module Messaging
    class EventsQueueReceiver
      include Sneakers::Worker
      from_queue :job_queue, env: nil

      def work(msg)
        logger.info msg
        
        received_hash = JSON.parse(msg)
        state_hash = received_hash["state"]
        puts received_hash
        device = state_hash["device"]
        os = state_hash["os"]
        memory = state_hash["memory"]
        storage = state_hash["storage"]
        application_token = received_hash["application_token"]
        bug_number = received_hash["number"]
        priority = received_hash["priority"]
        comment = received_hash["comment"]
        state_tosave = State.new(:device => device, :os => os, :memory => memory, :storage => storage)
        bug_tosave = Bug.new(:application_token => application_token, :number => bug_number, :status => "new", :priority => priority, :comment => comment)
        bug_tosave.state = state_tosave
        state_tosave.save!
        bug_tosave.save!
        puts "Saved Bug and State"
        url = "http://elasticsearch:9200/endpoint/bug"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
        request.body = msg
        response = http.request(request)
        logger.info response.body
        puts response.body
        ack!
      end

    end
  end