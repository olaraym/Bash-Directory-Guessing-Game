# Build README.md from README.template.md, filling in the date make was run
# and the number of lines in guessinggame.sh (the course requirement).

SCRIPT   := guessinggame.sh
TEMPLATE := README.template.md
TESTS    := tests/test_guessinggame.sh

.PHONY: all test lint clean

all: README.md

README.md: $(TEMPLATE) $(SCRIPT)
	sed -e "s|@DATE@|$$(date '+%a %d %b %Y, %H:%M %Z')|" \
	    -e "s|@LINES@|$$(wc -l < $(SCRIPT) | tr -d ' ')|" \
	    $(TEMPLATE) > $@

test:
	bash $(TESTS)

lint:
	shellcheck $(SCRIPT) $(TESTS)

clean:
	rm -f README.md
