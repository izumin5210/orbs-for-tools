GO_CROSSBUILD_TAG := 0.1.1
GITHUB_RELEASE_TAG := 0.1.1
HOMEBREW_TAG := 0.1.1
PROTOBUF_TAG := 0.1.0
INLINE_TAG := 0.1.0

dist:
	@mkdir dist

dist/%.yml: src/% dist
	circleci config pack $< > $@

VALIDATES :=

define cmd-tmpl
$(eval NAME := $(notdir $(1)))
$(eval VALIDATES += validate-$(NAME))

.PHONY: publish-$(NAME)
publish-$(NAME): dist/$(NAME).yml
	circleci orb publish $$< izumin5210/$(NAME)@$(2)

.PHONY: validate-$(NAME)
validate-$(NAME): dist/$(NAME).yml
	circleci orb validate $$<
endef

$(eval $(call cmd-tmpl,./src/go-crossbuild,$(GO_CROSSBUILD_TAG)))
$(eval $(call cmd-tmpl,./src/github-release,$(GITHUB_RELEASE_TAG)))
$(eval $(call cmd-tmpl,./src/homebrew,$(HOMEBREW_TAG)))
$(eval $(call cmd-tmpl,./src/protobuf,$(PROTOBUF_TAG)))
$(eval $(call cmd-tmpl,./src/inline,$(INLINE_TAG)))

.PHONY: validate
validate: $(VALIDATES)
