EXEC_TEMPLATE = _sh_template
EXEC_MODULES = ring_constructor_list ring_constructor_dict ring_constructor_child
ALL_MODULES = lib_ring ring_server bench ${EXEC_MODULES}
EXECUTABLE  = ${EXEC_MODULES:%=%.sh}
ERLC_FLAGS ?= -W

.PHONY: all run compile executable clean %.run_sh

all: executable

run: all ${EXEC_MODULES:%=%.run_sh}

%.beam: %.erl
	erlc ${ERLC_FLAGS} $<

%.sh: %.beam ${EXEC_TEMPLATE} 
	sed -e 's/{module}/bench/g' -e 's/{main}/run_main/g' -e 's/{constructor}/$*/g' ${EXEC_TEMPLATE} > $*.sh
	chmod u+x $*.sh

%.run_sh: %.sh
	@echo
	@./$< 100 100
	@./$< 10000 10
	@./$< 10 10000

compile: ${ALL_MODULES:%=%.beam}

executable: compile ${EXECUTABLE}

clean: 
	rm -rf ${EXECUTABLE} *.beam erl_crash.dump
