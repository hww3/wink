protected string event_name;
protected string event_source;
protected mapping data;

protected void create(string event_name, string event_source, mapping data) {
  this_program::event_name = event_name;
  this_program::event_source = event_source;
  this_program::data = data;
}

string get_event_source() { return event_source; }
string get_event_name() { return event_name; }
mapping get_data() { return data; }

protected string _sprintf(mixed ident) {
  return "WinkEvent(" + event_source + "::" + event_name + "::" 
       + data->data->name + ":" + data->data->local_id + ")";
}
