.PHONY: all tidy clean

ASM := motorz80
ASMFLAGS := -z00 -v

PYTHON := python3

LINK := xlink
LINKFLAGS :=

ASM_FILES := $(shell find -maxdepth 1 -name \*.asm | sort)
OBJ_FILES := $(patsubst %.asm, %.o, $(ASM_FILES))

PNG_FILES := $(shell find gfx -name \*.png | sort)
GFX_FILES := $(patsubst %.png, %.1bpp, $(PNG_FILES))

all: MBC3_Test.gbc

MBC3_Test.gbc: $(OBJ_FILES) include/*
	$(LINK) -fngb -cngb -mMBC3_Test.sym -o$@ $(OBJ_FILES)

%.o: %.asm $(GFX_FILES)
	$(ASM) $(ASMFLAGS) -mcg -o$@ $<

%.1bpp: %.png
	$(PYTHON) utils/gfx.py 1bpp $<

tidy:
	rm -fv $(OBJ_FILES) $(GFX_FILES) *.sym *.sav

clean: tidy
	rm -fv *.gb
