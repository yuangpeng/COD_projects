L1:lui		$0, 0x0000
ori		$0, 0x0000
lui		$1, 0x1234
ori		$1, 0x5678
L2:sll		$1, $1, 0
sll		$2, $1,	16
sll		$3, $1, 31
nor		$4, $1, $2
nor		$5, $1, $0
lui		$6, 0x8000
ori		$6, 0x0010
lui		$7, 0x0000
ori		$7, 0x0010
slti	$8, $6, -8
slti	$8, $6,  8
slti	$8, $7, -8
slti	$8, $7,  8
bne		$1, $2, L1
beq		$1, $3, L2