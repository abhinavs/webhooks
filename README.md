# webhooks
#### web service for enabling webhooks on your system

## What are WebHooks
WebHooks are HTTP POST callback requests sent to URL of a user’s choice in response to some event occurring. They offer simple and effective server to server communication without long running 
connections.

Webhooks can be used for

 * Notifications
 * Data Syncing
 * Chaining
 * Modifications
 * Plugins


### How to use webhooks.abhinav.co to enable webhooks?
webhooks.abhinav.co offers JSON APIs to help you create and manage channels and associated webhooks, and makes publishing events to these associated webhooks simple and easy.

A simple API workflow is as follows

* <code>POST /channels</code> - Create a new channel and get channel id and a publisher key.
* <code>POST /channels/:id/webhooks</code> - Use your publisher key to authenticate yourself and associate a webhook URL with this channel. You can call this API multiple times to associate as many 
  webhook URLs you want.
* <code>POST /channels/:id/events</code> - Post events to this channel, again authentication is done via publisher key.
* webhooks system notifies all associated webhook URLs and posts event data to them. In case any webhook URL does not receive data properly (ie, respond with any HTTP status code other than 200), our system continue trying to send event data to webhook URL once an hour for 24 hours.

## API Reference

### Create a new channel
<pre>DEFINITION
POST https://webhooks.abhinav.co/v1/channels

EXAMPLE REQUEST
$ curl -X POST https://webhooks.abhinav.co/v1/channels \
     -d "name=my first channel" \
     -d "description=my optional channel description" \
     -d "guid=optional-unique-uid" \
     -d "email=myemail@domain.com" \
     -d "public=false"

EXAMPLE RESPONSE
{
  "id" : 9999,
  "name" : "my first channel",
  "description" : "optional channel description",
  "guid" : "optional-unique-uid",
  "email" : "myemail@domain.com",
  "public" : false,
  "publisher_key": "pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29"
}
</pre>

### Retrieve an existing channel 
<pre>DEFINITION
GET https://webhooks.abhinav.co/v1/channels/{GUID_OR_ID}

AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 

EXAMPLE REQUEST
$ curl https://webhooks.abhinav.co/v1/channels/9999 \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29:
    
EXAMPLE RESPONSE
{ "id" : 9999,
   "name" : "my first channel",
   "description" : "optional channel description",
   "guid" : "optional-unique-uid",
   "email" : "myemail@domain.com",
   "public" : false,
   "publisher_key": "pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29"
}
</pre>

### Update an existing channel
<pre>DEFINITION
PUT https://webhooks.abhinav.co/v1/channels/{GUID_OR_ID}
 
AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 

EXAMPLE REQUEST
$ curl -X PUT https://webhooks.abhinav.co/v1/channels/9999 \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29: \
    -d "name=my new name"

EXAMPLE RESPONSE
{
   "id" : 9999,
   "name" : "my new name",
   "description" : "optional channel description",
   "guid" : "optional-unique-uid",
   "email" : "myemail@domain.com",
   "public" : false,
   "publisher_key": "pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29"
}
</pre>
  
### Delete an existing channel 
<pre>DEFINITION
DELETE https://webhooks.abhinav.co/v1/channels/{GUID_OR_ID}
 
AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 
 
EXAMPLE REQUEST
$ curl -X DELETE https://webhooks.abhinav.co/v1/channels/9999 \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29:

EXAMPLE RESPONSE
{
  "response" : "ok"
}
</pre>

### Associate a new webhook URL with an existing channel 
<pre>DEFINITION
POST https://webhooks.abhinav.co/v1/channels/{ID}/webhooksAUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 
 
EXAMPLE REQUEST
$ curl -X POST https://webhooks.abhinav.co/v1/channels/9999/webhooks \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29: \
    -d "name=subscriber name" \
    -d "webhook_url=http://subcriber.com/webhook_url"

EXAMPLE RESPONSE
{
   "id" : 123456,
   "name" : "subscriber name",
   "webhook_url" : "http://subscriber.com/webhook_url",
   "subscriber_key": "sk_ab043192b979363020879c5bb873616ec1ff2a12"
}
</pre>

### Retrieve all associated webhooks with an existing channel 
<pre>DEFINITION
GET https://webhooks.abhinav.co/v1/channels/{ID}/webhooks
 
AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 
 
EXAMPLE REQUEST
$ curl https://webhooks.abhinav.co/v1/channels/9999/webhooks \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29:

EXAMPLE RESPONSE
[
  {
    "id" : 123456,
    "name" : "subscriber name",
    "webhook_url" : "http://subscriber.com/webhook_url",
    "subscriber_key": "sk_ab043192b979363020879c5bb873616ec1ff2a12"
  }
]
</pre>

### Retrieve an existing associated webhook
<pre>DEFINITION
GET https://webhooks.abhinav.co/v1/channels/{ID}/webhooks/{WEBHOOK_ID}
 
AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key OR subscriber_key as basic auth username. 

EXAMPLE REQUEST
$ curl https://webhooks.abhinav.co/v1/channels/9999/webhooks/123456 \
    -u sk_ab043192b979363020879c5bb873616ec1ff2a12:

EXAMPLE RESPONSE
{
    "id" : 123456,
    "name" : "subscriber name",
    "webhook_url" : "http://subscriber.com/webhook_url",
    "subscriber_key": "sk_ab043192b979363020879c5bb873616ec1ff2a12"
}
</pre>

### Update an existing associated webhook
<pre>DEFINITION
PUT https://webhooks.abhinav.co/v1/channels/{ID}/webhooks/{WEBHOOK_ID}

AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key OR subscriber_key as basic auth username. 

EXAMPLE REQUEST
$ curl -X PUT https://webhooks.abhinav.co/v1/channels/9999/webhooks/123456 \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29: \
    -d "webhook_url=http://subcriber.com/new_webhook_url"

EXAMPLE RESPONSE
{
   "id" : 123456,
   "name" : "subscriber name",
   "webhook_url" : "http://subscriber.com/new_webhook_url",
   "subscriber_key": "sk_ab043192b979363020879c5bb873616ec1ff2a12"
}
</pre>

### Delete an existing associated webhook
<pre>DEFINITION
DELETE https://webhooks.abhinav.co/v1/channels/{ID}/webhooks/{WEBHOOK_ID}

AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key OR subscriber_key as basic auth username. 

EXAMPLE REQUEST
$ curl -X PUT https://webhooks.abhinav.co/v1/channels/9999/webhooks/123456 \
    -u sk_ab043192b979363020879c5bb873616ec1ff2a12:

EXAMPLE RESPONSE
{
   "response" : "ok"
}
</pre>

### Publish events on an existing channel
<pre>DEFINITION
POST https://webhooks.abhinav.co/v1/channels/{ID}/events

AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. EXAMPLE REQUEST

$ curl -X POST https://webhooks.abhinav.co/v1/channels/9999/events \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29: \
    -d "event_name=request.created" \
    -d "ext_ref_code=optional-reference-code-2396" \
    -d "event_url=http://publisher.com/optional_event_url_for_event_2396" \
    -d "data[any_data]=you-want-to-publish" \
    -d "data[example_request_id]=123" \
    -d "data[created_at]=1354649392"

EXAMPLE RESPONSE
{
   "id" : 567890,
   "event_name" : "request.created",
   "ext_ref_code" : "optional-reference-code-2396",
   "event_url" : "http://publisher.com/optional_event_url_for_event_2396",
   "data" : {
      "any_data" : "you-want-to-publish",
      "example_request_id" : "123",
      "created_at" : 1354649392"
    }
}
</pre>
  
### Retrieve notification log of an event
<pre>DEFINITION
GET https://webhooks.abhinav.co/v1/channels/{ID}/events/{EVENT_ID}/notification_log

AUTHENTICATION
via HTTP_BASIC_AUTH - publisher_key as basic auth username. 

EXAMPLE REQUEST
$ curl https://webhooks.abhinav.co/v1/channels/9999/events/567890/notification_log \
    -u pk_db0eaf8e5d11e6878f96cdcbe2a9de3228622f29: 

EXAMPLE RESPONSE
     - PENDING
</pre>

### Copyright

Copyright (c) 2013 Abhinav Saxena. See LICENSE for details.
