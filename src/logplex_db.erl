%% Copyright (c) 2010 Jacob Vorreuter <jacob.vorreuter@gmail.com>
%% 
%% Permission is hereby granted, free of charge, to any person
%% obtaining a copy of this software and associated documentation
%% files (the "Software"), to deal in the Software without
%% restriction, including without limitation the rights to use,
%% copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following
%% conditions:
%% 
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%% 
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%% HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%% WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%% OTHER DEALINGS IN THE SOFTWARE.
-module(logplex_db).
-export([start_link/0]).

-include_lib("logplex.hrl").

start_link() ->
    create_ets_tables(),
    {ok, Pid} = redo:start_link(config, redo_opts()),
    boot_nsync(),
    {ok, Pid}.

create_ets_tables() ->
    ets:new(channels, [named_table, public, set, {keypos, 2}]),
    ets:new(tokens,   [named_table, public, set, {keypos, 2}]),
    ets:new(drains,   [named_table, public, set, {keypos, 2}]),
    ets:new(sessions, [named_table, public, set, {keypos, 2}]),
    ok.

boot_nsync() ->
    ok = application:start(nsync, temporary),
    Opts = nsync_opts(),
    io:format("nsync:start_link(~p)~n", [Opts]),
    A = now(),
    {ok, _Pid} = nsync:start_link(Opts),
    B = now(),
    io:format("nsync load_time=~w~n", [timer:now_diff(B,A) div 1000000]).

nsync_opts() ->
    RedisOpts = logplex_utils:redis_opts("LOGPLEX_CONFIG_REDIS_URL"),
    Ip = case proplists:get_value(ip, RedisOpts) of
        {_,_,_,_}=L -> string:join([integer_to_list(I) || I <- tuple_to_list(L)], ".");
        Other -> Other
    end,
    RedisOpts1 = proplists:delete(ip, RedisOpts),
    RedisOpts2 = [{host, Ip} | RedisOpts1],
    [{callback, {nsync_callback, handle, []}}, {block, true}, {timeout, 20 * 60 * 1000} | RedisOpts2].

redo_opts() ->
    case os:getenv("LOGPLEX_CONFIG_REDIS_URL") of
        false -> [];
        Url -> redo_uri:parse(Url)
    end.
