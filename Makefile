LINUX_BASHCD=$(DESTDIR)/etc/bash_completion.d
LINUX_BIN=$(DESTDIR)/usr/bin
PLATFORM=$(shell uname)
OBJS=pinyinmatch.o pinyin.o utf8vector.o linereader.o
MAC_PREFIX ?= $(shell brew --prefix 2>/dev/null || printf /usr/local)
MAC_BASH_COMPLETION_D=$(MAC_PREFIX)/etc/bash_completion.d
MAC_ZSH_COMPLETION=$(MAC_PREFIX)/share/bash-pinyin-completion/pinyin_completion.zsh

all:pinyinmatch

build:pinyinmatch

pinyinmatch:$(OBJS)
	$(CC) -Wall $(CFLAGS) -std=c99 $^ -o $@

%.o:%.c
	$(CC) -Wall $(CFLAGS) -O2 -std=c99 -c $< -o $@

ifeq ($(PLATFORM),Darwin)
install: pinyinmatch
	@test -f "$(MAC_PREFIX)/etc/profile.d/bash_completion.sh" -o -f "$(MAC_PREFIX)/etc/bash_completion" || { echo 'Install and enable bash-completion first.' >&2; exit 1; }
	install -d "$(MAC_PREFIX)/bin" "$(MAC_BASH_COMPLETION_D)"
	install -m 755 pinyinmatch "$(MAC_PREFIX)/bin/pinyinmatch"
	install -m 644 pinyin_completion "$(MAC_BASH_COMPLETION_D)/pinyin_completion"

uninstall:
	rm -f "$(MAC_PREFIX)/bin/pinyinmatch" "$(MAC_BASH_COMPLETION_D)/pinyin_completion"

install-zsh: pinyinmatch
	install -d "$(MAC_PREFIX)/bin" "$(dir $(MAC_ZSH_COMPLETION))"
	install -m 755 pinyinmatch "$(MAC_PREFIX)/bin/pinyinmatch"
	install -m 644 pinyin_completion.zsh "$(MAC_ZSH_COMPLETION)"

uninstall-zsh:
	rm -f "$(MAC_PREFIX)/bin/pinyinmatch" "$(MAC_ZSH_COMPLETION)"
else
install: pinyinmatch
	install -d $(LINUX_BASHCD) $(LINUX_BIN)
	install -m 644 pinyin_completion $(LINUX_BASHCD)/pinyin_completion
	install -m 755 pinyinmatch $(LINUX_BIN)/pinyinmatch

uninstall:	
	rm -f $(LINUX_BASHCD)/pinyin_completion $(LINUX_BIN)/pinyinmatch
endif

clean:
	rm -f $(OBJS) pinyinmatch
