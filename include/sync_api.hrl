-define(APP, sync_api).

-define(INFO (Format, Data), lager:info  ([{request, info}], "~p.erl:~p: " ++  Format, [ ?MODULE, ?LINE ] ++ Data )).


-define(JSON_DECODE(Json), 	jsx:decode(Json)).
-define(JSON_ENCODE(Term), 	jsx:encode(Term)).

-define(H, #{
  <<"Accept">> => <<"application/json">>,
  <<"Content-Type">> => <<"application/json; charset=utf-8">>
}).

-define(COOKIE_OPT, #{
  path => "/",
  http_only => true,
  secure => true
}).

-define(BASE_HTTPC_OPTS, [
  {sync, true},
  {body_format, binary}
]).

