NAME=fexpr
VERSION=0.1
DATE=$(shell date +"%Y-%m-%d")

.PHONY: test

%.gemspec:%.gemspec.in
	cat $< | sed \
		-e 's/%NAME%/$(NAME)/g' \
		-e 's/%DATE%/$(DATE)/g' \
		-e 's/%VERSION%/$(VERSION)/g' \
		> $@

$(NAME)-$(VERSION).gem: $(NAME).gemspec rdoc
	gem build $<

all: gem

gem: $(NAME)-$(VERSION).gem

push: $(NAME)-$(VERSION).gem
	gem push $<

install: $(NAME)-$(VERSION).gem
	sudo gem install $<

rdoc:
	rdoc --title "Fexpr" `find lib -name "*.rb"`

test:
	ruby test/suite.rb

runtest: test/test_*.rb
	@for f in $^; do\
		echo --- $$f ---;\
		ruby $$f;\
	done

tests:
	chmod +x $(NAME)
	./$(NAME) test/logfile.txt

clean:
	rm -f `find . -name "*~"` $(NAME).gemspec $(NAME)-*.gem

docclean:
	rm -rf doc

allclean: docclean clean