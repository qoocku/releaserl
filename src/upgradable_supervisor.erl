%%% @doc This modules defines a behavior mostly needed for supervisors
%%%      after a release upgrade.
-module (upgradable_supervisor).
-author ("Damian T. Dobroczy\\'nski <qoocku@gmail.com>").
-include ("vsn").

-export ([init/3,
          behaviour_info/1,
          code_change/2]).

behaviour_info (callbacks) ->
  [{init, 1}, {children, 2}, {policy, 2}];
behaviour_info (_) ->
  undefined.

-define (DBID, 'upgradable_supervisors$db').

%% @doc Generic upgradable supervisor callback initialisation.
%%      It does have side effect - updates the process dictionary to
%%      be able to use supervisor callback module name and initial arguments.

-type supFlags() :: {supervisor:strategy(), pos_integer(), pos_integer()}.
-spec init (any(), module(), list()) -> {ok, supFlags(), supervisor:child_spec()}.

init (Vsn, Module, Args) when is_atom(Module) ->
  Policy = Module:policy(Vsn, Args),
  Kids   = Module:children(Vsn, Args),
  put({?DBID, Vsn}, {Module, Args}), %% slight side effect but probably not dangerous
  {ok, Policy, Kids}.

%% @doc Designed to be called after supervisor release upgrade.
%%      Kills unnecessary children (which are not included in the
%%      newest version) and starts additional which are specified
%%      by the module newest version.

-spec code_change (any(), any()) -> any().                       

code_change (OldVsn, _NewVsn) ->
  %% do not kill running children 'cause its code & state has been changed already
  %% just run kill unnecessary and run new one
  RunningChildren   = sets:from_list([Id || {Id, _, _, _} <- supervisor:which_children(self())]),
  {Module, Args}    = get({?DBID, OldVsn}),
  {ok, _, NewSpecs} = Module:init(Args),
  NewChildren       = sets:from_list([Id || {Id, _, _, _, _, _, _} <- NewSpecs]),
  ToKill            = sets:subtract(RunningChildren, NewChildren),
  ToRun             = sets:subtract(NewChildren, RunningChildren),
  sets:fold(fun (Id, ok) ->
                supervisor:terminate_child(self(), Id),
                supervisor:delete_child(self(), Id),
                ok
            end, ok, ToKill),
  sets:fold(fun (Spec, ok) ->
                {ok, _} = supervisor:start_child(Spec),
                ok
            end, lists:filter(fun ({Id, {Id, _, _, _, _, _, _}}) -> true;
                                  (_) -> false
                              end, lists:zip(sets:to_list(ToRun), NewSpecs))).
  
  
  
