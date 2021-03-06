%%%-------------------------------------------------------------------
%% @author Doug Tykocki <tykockda@gmail.com>
%% @doc virustotal public API and gen_server
%% @end
%%%-------------------------------------------------------------------

-module(virustotal).

-behaviour(gen_server).

%% API
-export([start/2, start_link/2, stop/1]).
-export([file_scan/2, file_report/2,
         url_scan/2, sync_url_scan/2, url_report/2,
         ip_address_report/2, domain_report/2]).

%% GenServer callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {key}).

%%%===================================================================
%%% API
%%%===================================================================

start(Name, Key) ->
  virustotal_sup:start_child(Name, Key).

start_link(Name, Key) ->
  gen_server:start_link({local, Name}, ?MODULE, [Key], []).

stop(Name) ->
  gen_server:call(Name, stop).

file_scan(Name, Resource) ->
  gen_server:call(Name, {file_scan, Resource}).

file_report(Name, Resource) ->
  gen_server:call(Name, {file_report, Resource}).

url_scan(Name, Resource) ->
  gen_server:cast(Name, {url_scan, Resource}).

sync_url_scan(Name, Resource) ->
  gen_server:call(Name, {url_scan, Resource}).

url_report(Name, Resource) ->
  gen_server:call(Name, {url_report, Resource}).

ip_address_report(Name, Resource) ->
  gen_server:call(Name, {ip_address_report, Resource}).

domain_report(Name, Resource) ->
  gen_server:call(Name, {domain_report, Resource}).

%%%===================================================================
%%% GenServer callbacks
%%%===================================================================

init([Key]) ->
  {ok, #state{key = Key}}.

handle_call(stop, _From, State) ->
  {stop, normal, stopped, State};

handle_call({file_scan, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:file_scan(Key, Resource),
  {reply, Reply, State};
handle_call({file_report, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:file_report(Key, Resource),
  {reply, Reply, State};
handle_call({url_scan, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:url_scan(Key, Resource),
  {reply, Reply, State};
handle_call({url_report, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:url_report(Key, Resource),
  {reply, Reply, State};
handle_call({ip_address_report, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:ip_address_report(Key, Resource),
  {reply, Reply, State};
handle_call({domain_report, Resource}, _From, #state{key=Key} = State) ->
  Reply = virustotal_client:domain_report(Key, Resource),
  {reply, Reply, State}.

handle_cast({url_scan, Resource}, #state{key=Key} = State) ->
  virustotal_client:url_scan(Key, Resource),
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.
