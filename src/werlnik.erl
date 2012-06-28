%% -------------------------------------------------------------------

%% %doc Wordnik Erlang Client.
-module(werlnik).

-author("Josh Rotenberg <joshrotenberg@gmail.com>").
-version("0.1").

-export([create/1, create/3,
	 authenticate/2,
	 word_lists/2,
	 user/2,
	 api_token_status/1,
	 examples/3,
	 word/3, 
	 definitions/3,
	 top_example/3,
	 pronunciations/3,
	 hyphenation/3,
	 frequency/3,
	 phrases/3,
	 related/3,
	 audio/3,
	 request_url/4,
	 search/3,
	 word_of_the_day/2,
	 random_word/2,
	 random_words/2]).

-include("werlnik.hrl").

%% 3348c2e6bd192e189d004095a5500d2fb705419146533e2dc

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-define(BASE_URL, "http://api.wordnik.com/v4/").

create(Key) ->
    #wc{key=Key}.
create(Key, User, Password) ->
    #wc{key=Key, user=User, password=Password}.

%% account

%% @doc Authenticate a Wordnik account
%% @spec authenticate({user(), password()}) -> token() 
authenticate(Key, {User, Password}) ->
    request_url(post, "account.json/authenticate/" ++ User, Key, Password).

word_lists(Key, Token) ->
    request_url(get, "account.json/wordLists/", Key, [{"auth_token", Token}]).

api_token_status(Key) ->
    request_url(get, "account.json/apiTokenStatus", Key, []).

user(Key, Token) ->
    request_url(get, "account.json/user", Key, [{"auth_token", Token}]).

%% word

examples(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/examples", Key, Args).
    
word(Key, W, Args) ->
    request_url(get, "word.json/" ++ W, Key, Args).

definitions(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/definitions", Key, Args).

top_example(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/topExample", Key, Args).

pronunciations(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/pronunciations", Key, Args).

hyphenation(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/hyphenation", Key, Args).

frequency(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/frequency", Key, Args).

phrases(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/phrases", Key, Args).

related(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/related", Key, Args).

audio(Key, W, Args) ->
    request_url(get, "word.json/" ++ W ++ "/audio", Key, Args).

%% wordList

%% words

search(Key, W, Args) ->
    request_url(get, "words.json/search/" ++ W, Key, Args).

word_of_the_day(Key, Args) ->
    request_url(get, "words.json/wordOfTheDay/", Key, Args).

random_word(Key, Args) ->
    request_url(get, "words.json/randomWord", Key, Args).

random_words(Key, Args) ->
    request_url(get, "words.json/randomWords", Key, Args).

build_url(Path, []) -> ?BASE_URL ++ Path;
build_url(Path, Args) -> 
    io:format("args: ~p ~n", [Args]),
    ?BASE_URL ++ Path ++ "?" ++ lists:concat(
        lists:foldl(
            fun (Rec, []) -> [Rec]; (Rec, Ac) -> [Rec, "&" | Ac] end, [],
            [K ++ "=" ++ V || {K, V} <- Args]
        )
    ).		

request_url(get, Path, Key, Args) ->
    Url = build_url(Path, [{"api_key", Key}|Args]),
    case ibrowse:send_req(Url, [{"Content-Type", "application/json"}], get) of
	Resp = {ok, _Status, _Headers, _Body} ->
	    mochijson2:decode(_Body);
	Other -> {error, Other}
    end;
request_url(post, Path, Key, Args) ->
    Url = build_url(Path, [{"api_key", Key}|Args]),
    io:format("~s~n", [Url]),
    case ibrowse:send_req(Url, [{"Content-Type", "application/json"}], post, Args) of
	Resp = {ok, _Status, _Headers, _Body} ->
	    mochijson2:decode(_Body);
	Other -> {error, Other}
    end.

right_age(X) when X >= 16, X =< 104 ->
    true;
right_age(_) ->
    false.

%% - tests

-ifdef(TEST).

simple_test() ->
    ?assert(true == true).

another_test() ->
    ?assert(true == true).

-endif.
