inherit .ServerEventQuery;

protected function(.WinkEvent:void) wink_event_cb;
protected string auth_token;

protected void create(string server, string token) {
  ::create("https://" + server + ":8888/updates");
  auth_token = token;
  set_event_callback(wink_event_callback);
}

void set_wink_callback(function(.WinkEvent:void) cb) {
  wink_event_cb = cb;
}

protected void wink_event_callback(mapping data) {
  if(data->event_name == "keep-alive") return;
// werror("eevent: %O\n", data);
  if(wink_event_cb) {
    mapping d = Standards.JSON.decode(data->data);
    .WinkEvent event = .WinkEvent(data->event_source, data->event_name, d);
    wink_event_cb(event);
  }
}

void connect() {
//werror("connecting to %O %O\n", event_source, auth_token);
  Protocols.HTTP.do_async_method("GET", event_source, ([]), 
      (["Authorization": "Bearer " + auth_token, 
        "Cache-control": "no-cache",
        "Accept": "text/event-stream"]), this);  
}
