-module(main_handler).
-include("sync_api.hrl").
-export([init/2]).

init(#{path := Path, path_info := PathInfo} = Req, Env) ->
    ?INFO("Path = ~p, PathInfo = ~p", [Path, PathInfo]),
    {ok, cowboy_req:reply(200, ?H, <<"{\"result\":\"success\"}">>, Req), Env}.

terminate(_Reason, _Req, _St) ->
  ok.
