
  inherit Protocols.HTTP.Query:q;

  protected function(object:void) close_cb;
  protected function(object:void) fail_cb;
  protected function(mapping:void) event_cb;

  protected string _data = "";
  protected string event_source;
  protected int retry_delay;
  protected int(0..1) auto_reconnect;

  protected void create(string _event_source) {
    event_source = _event_source;
    set_callbacks(success, failure);
  }
  
  void set_auto_reconnect(int(0..1) enabled) {
    auto_reconnect = enabled;
  }

  void set_event_callback(function(mapping:void) cb) {
     event_cb = cb;
  }

  void set_failure_callback(function(object:void) cb) {
     fail_cb = cb;
  }

  void set_close_callback(function(object:void) cb) {
     close_cb = cb;
  }

  void success() { 
//werror("headers: %O\n", headers);
    if(headers["content-type"] != "text/event-stream") {
      failure();
    }
    con->set_nonblocking(got_data, can_write, did_close);
  }

  void failure() {
//werror("failure!\n");
    if(fail_cb) fail_cb(this);
    close();
  }

  void can_write() {
  }

  void did_close() {
//    werror("connection_closed\n");
    scan_for_events(_data + "\r\n");
    if(close_cb) close_cb(this);
    if(auto_reconnect)
      call_out(connect, retry_delay||2);
  };
  
  void got_data(int id, string received_data) {
//    werror("received event: %O\n", received_data);
    _data += received_data;

    _data = scan_for_events(_data);
  }  

  string scan_for_events(string data) {
   Spliterator s = Spliterator(data);
   array events = s->parse_events();
   foreach(events;; mapping event)
   {
      if(event_cb) event_cb(event);
   //  werror("event: %O\n", event);
   }
   return s->data();
  }

  class Spliterator(string _data) {

    string data() { return _data; }

    array parse_events() {
       array x = ({});

       mapping event;

       while(event = parse_event())
         x += ({event});

       return x;
    }

    array valid_endings = ({"\r\n", "\n", "\r"});
    string read_line() {
     if(sizeof(_data))
      foreach(valid_endings;; string ending) {
        int point;
        if((point = search(_data, ending)) != -1)
        {
           string line;

           if(point == 0) line = "";
           else line = _data[0..point-1];
           if(sizeof(_data) >= ( point + sizeof(ending)))
             _data = _data[point + sizeof(ending)..];
           return line;
        }

      }
      return 0;
   }
   string lastId="";
   mapping current_event;

   mapping parse_event() {      
      if(!current_event) current_event = (["data": ({}), "lastId": lastId]);
      string line;
      while(line=read_line()) {
        string key, value;
        int pos;
        if(!strlen(line)) return check_and_post_event();
        else if(line[0] == ':') continue;
        else if((pos=search(line, ":")) == -1) key = line, value = "";
        else { key = line[0..pos-1]; value=line[pos+1..]; }

        if(sizeof(value) == 0 && value[0] == ' ') value = "";
        else if(sizeof(value) > 1 && value[0] == ' ' && value[1] != ' ') value = value[1..];

        switch(key) {
         case "id":
           current_event->lastId = value;
           break;
         case "data":
           current_event->data += ({value});
           break;
         case "event":
           current_event->event_name = value;
         case "retry":
           int retry;
           if(sscanf(value, "%d", retry)) current_event->retry = retry;
           break;
         default:
           break;
        }
      } 
      return 0;
   }

   mapping check_and_post_event() {
      int failed = 0;
      mapping ce = current_event;
      if(!sizeof(ce->data)) { failed = 1; }
      if(failed) {
        ce = 0;
      } else {
        if(ce->lastId)
         lastId = ce->lastId;
        else
         ce->lastId = lastId;
        ce->data = ce->data *"\n";
        ce->event_source = event_source;
        if(has_index(ce, "retry")) retry_delay = ce->retry;
      }
      current_event = 0;
      return ce;
    }
  }
