LINUX_BASHCD=$(DESTDIR)/etc/bash_completion.d
LINUX_BIN=$(DESTDIR)/usr/bin
XCODE_SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk
PLATFORM=$(shell uname)

OBJS=pinyinmatch.o pinyin.o utf8vector.o linereader.o

ifeq ($(PLATFORM),Darwin)
	CFLAGS+=-isysroot $(XCODE_SDK)
else
	CFLAGS+=
endif

all:pinyinmatch

build:pinyinmatch

pinyinmatch:${OBJS}
	gcc -Wall $(CFLAGS) -std=c99 $^ -o $@

%.o:%.c
	gcc -Wall $(CFLAGS) -std=c99 -c $^ -o $@

install:	
	@if [ "`uname`" = "Darwin" ];then \
		test ! -e "/opt/local/etc/bash_completion.d" && echo 需要安装bash-completion && exit 1; \
		cp pinyinmatch /usr/local/bin ;\
		cp pinyin_completion /opt/local/etc/bash_completion.d/ ;\
	elif [ "`uname`" = "Linux" ];then \
		install -d $(LINUX_BASHCD) ;\
		echo install -d $(LINUX_BASHCD) ;\
		install -d $(LINUX_BIN) ;\
		echo install -d $(LINUX_BIN) ;\
		install ./pinyin_completion $(LINUX_BASHCD) ;\
		echo install ./pinyin_completion $(LINUX_BASHCD) ;\
		install ./pinyinmatch $(LINUX_BIN) ;\
		echo install ./pinyinmatch $(LINUX_BIN) ;\
	fi

uninstall:	
	@if [ "`uname`" = "Darwin" ];then \
		rm -fr /usr/local/bin/pinyinmatch  ;\
		rm -fr /opt/local/etc/bash_completion.d/pinyin_completion ;\
	elif [ "`uname`" = "Linux" ];then \
		rm -fr $(LINUX_BASHCD)/pinyin_completion  ;\
		echo rm -fr  $(LINUX_BASHCD)/pinyin_completion  ;\
		rm -fr $(LINUX_BIN)/pinyinmatch  ;\
		echo rm -fr $(LINUX_BIN)/pinyinmatch  ;\
	fi

clean:
	-rm -fr *.o
	-rm -fr pinyinmatch
