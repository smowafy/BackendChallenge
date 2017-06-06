curl -XPUT 'http://elasticsearch:9200/endpoint' -d '{
	"settings" : {
		"analysis" : {
			"analyzer" : {
				"myanalyzer" : {
					"tokenizer" : "mytokenizer"
				}
			},
			"tokenizer" : {
				"mytokenizer" : {
					"type" : "nGram",
					"min_gram" : 1,
					"max_gram" : 50
				}	
			}
		}
	}
}'; curl -XPUT 'http://elasticsearch:9200/endpoint/bug/_mapping' -d '{
	"bug" : {
		"properties" : {
			"application_token" : { "type" : "string", "index" : "not_analyzed"},
			"number" : { "type" : "integer"},
			"status" : { "type" : "string", "index" : "not_analyzed"},
			"priority" : { "type" : "string", "index" : "not_analyzed"},
			"comment" : { "type" : "string", "analyzer" : "myanalyzer"},
			"state" : {
				"type" : "object",
				"properties" : {
					"device" : { "type" : "string", "index" : "not_analyzed"},
					"os" : { "type" : "string", "index" : "not_analyzed"},
					"memory" : { "type" : "integer"},
					"storage" : { "type" : "integer"}
				}
			}
		}
	}
}'
