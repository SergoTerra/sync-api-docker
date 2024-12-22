PROJECT=sync_api

ifeq ($(wildcard rebar3),rebar3)
REBAR3 = $(CURDIR)/rebar3
endif

REBAR3 ?= $(shell test -e `which rebar3` 2>/dev/null && which rebar3 || echo "./rebar3")

ifeq ($(REBAR3),)
REBAR3 = $(CURDIR)/rebar3
endif

.PHONY: all test clean

all: deps compile release

build: $(REBAR3)
	@$(REBAR3) compile

$(REBAR3):
	wget $(REBAR3_URL) || curl -Lo rebar3 $(REBAR3_URL)
	@chmod a+x rebar3

deps:
	@$(REBAR3) get-deps

compile:
	@$(REBAR3) compile

distclean: clean
	@$(REBAR3) delete-deps

recompile:
	@$(REBAR3) skip_deps=true compile

test:
	@$(REBAR3) skip_deps=true ct, cover

release:
	@$(REBAR3) release -n $(PROJECT)

production_release:
	@$(REBAR3) as production release -n $(PROJECT)

test_release:
	@$(REBAR3) as test release -n $(PROJECT)

console:
	./_build/default/rel/$(PROJECT)/bin/$(PROJECT) console

clean:
	@$(REBAR3) clean

cleanall:
	rm -rf ./_build

clean-release: clean
	rm -rf _build/default/rel/$(PROJECT)
