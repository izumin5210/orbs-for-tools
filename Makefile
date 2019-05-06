GO_CROSSBUILD_TAG := 0.1.0
GITHUB_RELEASE_TAG := 0.1.1
HOMEBREW_TAG := 0.1.1

dist:
	@mkdir dist

dist/%.yml: src/% dist
	circleci config pack $< > $@

define cmd-tmpl

$(eval NAME := $(notdir $(1)))

.PHONY: publish-$(NAME)
publish-$(NAME): dist/$(NAME).yml
	circleci orb publish $$< izumin5210/$(NAME)@$(2)

endef

$(eval $(call cmd-tmpl,./src/go-crossbuild,$(GO_CROSSBUILD_TAG)))
$(eval $(call cmd-tmpl,./src/github-release,$(GITHUB_RELEASE_TAG)))
$(eval $(call cmd-tmpl,./src/homebrew,$(HOMEBREW_TAG)))
