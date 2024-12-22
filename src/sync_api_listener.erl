-module(sync_api_listener).

-behaviour(gen_server).

-include("sync_api.hrl").

-define(SERVER, ?MODULE).

-record(state, {conf}).

-export([
  start_link/0,
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).

-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, SrvConf} = application:get_env(?APP, srv),
  erlang:send(self(), start_listener),
  {ok, #state{conf = SrvConf}}.

-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(start_listener, State) ->
  ok = start_listener(State#state.conf),
  {noreply, State};
handle_info(_Info, State) ->
  {noreply, State}.

-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

start_listener([
  {port,             Port},
  {request_timeout,  ReqTimeout},
  {max_connections,  MaxConn},
  {num_acceptors,    Acceptors},
  {max_keepalive,    MaxKeepAlive},
  {base_location,    BaseLocation}
]) ->

  {ok, AppKey}      = application:get_env(?APP, app_secret),
  {ok, Callback}    = application:get_env(?APP, app_callback),
  {ok, AppVersion}  = application:get_env(?APP, app_version)
  
  Routers = lists:reverse([
    {'_', z404_handler, []},
    {BaseLocation ++ "/[...]",  main_handler, []},
    ]),

  Dispatch = cowboy_router:compile([{'_', Routers}]),

  ProtoOptions = #{
    max_keepalive     => MaxKeepAlive,
    request_timeout   => ReqTimeout,
    env => #{dispatch => Dispatch}
  },

  TransportOptions = [
    {port, Port},
    {max_connections, MaxConn},
    {num_acceptors, Acceptors}
  ],

  Host  = lists:droplast(os:cmd("hostname")),
  cowboy:start_clear(http, TransportOptions, ProtoOptions),
  ?INFO("Locations : ~p", [Routers]),
  ?INFO("Application '~p' (version: ~s) started. BaseUrl http://~ts:~p~ts~n~n~n~n", [?APP, AppVersion, Host, Port, BaseLocation]).