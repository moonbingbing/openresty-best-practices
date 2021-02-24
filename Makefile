BOOK_NAME := openresty-best-practices
BOOK_OUTPUT := _book

.PHONY: install build all
install:
	npm install -g n
	n v6.14.4
	npm install gitbook-cli -g
	gitbook install

build:
	gitbook build . $(BOOK_OUTPUT)

all: install build

.PHONY: serve
serve:
	gitbook serve . $(BOOK_OUTPUT)

.PHONY: epub
epub:
	gitbook epub . $(BOOK_NAME).epub

.PHONY: pdf
pdf:
	gitbook pdf . $(BOOK_NAME).pdf

.PHONY: mobi
mobi:
	gitbook mobi . $(BOOK_NAME).mobi

.PHONY: clean
clean:
	rm -rf $(BOOK_OUTPUT)

.PHONY: help
help:
	@echo "Help for make"
	@echo "make          - Build the book"
	@echo "make build    - Build the book"
	@echo "make serve    - Serving the book on localhost:4000"
	@echo "make install  - Install gitbook and plugins"
	@echo "make epub     - Build epub book"
	@echo "make pdf      - Build pdf book"
	@echo "make clean    - Remove generated files"