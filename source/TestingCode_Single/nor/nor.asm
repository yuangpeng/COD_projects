lui		$1, 0x1234
ori		$1, 0x5678
lui		$0, 0x0000
ori		$0, 0x0000
sll		$1, $1, 0
sll		$2, $1, 4
sll		$3, $1, 8
sll		$4, $1,	16
sll		$5, $1, 31
nor		$6, $1, $2
nor		$7, $1, $0