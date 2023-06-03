OUTPUT_ARCH(i386:x86-64)
ENTRY(entry32)

SECTIONS {
	. = 1M;

	.text : {
		*(.text.head)
		*(.text)
	}
}
