-module(conn_sup_tests).

-include_lib("eunit/include/eunit.hrl").

create_test() ->
  recover:start(),
  crypto:start(),
  ssh:start(),
  ssh:daemon({127,0,0,1}, 2222, [{auth_methods, "password"}, {user_passwords, [{"lifu", "hello1234"}]}]),
  http_channel_sup:start_link(),
  conn_sup:start_link(responder_mock),
  ?assertMatch([], supervisor:which_children(conn_sup)),

  conn_sup:start_child_if_not_exist("localhost", 
    fun(_Host) ->
      [{user,"lifu"}, {password,"hello1234"}, {port,2222}]
    end),
  ?assertMatch([{undefined, _Pid, worker, [client]}], supervisor:which_children(conn_sup)),
  client:do_cmd("localhost"),
  timer:sleep(300),
  recover:stop(),
  ok.

