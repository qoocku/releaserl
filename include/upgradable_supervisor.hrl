-ifdef(RELEASERL_UPGRADABLE_SUPERVISOR_HRL).
-define(RELEASERL_UPGRADABLE_SUPERVISOR_HRL, true

-compile ({parse_transform, mixins_pt}).
-behavior (upgradable_supervisor).
-mixins ([upgradable_supervisor]).

-endif.
