/* $OpenBSD: brk.S,v 1.1 2020/06/25 02:38:28 drahn Exp $ */

/*
 * Copyright (c) 1996 Dale Rahn
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "SYS.h"

	.extern __curbrk
	.extern _C_LABEL(_end)

	.weak	brk

PSEUDO_PREFIX(,brk,break)
	/* check >= _end, if not make the call for _end */
	addis 5,2,.LC0@toc@ha
	ld  5,.LC0@toc@l(5)		/* # 5 = &_end */

	cmplw	%r3,%r5
	bge+	.L_brk_call
	mr	%r3, %r5

.L_brk_call:
	mr	%r7, %r3
	/* call break(size) */
	addis	%r6, %r2, __curbrk@toc@ha
	addi	%r6, %r6, __curbrk@toc@l	/* # 6 = &__curbrk */

	sc

	/* check for error */
	cmpwi	%r0, 0
	beq+	.L_brk_ok	/* OK so this is stupid but I haven't read b */
	stw	%r0, R13_OFFSET_ERRNO(13)
	li	%r3, -1
	blr
	nop

	/* update, __curbrk and return */
.L_brk_ok:
	stw	%r7, 0(%r6)	/* # remember, 6=&__curbrk, 3= new value */
	mr	%r3, 0		/* # return 0 */
	blr
END(brk)

        .section        .toc,"aw",@progbits
.LC0:
        .tc _end[TC],_end

