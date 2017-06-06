sleep 30 && { rake db:create; rake db:migrate; rake sneakers:run WORKERS=Messaging::EventsQueueReceiver &disown; chmod +x ./elasticinit.sh; ./elasticinit.sh; rails server -p 3000 -b '0.0.0.0'; }
