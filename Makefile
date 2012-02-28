all: do_notation_tran

do_natation_tran: %: %.c
	gcc -o $@ $< -lfl

%.c: %.l
	flex -o $@ $<

clean:
	rm -f do_notation_tran do_notation_tran.c
