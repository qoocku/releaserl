-ifdef(RELEASERL_UPGRADABLE_SUPERVISOR_HRL).
-define(RELEASERL_UPGRADABLE_SUPERVISOR_HRL, true

-include ("emixins/include/emixins.hrl").
-behavior (upgradable_supervisor).
-mixins ([upgradable_supervisor]).

-endif.
