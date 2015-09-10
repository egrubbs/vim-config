
WD:=$(shell pwd)
RUNVIMTESTS=$(WD)/testing/runvimtests/bin/runVimTests.sh -v
SHARE_TEST_DIR=./share/tests/runvimtests
PERSONAL_TEST_DIR=./personal/tests

# Filter out first four lines with `tail`. Do not filter anything out
# with grep by matching the zero-length `^` beginning-of-line, but
# use it to highlight failed tests.
FILTER_RUNVIMTESTS_HEADER=\
	tail -n+4 | grep -E --color '[1-9][0-9]* (failure|error)s*|^FAIL.*|^'
CTAGS=ctags-exuberant 


default:
	@echo "The 'clean' targets just get rid of the test temp files."
	@echo "Targets:"
	@grep '^[a-z0-9_]*:' Makefile \
		| grep -v '^default:' \
		| sed -re 's/:.*//' \
		| sed -re 's/^/    /' \
		| sort

test: test_share test_personal

clean: clean_share clean_personal

test_share:
	@$(RUNVIMTESTS) -1 \
		--source $(WD)/share/python_import_macros.vim \
		$(SHARE_TEST_DIR) \
		| $(FILTER_RUNVIMTESTS_HEADER)

clean_share:
	$(RM) $(SHARE_TEST_DIR)/*.msgout
	$(RM) $(SHARE_TEST_DIR)/*.out

test_personal:
	@$(RUNVIMTESTS) -1 $(PERSONAL_TEST_DIR) \
		| $(FILTER_RUNVIMTESTS_HEADER)

clean_personal:
	$(RM) $(PERSONAL_TEST_DIR)/*.msgout
	$(RM) $(PERSONAL_TEST_DIR)/*.out

build_test_tags:
	$(CTAGS) -R -f $(WD)/share/tests/data/tags $(WD)/share/tests/data/


.PHONY: test test_share test_personal clean clean_share clean_personal build_test_tags
