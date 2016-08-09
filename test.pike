
import Protocols.HTTP;

Wink.HubUpdates upd;
string url = "192.168.1.113";
string auth_token = "dYPxEJVt2B-lDJ-UV1Ox2r6G75MJ-HDO";

int main() { 
  upd = Wink.HubUpdates(url, auth_token);
  upd->set_wink_callback(event);
  upd->connect();
  return -1;
}

void event(Wink.WinkEvent evt) {
  werror("event: %O=>%O\n", evt, evt->get_data());
}
