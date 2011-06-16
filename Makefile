all: 
	(cd deps/redis_pool;$(MAKE) all)
	(cd deps/mochiweb;$(MAKE) all)
	(cd deps/pagerduty;$(MAKE) all)
	(cd deps/redgrid;$(MAKE) all)
	(cd deps/redo;$(MAKE) all)
	(cd deps/nsync;$(MAKE) all)
	(cd deps/gen_nb_server;$(MAKE) all)
	@erl -make
	@escript release/build_rel.escript boot logplex `pwd`/ebin

clean:
	rm -f ebin/*.beam erl_crash.dump release/*.boot

clean_all: clean
	(cd deps/redis_pool;$(MAKE) clean)
	(cd deps/mochiweb;$(MAKE) clean)
	(cd deps/pagerduty;$(MAKE) clean)
	(cd deps/redgrid;$(MAKE) clean)
	(cd deps/redo;$(MAKE) clean)
	(cd deps/nsync;$(MAKE) clean)
	(cd deps/gen_nb_server;$(MAKE) clean)
