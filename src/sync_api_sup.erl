-module(sync_api_sup).

-behaviour(supervisor).

-include("sync_api.hrl").

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Args), {I, {I, start_link, [Args]}, permanent, 5000, Type, [I]}).
-define(WORKER(Name), {Name, {Name, start_link, []}, permanent, 5000, worker, [Name]}).
-define(WORKER(Name, Module, Args), {Name, {Module, start_link, Args}, permanent, 5000, worker, []}).

-export([
  start_link/0,
  init/1
]).


start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->

  {ok, {{one_for_one, 60, 30}, [
    ?CHILD(sync_api_listener, worker)
  ]}}.