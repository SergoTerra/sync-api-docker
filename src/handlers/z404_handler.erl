-module(z404_handler).
-export([init/2]).
-include("sync_api.hrl").

init(#{path := Path, path_info := PathInfo} = Req, Env) ->
    ?INFO("Path = ~p, PathInfo = ~p", [Path, PathInfo]),
    {ok, cowboy_req:reply(404, #{}, <<"404 Not Found">>, Req), Env}.
