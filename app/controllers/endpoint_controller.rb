class EndpointController < ApplicationController

  def submitbug
    #puts "#{params.delete("controller").delete("action").to_json}"
    application_token = params[:application_token]
    priority = params[:priority]
    comment = params[:comment]
    device = params[:state][:device]
    os = params[:state][:os]
    memory = params[:state][:memory]
    storage = params[:state][:storage]
    gen_state = State.new(:device => device, :os => os, :memory => memory, :storage => storage)
    #gen_state.save!
    bug_number = -1
    AppMaxBug.transaction do
      max_bug_for_app = AppMaxBug.where("app_number = ?", application_token).lock(true).first
      if max_bug_for_app.nil?
        max_bug_for_app = AppMaxBug.new(:app_number => application_token, :bug_number => 0)
      end
      max_bug_for_app.bug_number += 1
      bug_number = max_bug_for_app.bug_number
      max_bug_for_app.save!
    end
    if bug_number == -1
        render :json => '{"success" : false}'
        return
        #raise "error"
    end
    gen_bug = Bug.new(:application_token => application_token, :number => bug_number, :status => "new", :priority => priority, :comment => comment)
    gen_bug.state = gen_state
    queue_hash = gen_bug.attributes
    queue_hash.delete("state_id")
    queue_hash[:state] = gen_state.attributes

    #inside_hash = {:inner => 'hey'}
	  #hash = {:attr => 'welcome', :in => inside_hash}
    #puts hash.to_json
    connection = Bunny.new(:host => "rabbitmq")
    connection.start
    channel = connection.create_channel
    queue_name = "job_queue"
    queue = channel.queue(queue_name, durable: true)
    channel.default_exchange.publish(queue_hash.to_json, :routing_key => queue.name)
    puts "[x] Sent #{gen_bug}!"
    connection.close
    target_hash = Hash.new
    target_hash = {:success => true}
    target_hash = target_hash.merge(queue_hash)
    target_hash.delete("id")
    target_hash.delete("created_at")
    target_hash.delete("updated_at")
    state_inner_hash = gen_state.attributes
    state_inner_hash.delete("id")
    state_inner_hash.delete("created_at")
    state_inner_hash.delete("updated_at")
    target_hash[:state] = state_inner_hash
    render :json => target_hash.to_json
    #render :json => hash.to_json
  end

  def getbug
    bug_number = params[:bugnumber]
    application_token = params[:apptoken]
    requested_bug = Bug.where('application_token = ? AND number = ?', application_token, bug_number).first
    if requested_bug.nil?
        render :json => '{"success" : false}'
        return
    end
    bug_has = Hash.new
    bug_hash = {:success => true}
    bug_hash = bug_hash.merge(requested_bug.attributes)
    bug_hash.delete("state_id")
    requested_state = requested_bug.state
    bug_hash[:state] = requested_state.attributes
    bug_hash.delete("id")
    bug_hash.delete("created_at")
    bug_hash.delete("updated_at")
    state_inner_hash = requested_state.attributes
    state_inner_hash.delete("id")
    state_inner_hash.delete("created_at")
    state_inner_hash.delete("updated_at")
    bug_hash[:state] = state_inner_hash
    render :json => bug_hash.to_json
  end
end
