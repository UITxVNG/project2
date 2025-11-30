class_name WallClingDecorator
extends PowerupDecorator

func modify_wall_cling(can_cling: bool) -> bool:
	return true  # khi có buff thì lúc nào cũng cho phép bám tường
