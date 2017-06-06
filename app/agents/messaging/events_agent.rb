 #require_dependency  #{Rails.root.join('app','agents','fsm','state_assignment_agent')}"

  module Messaging
    class EventsAgent
      EVENT_HANDLERS = {
        enroll_in_program: ["FSM::StateAssignmentAgent"]
      }
      class << self

        def publish(event)
          Messaging::Publisher.publish(event: event)
        end

        def distribute(event)
          puts "in #{self}.#{__method__}, message"
          if event[:handler]
            puts "in #{self}.#{__method__}, event[:handler: #{event[:handler]}"
            event[:handler].constantize.handle_event(event)
          else
            event_name = event[:event_name].to_sym
            EVENT_HANDLERS[event_name].each do |handler|
              event[:handler] = handler
              publish(event)
            end
          end
          return {success: true}
        end

      end
    end
  end